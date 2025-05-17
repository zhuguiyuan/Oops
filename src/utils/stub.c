#include <moonbit.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define BUFFER_SIZE 4096

typedef struct {
  uint8_t *output;
  int exit_code;
  int stopped;
  int signaled;
} *sh_result_t;

uint8_t *sh_result_get_output(sh_result_t self) {
  if (self->output == NULL) {
    return moonbit_make_bytes(1, 0);
  }
  moonbit_bytes_t ret = moonbit_make_bytes(strlen(self->output) + 1, 0);
  strcpy(ret, self->output);
  return ret;
}

uint32_t sh_result_get_stopped(sh_result_t self) { return self->stopped; }

uint32_t sh_result_get_exit_code(sh_result_t self) { return self->exit_code; }

uint32_t sh_result_get_signaled(sh_result_t self) { return self->signaled; }

static inline void sh_result_clean(void *result) {
  sh_result_t casted_result = result;
  free(casted_result->output);
}

void *execute_command(const uint8_t *cmd) {
  int pipefd[2];
  pid_t pid;
  uint8_t buffer[BUFFER_SIZE];
  ssize_t bytes_read;
  sh_result_t result =
      moonbit_make_external_object(sh_result_clean, sizeof(*result));

  if (pipe(pipefd)) {
    perror("pipe creation failed");
    return result;
  }

  if ((pid = fork()) < 0) {
    perror("fork failed");
    close(pipefd[0]);
    close(pipefd[1]);
    return result;
  }

  if (pid == 0) {
    close(pipefd[0]);

    if (dup2(pipefd[1], STDOUT_FILENO) == -1) {
      perror("dup2 failed");
      exit(EXIT_FAILURE);
    }
    close(pipefd[1]);

    execlp("bash", "bash", "-c", cmd);
    perror("exec failed");
    exit(EXIT_FAILURE);
  } else {
    close(pipefd[1]);

    uint8_t *output = NULL;
    size_t total_size = 0;
    while ((bytes_read = read(pipefd[0], buffer, sizeof(buffer))) > 0) {
      uint8_t *new_ptr = realloc(output, total_size + bytes_read + 1);
      if (!new_ptr) {
        perror("memory allocation failed");
        free(output);
        close(pipefd[0]);
        return result;
      }
      output = new_ptr;
      memcpy(output + total_size, buffer, bytes_read);
      total_size += bytes_read;
      output[total_size] = '\0';
    }
    close(pipefd[0]);

    int status;
    waitpid(pid, &status, 0);
    result->stopped = WIFSTOPPED(status);
    result->signaled = WIFSIGNALED(status);
    result->exit_code = WEXITSTATUS(status);
    result->output = output;
    return result;
  }
}

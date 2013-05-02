Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fw1.franz.com ([67.207.112.66]:41278 "EHLO mas.franz.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753427Ab3EBPlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 11:41:11 -0400
From: Ahmon Dancy <dancy@franz.com>
To: linux-nfs@vger.kernel.org
Subject: Unexpected NFS client cache drops
Date: Thu, 02 May 2013 08:32:40 -0700
Message-ID: <16805.1367508760@mas.franz.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Linux NFS folks.  I need help figuring out why the kernel is
sometimes discarding large portions of the page cache for a file that
I'm manipulating via NFS.

Attached is the source for a test program which models the behavior of
a larger program.  The program works as follows:

* Truncate the file to 0 bytes.
* while (1)
  * Use posix_fallocate to grow the file by 1GB.
  * mmap the file and touch the next 1GB of pages. munmap

The program reports the size of the page cache (and the delta from the
last sample) after various operations.

Run it like so:

./test-nfs-growth /mnt/testfile


What you'll see is the cache growing by 128MB for the posix_fallocate
calls and then growing by another ~895MB while touching the pages.
For a while, this pattern continues.  However, at some point during
the mmap operation, a large (1-4 GB) portion of the cache is
discarded even though there's plenty of free RAM.  In the real
program, the file is read in addition to be being written/grown so
performance drops considerably when the cache is dropped.


Notes:

* Experienced w/ kernel 2.6.32-279.19.1.el6.x86_64  (CentOS 6.3)
  as well as 3.8.4-102.fc17.x86_64 (Fedora 17).

* NFS server is 2.6.34.9-69.fc13.x86_64 (Fedora 13).

* Exported filesystem is xfs.

* The client is mounting using NFSv3.  The client and server are
  connected via Infiniband.

* No other program is manipulating the test file.

* NFS client has 48GB ram across two NUMA nodes (24GB+24GB).  Nothing
  else interesting is running on the system during testing so there is
  plenty of free RAM.

* If you run the test program and specify a file on a local
  filesystem, the problem does not occur. 

* The problem is usually exhibited when the file has grown to around
  5GB.

--- SNIP ---
// test-nfs-growth.c

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <sys/time.h>
#include <stdarg.h>

#define GROWTH_SIZE (1024*1024*1024L)
#define CACHE_DROP_THRESHOLD (1024*1024) // KB

void print_current_time() {
  struct timeval tv;

  if (gettimeofday(&tv, NULL) != 0) {
    perror("gettimeofday");
    exit(1);
  }

  struct tm *tm=localtime(&tv.tv_sec);

  printf("%4d-%02d-%02d %02d:%02d:%02d.%06ld",
	 tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
	 tm->tm_hour, tm->tm_min, tm->tm_sec, tv.tv_usec);
}

void timestamp_vprintf(char *format, va_list ap) {
  print_current_time();
  printf(": ");
  
  vprintf(format, ap);
}
  
void timestamp_printf(char *format, ...) {
  va_list ap;

  va_start(ap, format);
  
  timestamp_vprintf(format, ap);
  
  va_end(ap);
}

  
long get_cache_size() {
  FILE *f=fopen("/proc/meminfo", "r");

  if (!f) {
    perror("fopen(/proc/meminfo)");
    exit(1);
  }

  char buf[1024];
  
  while (fgets(buf, sizeof(buf), f)) {
    long size;
    if (sscanf(buf, "Cached: %ld kB", &size)) {
      fclose(f);
      return size;
    }
    
  }
  fclose(f);
  printf("Didn't find the Cached line\n");
  exit(1);
}
  
unsigned long prior_cache_size;

void report_cache_size(char *format, ...) {
  va_list ap;

  va_start(ap, format);
  
  long size=get_cache_size();
  long delta=size - prior_cache_size;
  
  timestamp_vprintf(format, ap);

  va_end(ap);

  printf(": Cached: %ld (%+ld)\n", size, delta);

  if (delta < 0 && -delta >= CACHE_DROP_THRESHOLD) {
      printf("Terminating due to large cache drop.\n");
      exit(1);
  }

  prior_cache_size = size;
}


off_t get_size(char *filename) {
  struct stat sb;

  if (stat(filename, &sb) != 0) {
    printf("stat(%s): %s\n", filename, strerror(errno));
    exit(1);
  }

  return sb.st_size;
}
  
int open_file(char *filename) {
  int fd=open(filename, O_CREAT|O_RDWR, 0666);
  if (fd < 0) {
    printf("open(%s): %s\n", filename, strerror(errno));
    exit(1);
  }
  
  return fd;
}

void truncate_to_zero(char *filename) {
  report_cache_size("Truncating...");
  int fd=open_file(filename);
  if (ftruncate(fd, 0) != 0) {
    printf("ftruncate(0): %s\n", strerror(errno));
    exit(1);
  }

  report_cache_size("Closing...");
  close(fd);

  report_cache_size("Truncate complete");
}


void grow(char *filename) {
  off_t old_size=get_size(filename);
  
  report_cache_size("Grow : From %ld to %ld..", old_size, old_size + GROWTH_SIZE);

  int fd=open_file(filename);

  int err=posix_fallocate(fd, old_size, GROWTH_SIZE);
  if (err) {
    printf("posix_fallocate(fd,%ld,%ld): %s\n", old_size, GROWTH_SIZE, strerror(errno));
    exit(1);
  }
  report_cache_size("     : posix_fallocate done.  Closing...");
  close(fd);

  report_cache_size("Grow : closed.  Operation completed.");
}

off_t touch(char *filename, off_t start_offset) {
  int pagesize=getpagesize();
  off_t end_offset = get_size(filename);

  report_cache_size("Touch: open...");
  int fd=open_file(filename);
  report_cache_size("     : open completed. mmap...");
  void *base=mmap(NULL, end_offset, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
  if (base == MAP_FAILED) {
    perror("mmap");
    exit(1);
  }

  report_cache_size("     : mmap completed. close...");
  close(fd);

  off_t offset;

  report_cache_size("     : close completed. touching...");
  for (offset=start_offset; offset < end_offset; offset+=pagesize) {
    *(off_t *)(base + offset) = offset;
  }
  report_cache_size("     : touch completed.  munmap...");
  munmap(base, end_offset);

  report_cache_size("Touch: munmap completed.  Operation completed");

  return offset;
}

int main(int argc, char **argv) {
  if (argc != 2) {
    printf("Usage: %s filename\n", argv[0]);
    exit(1);
  }
  
  char *filename=argv[1];

  truncate_to_zero(filename);

  off_t offset=0;

  while (1) {
    grow(filename);
    offset=touch(filename, offset);
  }
  
  return 0;
}


From: William Bardwell <bardwell@curl.com>
Subject: Trouble with Linux NFS open()/close()/unlink() when interupted by SIGTSTP
Date: Fri, 10 Feb 2006 04:44:00 -0500
Message-ID: <20060210094400.3BE10E616@bela.curl.com>
Reply-To: wbardwel@curl.com
Cc: wbardwel@curl.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F7Uoz-0002sp-De
	for nfs@lists.sourceforge.net; Fri, 10 Feb 2006 01:44:09 -0800
Received: from mail-ext.curl.com ([66.228.88.132])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1F7Uox-0003gE-Tf
	for nfs@lists.sourceforge.net; Fri, 10 Feb 2006 01:44:09 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On a 2.6.11 client, with a 2.6.11 server, on a filesystem mounted:
(nfsv3,intr,proto=udp,vers=3)

If I run a program that opens a file, writes to it, closes and unlinks
it, and then another program that sends SIGTSTP and SIGCONT to the
first program, all sorts of weird failures happen.

1) If open() is called with O_EXCL|O_CREAT then it will sometimes fail
with errno 17 (EEXIST) and the file will be created, but be mode 0
and have a date like Dec 30 20034.
2) (without O_EXCL on open) sometimes close() will fail with 3 (BADF)
3) (without O_EXCL on open) sometimes unlink() will fail with 2 (ENOENT)
    and sometimes with 16 (EBUSY).

These all seem wrong.  And are all presumably due to it starting to
do the proper operations, and getting interupted, and not remembering
where to resume the operation.  But the calls aren't getting
EINTR, so shouldn't this just work?

Curiously, it only happens if the IO is in a pthreads spawned thread,
and ofcourse only on an NFS filesystem.  (And if I remove the FD_CLOEXEC
stuff, the unlink and close problems are reduced.)

The script to send the signals:

#!/bin/sh
$@ &
back_pid=$!
while true; do
    kill -TSTP $back_pid;
    kill -CONT $back_pid;
done
exit 0

---
// The C program to do IO, compiled with -lpthreads and optionaly
// -DNO_EXCL or -DNO_PTHREADS
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <pthread.h>

void *thingy(void *data);

int main()
{
#ifndef NO_THREADS
  pthread_t thread = 0;
  pthread_create(&thread, NULL, thingy, NULL);
  pthread_join(thread, NULL);
  return 0;
}

void *thingy(void *data)
{
#endif
  char base_filename[] = "xxx";
  char filename[128];
  char stuff[10000] = "xxx.txt";
  int i = 0;
  int flags =
    O_CREAT | O_TRUNC | O_RDWR |
#ifdef NO_EXCL
    0
#else
    O_EXCL
#endif
    ;
    
  while (1)
  {
    ++i;
    sprintf(filename, "%s%d.txt", base_filename, i);
    int fd = open(filename, flags, 0666);
    if (fd < 0 && errno == EINTR)
    {
        printf("open got EINTR\n");
        continue;
    }
    if (fd < 0)
    {
        printf("open got %d\n", errno);
        continue;
    }
    int old_flags = fcntl(fd, F_GETFD);
    if (old_flags >= 0 && (old_flags & FD_CLOEXEC) == 0)
    {
        fcntl(fd, F_SETFD, old_flags | FD_CLOEXEC);
    }
    while (write(fd, stuff, sizeof stuff) < 0 && errno == EINTR);
    if (close(fd) != 0)
    {
        if (errno != EBADF)
        {
            printf("close failed %d %d\n", errno, fd); fflush(stdout);
            exit (1);
        }
         else
        {
            printf("close failed EBADF %d\n", fd); fflush(stdout);
        }
    }
    while (unlink(filename) < 0)
    {
        if (errno == EINTR)
        {
            printf("unlink got EINTR\n");
        } else {
            printf("unlink got %d\n", errno);
            break;
        }
    }
  }
  return 0;
}

William Bardwell
wbardwel@curl.com


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Philippe Troin <phil@fifi.org>
Subject: Killed process on NFS client can result in lost lock on server
Date: 30 Sep 2003 13:06:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87r81y11og.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4QlU-0002wI-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 13:06:32 -0700
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A4QlT-0007HA-Dj
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 13:06:31 -0700
Received: from ceramic.fifi.org (mail@ceramic.fifi.org [216.27.190.147])
	by tantale.fifi.org (8.9.3p2/8.9.3/Debian 8.9.3-21) with ESMTP id NAA11647
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 13:06:24 -0700
Received: from phil by ceramic.fifi.org with local (Exim 4.22)
	id 1A4QlM-0002jp-2X
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 13:06:24 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

--=-=-=

I've noticed this first with bogofilter, and was able to reproduce the
problem with the enclosed test program.

Setup: kernel 2.4.22 and nfs-utils 1.0.5

A (nfs) client mounts a file system from the (nfs) server with these
options (from /proc/mounts):

server:/fs /fs nfs rw,nodev,v3,rsize=8192,wsize=8192,hard,intr,udp,lock,addr=server

If a process running on the (nfs) client is killed by a signal while
holding a lock on a (nfs) file, the server might not relinquish the
lock even though the locker is dead.

Try compiling and running the enclosed C program on a nfs client to
demonstrate the problem:

   phil@client:~% gcc -Wall -W -o kill-locks kill-locks.c
   phil@client:~% ./kill-locks
   [child] fcntl(F_SETLK): Resource temporarily unavailable
   unexpected status from child 00000100
   successful locking attempts: 2
   zsh: 10479 exit 1     ./kill-locks
   phil@client:~% ./kill-locks
   [child] fcntl(F_SETLK): Resource temporarily unavailable
   unexpected status from child 00000100
   successful locking attempts: 0
   zsh: 10483 exit 1     ./kill-locks
   phil@client:~% ls -i kill-locks.tmp
    371922 kill-locks.tmp
   phil@client:~% grep 371922 /proc/locks
   zsh: 10492 exit 1     grep 371922 /proc/locks
   phil@client:~%

On the server:

   phil@server:~% grep 371922 /proc/locks
   2: POSIX  ADVISORY  WRITE 10480 3a:04:371922 0 EOF c8138840 c8138484 cda9d324 00000000 c813884c
   phil@server:~%

The lock is still held.

While trying to make this test program, I've noticed that the problem
only occurs while I/O is done on the locked file. Note the write() in
a while loop in the test program. I could not get the bad behavior to
show up if no I/O is going on.

Phil.

--=-=-=
Content-Type: text/x-csrc
Content-Disposition: attachment; filename=kill-locks.c

#define _GNU_SOURCE
#define _LARGEFILE_SOURCE
#define _FILE_OFFSET_BITS 64

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <errno.h>

#define FNAME		"kill-locks.tmp"
#define BUFSIZE		16384
#define DEATHSIG	SIGINT

void sighandler(int signum)
{
  if (0) signum = 0;
}

int
main()
{
  int			successcount = 0;
  struct sigaction	sa;
  sigset_t		blockset, origset, waitset;
  /**/

  sa.sa_handler = &sighandler;
  sa.sa_flags	= 0;
  sigemptyset(&sa.sa_mask);
  if (sigaction(SIGUSR1, &sa, NULL) == -1)
    perror("sigaction(SIGUSR1)"), exit(1);
  if (sigaction(SIGCHLD, &sa, NULL) == -1)
    perror("sigaction(SIGCHLD)"), exit(1);

  sigemptyset(&blockset);
  sigaddset(&blockset, SIGUSR1);
  sigaddset(&blockset, SIGCHLD);
  if (sigprocmask(SIG_BLOCK, &blockset, &origset) == -1)
    perror("sigprocmask"), exit(1);
  waitset = origset;
  sigdelset(&waitset, SIGUSR1);
  sigdelset(&waitset, SIGCHLD);
  sigaddset(&waitset, DEATHSIG);

  while (1)
    {
      pid_t	childpid = fork();
      int	status;
      /**/

      if (childpid == (pid_t) -1)
	perror("fork()"), exit(1);
      if (childpid == 0)
	{
	  /* Child */
	  int		fd;
	  struct flock	lck;
	  char		buf[BUFSIZE];
	  /**/

	  if (sigprocmask(SIG_SETMASK, &origset, NULL) == -1)
	    perror("[child] sigprocmask"), exit(1);

	  fd = open(FNAME, O_RDWR|O_CREAT, 0666);
	  if (fd == -1)
	    perror("[child] open()"), exit(1);

	  lck.l_type   = F_WRLCK;
	  lck.l_whence = SEEK_SET;
	  lck.l_start  = (off_t)0;
	  lck.l_len    = (off_t)0;
	  if (fcntl(fd, F_SETLK, &lck) == -1)
	    perror("[child] fcntl(F_SETLK)"), exit(1);
	  memset(buf, 0, sizeof(buf));
	  kill(getppid(), SIGUSR1);
	  while(1)
	    write(fd, buf, sizeof(buf));
	}

      if ( ! (sigsuspend(&waitset) == -1 && errno == EINTR))
	perror("sigsuspend"), exit(1);
      usleep(rand()%1000);
      kill(childpid, DEATHSIG);
      if (waitpid(childpid, &status, 0) != childpid)
	perror("waitpid"), exit(1);
      if ( ! (WIFSIGNALED(status) && WTERMSIG(status) == DEATHSIG))
	{
	  fprintf(stderr,
		  "unexpected status from child %08X\n"
		  "successful locking attempts: %d\n",
		  status, successcount);
	  exit(1);
	}
      ++successcount;
    }
}

--=-=-=--


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

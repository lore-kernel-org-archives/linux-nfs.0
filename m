From: Philippe Troin <phil@fifi.org>
Subject: 2.4.23: Killed process on NFS client can result in lost lock on server
Date: 02 Dec 2003 11:56:59 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <873cc3q9h0.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ARGdu-0006g0-KB
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 11:57:06 -0800
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ARGdu-00078y-Bb
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 11:57:06 -0800
Received: from ceramic.fifi.org (mail@ceramic.fifi.org [216.27.190.147])
	by tantale.fifi.org (8.9.3p2/8.9.3/Debian 8.9.3-21) with ESMTP id LAA08789
	for <nfs@lists.sourceforge.net>; Tue, 2 Dec 2003 11:57:01 -0800
Received: from phil by ceramic.fifi.org with local (Exim 4.22)
	id 1ARGdn-0002K0-8q
	for nfs@lists.sourceforge.net; Tue, 02 Dec 2003 11:56:59 -0800
To: nfs@lists.sourceforge.net
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

--=-=-=

The problem described in the enclosed mail still occurs in 2.4.23. If
anybody cares.

Applying the enclosed patch from Trond makes the problem less
frequent, but it still occurs.

Phil.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=linux-2.4.23-nfs-locks.patch

diff -ruN linux-2.4.23.orig/fs/nfs/file.c linux-2.4.23/fs/nfs/file.c
--- linux-2.4.23.orig/fs/nfs/file.c	Mon Aug 25 04:44:43 2003
+++ linux-2.4.23/fs/nfs/file.c	Mon Dec  1 11:35:22 2003
@@ -293,7 +293,8 @@
 	status2 = filemap_fdatawait(inode->i_mapping);
 	if (status2 && !status)
 		status = status2;
-	if (status < 0)
+	/* Note: Ignore status if we're cleaning up locks on process exit */
+	if (status < 0 && !(current->flags & PF_EXITING))
 		return status;
 
 	lock_kernel();

--=-=-=
Content-Type: message/rfc822
Content-Disposition: inline

X-From-Line: nfs-admin@lists.sourceforge.net  Tue Sep 30 13:16:53 2003
Return-Path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list2.sourceforge.net (lists.sourceforge.net [66.35.250.206])
	by tantale.fifi.org (8.9.3p2/8.9.3/Debian 8.9.3-21) with ESMTP id NAA12089
	for <phil@fifi.org>; Tue, 30 Sep 2003 13:16:51 -0700
X-Authentication-Warning: tantale.fifi.org: Host lists.sourceforge.net [66.35.250.206] claimed to be sc8-sf-list2.sourceforge.net
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.13] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4Qmg-0003Dk-00; Tue, 30 Sep 2003 13:07:46 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4QlU-0002wI-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 13:06:32 -0700
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)	id 1A4QlT-0007HA-Dj
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 13:06:31 -0700
Received: from ceramic.fifi.org (mail@ceramic.fifi.org [216.27.190.147])
	by tantale.fifi.org (8.9.3p2/8.9.3/Debian 8.9.3-21) with ESMTP id NAA11647
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 13:06:24 -0700
Received: from phil by ceramic.fifi.org with local (Exim 4.22)
	id 1A4QlM-0002jp-2X
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 13:06:24 -0700
To: nfs@lists.sourceforge.net
Mail-Copies-To: nobody
From: Philippe Troin <phil@fifi.org>
Message-ID: <87r81y11og.fsf@ceramic.fifi.org>
User-Agent: Gnus/5.09 (Gnus v5.9.0) Emacs/21.2
X-Spam-Score: -0.5 (/)
X-Spam-Report: -0.5/5.0	Spam Filtering performed by sourceforge.net.
	See http://spamassassin.org/tag/ for more details.
	Report problems to https://sf.net/tracker/?func=add&group_id=1&atid=200001
	USER_AGENT_GNUS_UA (-0.5 points) User-Agent header indicates a non-spam MUA (Gnus)
Subject: [NFS] Killed process on NFS client can result in lost lock on server
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
X-BeenThere: nfs@lists.sourceforge.net
X-Mailman-Version: 2.0.9-sf.net
Precedence: bulk
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
X-Original-Date: 30 Sep 2003 13:06:23 -0700
Date: 30 Sep 2003 13:06:23 -0700
Lines: 167
Xref: ceramic.fifi.org lists.nfs:8773
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="===-=-="

--===-=-=

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

--===-=-=
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

--===-=-=--

--=-=-=--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

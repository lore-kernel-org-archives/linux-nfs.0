From: Philippe Troin <phil@fifi.org>
Subject: Re: [NFS client] NFS locks not released on abnormal process termination
Date: 09 Dec 2003 10:46:44 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8765gpvnfv.fsf@ceramic.fifi.org>
References: <20031208033933.16136.qmail@web20024.mail.yahoo.com>
	<shszne3risb.fsf@charged.uio.no> <877k17rzai.fsf@ceramic.fifi.org>
	<1070913367.2941.137.camel@nidelv.trondhjem.org>
	<87llpms8yr.fsf@ceramic.fifi.org> <shsekvetmat.fsf@guts.uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Kenny Simpson <theonetruekenny@yahoo.com>, linux-kernel@vger.kernel.org,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATmsu-0003W2-1v
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 10:47:00 -0800
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ATmst-0003zN-LZ
	for nfs@lists.sourceforge.net; Tue, 09 Dec 2003 10:46:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsekvetmat.fsf@guts.uio.no>
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

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> >>>>> " " == Philippe Troin <phil@fifi.org> writes:
> 
>      > From my reading of the patch, it supersedes the old patch, and
>      > is only
>      > necessary on the client. Is also does not compile :-)
> 
> Yeah, I admit I didn't test it out...
> 
>      > Here's an updated patch which does compile.
> 
> Thanks.
> 
>      > I am still running tests, but so far it looks good (that is all
>      > locks are freed when a process with locks running on a NFS
>      > client is killed).
> 
> Good...

I've ran test overnight on four boxen, and no locks were lost.
I guess you can send this patch to Marcello now.

I've tested with the enclosed program.

 
> There are still 2 other issues with the generic POSIX locking code.
> Both issues have to do with CLONE_VM and have been raised on
> linux-kernel & linux-fsdevel. Unfortunately they met with no response,
> so I'm unable to pursue...

Can we help? Pointers?

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

#define FNAME	"kill-locks.tmp"
#define BUFSIZE	16384
#define DEATHSIG SIGINT
#define LOCKTRIES       10
#define STRINGIFY_(x)	#x
#define STRINGIFY(x)    STRINGIFY_(x)
#define LOCKTRIESSTR    STRINGIFY(LOCKTRIES)
#define LOCKSLEEPSECS   1

void parent_try_lock(int mfd, int successcount, int status)
{
  int		i;
  struct flock	lck;

  for (i=0; 1 /* always true */; ++i)
    {
      lck.l_type   = F_WRLCK;
      lck.l_whence = SEEK_SET;
      lck.l_start  = (off_t)0;
      lck.l_len    = (off_t)0;
      if (fcntl(mfd, F_SETLK, &lck) == -1)
	{
	  if (errno == EAGAIN)
	    {
	      if ( i == LOCKTRIES )
		{
		  fprintf(stderr,
			  "unexpected status from child %08X\n"
			  "successful locking attempts: %d\n",
			  status, successcount);
		  exit(1);
		}
	      else
		{
		  sleep(LOCKSLEEPSECS);
		}
	    }
	  else
	    perror("[parent] fcntl(F_SETLK)"), exit(1);
	}
      else
	{
	  lck.l_type   = F_UNLCK;
	  lck.l_whence = SEEK_SET;
	  lck.l_start  = (off_t)0;
	  lck.l_len    = (off_t)0;
	  if (fcntl(mfd, F_SETLK, &lck) == -1)
	    perror("[parent] fcntl(F_SETLK) UNLCK"), exit(1);
	  if (status)
	    fprintf(stderr, "[parent] transient error, going on...\n");
	  break;
	}
    }
}

int
main()
{
  int	successcount = 0;
  int	mfd;
  /**/

  mfd = open(FNAME, O_RDWR|O_CREAT, 0666);
  if (mfd == -1)
    perror("open()"), exit(1);
  parent_try_lock(mfd, successcount, 0);

  while (1)
    {
      pid_t	childpid;
      int	status;
      /**/

      childpid = fork();
      if (childpid == (pid_t) -1)
	perror("fork()"), exit(1);
      if (childpid == 0)
	{
	  /* Child */
	  int		fd;
	  struct flock	lck;
	  char		buf[BUFSIZE];
	  /**/

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
	  while(1)
	    write(fd, buf, sizeof(buf));
	}

      usleep(rand()%1000);
      kill(childpid, DEATHSIG);
      if (waitpid(childpid, &status, 0) != childpid)
	perror("waitpid"), exit(1);
      if ( ! (WIFSIGNALED(status) && WTERMSIG(status) == DEATHSIG))
	parent_try_lock(mfd, successcount, status);
      ++successcount;
    }
}

--=-=-=--


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

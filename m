From: Stephan Koledin <skoledin@neolinear.com>
Subject: Re: NFS lockups with 2.4.18
Date: Tue, 30 Sep 2003 19:08:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F7A0CF8.4000407@neolinear.com>
References: <3F71CB8A.3090208@neolinear.com> <3F7347FF.2000403@neolinear.com> <3F745FA5.5010907@neolinear.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020607030209000905040509"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4Tbn-0000t5-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 16:08:43 -0700
Received: from n5.neolinear.com ([208.20.218.5] helo=flood.neolinear.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A4Tbm-0001J0-Qg
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 16:08:42 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <3F745FA5.5010907@neolinear.com>
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

This is a multi-part message in MIME format.
--------------020607030209000905040509
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello all.

I think we're finally making some progress with our problem. We've 
isolated the application and the system calls causing the lockups and I 
performed a bunch of testing today to try and define the causes of the 
lockups a little better. The recent 2.4.22 kernel from debian testing is 
affected the same as all other kernels we tried. I suppose I could be 
missing a more recent patch that fixes things - if so, please let me know.

Here is what we've found out:

- The problem is triggered by a distributed build process running on 
multiple Solaris 8 machines. The Sun compiler that we're using issues 
F_SETLKW calls to manage it's lock files during the build process. Since 
the build is distributed across a number of machines, we are seeing 
SETLKW attempts on the same file from several machines at the same time.

- We now have some code (attached) and various scripts to reproduce the 
problem.   It requires some coordination of requests from multiple 
machines, but is easily reproducible, given a proper environment. I can 
currently trigger the lockup within a couple seconds, even on a machine 
with a substantial number of nfsd processes running.

- I am unable to reproduce the problem with Linux clients. Only Solaris 
clients appear able to lock up the NFS server, even using the exact same 
test code and methodology.

- lockd enters a "D" state, with a WCHAN of "down" when multiple 
machines try to get a write lock (using F_SETLKW) on the same file(s). 
There must be at least two machines attempting to lock the same file, 
and the total number of processes/machines either with locks or waiting 
for any locks must be approximately 3-5x the number of nfsd processes. 
It really looks like it's triggered when there are 4x outstanding locks 
or lock requests, but it's a bit difficult to track given the 
distributed nature of the problem.

- For example, if I'm running 4 nfsd processes, the problem is triggered 
with around 16 lock requests from different machines. When running a 
more typical setup of 32 nfsd, triggering the problem requires a 
substantial amount of computing resources. We do see the problem with 
less than 128 machines requesting locks, but we cannot reproduce the 
problem with only one or two machines.

- Once lockd enters a "D" state, the nfsd processes also begin hitting a 
"D" state, and no more NFS requests are possible, even ones that do not 
require locking.

Now that the problem is easily reproducible, I would love to test any 
suggested solutions/patches. I wish I was more familiar with the 
lockd/nfs code, but unfortunately I don't have much kernel coding 
experience. Please let me know if there's anything else I can do (or 
data I can provide) to help get to the bottom of this issue.

Thanks in advance for any help with this problem, although it does seems 
like a rare issue, it is causing us a great deal of pain in our environment.

-Stephan

-- 
Stephan B Koledin
Network Systems Developer
http://neolinear.com/

--------------020607030209000905040509
Content-Type: text/x-csrc;
 name="setlkw.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="setlkw.c"

/*
 * To compile run: gcc lock.c
 *	      or:   cc lock.c
 *
 * To lock a file run: a.out <filename> 
 *
 */

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

extern int errno;
extern char *getenv();


static locking_debug_p()
{
	return (getenv("LOCKING_DEBUG") != NULL);
}

__lock_file(filename)
char *filename;
{
	int o_flags;
	int fd;
	struct flock lockstruct;


	o_flags = O_RDWR|O_CREAT|O_TRUNC;

	errno = 0;

	/* Open the file */
	if ((fd = open(filename, o_flags, 0666)) == -1) {
		fprintf(stderr, "error opening");
	}

	lockstruct.l_type = F_WRLCK;
	lockstruct.l_whence = SEEK_SET;
	lockstruct.l_start = 0L;
	lockstruct.l_len = 0L;

	/* Try and set the lock */
	if (fcntl(fd, F_SETLKW, &lockstruct) == -1) {
	    fprintf(stderr, "error Locking");
	}
	
	return fd;
}


__unlock_file(locknum)
int locknum;
{
	struct flock lockstruct;

	if (locking_debug_p())
		fprintf(stderr, "Unlocking fd %d ...\n", locknum);

	errno = 0;

	lockstruct.l_type = F_UNLCK;
	lockstruct.l_whence = SEEK_SET;
	lockstruct.l_start = 0L;
	lockstruct.l_len = 0L;

	if ((fcntl(locknum, F_SETLKW, &lockstruct)) == -1) {
	    fprintf(stderr, "error unlocking ");
	}

	if ((close(locknum)) == -1) {
	    fprintf(stderr, "error closing ");
	}

	return 0;
}


void print_usage(const char* progname)
{
    printf("\nUsage:\n	 %s  <file_to_lock> \n", progname);
    printf("   where  <file_to_lock> is the name of an existing file\n");
}


main(argc, argv)
int argc;
char **argv;
{
  int result;

  /* Did the user specify the correct number of arguments? */
  if (argc < 2) {
    printf("Error: not enough arguments specified.\n");
    print_usage(argv[0]);
    exit(1);
  }

  if (argc > 2) {
    printf("Warning: ignoring all arguments other than the first One.\n");
  }

  result = __lock_file(argv[1]);
  printf("#");
  fflush(stdout);

  /* We sleep here just to give enough time to start other competing 
   * lock attempts on other machines 
   */
  sleep(60);
  
  
  result = __unlock_file(result);
  printf("!");

  exit(0);

}


--------------020607030209000905040509--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

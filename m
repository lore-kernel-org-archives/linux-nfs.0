From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH fs/locks 3 of 3] Fix race conditions with file lock vs close
Date: Mon, 11 Jul 2005 15:20:41 +0200
Message-ID: <20050711132041.GV27163@suse.de>
References: <20050711103254.GI27163@suse.de> <42D266C5.4010203@redhat.com> <20050711125419.GS27163@suse.de> <42D26E41.1020605@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="u65IjBhB3TIa72Vp"
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DryDG-0001uc-Ck
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:20:46 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DryDF-0006OA-Fb
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:20:46 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <42D26E41.1020605@redhat.com>
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


--u65IjBhB3TIa72Vp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 11, 2005 at 09:04:01AM -0400, Peter Staubach wrote:
> I didn't change the way that the code works in this area, I just changed the
> indentation.  As far as I can tell, the new code works the same way as the
> old code did, except that it also doesn't leave dangling locks 
> around...  :-)

Doh, you're right.  Time for a break :)

> I wrote a small program to reproduce the race that I thought that the 2.6
> code was not already handling.  It is attached.  (Please note that it needs
> to run with a large-ish delay value, something like 40 or 45 seconds.  There
> is some interaction with the Linux threading which I haven't had/made time
> to investigate yet.)  I can also attach the email that I sent upstream
> which describes my analysis, if you like.

Thanks, I'll give it a try.

While we're on the subject of swapping test cases, here's the one I've
been using.

Cheers
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--u65IjBhB3TIa72Vp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="fusi-lock-crasher.c"

/* butchered test case for lock/close problems */

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/param.h>
#include <fcntl.h>
#include <pthread.h>
#include <string.h>

#define	MAXLOOPS	10000000

int	fd, i = 0;
int	failures = 0;
int	obtained = 0;
int	running = 1;

void
alrm_hndl(int sig)
{
	printf ("Timeout\n");
}

int
get_lock (int fd)
{
	struct flock    lock_it;
	int		res = 0;

#if 0
	lock_it.l_type = F_WRLCK;
	lock_it.l_whence = SEEK_SET;
	lock_it.l_start = 0;
	lock_it.l_len = 0;

	if (fcntl (fd, F_GETLK, &lock_it) < 0) {
		if (errno != EBADF)
			perror("fcntl(GETLK)");
		return (-1);
	}

	if (lock_it.l_type != F_UNLCK)
		printf("File is locked!\n");
#endif

	lock_it.l_type = F_WRLCK;
	lock_it.l_whence = SEEK_SET;
	lock_it.l_start = 0;
	lock_it.l_len = 0;

	if (fcntl (fd, F_SETLK, &lock_it) < 0) {
		if (errno == EINTR) {
			printf("Timed out.\n");
			return 0;
		}
		if (errno != EBADF && errno != EAGAIN)
			perror ("fcntl(F_WRLCK)");
		failures++;
		res = -1;
	} else {
		obtained++;
	}

	return res;
}


int
release_lock (int fd)
{
	struct flock    lock_it;

	lock_it.l_type = F_UNLCK;
	lock_it.l_whence = SEEK_SET;
	lock_it.l_start = 0;
	lock_it.l_len = 0;

	if (fcntl (fd, F_SETLKW, &lock_it) < 0) {
		if (errno == EINTR)
			return 0;
		if (errno != EBADF)
			perror ("fcntl(F_UNLCK)");
		return -1;
	}
	return 0;
}

void *
loop(void *arg)
{
	printf("Locking "); fflush(stdout);
	while (running) {
		if (get_lock(fd) >= 0) {
			write(1, ".", 1);
			/* usleep(1); */
			if (release_lock(fd) < 0) {
				/* printf("Unlock failed!\n"); */
			} 
		}
	} 
	printf("\nLock thread done, %d successful calls, %d failures\n",
			obtained, failures);
	return (NULL);
}

void *
c_loop(void *arg)
{
	char*	fn = (char*) arg;
	while (running) {
		close(fd);
		if ((fd = open (fn, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)) < 0)
			perror ("open");
		//usleep(1);
		i++;
	}
	printf("Open thread done\n");
	return NULL;
}

int
main(int argc, char** argv)
{
#define THREADS 1

	struct sigaction act;
	int		i;
	pthread_t	thread[THREADS];
	pthread_t	close_thread;

	if(argc != 2) {
		fprintf(stderr, "%s <path>\n", argv[0]);
		exit(-1);
	}

	memset(&act, 0, sizeof(act));
	act.sa_handler = alrm_hndl;
	if (sigaction (SIGALRM, &act, NULL) < 0) {
		perror("sigaction");
		return 1;
	}

	if ((fd = open (argv[1], O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)) < 0) {
		perror ("open");
		return 1;
	}

	for (i = 0; i < THREADS; i++) {
		pthread_create(&thread[i], NULL, loop, (void*) NULL);
	}
	usleep(100000);
	pthread_create(&close_thread, NULL, c_loop, (void*) argv[1]);

	sleep(5);

	running = 0;
	for (i = 0; i < THREADS; i++)
		pthread_join(thread[i], NULL);

	return 0;
}

--u65IjBhB3TIa72Vp--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

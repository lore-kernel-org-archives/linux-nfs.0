From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in locks_remove_posix
Date: Mon, 11 Jul 2005 16:23:13 +0200
Message-ID: <20050711142313.GA25020@suse.de>
References: <20050711103250.GH27163@suse.de> <1121084217.8204.52.camel@lade.trondhjem.org> <20050711124840.GR27163@suse.de> <1121086941.13326.14.camel@lade.trondhjem.org> <20050711131639.GU27163@suse.de> <1121089937.13326.41.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qDbXVdCdHGoSgWSk"
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrzBl-0004ku-TD
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 07:23:17 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DrzBl-0002u9-7Y
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 07:23:17 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121089937.13326.41.camel@lade.trondhjem.org>
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


--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jul 11, 2005 at 09:52:17AM -0400, Trond Myklebust wrote:
> In the case of NLM, we use the function nlm_find_lockowner() to create a
> mapping between fl_owner and a 32-bit numerical value which we call
> "pid", but which is really just a unique number. This mapping is
> preserved at least for the lifetime of the lock, and is shared between
> all locks that reference the same fl_owner.
> The "pid" of this mapping is the number that is seen by the server.

Alright. I stand corrected.

I originally reproduced this problem on SLES (ie 2.6.5), where the
lockowner stuff didn't exist yet. I then retested on 2.6.12, and found
the same problem - but didn't notice the mechanism is entirely different.
So whatever I'm seeing on 2.6.12 is different from what I saw on 2.6.5.

I'll do some more testing - in case anyone else would like to do so, too,
the test app is attached.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--qDbXVdCdHGoSgWSk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="two-thread-unlock.c"

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

int	fd;
int	running = 1;
int	locked = 0;

int
get_lock (int fd)
{
	struct flock    lock_it;
	int		res = 0;

	lock_it.l_type = F_WRLCK;
	lock_it.l_whence = SEEK_SET;
	lock_it.l_start = 0;
	lock_it.l_len = 0;

	if (fcntl (fd, F_SETLK, &lock_it) < 0) {
		perror ("fcntl(F_WRLCK)");
		res = -1;
	}

	return res;
}


void *
do_lock(void *arg)
{
	if (get_lock(fd) >= 0) {
		printf("Locked file\n");
		sleep(1);
		locked = 1;
	}

	while (running)
		sleep(1);
	return NULL;
}

void *
do_close(void *arg)
{
	int i;

	for (i = 0; !locked && i < 10; ++i)
		sleep(1);
	if (locked)
		close(fd);
	else
		printf("Never obtained the lock\n");
	running = 0;
	return NULL;
}

int
main(int argc, char** argv)
{
#define THREADS 1

	pthread_t	locker_thread;
	pthread_t	close_thread;

	if (argc != 2) {
		fprintf(stderr, "%s <path>\n", argv[0]);
		exit(-1);
	}

	if ((fd = open (argv[1], O_RDWR | O_CREAT, S_IRUSR | S_IWUSR)) < 0) {
		perror ("open");
		return 1;
	}

	pthread_create(&locker_thread, NULL, do_lock, NULL);
	pthread_create(&close_thread, NULL, do_close, NULL);
	sleep(2);

	running = 0;
	pthread_join(locker_thread, NULL);
	pthread_join(close_thread, NULL);

	return 0;
}

--qDbXVdCdHGoSgWSk--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

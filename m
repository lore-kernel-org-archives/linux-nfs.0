From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH fs/locks 3 of 3] Fix race conditions with file lock
 vs close
Date: Mon, 11 Jul 2005 09:04:01 -0400
Message-ID: <42D26E41.1020605@redhat.com>
References: <20050711103254.GI27163@suse.de> <42D266C5.4010203@redhat.com> <20050711125419.GS27163@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010208080600010207000208"
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Drxxr-00013B-Be
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:04:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Drxxq-0002m2-Oi
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:04:51 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711125419.GS27163@suse.de>
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

This is a multi-part message in MIME format.
--------------010208080600010207000208
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Olaf Kirch wrote:

>On Mon, Jul 11, 2005 at 08:32:05AM -0400, Peter Staubach wrote:
>  
>
>>A different patch was submitted upstream already to address the fcntl/close
>>race.  It was accepted into the '-mm' kernel on June 28'th.  That patch is
>>attached.
>>    
>>
>
>I see, it seems this customer has been spamming just about everyone
>about this problem :)
>
>I just wonder how the following can work - your patch seems to drop
>local book-keeping of locks completely, unless I misread it:
>
>
>  
>
>>+	if (filp->f_op && filp->f_op->lock != NULL)
>> 		error = filp->f_op->lock(filp, cmd, file_lock);
>>+	else {
>>+		for (;;) {
>>+			error = __posix_lock_file(inode, file_lock);
>>+			if ((error != -EAGAIN) || (cmd == F_SETLK))
>>+				break;
>>+			error = wait_event_interruptible(file_lock->fl_wait,
>>+					!file_lock->fl_next);
>>+			if (!error)
>>+				continue;
>>+	
>>+			locks_delete_block(file_lock);
>> 			break;
>>+		}
>>+	}
>>    
>>
>
>This means if the application establishes an NFS lock, this will not
>be reflected locally - and as a consequence, when the application just
>exits, the lock will never be released.
>

I didn't change the way that the code works in this area, I just changed the
indentation.  As far as I can tell, the new code works the same way as the
old code did, except that it also doesn't leave dangling locks 
around...  :-)

I wrote a small program to reproduce the race that I thought that the 2.6
code was not already handling.  It is attached.  (Please note that it needs
to run with a large-ish delay value, something like 40 or 45 seconds.  There
is some interaction with the Linux threading which I haven't had/made time
to investigate yet.)  I can also attach the email that I sent upstream
which describes my analysis, if you like.

    Thanx...

       ps

--------------010208080600010207000208
Content-Type: text/x-csrc;
 name="repo.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="repo.c"

#
#include <sys/types.h>
#include <stdio.h>
#include <pthread.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>

#define	SLEEPTIME	2

int delay = SLEEPTIME;

void do_child_process(int fd);
void *do_child_thread(void *arg);

main(int argc, char *argv[])
{
	int fd;
	int pid;
	int error;
	char *fname;
	pthread_t tid;

	if (argc == 1 || argc > 3) {
		fprintf(stderr, "usage: %s [delay] testfile_name\n", argv[0]);
		exit(1);
	}

	if (argc == 2)
		fname = argv[1];
	else {
		delay = atoi(argv[1]);
		fname = argv[2];
	}

	fd = open(fname, O_CREAT | O_RDWR, 0644);
	if (fd < 0) {
		fprintf(stderr, "%s: can't create %s\n", argv[0], fname);
		exit(1);
	}

	pid = fork();
	if (pid < 0) {
		perror("fork");
		exit(1);
	}

	if (pid == 0)
		do_child_process(fd);

	/*
	 * Give the child process more than enough time to lock
	 * the file.
	 */
	sleep(delay);

	error = pthread_create(&tid, NULL, do_child_thread, (void *)&fd);
	if (error < 0) {
		perror("pthread_create");
		(void) kill(pid, SIGTERM);
		exit(1);
	}

	/*
	 * Give the child thread long enough to start the lock and block
	 * waiting for the child process.
	 */
	sleep(delay);

	if (close(fd) < 0) {
		perror("parent close");
		(void) kill(pid, SIGTERM);
		exit(1);
	}

	if (pthread_join(tid, NULL) < 0)
		perror("pthread_join");

	if  (wait(NULL) < 0)
		perror("wait");

	exit(0);
}

void
do_child_process(int fd)
{
	struct flock lock;

	/*
	 * Lock the entire file to block the parent locking.
	 * Once the lock is acquired, wait until the parent
	 * process is set, with a lock pending and the file
	 * closed, and then unlock the file.
	 */
	lock.l_type = F_WRLCK;
	lock.l_whence = SEEK_SET;
	lock.l_start = 0;
	lock.l_len = 0;
	if (fcntl(fd, F_SETLKW, &lock) < 0) {
		perror("child process wait lock fcntl");
		exit(1);
	}

	/*
	 * Wait long enough for the parent process to spawn a thread to
	 * block waiting to lock the file that this process has locked
	 * and to close the file descriptor.  
	 */
	sleep(3 * delay);

	/*
	 * Now unlock the locked region.
	 */
	lock.l_type = F_UNLCK;
	if (fcntl(fd, F_SETLKW, &lock) < 0) {
		perror("child process wait unlock fcntl");
		exit(1);
	}

	/*
	 * Wait long enough for the parent process to to complete
	 * locking the file.  The file should not be locked because
	 * the parent process also closed the file descriptor.
	 */
	sleep(delay);

	/*
	 * Try to lock the file again.  This is a non-blocking request
	 * and should succeed immediately if everything is working
	 * correctly.  If it fails with EAGAIN, then the lock did not
	 * get properly removed after all of the parent process races.
	 */
	lock.l_type = F_WRLCK;
	if (fcntl(fd, F_SETLK, &lock) < 0) {
		if (errno == EAGAIN)
			printf("Dangling lock detected\n");
		else {
			printf(
			  "Oops, indeterminate results, try a larger delay?\n");
		}
	} else {
		printf("No dangling lock detected\n");
		lock.l_type = F_UNLCK;
		(void) fcntl(fd, F_SETLK, &lock);
	}

	exit(0);
}

void *
do_child_thread(void *arg)
{
	int fd = *((int *)arg);
	struct flock lock;

	/*
	 * Lock the entire file.  This should block, waiting for the
	 * child process to release its lock.  Once it does, then this
	 * lock request should proceed and succeed.
	 */
	lock.l_type = F_WRLCK;
	lock.l_whence = SEEK_SET;
	lock.l_start = 0;
	lock.l_len = 0;
	if (fcntl(fd, F_SETLKW, &lock) < 0)
		perror("child thread lock fcntl");
	pthread_exit(NULL);
}

--------------010208080600010207000208--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41266 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752092AbdGXDbb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Jul 2017 23:31:31 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 24 Jul 2017 13:18:50 +1000
Subject: [PATCH 0/2] Fix NFS issues with posix_fallocate() in locked file.
Cc: linux-nfs@vger.kernel.org
Message-ID: <150086579083.13837.3550463220871996964.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These two patches address two issues I found while examining the
behaviour of posix_fallocate() on a file which had recently
been locked. posix_fallocate() allocates space in a file by writing
bytes, so locking is important if sharing is possible.

The first patch fixes a bug which can lead to data corruption.
The second fixes a performance issue which can be demonstrated without
the first patch, but is made more likely by that patch (it was the
performance issue that caused me to start looking).

The program below can be used to demonstrate both problems.
Given a remote filesystem and 2 mount points, it mounts the filesystem
twice using nosharecache so that it acts like two separate clients.
It then creates a file and uses locking and posix_fallocate to trigger
the behaviours.
There are two threads.  Each reads the first byte, increments it, and
writes it out again.  This is done with proper file locking, so the
result should be '2'.  With the current kernel it is '1'. because one
of the posix_fallocate() corrupts a '1' making it '0'.

Mount options can be specified, so it can be confirmed that the
befaviour is the same for v3 and v4.1.  If used with v4.2 to a server
that supports ALLOCATE, the corruption doesn't happen.

To see the performance issue, a network trace is required.  Allocating
1 megabyte as this program does, doesn't take very long and it is hard
to measure a performance difference.  Allocating several gigabytes can
make the difference quite noticeable.

Thanks,
NeilBrown
---

NeilBrown (2):
      NFS: invalidate file size when taking a lock.
      NFS: Optimize fallocate by refreshing mapping when needed.


 fs/nfs/file.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--

/* nfs-lock-allocate.c
 * Test for performing fallocate() after locking an NFS file.
 * The nfs client must revalidate the size after getting the
 * lock, and should merge all the 1-byte writes past EOF into
 * fewer large writes.
 */
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <sys/fcntl.h>
#include <stdio.h>

static void setup(char *mnt, char *remote, char *options)
{
	char *buf = NULL;
	int fd;

	asprintf(&buf, "/bin/mount %s %s -o %s,nosharecache",
		 remote, mnt, options);
	system(buf);
	free(buf);
}

static void prepare(char *mnt, char *file)
{
	char *buf = NULL;
	int fd;

	asprintf(&buf, "%s/%s", mnt, file);
	unlink(buf);
	fd = open(buf, O_RDWR|O_CREAT|O_TRUNC, 0600);
	close(fd);
	free(buf);
}

static void teardown(char *mnt)
{
	umount(mnt);
}

static void test(int thread, char *mnt, char *file, int sync_fd)
{

	/* thread 1 writes a zero the file.
	 * thread 1 then gets the lock, allocates the file, and increments the byte.
	 * thread 2 then gets the lock and increments the byte.
	 */

	char *path = NULL;
	int fd;
	char buf[100];
	struct flock lk;
	asprintf(&path, "%s/%s", mnt, file);
	fd = open(path, O_RDWR, 0600);
	if (fd < 0) {
		perror(path);
		exit(1);
	}
	free(path);
	buf[0] = 0;
	if (thread == 1) {
		write(fd, buf, 1);
		fsync(fd);
	}

	if (thread == 2) {
		/* Allow thread 1 to get the lock first */
		write(sync_fd, buf, 1);
		read(sync_fd, buf, 1);
	}

	lk.l_type = F_WRLCK;
	lk.l_whence = SEEK_SET;
	lk.l_start = 0;
	lk.l_len = 0;
	fcntl(fd, F_SETLKW, &lk);
	if (thread == 1) {
		/* Now thread 2 can wait for the lock */
		write(sync_fd, buf, 1);
		read(sync_fd, buf, 1);
	}
	posix_fallocate(fd, 0, 1024*1024);
	lseek(fd, 0, 0);
	read(fd, buf, 1);
	lseek(fd, 0, 0);
	buf[0] += 1;
	write(fd, buf, 1);
	close(fd);
}

static int check(char *mnt, char *file)
{
	char *path = NULL;
	char buf[100];
	int fd;

	asprintf(&path, "%s/%s", mnt, file);
	fd = open(path, O_RDWR|O_CREAT, 0600);
	if (read(fd, buf, 1) != 1) {
		perror("read");
		close(fd);
		return 2;
	}
	close(fd);
	if (buf[0] != 2)
		return 3;
	return 0;
}

int main(int argc, char *argv[])
{
	char *remote;
	char *options;
	char *mnt1;
	char *mnt2;
	char *file;
	int socks[2];
	int ret;

	if (argc != 6) {
		fprintf(stderr, "Usage: %s server:/path mount-options /mntpoint1 /mntpoint2 file\n", argv[0]);
		exit(1);
	}
	remote = argv[1];
	options = argv[2];
	mnt1 = argv[3];
	mnt2 = argv[4];
	file = argv[5];

	setup(mnt1, remote, options);
	setup(mnt2, remote, options);
	prepare(mnt1, file);
	socketpair(AF_UNIX, SOCK_STREAM, 0, socks);
	switch (fork()) {
	case -1:
		perror("fork");
		exit(1);
	case 0: /* child */
		test(1, mnt1, file, socks[0]);
		exit(1);
		break;
	default:
		test(2, mnt2, file, socks[1]);
		break;
	}
	wait(NULL);
	teardown(mnt1);
	teardown(mnt2);
	setup(mnt1, remote, options);
	ret = check(mnt1, file);
	teardown(mnt1);
	if (ret == 3)
		fprintf(stderr, "File was corrupted\n");

	exit(ret);
}


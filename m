From: Olaf Kirch <okir@suse.de>
Subject: Problems with mmap consistency
Date: Fri, 17 Feb 2006 11:57:56 +0100
Message-ID: <20060217105756.GE25707@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qcHopEYAB45HaUaB"
Cc: Andrea Arcangeli <andrea@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA3JI-0007Ar-6Z
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 02:58:00 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FA3JH-0000Yc-A7
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 02:58:00 -0800
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 512A7E8CF
	for <nfs@lists.sourceforge.net>; Fri, 17 Feb 2006 11:57:56 +0100 (CET)
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


--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

we are currently investigating a customer problem with NFS mmap
consistency. They have an application (binary only, oh joy :) that
makes heavy use of a shared mmapped file (it's basically used as a work
queue for a local service).

They experienced frequent data corruption on the file. What happens is
that they establish a lock when updating a portion of the file, which
invalidates all cached data. Now until recently, nfs_revalidate_inode did
not make any attempt to flush out dirty mmapped pages. Andrea Arcangeli
recently submitted a fix to mainline with changes __nfs_revalidate_inode
to do this:

/* Do the page cache invalidation */
if (flags & NFS_INO_INVALID_DATA) {
	if (S_ISREG(inode->i_mode)) {
		if (mapping_mapped(inode->i_mapping))
			unmap_mapping_range(inode->i_mapping, 0, -1, 0);
		filemap_write_and_wait(inode->i_mapping);
		nfs_wb_all(inode);
	}
	nfsi->flags &= ~NFS_INO_INVALID_DATA;
	invalidate_inode_pages2(inode->i_mapping);

This improved the customer's situation slightly, but they are still
seeing corruption. I put together a test case that demonstrates this
problem within a few seconds.

It seems the problem is that there is still a fairly big race window
in this code - after unmap_mapping_range returns, we're waiting for
all dirty pages to be flushed to the server. A lot can happen while
we wait - for instance, some other process may modify a page that
has already been written. This modification will be lost during
the subsequent invalidate_inode_pages2 call.

Is there a simple VM mechanism that could be used to prevent this,
or does it need some extra logic to block a process in nfs_readpage
while we're revalidating?

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--qcHopEYAB45HaUaB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="mmapper.c"

/*
 * Test NFS mmap consistency
 *
 * Run as "./mmapper -u /nfsdir/somefile"
 *
 * Copyright (C) 2005 Olaf Kirch <okir@suse.de>
 */

#define _LARGEFILE64_SOURCE
#define _GNU_SOURCE
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/file.h>
#include <sys/vfs.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <stdint.h>
#include <signal.h>
#include <stdarg.h>
#include <errno.h>
#include <time.h>

static void	handler(int);
static void	setup(const char *, size_t);
static pid_t	do_master(const char *, size_t);
static pid_t	do_slave(unsigned int, const char *, size_t);
static void	usage(int);

#define MAXPROCS	64
#define PROCSPACE	1024

static int	opt_procs = 10;
static int	opt_timeout = 0;
static int	opt_lock = 1;
static int	opt_sleep = 100; /* ms */
static int	opt_unmap = 0;
static int	child_died = 0;

struct procinfo {
	uint32_t	pid;
	uint32_t	time;
	uint32_t	index;
	uint32_t	done;
};

int
main(int argc, char **argv)
{
	char *	opt_filename = NULL;
	size_t	opt_filesize = MAXPROCS * PROCSPACE;
	pid_t	children[MAXPROCS], pid;
	int	c, n, status, failed = 0;

	while ((c = getopt(argc, argv, "hln:t:u")) != EOF) {
		switch (c) {
		case 'h':
			usage(0);
		case 'l':
			opt_lock = !opt_lock;
			break;
		case 'n':
			opt_procs = atoi(optarg);
			if (opt_procs < 2) {
				fprintf(stderr, "nprocs must be >= 2\n");
				usage(1);
			}
			break;
		case 't':
			opt_timeout = atoi(optarg);
			break;
		case 'u':
			opt_unmap = 1;
			break;
		default:
			usage(1);
		}
	}

	if (optind + 1 != argc)
		usage(1);
	opt_filename = argv[optind++];

	setup(opt_filename, opt_filesize);

	for (n = 1; n < opt_procs; ++n)
		children[n] = do_slave(n, opt_filename, opt_filesize);
	children[0] = do_master(opt_filename, opt_filesize);

	signal(SIGCHLD, handler);
	if (opt_timeout) {
		sleep(opt_timeout);
		pid = 0;
	} else {
		/* Just wait for any status */
		pid = wait(&status);
	}

	for (n = 0; n < opt_procs; ++n)
		kill(children[n], SIGTERM);

	do {
		if (pid && WIFEXITED(status) && WEXITSTATUS(status) != 0) {
			fprintf(stderr,
				"Subprocess exit code %u - test failed\n",
				WEXITSTATUS(status));
			failed++;
		}
		pid = wait(&status);
	} while (pid > 0);

	if (!failed)
		printf("Test completed successfully\n");

	return failed? 1 : 0;
}

void
handler(int dummy)
{
	child_died++;
}

void
usage(int error)
{
	fprintf(error? stderr : stdout,
		"usage: mmapper [-n numprocs] [-h] mapfile\n");
	exit(error);
}

static void
fatal(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);
	exit(1);
}

static void
setup(const char *filename, size_t size)
{
	int	fd;

	if ((fd = open(filename, O_RDWR|O_CREAT, 0644)) < 0)
		fatal("Unable to open %s: %m\n", filename);

	/* Wipe the file */
	if (ftruncate(fd, 0) < 0
	 || ftruncate(fd, size) < 0)
		fatal("%s: %m\n", filename);

	close(fd);
}

/*
 * Map/unmap the file
 */
static void *
map_it(const char *filename, size_t size, int *fdp)
{
	unsigned char	*addr = NULL;
	int		fd;

	if ((fd = open(filename, O_RDWR, 0644)) < 0)
		fatal("Unable to open %s: %m\n", filename);

	addr = mmap(NULL, size, PROT_WRITE|PROT_READ, MAP_SHARED, fd, 0);
	if (addr == MAP_FAILED)
		fatal("Unable to map %s: %m\n", filename);

	*fdp = fd;
	return addr;
}

static void
unmap_it(unsigned char *addr, size_t size, int fd)
{
	munmap(addr, size);
	close(fd);
}

/*
 * Lock/unlock the file
 */
static void
lock_it(int fd, struct flock *flp, off_t start, size_t len)
{
	flp->l_type = F_WRLCK;
	flp->l_whence = SEEK_SET;
	flp->l_start = start;
	flp->l_len = len;
	if (fcntl(fd, F_SETLKW, flp) < 0)
		fatal("fcntl(F_SETLKW): %m\n");
}

static void
unlock_it(int fd, struct flock *flp)
{
	flp->l_type = F_UNLCK;
	if (fcntl(fd, F_SETLKW, flp) < 0)
		fatal("fcntl(F_SETLKW): %m\n");
}

/*
 * Frob the per-process data in the file
 */
#define proc_offset(n)		((n) * PROCSPACE)

static inline struct procinfo *
get_procinfo(unsigned char *addr, unsigned int n)
{
	return (struct procinfo *) (addr + proc_offset(n));
}

static void
init_procinfo(struct procinfo *info)
{
	info->pid = getpid();
	info->time = time(NULL);
	info->index = 0;
	info->done = 0;
}

static void
check_procinfo(struct procinfo *info, const char *name, struct procinfo *old)
{
	uint32_t	now;

	now = time(NULL);
	if (info->time != old->time
	 || info->pid != old->pid
	 || info->index != old->index) {
		fprintf(stderr,
			"\nError: process %s: data is stale\n"
			"----------------------------------\n"
			"                   Got    Expected\n"
			"----------------------------------\n"
			"Index:      %10u  %10u\n"
			"PID:        %10u  %10u\n"
			"Done:       %10u  %10u%s\n"
			"Time:       %10u  %10u\n",
			name,
			info->index, old->index,
			info->pid, old->pid,
			info->done, old->done,
				(info->done != old->done)? " (ignored)" : "",
			info->time, old->time);
		exit(1);
	 }

	info->time = now;
	info->index++;
	info->done = 0;

	*old = *info;
}

pid_t
do_master(const char *filename, size_t size)
{
	int		fd;
	unsigned char	*addr = NULL;
	struct procinfo	*info, previous;
	pid_t		pid;

	pid = fork();
	if (pid < 0)
		fatal("Unable to fork master: %m\n");
	if (pid != 0) {
		close(fd);
		return pid;
	}

	addr = map_it(filename, size, &fd);
	info = get_procinfo(addr, 0);
	init_procinfo(info);
	previous = *info;

	while (1) {
		struct flock	fl;
		unsigned int	n;

		write(1, ".", 1);

		lock_it(fd, &fl, 0, 0);

		check_procinfo(info, "master", &previous);

		/* Loop over all slaves and mark their "jobs"
		 * as done. Doesn't really matter what we do
		 * here as long as we do something to their mapped
		 * data. */
		for (n = 1; n < opt_procs; ++n) {
			struct procinfo *clnt;

			clnt = get_procinfo(addr, n);
			clnt->done = 1;
		}

		msync(addr, size, MS_SYNC);
		unlock_it(fd, &fl);

		usleep(opt_sleep * 1000);
	}

	unmap_it(addr, size, fd);
}

pid_t
do_slave(unsigned int slot, const char *filename, size_t size)
{
	char		procname[16];
	int		fd;
	unsigned char	*addr = NULL;
	struct procinfo	*info, previous;
	pid_t		pid;

	sprintf(procname, "slave%u", slot);

	pid = fork();
	if (pid < 0)
		fatal("Unable to fork %s: %m\n", procname);
	if (pid != 0) {
		close(fd);
		return pid;
	}

	addr = map_it(filename, size, &fd);
	info = get_procinfo(addr, slot);
	init_procinfo(info);
	previous = *info;
	if (opt_unmap)
		unmap_it(addr, size, fd);

	printf("Start %s, offset %u, pid %u\n", procname, proc_offset(slot), getpid());

	while (1) {
		struct flock	fl;

		if (opt_unmap) {
			addr = map_it(filename, size, &fd);
			info = get_procinfo(addr, slot);
		}

		lock_it(fd, &fl, proc_offset(slot), PROCSPACE);

		check_procinfo(info, procname, &previous);

		msync(addr, size, MS_SYNC);
		unlock_it(fd, &fl);

		if (opt_unmap)
			unmap_it(addr, size, fd);

		usleep(opt_sleep * 1000);
	}
	if (!opt_unmap)
		unmap_it(addr, size, fd);
}

--qcHopEYAB45HaUaB--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

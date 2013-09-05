Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36068 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755541Ab3IETLo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Sep 2013 15:11:44 -0400
Received: by mail-ie0-f179.google.com with SMTP id m16so4015614ieq.10
        for <linux-nfs@vger.kernel.org>; Thu, 05 Sep 2013 12:11:44 -0700 (PDT)
Date: Thu, 5 Sep 2013 14:11:39 -0500
From: Quentin Barnes <qbarnes@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Re: nfs-backed mmap file results in 1000s of WRITEs per second
Message-ID: <20130905191139.GA20830@gmail.com>
References: <20130905162110.GA17920@gmail.com>
 <20130905170303.GB17330@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130905170303.GB17330@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 05, 2013 at 12:03:03PM -0500, Malahal Naineni wrote:
> Neil Brown posted a patch couple days ago for this!
> 
> http://thread.gmane.org/gmane.linux.nfs/58473

I tried Neil's patch on a v3.11 kernel.  The rebuilt kernel still
exhibited the same 1000s of WRITEs/sec problem.

Any other ideas?

> Regards, Malahal.
> 
> Quentin Barnes [qbarnes@gmail.com] wrote:
> > If two (or more) processes are doing nothing more than writing to
> > the memory addresses of an mmapped shared file on an NFS mounted
> > file system, it results in the kernel scribbling WRITEs to the
> > server as fast as it can (1000s per second) even while no syscalls
> > are going on.
> > 
> > The problems happens on NFS clients mounting NFSv3 or NFSv4.  I've
> > reproduced this on the 3.11 kernel, and it happens as far back as
> > RHEL6 (2.6.32 based), however, it is not a problem on RHEL5 (2.6.18
> > based).  (All x86_64 systems.)  I didn't try anything in between.
> > 
> > I've created a self-contained program below that will demonstrate
> > the problem (call it "t1").  Assuming /mnt has an NFS file system:
> > 
> >   $ t1 /mnt/mynfsfile 1    # Fork 1 writer, kernel behaves normally
> >   $ t1 /mnt/mynfsfile 2    # Fork 2 writers, kernel goes crazy WRITEing
> > 
> > Just run "watch -d nfsstat" in another window while running the two
> > writer test and watch the WRITE count explode.
> > 
> > I don't see anything particularly wrong with what the example code
> > is doing with its use of mmap.  Is there anything undefined about
> > the code that would explain this behavior, or is this a NFS bug
> > that's really lived this long?
> > 
> > Quentin
> > 
> > 
> > 
> > #include <sys/stat.h>
> > #include <sys/mman.h>
> > #include <sys/stat.h>
> > #include <sys/wait.h>
> > #include <errno.h>
> > #include <fcntl.h>
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <signal.h>
> > #include <string.h>
> > #include <unistd.h>
> > 
> > int
> > kill_children()
> > {
> > 	int		cnt = 0;
> > 	siginfo_t	infop;
> > 
> > 	signal(SIGINT, SIG_IGN);
> > 	kill(0, SIGINT);
> > 	while (waitid(P_ALL, 0, &infop, WEXITED) != -1) ++cnt;
> > 
> > 	return cnt;
> > }
> > 
> > void
> > sighandler(int sig)
> > {
> > 	printf("Cleaning up all children.\n");
> > 	int cnt = kill_children();
> > 	printf("Cleaned up %d child%s.\n", cnt, cnt == 1 ? "" : "ren");
> > 
> > 	exit(0);
> > }
> > 
> > int
> > do_child(volatile int *iaddr)
> > {
> > 	while (1) *iaddr = 1;
> > }
> > 
> > int
> > main(int argc, char **argv)
> > {
> > 	const char	*path;
> > 	int		fd;
> > 	ssize_t		wlen;
> > 	int		*ip;
> > 	int		fork_count = 1;
> > 
> > 	if (argc == 1) {
> > 		fprintf(stderr, "Usage: %s {filename} [fork_count].\n",
> > 			argv[0]);
> > 		return 1;
> > 	}
> > 
> > 	path = argv[1];
> > 
> > 	if (argc > 2) {
> > 		int fc = atoi(argv[2]);
> > 		if (fc >= 0)
> > 			fork_count = fc;
> > 	}
> > 
> > 	fd = open(path, O_CREAT|O_TRUNC|O_RDWR|O_APPEND, S_IRUSR|S_IWUSR);
> > 	if (fd < 0) {
> > 		fprintf(stderr, "Open of '%s' failed: %s (%d)\n",
> > 			path, strerror(errno), errno);
> > 		return 1;
> > 	}
> > 
> > 	wlen = write(fd, &(int){0}, sizeof(int));
> > 	if (wlen != sizeof(int)) {
> > 		if (wlen < 0)
> > 			fprintf(stderr, "Write of '%s' failed: %s (%d)\n",
> > 				path, strerror(errno), errno);
> > 		else
> > 			fprintf(stderr, "Short write to '%s'\n", path);
> > 		return 1;
> > 	}
> > 
> > 	ip = (int *)mmap(NULL, sizeof(int), PROT_READ|PROT_WRITE,
> > 			   MAP_SHARED, fd, 0);
> > 	if (ip == MAP_FAILED) {
> > 		fprintf(stderr, "Mmap of '%s' failed: %s (%d)\n",
> > 			path, strerror(errno), errno);
> > 		return 1;
> > 	}
> > 
> > 	signal(SIGINT, sighandler);
> > 
> > 	while (fork_count-- > 0) {
> > 		switch(fork()) {
> > 		case -1:
> > 			fprintf(stderr, "Fork failed: %s (%d)\n",
> > 				strerror(errno), errno);
> > 			kill_children();
> > 			return 1;
> > 		case 0:   /* child  */
> > 			signal(SIGINT, SIG_DFL);
> > 			do_child(ip);
> > 			break;
> > 		default:  /* parent */
> > 			break;
> > 		}
> > 	}
> > 
> > 	printf("Press ^C to terminate test.\n");
> > 	pause();
> > 
> > 	return 0;
> > }
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 

Quentin

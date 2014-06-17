Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:46550 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932133AbaFQNtp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2014 09:49:45 -0400
Date: Tue, 17 Jun 2014 13:51:42 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>, linux-nfs@vger.kernel.org
Message-ID: <1049368555.86792.1403013102335.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <1726881404.72983.1402308693418.JavaMail.zimbra@opinsys.fi>
References: <199810131.34257.1400570367382.JavaMail.zimbra@opinsys.fi> <1176115795.34522.1400575248541.JavaMail.zimbra@opinsys.fi> <20140520102117.2582abac@tlielax.poochiereds.net> <2137177707.38241.1400684149690.JavaMail.zimbra@opinsys.fi> <20140521165304.4331255d@tlielax.poochiereds.net> <1726881404.72983.1402308693418.JavaMail.zimbra@opinsys.fi>
Subject: Re: Soft lockups on kerberised NFSv4.0 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
> From: "Tuomas Räsänen" <tuomasjjrasanen@opinsys.fi>
> 
> The lockup mechnism seems to be as follows: the process (which is always
> firefox) is killed, and it tries to unlock the file (which is always a
> mmapped sqlite3 WAL index) which still has some pending IOs going on. The
> return value of nfs_wait_bit_killable() (-ERESTARTSYS from
> fatal_signal_pending(current)) is ignored and the process just keeps looṕing
> because io_count seems to be stuck at 1 (I still don't know why..). 

I wrote a simple program which simulates the behavior described above
and causes softlockups (see the bottom of the file).

Here's what it does:
- creates and opens jamfile.dat (10M)
- locks the file with flock
- spawns N threads which all:
  - mmap the whole file and write to the map
- unlocks the file after spawning threads

Sometimes unlocking flock() blocks for a while, waiting for pending
IOs [*]. If the process is killed during unlock (signaled SIGINT before the
program has printed 'unlock ok'), it seems to get stuck: pending IOs are
not finished and -ERESTARTSYS from nfs_wait_bit_killable() is not
handled, causing the task to loop inside __nfs_iocounter_wait()
indefinitely.

How to cause soft lockups:

1. Compile: gcc -pthread -o jam jam.c

2. Run ./jam

3. Press C-c shortly after running the script, after 'unlock' but before
   'unlock ok' is printed

4. You might need to repeat steps 2. and 3. couple of times

[*]: Sometimes flock() seem to block for *very* long time (for ever?),
     but sometimes only for a short period of time. But regarding this
     problem, it does not matter: whenever the task is killed during the
     unlock, the process freezes.

Applying the patch from my previous mail fixes the soft lockup issue,
because the task does not get into a infinite (or at least indefinite)
loop because interruptible wait_on_bit() is used instead. But what are
its side-effects? Is it completely brain-dead idea?

jam.c:

#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/file.h>
#include <sys/mman.h>
#include <unistd.h>

#define MAP_SIZE (sizeof(char) *  1024 * 1024 * 10)
#define THREADS 4

void *work_on_file(void *const arg)
{
	int i;
	int fd;
	char *map;

	fd = *((int *) arg);
	map = (char *) mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

	printf("write begins\n");
	for (i = 0; i < MAP_SIZE; ++i) {
		map[i] = 'a';
	}
	printf("write ends\n");

	return NULL;
}

int main(void)
{
	int i;
	pthread_t *threads;
	int fd;

	fd = open("jamfile.dat", O_RDWR | O_CREAT);
	ftruncate(fd, MAP_SIZE);

	threads = malloc(sizeof(pthread_t) * THREADS);

	printf("lock\n");
	if (flock(fd, LOCK_EX) == -1) {
		perror("failed to lock");
		return -1;
	}
	printf("lock ok\n");

	for (i = 0; i < THREADS; ++i) {
		pthread_attr_t attr;
		pthread_attr_init(&attr);
		pthread_create(&threads[i], &attr, &work_on_file, &fd);
		pthread_attr_destroy(&attr);
	}

	printf("unlock\n");
	if (flock(fd, LOCK_UN) == -1) {
		perror("failed to unlock");
		return -1;
	}
	printf("unlock ok\n");

	for (i = 0; i < THREADS; ++i) {
		pthread_join(threads[i], NULL);
	}

	free(threads);

	return close(fd);
}

-- 
Tuomas

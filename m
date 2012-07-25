Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36210 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab2GYHcP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2012 03:32:15 -0400
Received: by lbbgm6 with SMTP id gm6so426639lbb.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jul 2012 00:32:14 -0700 (PDT)
MIME-Version: 1.0
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 25 Jul 2012 15:31:53 +0800
Message-ID: <CA+a=Yy7B0uk-FWr3hOjWC+=Xq+UtHnEC4speD3OZzMFfXksyOw@mail.gmail.com>
Subject: pnfs LD partial sector write
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: linuxnfs <linux-nfs@vger.kernel.org>, Benny Halevy <bhalevy@tonian.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Boaz,

Sorry about the long delay. I had some internal interrupt. Now I'm
looking at the partial LD write problem again. Instead of trying to
bail out unaligned writes blindly, this time I want to fix the write
code to handle partial write as you suggested before. However, it
seems to be more problematic than I used to think.

The dirty range of a page passed to LD->write_pagelist may be
unaligned to sector size, in which case block layer cannot handle it
correctly. Even worse, I cannot do a read-modify-write cycle within
the same page because bio would read in the entire sector and thus
ruin user data within the same sector. Currently I'm thinking of
creating shadow pages for partial sector write and use them to read in
the sector and copy necessary data into user pages. But it is way too
tricky and I don't feel like it at all. So I want to ask how you solve
the partial sector write problem in object layout driver.

I looked at the ore code and found that you are using bio to deal with
partial page read/write as well. But in places like _add_to_r4w(), I
don't see how partial sectors are handled. Maybe I was misreading the
code. Would you please shed some light? More specifically, how does
object layout driver handle partial sector writers like in bellow
simple testcase? Thanks in advance.

-- 
Best,
Tao


flock-partial-write.c:

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>

int main(char argc, char **argv)
{
	int fd, i, offset = 666, len = 777;
	char buf[4096], buf_v[4096];
	struct flock lock;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s [filename]\n", argv[0]);
		return -1;
	}

	memset(buf, 'A', sizeof(buf));

	if ((fd = open(argv[1], O_CREAT|O_RDWR, 0644)) < 0) {
		perror("open fail");
		return -1;
	}

	if (write(fd, buf, sizeof(buf)) < sizeof(buf)) {
		perror("write fail");
		return -1;
	}

	close(fd);

	system("echo 1 > /proc/sys/vm/drop_caches");

	memset(buf + offset, 'B', len);
	memcpy(buf_v, buf, sizeof(buf_v));

	if ((fd = open(argv[1], O_WRONLY)) < 0) {
		perror("open fail");
		return -1;
	}

	lock.l_type = F_WRLCK;
	lock.l_whence = SEEK_SET;
	lock.l_start = offset;
	lock.l_len = len;

	if (fcntl(fd, F_SETLKW, &lock) < 0) {
		perror("lock fail");
		return -1;
	}

	if (lseek(fd, offset, SEEK_SET) < 0) {
		perror("seek fail");
		return -1;
	}

	if (write(fd, buf + offset, len) < len) {
		perror("write fail");
		return -1;
	}

	lock.l_type = F_UNLCK;
	fcntl(fd, F_SETLK, &lock);

	close(fd);

	if ((fd = open(argv[1], O_RDONLY)) < 0) {
		perror("open fail");
		return -1;
	}

	if (read(fd, buf, sizeof(buf)) < sizeof(buf)) {
		perror("read fail");
		return -1;
	}

	if (memcmp(buf, buf_v, sizeof(buf)) != 0) {
		fprintf(stderr, "aha, buf not match\n");
		for (i = 0; i < sizeof(buf); i++) {
			if (buf[i] != buf_v[i])
				fprintf(stderr, "%dth %c vs %c\n", i, buf[i], buf_v[i]);
		}
	} else {
		printf("nice done!\n");
	}

	close(fd);
	return 0;
}

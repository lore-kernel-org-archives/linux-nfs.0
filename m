Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53730 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754502Ab2LLOq5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2012 09:46:57 -0500
Date: Wed, 12 Dec 2012 09:46:54 -0500
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, eguan@redhat.com
Subject: non-aligned DIO reads on NFS are corrupting memory in 3.7.0
Message-ID: <20121212094654.5ce53d89@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/+NN_8c_THJeYJ0A_pQSw=Vu"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/+NN_8c_THJeYJ0A_pQSw=Vu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

One of our QA folks found that the attached testcase would segfault
when run on a recent rhel6 kernel that has a backport of the pnfs dio
code. I get the same segfault when I run it on a 3.7.0 kernel as well.

I think the problem is that because the buffer we're reading into is on
the stack, the kernel is scribbling over the rest of the page after the
read and corrupting it.

The problem, I think is this block in nfs_direct_read_completion():

-----------------------[snip]-----------------------
                if (test_bit(NFS_IOHDR_EOF, &hdr->flags)) {
                        if (bytes > hdr->good_bytes)
                                zero_user(page, 0, PAGE_SIZE);
                        else if (hdr->good_bytes - bytes < PAGE_SIZE)
                                zero_user_segment(page,
                                        hdr->good_bytes & ~PAGE_MASK,
                                        PAGE_SIZE);
                }
-----------------------[snip]-----------------------

If I comment that out, then the test passes and it doesn't scribble
over memory. I'm not clear on what that block is trying to accomplish.
If we get a short read in the DIO codepath, I don't think we ought to
be zeroing out the rest of the page. We should just return the number
of bytes read and be done with it.

I'm also suspicious of the "if (!PageCompound(page))" check in that
function as well. It doesn't seem like we ought to be marking pages
dirty in the DIO codepaths, should we?

-- 
Jeff Layton <jlayton@redhat.com>

--MP_/+NN_8c_THJeYJ0A_pQSw=Vu
Content-Type: text/x-csrc
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=dio.c

#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define T_TEST_TEXT "This is a test\n"
#define BUF_SIZE 32
/* 16 won't work, 17 will cause segfault */
//#define READ_SIZE 16
#define READ_SIZE 17

int test_write(char *testfile)
{
	int fd;
	int ret;
	int status;
	char buf[BUF_SIZE];

	status = 0;
	printf("Write file with O_DIRECT\n");
	memset(buf, 'a', BUF_SIZE);
	/* Buffered write or direct write both work */
	fd = open(testfile, O_CREAT | O_RDWR | O_DIRECT | O_TRUNC, 0644);
//	fd = open(testfile, O_CREAT | O_RDWR | O_TRUNC, 0644);
	if (fd == -1) {
		printf("FAIL - open: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}

	ret = write(fd, T_TEST_TEXT, sizeof(T_TEST_TEXT));
	if (ret == -1) {
		printf("FAIL - write: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}

	close(fd);

	printf("Read file with O_DIRECT\n");
	/* Only direct read would get segfault */
	fd = open(testfile, O_RDONLY | O_DIRECT);
//	fd = open(testfile, O_RDONLY);
	ret = read(fd, buf, READ_SIZE);
	if (ret == -1) {
		printf("FAIL - re-read: %s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}

	if (!strcmp(buf, T_TEST_TEXT)) {
		printf("PASS\n");
	} else {
		printf("FAIL - expect \"%s\" - got \"%s\"\n",
			T_TEST_TEXT, buf);
		status++;
	}
	close(fd);

	return status;
}

int main(int argc, char *argv[])
{
	int ret;
	ret = test_write(argv[1]);
	exit(ret);
}

--MP_/+NN_8c_THJeYJ0A_pQSw=Vu--

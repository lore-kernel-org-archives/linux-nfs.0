Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:34550 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751169AbaGIVzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 17:55:13 -0400
From: "Frank S. Filz" <ffilzlnx@mindspring.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "Frank S. Filz" <ffilzlnx@mindspring.com>
Subject: Re: [PATCH 1/1] Fix permission checking by NFS client for open-create with mode 000
Date: Wed,  9 Jul 2014 17:55:04 -0400
Message-Id: <1404942904-18361-1-git-send-email-ffilzlnx@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Frank S. Filz" <ffilzlnx@mindspring.com>

I used the following program to test the patch:

It does report 4 failures, as expected, when the file does not already exist:

	open("foo", O_CREAT | O_TRUNC | O_RDONLY, 000);
	open("foo", O_CREAT | O_TRUNC | O_RDONLY, 111);
	open("foo", O_CREAT | O_TRUNC | O_RDONLY, 222);
	open("foo", O_CREAT | O_TRUNC | O_RDONLY, 333);

These will not fail on a local filesystem.

---
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <strings.h>
#include <string.h>

static inline int expect(int required, int actual)
{
	return (actual & required) == required;
}

void check_one(char *name, int flags, int required, int mode)
{
	int fd, rc, access = flags & O_ACCMODE;
	char flags_s[1024], open_s[1024];
	int expected = expect(required, mode);

	sprintf(flags_s, "%s%s%s",
		flags & O_CREAT ? "O_CREAT | " : "",
		flags & O_TRUNC ? "O_TRUNC | " : "",
		access == O_RDONLY ? "O_RDONLY" :
		access == O_WRONLY ? "O_WRONLY" :
		access == O_RDWR ? "O_RDWR" :
		"UNKNOWN");

	if (flags & O_CREAT) {
		strcat(flags_s, ",");
		sprintf(open_s, "EXISTS: open(%s, %-29s %03o)",
			name, flags_s, mode);
		fd = open(name, flags, mode);
	} else {
		sprintf(open_s, "EXISTS: open(%s, %-29s)    ",
			name, flags_s);
		fd = open(name, flags);
	}

	if (fd == -1) {
		rc = errno;

		if (expected || (rc != EACCES))
			printf("FAIL - %s - Error %s (%d)\n",
			       open_s,
			       strerror(rc), rc);
		else
			printf("PASS - %s - Expected Error %s (%d)\n",
			       open_s,
			       strerror(rc), rc);

		return;
	}

	if (!expected) {
		printf("FAIL - %s - Unexpected Success\n",
		       open_s);
	} else {
		printf("PASS - %s - Success\n",
		       open_s);
	}

	rc = close(fd);

	if (rc == -1) {
		printf("Error %s (%d) closing %s\n",
		       strerror(errno), errno, name);
		return;
	}
}


int check_create(char *name, int access, int mode)
{
	int fd, rc, len, flags = access | O_CREAT | O_TRUNC;
	char flags_s[1024], open_s[1024];
	char buffer_w[1024], buffer_r[1024];

	sprintf(buffer_w,"File: %s\n", name);

	/* Make sure file is unlinked */
	rc = unlink(name);
	if (rc == -1) {
		rc = errno;
		if (rc != ENOENT) {
			printf("FAIL - Error %s (%d) unlinking %s\n",
			       strerror(errno), errno, name);
			return 0;
		}
	}

	sprintf(flags_s, "O_CREAT | O_TRUNC | %s,",
		access == O_RDONLY ? "O_RDONLY" :
		access == O_WRONLY ? "O_WRONLY" :
		access == O_RDWR ? "O_RDWR" :
		"UNKNOWN");

	/* Now do the open and create */
	sprintf(open_s, "CREATE: open(%s, %-29s %03o)",
		name, flags_s, mode);
	fd = open(name, flags, mode);

	if (fd == -1) {
		printf("FAIL - %s - Error %s (%d)\n",
		       open_s,
		       strerror(errno), errno);
		return 0;
	}

	if (access == O_RDONLY)
		goto close_it;

	len = strlen(buffer_w);

	rc = write(fd, buffer_w, len);

	if (rc == -1) {
		printf("FAIL - Error %s (%d) writing %s\n",
		       strerror(errno), errno, name);
		return 0;
	}

	if (access == O_WRONLY)
		goto close_it;

	rc = lseek(fd, 0, SEEK_SET);

	if (rc == -1) {
		printf("FAIL - Error %s (%d) seeking %s\n",
		       strerror(errno), errno, name);
		return 0;
	}

	rc = read(fd, buffer_r, len);

	if (rc == -1) {
		printf("FAIL - Error %s (%d) reading %s\n",
		       strerror(errno), errno, name);
		return 0;
	}

	buffer_r[rc] = '\0';

	if (rc != len) {
		printf("FAIL - Mismatch only read %d bytes from %s = %s\n",
		       rc, name, buffer_r);
	}

close_it:

	rc = close(fd);

	if (rc == -1) {
		printf("FAIL - Error %s (%d) closing %s\n",
		       strerror(errno), errno, name);
		return 0;
	}

	printf("PASS - %s - Success\n",
	       open_s);

	return 1;
}

void test_one(char *base, int mode)
{
	char name[1024];
	int rc;

	sprintf(name, "%s.%03o", base, mode);

	(void) check_create(name, O_RDONLY, mode);
	(void) check_create(name, O_WRONLY, mode);
	rc =   check_create(name, O_RDWR, mode);

	if (rc == 0) {
		printf("FAIL - can't continue with mode %03o\n");
		return;
	}

	/* Now try to open the file in various modes */
	check_one(name, O_RDONLY, S_IRUSR, mode);
	check_one(name, O_WRONLY, S_IWUSR, mode);
	check_one(name, O_RDWR, S_IRUSR | S_IWUSR, mode);
	check_one(name, O_CREAT | O_WRONLY, S_IWUSR, mode);
	check_one(name, O_CREAT | O_RDONLY, S_IRUSR, mode);
	check_one(name, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR, mode);
}

int main(int argc, char **argv)
{
	int i;
	char *name;
	int mode;

	if (argc > 1) {
		name = argv[1];
	} else {
		printf("usage %s {file-name}\n",
		       argv[0]);
		return 1;
	}

	for (i = 0; i <= 7; i++) {
		mode = i * S_IXUSR + i * S_IXGRP + i * S_IXOTH;
		test_one(name, mode);
	}
	return 0;
}

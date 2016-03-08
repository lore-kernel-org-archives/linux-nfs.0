Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:13231 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984AbcCHV4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Mar 2016 16:56:22 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>, <hch@infradead.org>
Subject: [PATCH v3 4/3] vfs_copy_range() test program
Date: Tue, 8 Mar 2016 16:55:58 -0500
Message-ID: <1457474158-16050-5-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1457474158-16050-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a simple C program that I used for calling the copy system call.
Usage:  ./nfscopy /nfs/original.txt /nfs/copy.txt
---
 nfscopy.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)
 create mode 100644 nfscopy.c

diff --git a/nfscopy.c b/nfscopy.c
new file mode 100644
index 0000000..3417a14
--- /dev/null
+++ b/nfscopy.c
@@ -0,0 +1,59 @@
+#define _GNU_SOURCE
+#include <fcntl.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+loff_t copy_file_range(int fd_in, loff_t *off_in, int fd_out,
+		       loff_t *off_out, size_t len, unsigned int flags)
+{
+	return syscall(__NR_copy_file_range, fd_in, off_in, fd_out,
+		       off_out, len, flags);
+}
+
+int main(int argc, char **argv)
+{
+	int fd_in, fd_out;
+	struct stat stat;
+	loff_t len, ret;
+	char buf[2];
+
+	if (argc != 3) {
+		fprintf(stderr, "Usage: %s <source> <destination>\n", argv[0]);
+		exit(EXIT_FAILURE);
+	}
+
+	fd_in = open(argv[1], O_RDONLY);
+	if (fd_in == -1) {
+		perror("open (argv[1])");
+		exit(EXIT_FAILURE);
+	}
+
+	if (fstat(fd_in, &stat) == -1) {
+		perror("fstat");
+		exit(EXIT_FAILURE);
+	}
+	len = stat.st_size;
+
+	fd_out = open(argv[2], O_CREAT|O_WRONLY|O_TRUNC, 0644);
+	if (fd_out == -1) {
+		perror("open (argv[2])");
+		exit(EXIT_FAILURE);
+	}
+
+	do {
+		ret = copy_file_range(fd_in, NULL, fd_out, NULL, len, 0);
+		if (ret == -1) {
+			perror("copy_file_range");
+			exit(EXIT_FAILURE);
+		}
+
+		len -= ret;
+	} while (len > 0);
+
+	close(fd_in);
+	close(fd_out);
+	exit(EXIT_SUCCESS);
+}
-- 
2.7.2


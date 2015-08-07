Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:35114 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946232AbbHGUii (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Aug 2015 16:38:38 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <bfields@fieldses.org>
CC: <Anna.Schumaker@netapp.com>
Subject: [RFC] vfs_copy_range() test program
Date: Fri, 7 Aug 2015 16:38:24 -0400
Message-ID: <1438979904-8775-9-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a simple C program that I used for calling the copy system call.
Usage:  ./nfscopy /nfs/original.txt /nfs/copy.txt
---
 nfscopy.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 64 insertions(+)
 create mode 100644 nfscopy.c

diff --git a/nfscopy.c b/nfscopy.c
new file mode 100644
index 0000000..535673e
--- /dev/null
+++ b/nfscopy.c
@@ -0,0 +1,64 @@
+#include <errno.h>
+#include <fcntl.h>
+#include <limits.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <unistd.h>
+
+#define SYS_COPY_RANGE 323
+
+int do_copy(int f_in, int f_out, loff_t f_size)
+{
+	loff_t offset = 0;
+	ssize_t ret;
+
+	while (offset < f_size) {
+		size_t size = f_size - offset;
+		if ((size + offset) != f_size)
+			size = INT_MAX - 1;
+
+		ret = syscall(SYS_COPY_RANGE, f_in, &offset, f_out, &offset, size, 0);
+		if (ret < 0) {
+			printf("Copy error: %s\n", strerror(errno));
+			return ret;
+		}
+	}
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	int f_in, f_out, ret;
+	struct stat fstat;
+
+	if (argc != 3) {
+		printf("Usage: %s f_in f_out\n", argv[0]);
+		exit(1);
+	}
+
+	f_in = open(argv[1], O_RDONLY);
+	if (f_in < 0) {
+		printf("%s: %s\n", argv[1], strerror(errno));
+		exit(1);
+	}
+
+	if (stat(argv[1], &fstat) < 0) {
+		printf("%s: %s\n", argv[1], strerror(errno));
+		exit(1);
+	}
+
+	f_out = open(argv[2], O_WRONLY | O_CREAT | O_SYNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+	if (f_out < 0) {
+		printf("%s: %s\n", argv[2], strerror(errno));
+		exit(1);
+	}
+
+	ret = do_copy(f_in, f_out, fstat.st_size);
+
+	fsync(f_out);
+	close(f_in);
+	close(f_out);
+	return ret;
+}
-- 
2.5.0


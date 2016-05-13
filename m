Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:7427 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753076AbcEMUu5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:50:57 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <fstests@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <linux-nfs@vger.kernel.org>,
        <hch@infradead.org>
Subject: [PATCH 1/5] src/copy_file_range: Add a program for testing vfs_copy_file_range()
Date: Fri, 13 May 2016 16:50:48 -0400
Message-ID: <1463172652-22361-2-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1463172652-22361-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This will be used by the various copy tests to call the Linux
copy_file_range() system call.  I used src/cloner.c as a reference while
writing this tool.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 .gitignore            |   1 +
 common/rc             |   7 ++
 src/Makefile          |   3 +-
 src/copy_file_range.c | 189 ++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 199 insertions(+), 1 deletion(-)
 create mode 100644 src/copy_file_range.c

diff --git a/.gitignore b/.gitignore
index f9ea1fa..07cb94b 100644
--- a/.gitignore
+++ b/.gitignore
@@ -38,6 +38,7 @@
 /src/bstat
 /src/bulkstat_unlink_test
 /src/bulkstat_unlink_test_modified
+/src/copy_file_range
 /src/dbtest
 /src/devzero
 /src/dirperf
diff --git a/common/rc b/common/rc
index 8bec836..735ff7a 100644
--- a/common/rc
+++ b/common/rc
@@ -2909,6 +2909,13 @@ _require_cloner()
 		_notrun "cloner binary not present at $CLONER_PROG"
 }
 
+_require_copy_file_range()
+{
+	COPY_FILE_RANGE_PROG=$here/src/copy_file_range
+	[ -x $COPY_FILE_RANGE_PROG ] || \
+		_notrun "copy file range binary not present at $COPY_FILE_RANGE_PROG"
+}
+
 _require_atime()
 {
 	if [ "$FSTYP" == "nfs" ]; then
diff --git a/src/Makefile b/src/Makefile
index 1bf318b..b1b5766 100644
--- a/src/Makefile
+++ b/src/Makefile
@@ -20,7 +20,8 @@ LINUX_TARGETS = xfsctl bstat t_mtab getdevicesize preallo_rw_pattern_reader \
 	bulkstat_unlink_test_modified t_dir_offset t_futimens t_immutable \
 	stale_handle pwrite_mmap_blocked t_dir_offset2 seek_sanity_test \
 	seek_copy_test t_readdir_1 t_readdir_2 fsync-tester nsexec cloner \
-	renameat2 t_getcwd e4compact test-nextquota punch-alternating
+	renameat2 t_getcwd e4compact test-nextquota punch-alternating \
+	copy_file_range
 
 SUBDIRS =
 
diff --git a/src/copy_file_range.c b/src/copy_file_range.c
new file mode 100644
index 0000000..067de26
--- /dev/null
+++ b/src/copy_file_range.c
@@ -0,0 +1,189 @@
+/*
+ * Tiny program to perform file range copies using the Linux system call.
+ *
+ *  Copyright (c) 2016 Netapp, Inc. All rights reserved.
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ */
+#include <errno.h>
+#include <fcntl.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+static void
+usage(char *name, const char *msg)
+{
+	printf("Fatal: %s\n"
+	       "Usage:\n"
+	       "%s [options] <src_file> <dest_file>\n"
+	       "\tA full file copy is performed by default, "
+	       "unless any of the following are specified:\n"
+	       "\t-s <offset>:	source file offset (default = 0)\n"
+	       "\t-d <offset>:	destination file offset (default = 0)\n"
+	       "\t-l <length>:	length of copy (default = 0)\n",
+	       msg, name);
+	_exit(1);
+}
+
+static loff_t
+copy_file_range(int src_fd,  loff_t *src_pos, int dst_fd, loff_t *dst_pos,
+		size_t len, unsigned int flags)
+{
+	loff_t ret;
+
+	do {
+		ret = syscall(__NR_copy_file_range, src_fd, src_pos,
+						    dst_fd, dst_pos,
+						    len, flags);
+		if (ret == -1)
+			return errno;
+		len -= ret;
+	} while (len > 0);
+
+	return 0;
+}
+
+static loff_t
+copy_file(int src_fd, int dst_fd, unsigned int flags)
+{
+	struct stat stat;
+	loff_t src_pos = 0;
+	loff_t dst_pos = 0;
+	size_t len;
+	loff_t ret;
+
+	ret = fstat(src_fd, &stat);
+	if (ret == -1) {
+		ret = errno;
+		printf("stat failed: %s\n", strerror(ret));
+		return ret;
+	}
+
+	len = stat.st_size;
+	ret = ftruncate(dst_fd, 0);
+	if (ret == -1) {
+		ret = errno;
+		printf("truncate failed: %s\n", strerror(ret));
+		return ret;
+	}
+
+	return copy_file_range(src_fd, &src_pos, dst_fd, &dst_pos, len, flags);
+}
+
+
+int
+main(int argc, char **argv)
+{
+	char *src_file, *dst_file;
+	bool full_file = true;
+	loff_t src_off = 0;
+	loff_t dst_off = 0;
+	int src_fd, dst_fd;
+	size_t len = 0;
+	int opt, ret;
+
+	while ((opt = getopt(argc, argv, "s:d:l:")) != -1) {
+		char *sval_end;
+		switch (opt) {
+		case 's':
+			errno = 0;
+			src_off = strtoull(optarg, &sval_end, 10);
+			if ((errno) || (*sval_end != '\0'))
+				usage(argv[0], "invalid source offset");
+			full_file = false;
+			break;
+		case 'd':
+			errno = 0;
+			dst_off = strtoull(optarg, &sval_end, 10);
+			if ((errno) || (*sval_end != '\0'))
+				usage(argv[0], "invalid destination offset");
+			full_file = false;
+			break;
+		case 'l':
+			errno = 0;
+			len = strtoul(optarg, &sval_end, 10);
+			if ((errno) || (*sval_end != '\0'))
+				usage(argv[0], "invalid length");
+			full_file = false;
+			break;
+		default:
+			usage(argv[0], "invalid argument");
+		}
+	}
+
+	/* should be exactly two args left */
+	if (optind != argc - 2)
+		usage(argv[0], "src_file and dst_file arguments are mandatory");
+
+	src_file = (char *)strdup(argv[optind++]);
+	if (src_file == NULL) {
+		ret = ENOMEM;
+		printf("no memory\n");
+		goto err_out;
+	}
+	dst_file = (char *)strdup(argv[optind++]);
+	if (dst_file == NULL) {
+		ret = ENOMEM;
+		printf("no memory\n");
+		goto err_src_free;
+	}
+
+	src_fd = open(src_file, O_RDONLY);
+	if (src_fd == -1) {
+		ret = errno;
+		printf("failed to open %s: %s\n", src_file, strerror(errno));
+		goto err_dst_free;
+	}
+	dst_fd = open(dst_file, O_CREAT | O_WRONLY, 0644);
+	if (dst_fd == -1) {
+		ret = errno;
+		printf("failed to open %s: %s\n", dst_file, strerror(errno));
+		goto err_src_close;
+	}
+
+	if (full_file) {
+		ret = copy_file(src_fd, dst_fd, 0);
+	} else {
+		ret = copy_file_range(src_fd, &src_off, dst_fd, &dst_off, len, 0);
+	}
+	if (ret != 0) {
+		printf("copy failed: %s\n", strerror(ret));
+		goto err_dst_close;
+	}
+
+	ret = 0;
+err_dst_close:
+	if (close(dst_fd)) {
+		ret |= errno;
+		printf("failed to close dst file: %s\n", strerror(errno));
+	}
+err_src_close:
+	if (close(src_fd)) {
+		ret |= errno;
+		printf("failed to close src file: %s\n", strerror(errno));
+	}
+err_dst_free:
+	free(dst_file);
+err_src_free:
+	free(src_file);
+err_out:
+	return ret;
+}
-- 
2.8.2


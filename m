Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:49777 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118AbbIKUaq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 16:30:46 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <linux-nfs@vger.kernel.org>, <linux-btrfs@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-api@vger.kernel.org>,
        <zab@zabbo.net>, <viro@zeniv.linux.org.uk>, <clm@fb.com>,
        <darrick.wong@oracle.com>, <mtk.manpages@gmail.com>,
        <andros@netapp.com>, <hch@infradead.org>
Subject: [PATCH v2 10/9] copy_file_range.2: New page documenting copy_file_range()
Date: Fri, 11 Sep 2015 16:30:23 -0400
Message-ID: <1442003423-6884-11-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1442003423-6884-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

copy_file_range() is a new system call for copying ranges of data
completely in the kernel.  This gives filesystems an opportunity to
implement some kind of "copy acceleration", such as reflinks or
server-side-copy (in the case of NFS).

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 man2/copy_file_range.2 | 188 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 188 insertions(+)
 create mode 100644 man2/copy_file_range.2

diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
new file mode 100644
index 0000000..84912b5
--- /dev/null
+++ b/man2/copy_file_range.2
@@ -0,0 +1,188 @@
+.\"This manpage is Copyright (C) 2015 Anna Schumaker <Anna.Schumaker@Netapp.com>
+.TH COPY 2 2015-8-31 "Linux" "Linux Programmer's Manual"
+.SH NAME
+copy_file_range \- Copy a range of data from one file to another
+.SH SYNOPSIS
+.nf
+.B #include <linux/copy.h>
+.B #include <sys/syscall.h>
+.B #include <unistd.h>
+
+.BI "ssize_t syscall(__NR_copy_file_range, int " fd_in ", loff_t * " off_in ",
+.BI "                int " fd_out ", loff_t * " off_out ", size_t " len ",
+.BI "                unsigned int " flags );
+.fi
+.SH DESCRIPTION
+The
+.BR copy_file_range ()
+system call performs an in-kernel copy between two file descriptors
+without all that tedious mucking about in userspace.
+It copies up to
+.I len
+bytes of data from file descriptor
+.I fd_in
+to file descriptor
+.IR fd_out ,
+overwriting any data that exists within the requested range.
+
+The following semantics apply for
+.IR off_in ,
+and similar statements apply to
+.IR off_out :
+.IP * 3
+If
+.I off_in
+is NULL, then bytes are read from
+.I fd_in
+starting from the current file offset and the current
+file offset is adjusted appropriately.
+.IP *
+If
+.I off_in
+is not NULL, then
+.I off_in
+must point to a buffer that specifies the starting
+offset where bytes from
+.I fd_in
+will be read.  The current file offset of
+.I fd_in
+is not changed, but
+.I off_in
+is adjusted appropriately.
+.PP
+
+The
+.I flags
+argument is a bit mask composed by OR-ing together zero
+or more of the following flags:
+.TP 1.9i
+.B COPY_FR_COPY
+Copy all the file data in the requested range.
+Some filesystems, like NFS, might be able to accelerate this copy
+to avoid unnecessary data transfers.
+.TP
+.B COPY_FR_REFLINK
+Create a lightweight "reflink", where data is not copied until
+one of the files is modified.
+.PP
+The default behavior
+.RI ( flags
+== 0) is to try creating a reflink,
+and if reflinking fails
+.BR copy_file_range ()
+will fall back on performing a full data copy.
+This is equivalent to setting
+.I flags
+equal to
+.RB ( COPY_FR_COPY | COPY_FR_REFLINK ).
+.SH RETURN VALUE
+Upon successful completion,
+.BR copy_file_range ()
+will return the number of bytes copied between files.
+This could be less than the length originally requested.
+
+On error,
+.BR copy_file_range ()
+returns \-1 and
+.I errno
+is set to indicate the error.
+.SH ERRORS
+.TP
+.B EBADF
+One or more file descriptors are not valid,
+or do not have proper read-write mode;
+.I fd_in
+is not open for reading; or
+.I fd_out
+is not open for writing.
+.TP
+.B EINVAL
+Requested range extends beyond the end of the file; or the
+.I flags
+argument is set to an invalid value.
+.TP
+.B EIO
+A low level I/O error occurred while copying.
+.TP
+.B ENOMEM
+Out of memory.
+.TP
+.B ENOSPC
+There is not enough space to complete the copy.
+.TP
+.B EOPNOTSUPP
+.B COPY_REFLINK
+was specified in
+.IR flags ,
+but the target filesystem does not support reflinks.
+.TP
+.B EXDEV
+Target filesystem doesn't support cross-filesystem copies.
+.SH VERSIONS
+The
+.BR copy_file_range ()
+system call first appeared in Linux 4.4.
+.SH CONFORMING TO
+The
+.BR copy_file_range ()
+system call is a nonstandard Linux extension.
+.SH EXAMPLE
+.nf
+
+#define _GNU_SOURCE
+#include <fcntl.h>
+#include <linux/copy.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/stat.h>
+#include <sys/syscall.h>
+#include <unistd.h>
+
+
+int main(int argc, char **argv)
+{
+    int fd_in, fd_out;
+    struct stat stat;
+    loff_t len, ret;
+
+    if (argc != 3) {
+        fprintf(stderr, "Usage: %s <source> <destination>\\n", argv[0]);
+        exit(EXIT_FAILURE);
+    }
+
+    fd_in = open(argv[1], O_RDONLY);
+    if (fd_in == -1) {
+        perror("open (argv[1])");
+        exit(EXIT_FAILURE);
+    }
+
+    if (fstat(fd_in, &stat) == -1) {
+        perror("fstat");
+        exit(EXIT_FAILURE);
+    }
+    len = stat.st_size;
+
+    fd_out = creat(argv[2], 0644);
+    if (fd_out == -1) {
+        perror("creat (argv[2])");
+        exit(EXIT_FAILURE);
+    }
+
+    do {
+        ret = syscall(__NR_copy_file_range, fd_in, NULL,
+                      fd_out, NULL, len, 0);
+        if (ret == -1) {
+            perror("copy_file_range");
+            exit(EXIT_FAILURE);
+        }
+
+        len -= ret;
+    } while (len > 0);
+
+    close(fd_in);
+    close(fd_out);
+    exit(EXIT_SUCCESS);
+}
+.fi
+.SH SEE ALSO
+.BR splice (2)
-- 
2.5.1


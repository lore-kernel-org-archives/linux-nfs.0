Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59376 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752483AbdFNPRl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Jun 2017 11:17:41 -0400
Subject: [PATCH 14/27] VFS: Add a sample program for fsopen/fsmount [ver #5]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Date: Wed, 14 Jun 2017 16:17:28 +0100
Message-ID: <149745344797.10897.1483436431670546915.stgit@warthog.procyon.org.uk>
In-Reply-To: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a sample program for driving fsopen/fsmount.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 samples/fsmount/test-fsmount.c |   92 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)
 create mode 100644 samples/fsmount/test-fsmount.c

diff --git a/samples/fsmount/test-fsmount.c b/samples/fsmount/test-fsmount.c
new file mode 100644
index 000000000000..30caad8e05a3
--- /dev/null
+++ b/samples/fsmount/test-fsmount.c
@@ -0,0 +1,92 @@
+/* fd-based mount test.
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <fcntl.h>
+#include <sys/prctl.h>
+#include <sys/wait.h>
+
+#define PR_ERRMSG_ENABLE		48
+#define PR_ERRMSG_READ			49
+
+#define E(x) do { if ((x) == -1) { perror(#x); exit(1); } } while(0)
+
+static __attribute__((noreturn))
+void mount_error(int fd, const char *s)
+{
+	char buf[4096];
+	int err, n, perr;
+
+	do {
+		err = errno;
+		errno = 0;
+		n = prctl(PR_ERRMSG_READ, buf, sizeof(buf));
+		perr = errno;
+		errno = err;
+		if (n > 0) {
+			fprintf(stderr, "Error: '%s': %*.*s: %m\n", s, n, n, buf);
+		} else {
+			fprintf(stderr, "%s: %m\n", s);
+		}
+	} while (perr == 0);
+	exit(1);
+}
+
+#define E_write(fd, s)							\
+	do {								\
+		if (write(fd, s, sizeof(s) - 1) == -1)			\
+			mount_error(fd, s);				\
+	} while (0)
+
+static inline int fsopen(const char *fs_name, int reserved, int flags)
+{
+	return syscall(333, fs_name, reserved, flags);
+}
+
+static inline int fsmount(int fsfd, int dfd, const char *path,
+			  unsigned int at_flags, unsigned int flags)
+{
+	return syscall(334, fsfd, dfd, path, at_flags, flags);
+}
+
+int main()
+{
+	int mfd;
+
+	if (prctl(PR_ERRMSG_ENABLE, 1) < 0) {
+		perror("prctl/en");
+		exit(1);
+	}
+
+	/* Mount an NFS filesystem */
+	mfd = fsopen("nfs4", -1, 0);
+	if (mfd == -1) {
+		perror("fsopen");
+		exit(1);
+	}
+
+	E_write(mfd, "s warthog:/data");
+	E_write(mfd, "o fsc");
+	E_write(mfd, "o sync");
+	E_write(mfd, "o intr");
+	E_write(mfd, "o vers=4.2");
+	E_write(mfd, "o addr=90.155.74.18");
+	E_write(mfd, "o clientaddr=90.155.74.21");
+	E_write(mfd, "x create");
+	if (fsmount(mfd, AT_FDCWD, "/mnt", 0, 0) < 0)
+		mount_error(mfd, "fsmount");
+	E(close(mfd));
+
+	exit(0);
+}


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8184 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752268AbdJFPuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 6 Oct 2017 11:50:07 -0400
Subject: [PATCH 07/14] VFS: Add a sample program for fsopen/fsmount [ver #6]
From: David Howells <dhowells@redhat.com>
To: viro@ZenIV.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Fri, 06 Oct 2017 16:50:00 +0100
Message-ID: <150730500019.6182.15975727444128962384.stgit@warthog.procyon.org.uk>
In-Reply-To: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
References: <150730494491.6182.5139368907374172391.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a sample program for driving fsopen/fsmount.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 samples/fsmount/test-fsmount.c |   94 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 94 insertions(+)
 create mode 100644 samples/fsmount/test-fsmount.c

diff --git a/samples/fsmount/test-fsmount.c b/samples/fsmount/test-fsmount.c
new file mode 100644
index 000000000000..75f91d272a19
--- /dev/null
+++ b/samples/fsmount/test-fsmount.c
@@ -0,0 +1,94 @@
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
+static inline int fsopen(const char *fs_name, int flags,
+			 void *reserved3, void *reserved4, void *reserved5);
+
+{
+	return syscall(333, fs_name, flags, reserved3, reserved4, reserved5);
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
+	mfd = fsopen("nfs4", 0, NULL, NULL, NULL);
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


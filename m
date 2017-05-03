Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49062 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752516AbdECQFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 12:05:31 -0400
Subject: [PATCH 6/9] Sample program for driving fsopen/fsmount
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, dhowells@redhat.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Wed, 03 May 2017 17:05:24 +0100
Message-ID: <149382752396.30481.8468912363685051016.stgit@warthog.procyon.org.uk>
In-Reply-To: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---

 samples/fsmount/test-fsmount.c |   79 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 79 insertions(+)
 create mode 100644 samples/fsmount/test-fsmount.c

diff --git a/samples/fsmount/test-fsmount.c b/samples/fsmount/test-fsmount.c
new file mode 100644
index 000000000000..715617f86000
--- /dev/null
+++ b/samples/fsmount/test-fsmount.c
@@ -0,0 +1,79 @@
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
+#include <sys/wait.h>
+
+#define E(x) do { if ((x) == -1) { perror(#x); exit(1); } } while(0)
+
+static __attribute__((noreturn))
+void mount_error(int fd, const char *s)
+{
+	char buf[4096];
+	int err, n;
+
+	err = errno;
+	n = read(fd, buf, sizeof(buf));
+	errno = err;
+	if (n > 0) {
+		n -= 2;
+		fprintf(stderr, "Error: '%s': %*.*s: %m\n", s, n, n, buf + 2);
+	} else {
+		fprintf(stderr, "%s: %m\n", s);
+	}
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
+static inline int fsmount(int fsfd, int dfd, const char *path)
+{
+	return syscall(334, fsfd, dfd, path);
+}
+
+int main()
+{
+	int mfd;
+
+	/* Mount an NFS filesystem */
+	mfd = fsopen("nfs4", -1, 0);
+	if (mfd == -1) {
+		perror("fsopen");
+		exit(1);
+	}
+
+	E_write(mfd, "d warthog:/data");
+	E_write(mfd, "o fsc");
+	E_write(mfd, "o sync");
+	E_write(mfd, "o intr");
+	E_write(mfd, "o vers=4.2");
+	E_write(mfd, "o addr=90.155.74.18");
+	E_write(mfd, "o clientaddr=90.155.74.21");
+	//E_write(mfd, "r /data");
+	if (fsmount(mfd, AT_FDCWD, "/mnt") < 0)
+		mount_error(mfd, "fsmount");
+	E(close(mfd));
+
+	exit(0);
+}


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50132 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935713AbdEVQXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:23:43 -0400
Subject: [PATCH 9/9] Sample program for driving container objects
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:23:40 +0100
Message-ID: <149547022026.10599.11739060904213051113.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


---

 samples/containers/test-container.c |  162 +++++++++++++++++++++++++++++++++++
 1 file changed, 162 insertions(+)
 create mode 100644 samples/containers/test-container.c

diff --git a/samples/containers/test-container.c b/samples/containers/test-container.c
new file mode 100644
index 000000000000..c467b447c63d
--- /dev/null
+++ b/samples/containers/test-container.c
@@ -0,0 +1,162 @@
+/* Container test.
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
+#include <sys/wait.h>
+#include <sys/prctl.h>
+
+#define PR_ERRMSG_ENABLE		48
+#define PR_ERRMSG_READ			49
+
+#define E(x) do { if ((x) == -1) { perror(#x); exit(1); } } while(0)
+
+static __attribute__((noreturn))
+void display_error(const char *s)
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
+
+	exit(1);
+}
+
+#define E_write(fd, s)							\
+	do {								\
+		if (write(fd, s, sizeof(s) - 1) == -1)			\
+			display_error(s);				\
+	} while (0)
+
+#define CONTAINER_NEW_FS_NS		0x00000001 /* Dup current fs namespace */
+#define CONTAINER_NEW_EMPTY_FS_NS	0x00000002 /* Provide new empty fs namespace */
+#define CONTAINER_NEW_CGROUP_NS		0x00000004 /* Dup current cgroup namespace [priv] */
+#define CONTAINER_NEW_UTS_NS		0x00000008 /* Dup current uts namespace */
+#define CONTAINER_NEW_IPC_NS		0x00000010 /* Dup current ipc namespace */
+#define CONTAINER_NEW_USER_NS		0x00000020 /* Dup current user namespace */
+#define CONTAINER_NEW_PID_NS		0x00000040 /* Dup current pid namespace */
+#define CONTAINER_NEW_NET_NS		0x00000080 /* Dup current net namespace */
+#define CONTAINER_KILL_ON_CLOSE		0x00000100 /* Kill all member processes when fd closed */
+#define CONTAINER_FD_CLOEXEC		0x00000200 /* Close the fd on exec */
+#define CONTAINER__FLAG_MASK		0x000003ff
+
+#define AT_FSMOUNT_CONTAINER_ROOT	0x2000
+
+static inline int fsopen(const char *fs_name, int containerfd, int flags)
+{
+	return syscall(333, fs_name, containerfd, flags);
+}
+
+static inline int fsmount(int fsfd, int dfd, const char *path,
+			  unsigned int at_flags, unsigned int flags)
+{
+	return syscall(334, fsfd, dfd, path, at_flags, flags);
+}
+
+static inline int container_create(const char *name, unsigned int mask)
+{
+	return syscall(335, name, mask, 0, 0, 0);
+}
+
+static inline int fork_into_container(int containerfd)
+{
+	return syscall(336, containerfd);
+}
+
+int main()
+{
+	pid_t pid;
+	int mfd, cfd, ws;
+
+	if (prctl(PR_ERRMSG_ENABLE, 1) < 0) {
+		perror("prctl/en");
+		exit(1);
+	}
+
+	cfd = container_create("foo-test",
+			       CONTAINER_NEW_EMPTY_FS_NS |
+			       CONTAINER_NEW_UTS_NS |
+			       CONTAINER_NEW_IPC_NS |
+			       CONTAINER_NEW_USER_NS |
+			       CONTAINER_NEW_PID_NS |
+			       CONTAINER_KILL_ON_CLOSE |
+			       CONTAINER_FD_CLOEXEC);
+	if (cfd == -1) {
+		perror("container_create");
+		exit(1);
+	}
+
+	system("cat /proc/containers");
+
+	/* Open the filesystem that's going to form the container root. */
+	mfd = fsopen("nfs4", cfd, 0);
+	if (mfd == -1) {
+		perror("fsopen/root");
+		exit(1);
+	}
+
+	E_write(mfd, "s foo:/bar");
+	E_write(mfd, "o fsc");
+	E_write(mfd, "o sync");
+	E_write(mfd, "o intr");
+	E_write(mfd, "o vers=4.2");
+	E_write(mfd, "o addr=192.168.1.1");
+	E_write(mfd, "o clientaddr=192.168.1.1");
+	E_write(mfd, "x create");
+
+	/* Mount the container root */
+	if (fsmount(mfd, cfd, "/", AT_FSMOUNT_CONTAINER_ROOT, 0) < 0)
+		display_error("fsmount");
+	E(close(mfd));
+
+	/* Mount procfs within the container */
+	mfd = fsopen("proc", cfd, 0);
+	if (mfd == -1) {
+		perror("fsopen/proc");
+		exit(1);
+	}
+	E_write(mfd, "x create");
+	if (fsmount(mfd, cfd, "proc", 0, 0) < 0)
+		display_error("fsmount");
+	E(close(mfd));
+
+	switch ((pid = fork_into_container(cfd))) {
+	case -1:
+		perror("fork_into_container");
+		exit(1);
+	case 0:
+		close(cfd);
+		setenv("PS1", "container>", 1);
+		execl("/bin/bash", "bash", NULL);
+		perror("execl");
+		exit(1);
+	default:
+		if (waitpid(pid, &ws, 0) < 0) {
+			perror("waitpid");
+			exit(1);
+		}
+	}
+	E(close(cfd));
+	exit(0);
+}


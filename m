Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39248 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754343AbcHSCEK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Aug 2016 22:04:10 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 19 Aug 2016 11:45:56 +1000
Subject: [PATCH 1/2] systemd: improve ordering between nfs-server and
 various mounts
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Message-ID: <147157115637.26568.2867884353016441810.stgit@noble>
In-Reply-To: <147157095612.26568.14161646901346011334.stgit@noble>
References: <147157095612.26568.14161646901346011334.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit: 1e41488f428c ("systemd: Order NFS server before client")

added an ordering dependency between network mounts and nfs-server.
This is good for loop-back NFS mounts as it ensures the server
will remain until after the mountpoint is unmounted.

However is is bad for _net mounts (such as those via iSCSI) which
are being NFS exported.

nfs-server needs to be start *after* exported filesystems are mounted,
and *before* NFS filesystems are mounted.  systemd isn't able to make
this distinction natively, so we need to help it.

This patch adds a systemd generator which creates a drop-in for
nfs-server.services so that it is started "After" any "nfs" or "nfs4"
mount, and so that it has a "RequiresMountsFor" dependency on any
exported filesystem.  This creates the required ordering.

Note that if you try to export an "nfs" mount, systemd will detect an
ordering loop and will refused to start the nfs server.  This is
probably the correct thing to do.

This patch also removes the ordering dependency with
remote-fs-pre.target which the above-mentioned commit added.  It is no
longer needed.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 systemd/Makefile.am            |    8 ++
 systemd/nfs-server-generator.c |  144 ++++++++++++++++++++++++++++++++++++++++
 systemd/nfs-server.service     |    3 -
 3 files changed, 152 insertions(+), 3 deletions(-)
 create mode 100644 systemd/nfs-server-generator.c

diff --git a/systemd/Makefile.am b/systemd/Makefile.am
index 03f96e93dccf..49c9b8d3b459 100644
--- a/systemd/Makefile.am
+++ b/systemd/Makefile.am
@@ -39,8 +39,16 @@ endif
 EXTRA_DIST = $(unit_files)
 
 unit_dir = /usr/lib/systemd/system
+generator_dir = /usr/lib/systemd/system-generators
+
+EXTRA_PROGRAMS	= nfs-server-generator
+genexecdir = $(generator_dir)
+nfs_server_generator_LDADD = ../support/export/libexport.a \
+			     ../support/nfs/libnfs.a \
+			     ../support/misc/libmisc.a
 
 if INSTALL_SYSTEMD
+genexec_PROGRAMS = nfs-server-generator
 install-data-hook: $(unit_files)
 	mkdir -p $(DESTDIR)/$(unitdir)
 	cp $(unit_files) $(DESTDIR)/$(unitdir)
diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
new file mode 100644
index 000000000000..af8bb52bfbd7
--- /dev/null
+++ b/systemd/nfs-server-generator.c
@@ -0,0 +1,144 @@
+/*
+ * nfs-server-generator:
+ *   systemd generator to create ordering dependencies between
+ *   nfs-server and various filesystem mounts
+ *
+ * 1/ nfs-server should start Before any 'nfs' mountpoints are
+ *    mounted, in case they are loop-back mounts.  This ordering is particularly
+ *    important for the shutdown side, so the nfs-server is stopped
+ *    after the filesystems are unmounted.
+ * 2/ nfs-server should start After all exported filesystems are mounted
+ *    so there is no risk of exporting the underlying directory.
+ *    This is particularly important for _net mounts which
+ *    are not caught by "local-fs.target".
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <string.h>
+#include <ctype.h>
+#include <stdio.h>
+#include <mntent.h>
+
+#include "misc.h"
+#include "nfslib.h"
+#include "exportfs.h"
+
+/* A simple "set of strings" to remove duplicates
+ * found in /etc/exports
+ */
+struct list {
+	struct list *next;
+	char *name;
+};
+static int is_unique(struct list **lp, char *path)
+{
+	struct list *l = *lp;
+
+	while (l) {
+		if (strcmp(l->name, path) == 0)
+			return 0;
+		l = l->next;
+	}
+	l = malloc(sizeof(*l));
+	l->name = path;
+	l->next = *lp;
+	*lp = l;
+	return 1;
+}
+
+/* We need to convert a path name to a systemd unit
+ * name.  This requires some translation ('/' -> '-')
+ * and some escaping.
+ */
+static void systemd_escape(FILE *f, char *path)
+{
+	while (*path == '/')
+		path++;
+	if (!*path) {
+		/* "/" becomes "-", otherwise leading "/" is ignored */
+		fputs("-", f);
+		return;
+	}
+	while (*path) {
+		char c = *path++;
+
+		if (c == '/') {
+			/* multiple non-trailing slashes become '-' */
+			while (*path == '/')
+				path++;
+			if (*path)
+				fputs("-", f);
+		} else if (isalnum(c) || c == ':' || c == '.')
+			fputc(c, f);
+		else
+			fprintf(f, "\\x%02x", c & 0xff);
+	}
+}
+
+int main(int argc, char *argv[])
+{
+	char		*path;
+	char		dirbase[] = "/nfs-server.service.d";
+	char		filebase[] = "/order-with-mounts.conf";
+	nfs_export	*exp;
+	int		i;
+	struct list	*list = NULL;
+	FILE		*f, *fstab;
+	struct mntent	*mnt;
+
+	if (argc != 4 || argv[1][0] != '/') {
+		fprintf(stderr, "nfs-server-generator: create systemd dependencies for nfs-server\n");
+		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
+		exit(1);
+	}
+
+	path = malloc(strlen(argv[1]) + sizeof(dirbase) + sizeof(filebase));
+	if (!path)
+		exit(2);
+	if (export_read(_PATH_EXPORTS) +
+	    export_d_read(_PATH_EXPORTS_D) == 0)
+		/* Nothing is exported, so nothing to do */
+		exit(0);
+
+	strcat(strcpy(path, argv[1]), dirbase);
+	mkdir(path, 0755);
+	strcat(path, filebase);
+	f = fopen(path, "w");
+	if (!f)
+		return 1;
+	fprintf(f, "# Automatically generated by nfs-server-generator\n\n[Unit]\n");
+
+	for (i = 0; i < MCL_MAXTYPES; i++) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
+			if (!is_unique(&list, exp->m_export.e_path))
+				continue;
+			if (strchr(exp->m_export.e_path, ' '))
+				fprintf(f, "RequiresMountsFor=\"%s\"\n",
+					exp->m_export.e_path);
+			else
+				fprintf(f, "RequiresMountsFor=%s\n",
+					exp->m_export.e_path);
+		}
+	}
+
+	fstab = setmntent("/etc/fstab", "r");
+	while ((mnt = getmntent(fstab)) != NULL) {
+		if (strcmp(mnt->mnt_type, "nfs") != 0 &&
+		    strcmp(mnt->mnt_type, "nfs4") != 0)
+			continue;
+		fprintf(f, "Before= ");
+		systemd_escape(f, mnt->mnt_dir);
+		fprintf(f, ".mount\n");
+	}
+
+	fclose(f);
+
+	exit(0);
+}
diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 2ccdc6344cd5..196c81849ff4 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -16,9 +16,6 @@ Before= rpc-statd-notify.service
 Wants=auth-rpcgss-module.service
 After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
 
-# start/stop server before/after client
-Before=remote-fs-pre.target
-
 Wants=nfs-config.service
 After=nfs-config.service
 



Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:38170 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab0JKAGZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 10 Oct 2010 20:06:25 -0400
Received: by mail-iw0-f174.google.com with SMTP id 6so2668490iwn.19
        for <linux-nfs@vger.kernel.org>; Sun, 10 Oct 2010 17:06:24 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/15] umount.nfs: Distinguish between nfs4 and nfs mounts
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Sun, 10 Oct 2010 20:06:20 -0400
Message-ID: <20101011000620.6667.79025.stgit@ellison.1015granger.net>
In-Reply-To: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Neil Brown reports that umount.nfs is still confused by "-t nfs -o
vers=4" mounts.

/etc/mtab can be confused.  /proc/mounts is authoritative on the
fstype of a mount.  Have umount.nfs consult it to determine which
mechanism to use for unmounting.  The code to read /proc/mounts was
lifted from the nfsstat command.

The code introduced by this patch may look like belt-n-suspenders, but
we have two use cases to consider:

  1.  Old kernels don't support the "vers=4" mount option, so
      umount.nfs must look for the "nfs4" fstype
  2.  Upcoming kernels may eliminate support the "nfs4" fstype, so
      umount.nfs must look for the "vers=4" mount option

Thus this logic checks for "nfs4" first then looks for the NFS version
setting.

Note that we could handle unmounting entirely in the kernel, but that
won't help older kernels that have this issue.

See:
  https://bugzilla.linux-nfs.org/show_bug.cgi?id=189

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfsumount.c |  111 ++++++++++++++++++++++++++++++++++++++++++++---
 1 files changed, 104 insertions(+), 7 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index b1927de..02d40ff 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -38,6 +38,9 @@
 #include "parse_opt.h"
 #include "parse_dev.h"
 
+#define MOUNTSFILE	"/proc/mounts"
+#define LINELEN		(4096)
+
 #if !defined(MNT_FORCE)
 /* dare not try to include <linux/mount.h> -- lots of errors */
 #define MNT_FORCE 1
@@ -242,6 +245,91 @@ static int nfs_umount23(const char *devname, char *string)
 	return result;
 }
 
+/*
+ * Detect NFSv4 mounts.
+ *
+ * Consult /proc/mounts to determine if the mount point
+ * is an NFSv4 mount.  The kernel is authoritative about
+ * what type of mount this is.
+ *
+ * Returns 1 if "mc" is an NFSv4 mount, zero if not, and
+ * -1 if some error occurred.
+ */
+static int nfs_umount_is_vers4(const struct mntentchn *mc)
+{
+	char buffer[LINELEN], *next;
+	int retval;
+	FILE *f;
+
+	if ((f = fopen(MOUNTSFILE, "r")) == NULL) {
+		fprintf(stderr, "%s: %s\n",
+			MOUNTSFILE, strerror(errno));
+		return -1;
+	}
+
+	retval = -1;
+	while (fgets(buffer, sizeof(buffer), f) != NULL) {
+		char *device, *mntdir, *type, *flags;
+		struct mount_options *options;
+		char *line = buffer;
+
+		next = strchr(line, '\n');
+		if (next != NULL)
+			*next = '\0';
+
+		device = strtok(line, " \t");
+		if (device == NULL)
+			continue;
+		mntdir = strtok(NULL, " \t");
+		if (mntdir == NULL)
+			continue;
+		if (strcmp(device, mc->m.mnt_fsname) != 0 &&
+		    strcmp(mntdir, mc->m.mnt_dir) != 0)
+			continue;
+
+		type = strtok(NULL, " \t");
+		if (type == NULL)
+			continue;
+		if (strcmp(type, "nfs4") == 0)
+			goto out_nfs4;
+
+		flags = strtok(NULL, " \t");
+		if (flags == NULL)
+			continue;
+		options = po_split(flags);
+		if (options != NULL) {
+			unsigned long version;
+			int rc;
+
+			rc = nfs_nfs_version(options, &version);
+			po_destroy(options);
+			if (rc && version == 4)
+				goto out_nfs4;
+		}
+
+		goto out_nfs;
+	}
+	if (retval == -1)
+		fprintf(stderr, "%s was not found in %s\n",
+			mc->m.mnt_dir, MOUNTSFILE);
+
+out:
+	fclose(f);
+	return retval;
+
+out_nfs4:
+	if (verbose)
+		fprintf(stderr, "NFSv4 mount point detected\n");
+	retval = 1;
+	goto out;
+
+out_nfs:
+	if (verbose)
+		fprintf(stderr, "Legacy NFS mount point detected\n");
+	retval = 0;
+	goto out;
+}
+
 static struct option umount_longopts[] =
 {
   { "force", 0, 0, 'f' },
@@ -365,13 +453,22 @@ int nfsumount(int argc, char *argv[])
 
 	ret = EX_SUCCESS;
 	if (mc) {
-		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
-			/* We ignore the error from nfs_umount23.
-			 * If the actual umount succeeds (in del_mtab),
-			 * we don't want to signal an error, as that
-			 * could cause /sbin/mount to retry!
-			 */
-			nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+		if (!lazy) {
+			switch (nfs_umount_is_vers4(mc)) {
+			case 0:
+				/* We ignore the error from nfs_umount23.
+				 * If the actual umount succeeds (in del_mtab),
+				 * we don't want to signal an error, as that
+				 * could cause /sbin/mount to retry!
+				 */
+				nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+				break;
+			case 1:
+				break;
+			default:
+				return EX_FAIL;
+			}
+		}
 		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)


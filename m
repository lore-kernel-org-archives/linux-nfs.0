Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758107Ab2CFBlG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 20:41:06 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q261f65d030144
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 20:41:06 -0500
Received: from badhat.bos.devel.redhat.com (vpn-9-158.rdu.redhat.com [10.11.9.158])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q261f5nP001760
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 20:41:06 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 1/1] umount.nfs: normalize path names during umounts.
Date: Mon,  5 Mar 2012 20:41:08 -0500
Message-Id: <1330998068-23492-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So path names are found during umounts, normalize
path names by removing any extra slashes and add
a lead slash if one does not exist.

This normalization only has to occur when the mtab
and /proc/mounts are not the same file.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mount/nfsumount.c |   65 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 63 insertions(+), 2 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 3538d88..a2f3cdf 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -140,6 +140,52 @@ static int del_mtab(const char *spec, const char *node)
 }
 
 /*
+ * To ensure the path is found during unmounts, strip
+ * off the multiple '/' or add a '/' if one does not exist.
+ */
+static inline char *
+normalize_path(char *spec) 
+{
+	char *colen, *ptr, *str, *dev;
+
+	if ((colen = strchr(spec, ':')) == NULL)
+		return NULL;
+
+	if (*(colen + 1) != '/') {
+		dev = str = malloc(strlen(spec) + 2);
+		if (dev == NULL) 
+			return NULL;
+
+		ptr = spec;
+		while (ptr <= colen)
+			*(str++) = *(ptr++);
+		*str++='/';
+		while (*ptr)
+			*(str++) = *(ptr++);
+		*str='\0';
+
+		return dev;
+	}
+
+	if (strstr(spec, "//") != NULL) {
+		dev = strdup(spec);
+		if (dev == NULL)
+			return NULL;
+
+		colen = strchr(dev, ':');
+		ptr = (colen +1);
+		while (*ptr && *(ptr+1) == '/')
+			ptr++;
+		while (*ptr)
+			*(++colen) = *(ptr++);
+		*(colen+1) = '\0';
+
+		return dev;
+	} 
+	return NULL;
+}
+
+/*
  * Detect NFSv4 mounts.
  *
  * Consult /proc/mounts to determine if the mount point
@@ -154,12 +200,20 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
 	struct mntentchn *pmc;
 	struct mount_options *options;
 	int retval;
+	char *normpath=NULL;
 
 	retval = -1;
 	pmc = getprocmntdirbackward(mc->m.mnt_dir, NULL);
 	if (!pmc)
 		goto not_found;
 
+	/*
+	 * When the mtab and /proc/mounts are not the same
+	 * file, normalize the path in the mtab if needed.
+	 */
+	if (mtab_is_writable())
+		normpath = normalize_path(mc->m.mnt_fsname);
+
 	do {
 		size_t nlen = strlen(pmc->m.mnt_fsname);
 
@@ -171,8 +225,14 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
 		 */
 		while (pmc->m.mnt_fsname[nlen - 1] == '/')
 			nlen--;
-		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
-			continue;
+
+		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0) {
+			/* Is there a normalized path, if so compare that one too */
+			if (normpath == NULL)
+				continue;
+			if (strncmp(pmc->m.mnt_fsname, normpath, nlen) != 0)
+				continue;
+		}
 
 		if (strcmp(pmc->m.mnt_type, "nfs4") == 0)
 			goto out_nfs4;
@@ -209,6 +269,7 @@ out_nfs:
 	retval = 0;
 
 out:
+	free(normpath);
 	return retval;
 }
 
-- 
1.7.1


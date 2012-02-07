Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e37.co.us.ibm.com ([32.97.110.158]:39663 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab2BGUoG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2012 15:44:06 -0500
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Tue, 7 Feb 2012 13:44:05 -0700
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C6445C90056
	for <linux-nfs@vger.kernel.org>; Tue,  7 Feb 2012 15:44:02 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q17Ki2Am276516
	for <linux-nfs@vger.kernel.org>; Tue, 7 Feb 2012 15:44:02 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q17Ki20x000332
	for <linux-nfs@vger.kernel.org>; Tue, 7 Feb 2012 18:44:02 -0200
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q17Ki2n3032767
	for <linux-nfs@vger.kernel.org>; Tue, 7 Feb 2012 18:44:02 -0200
Date: Tue, 7 Feb 2012 14:44:01 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] Get normalized paths for comparing NFS export paths
Message-ID: <20120207204401.GA31752@us.ibm.com>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
 <4F2BC1C0.8070900@panasas.com>
 <20120203231623.442fefde@notabene.brown>
 <20120203142945.GA31805@us.ibm.com>
 <4F2E620F.5090100@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F2E620F.5090100@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 gladly accepts and mounts "hostname:path" instead of
"hostname:/path". NFS also accepts other forms for pathname, but it
doesn't use the exact pathname string used for generating /proc/mounts.
This causes mount entry mistmatch between /etc/mtab and /proc/mounts
files. The former will have the exact given pathname string but the
latter will have a modified path name.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 utils/mount/nfsumount.c |   94 +++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 83 insertions(+), 11 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 3538d88..54542a5 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -139,6 +139,88 @@ static int del_mtab(const char *spec, const char *node)
 	return EX_FILEIO;
 }
 
+/* 
+ * Return normalized path.
+ *
+ * Resolve "." and ".." components. Replace multiple slashes with one
+ * slash. realpath is close but doesn't work for us as the path won't
+ * exist on the client.
+ *
+ * The return string must be freed by the caller.
+ */
+static char *normpath(const char *path)
+{
+	const char *ptr, *next, *end;
+	char *norm; /* result */
+
+	if (!path)
+		return NULL;
+
+	norm = malloc(strlen(path)+1);
+	if (!norm)
+		return NULL;
+		
+	end = path+strlen(path);
+	*norm = '\0'; /* Make it a NULL string */
+	for (ptr = path; ptr < end; ptr = next+1) {
+		next = strchr(ptr, '/');
+		if (!next)
+			next = end;
+		int pclen = next - ptr; /* path component length */
+		if (strncmp(ptr, ".", pclen) == 0)
+			continue;
+		if (strncmp(ptr, "..", pclen) == 0) {
+			char *tmp = strrchr(norm, '/');
+			if (tmp)
+				*tmp = '\0';
+			continue;
+		}
+
+		/* Add the new component */
+		strncat(norm, "/", 1);
+		strncat(norm, ptr, pclen);
+	}
+
+	/*
+	 * If there was no component to copy, norm would be null.
+	 * Return "/" in that case
+	 */
+	if (*norm == '\0')
+		strcpy(norm, "/");
+
+	return norm;
+}
+
+/*
+ * Detect if the given two entries refer to the same mount entry.
+ * Usually one entry is from /etc/mtab and the other is from
+ * /proc/mounts.
+ */
+static int nfs_same_mount_entry(const struct mntentchn *mc1,
+				const struct mntentchn *mc2)
+{
+	char *host1, *host2;
+	char *path1, *path2;
+	char *norm1, *norm2;
+	int retval;
+
+	nfs_parse_devname(mc1->m.mnt_fsname, &host1, &path1);
+	nfs_parse_devname(mc2->m.mnt_fsname, &host2, &path2);
+	norm1 = normpath(path1);
+	norm2 = normpath(path2);
+
+	retval = strcmp(host1, host2) == 0 && strcmp(norm1, norm2) == 0;
+
+	free(host1);
+	free(host2);
+	free(path1);
+	free(path2);
+	free(norm1);
+	free(norm2);
+
+	return retval;
+}
+
 /*
  * Detect NFSv4 mounts.
  *
@@ -161,17 +243,7 @@ static int nfs_umount_is_vers4(const struct mntentchn *mc)
 		goto not_found;
 
 	do {
-		size_t nlen = strlen(pmc->m.mnt_fsname);
-
-		/*
-		 * It's possible the mount location string in /proc/mounts
-		 * ends with a '/'. In this case, if the entry came from
-		 * /etc/mtab, it won't have the trailing '/' so deal with
-		 * it.
-		 */
-		while (pmc->m.mnt_fsname[nlen - 1] == '/')
-			nlen--;
-		if (strncmp(pmc->m.mnt_fsname, mc->m.mnt_fsname, nlen) != 0)
+		if (!nfs_same_mount_entry(pmc, mc))
 			continue;
 
 		if (strcmp(pmc->m.mnt_type, "nfs4") == 0)
-- 
1.7.8.3


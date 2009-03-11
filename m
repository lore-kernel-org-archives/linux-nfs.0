From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 2/9] NFS: Fix misparsing of nfsv4 fs_locations attribute
 (take 2)
Date: Wed, 11 Mar 2009 14:25:25 -0400
Message-ID: <20090311182525.403.55308.stgit@heimdal.trondhjem.org>
References: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755384AbZCKS3v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:51 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIThEw008166
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:29:49 -0700 (PDT)
In-Reply-To: <20090311182525.403.42026.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The changeset ea31a4437c59219bf3ea946d58984b01a45a289c (nfs: Fix
misparsing of nfsv4 fs_locations attribute) causes the mountpath that is
calculated at the beginning of try_location() to be clobbered when we
later strncpy a non-nul terminated hostname using an incorrect buffer
length.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4namespace.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)


diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index 30befc3..2a2a0a7 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -21,7 +21,9 @@
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
 /*
- * Check if fs_root is valid
+ * Convert the NFSv4 pathname components into a standard posix path.
+ *
+ * Note that the resulting string will be placed at the end of the buffer
  */
 static inline char *nfs4_pathname_string(const struct nfs4_pathname *pathname,
 					 char *buffer, ssize_t buflen)
@@ -99,21 +101,20 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 {
 	struct vfsmount *mnt = ERR_PTR(-ENOENT);
 	char *mnt_path;
-	int page2len;
+	unsigned int maxbuflen;
 	unsigned int s;
 
 	mnt_path = nfs4_pathname_string(&location->rootpath, page2, PAGE_SIZE);
 	if (IS_ERR(mnt_path))
 		return mnt;
 	mountdata->mnt_path = mnt_path;
-	page2 += strlen(mnt_path) + 1;
-	page2len = PAGE_SIZE - strlen(mnt_path) - 1;
+	maxbuflen = mnt_path - 1 - page2;
 
 	for (s = 0; s < location->nservers; s++) {
 		const struct nfs4_string *buf = &location->servers[s];
 		struct sockaddr_storage addr;
 
-		if (buf->len <= 0 || buf->len >= PAGE_SIZE)
+		if (buf->len <= 0 || buf->len >= maxbuflen)
 			continue;
 
 		mountdata->addr = (struct sockaddr *)&addr;
@@ -126,8 +127,8 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 			continue;
 		nfs_set_port(mountdata->addr, NFS_PORT);
 
-		strncpy(page2, buf->data, page2len);
-		page2[page2len] = '\0';
+		memcpy(page2, buf->data, buf->len);
+		page2[buf->len] = '\0';
 		mountdata->hostname = page2;
 
 		snprintf(page, PAGE_SIZE, "%s:%s",


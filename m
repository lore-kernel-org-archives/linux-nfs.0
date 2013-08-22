Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:10864 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752864Ab3HVA0b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Aug 2013 20:26:31 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/6] NFS: Clean up nfs_sillyrename()
Date: Wed, 21 Aug 2013 20:26:26 -0400
Message-ID: <1377131186-40249-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1377131186-40249-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1377131186-40249-1-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-2-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-3-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-4-git-send-email-Trond.Myklebust@netapp.com>
 <1377131186-40249-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Optimise for the case where we only do one lookup.
Clean up the code so it is obvious that silly[] is not a dynamic array.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/unlink.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 60395ad..488fd16 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -444,6 +444,14 @@ nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
 	return rpc_run_task(&task_setup_data);
 }
 
+#define SILLYNAME_PREFIX ".nfs"
+#define SILLYNAME_PREFIX_LEN ((unsigned)sizeof(SILLYNAME_PREFIX) - 1)
+#define SILLYNAME_FILEID_LEN ((unsigned)sizeof(u64) << 1)
+#define SILLYNAME_COUNTER_LEN ((unsigned)sizeof(unsigned int) << 1)
+#define SILLYNAME_LEN (SILLYNAME_PREFIX_LEN + \
+		SILLYNAME_FILEID_LEN + \
+		SILLYNAME_COUNTER_LEN)
+
 /**
  * nfs_sillyrename - Perform a silly-rename of a dentry
  * @dir: inode of directory that contains dentry
@@ -469,10 +477,8 @@ int
 nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 {
 	static unsigned int sillycounter;
-	const int      fileidsize  = sizeof(NFS_FILEID(dentry->d_inode))*2;
-	const int      countersize = sizeof(sillycounter)*2;
-	const int      slen        = sizeof(".nfs")+fileidsize+countersize-1;
-	char           silly[slen+1];
+	unsigned char silly[SILLYNAME_LEN + 1];
+	unsigned long long fileid;
 	struct dentry *sdentry;
 	struct rpc_task *task;
 	int            error = -EIO;
@@ -489,20 +495,20 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	if (dentry->d_flags & DCACHE_NFSFS_RENAMED)
 		goto out;
 
-	sprintf(silly, ".nfs%*.*Lx",
-		fileidsize, fileidsize,
-		(unsigned long long)NFS_FILEID(dentry->d_inode));
+	fileid = NFS_FILEID(dentry->d_inode);
 
 	/* Return delegation in anticipation of the rename */
 	NFS_PROTO(dentry->d_inode)->return_delegation(dentry->d_inode);
 
 	sdentry = NULL;
 	do {
-		char *suffix = silly + slen - countersize;
-
+		int slen;
 		dput(sdentry);
 		sillycounter++;
-		sprintf(suffix, "%*.*x", countersize, countersize, sillycounter);
+		slen = scnprintf(silly, sizeof(silly),
+				SILLYNAME_PREFIX "%0*llx%0*x",
+				SILLYNAME_FILEID_LEN, fileid,
+				SILLYNAME_COUNTER_LEN, sillycounter);
 
 		dfprintk(VFS, "NFS: trying to rename %s to %s\n",
 				dentry->d_name.name, silly);
-- 
1.8.3.1


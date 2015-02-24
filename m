Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33377 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbbBXAPE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 19:15:04 -0500
Received: by iecar1 with SMTP id ar1so28086198iec.0
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 16:15:04 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Nix <nix@esperi.org.uk>, Neil Brown <neilb@suse.de>
Subject: [PATCH 3/3] NFS: Don't require a filehandle to refresh the inode in nfs_prime_dcache()
Date: Mon, 23 Feb 2015 19:14:57 -0500
Message-Id: <1424736897-95767-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1424736897-95767-2-git-send-email-trond.myklebust@primarydata.com>
References: <1424736897-95767-1-git-send-email-trond.myklebust@primarydata.com>
 <1424736897-95767-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server does not return a valid set of attributes that we can
use to either create a file or refresh the inode, then there is no
value in calling nfs_prime_dcache().

However if we're just refreshing the inode using the attributes that
the server returned, then it shouldn't matter whether or not we have
a filehandle, as long as we check the fsid+fileid combination.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0da617a61c0b..c19e16f0b2d0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -408,14 +408,22 @@ static int xdr_decode(nfs_readdir_descriptor_t *desc,
 	return 0;
 }
 
+/* Match file and dirent using either filehandle or fileid
+ * Note: caller is responsible for checking the fsid
+ */
 static
 int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
 {
+	struct nfs_inode *nfsi;
+
 	if (dentry->d_inode == NULL)
 		goto different;
-	if (nfs_compare_fh(entry->fh, NFS_FH(dentry->d_inode)) != 0)
-		goto different;
-	return 1;
+
+	nfsi = NFS_I(dentry->d_inode);
+	if (entry->fattr->fileid == nfsi->fileid)
+		return 1;
+	if (nfs_compare_fh(entry->fh, &nfsi->fh) == 0)
+		return 1;
 different:
 	return 0;
 }
@@ -469,6 +477,10 @@ void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 	struct inode *inode;
 	int status;
 
+	if (!(entry->fattr->valid & NFS_ATTR_FATTR_FILEID))
+		return;
+	if (!(entry->fattr->valid & NFS_ATTR_FATTR_FSID))
+		return;
 	if (filename.name[0] == '.') {
 		if (filename.len == 1)
 			return;
-- 
2.1.0


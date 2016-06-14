Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33242 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbcFNVZp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2016 17:25:45 -0400
Received: by mail-io0-f194.google.com with SMTP id 5so843249ioy.0
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2016 14:25:45 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Don't let readdirplus revalidate an inode that was marked as stale
Date: Tue, 14 Jun 2016 17:25:16 -0400
Message-Id: <1465939516-44769-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index aaf7bd0cbae2..a924d66b5608 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -424,12 +424,17 @@ static int xdr_decode(nfs_readdir_descriptor_t *desc,
 static
 int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
 {
+	struct inode *inode;
 	struct nfs_inode *nfsi;
 
 	if (d_really_is_negative(dentry))
 		return 0;
 
-	nfsi = NFS_I(d_inode(dentry));
+	inode = d_inode(dentry);
+	if (is_bad_inode(inode) || NFS_STALE(inode))
+		return 0;
+
+	nfsi = NFS_I(inode);
 	if (entry->fattr->fileid == nfsi->fileid)
 		return 1;
 	if (nfs_compare_fh(entry->fh, &nfsi->fh) == 0)
-- 
2.5.5


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19651 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754855Ab0K3Rm5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Nov 2010 12:42:57 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Fix a readdirplus bug
Date: Tue, 30 Nov 2010 12:42:34 -0500
Message-Id: <1291138954-10310-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When comparing filehandles in the helper nfs_same_file(), we should not be
using 'strncmp()': filehandles are not null terminated strings.

Instead, we should just use the existing helper nfs_compare_fh().

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8ea4a41..f0a384e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -395,13 +395,9 @@ int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, struct x
 static
 int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
 {
-	struct nfs_inode *node;
 	if (dentry->d_inode == NULL)
 		goto different;
-	node = NFS_I(dentry->d_inode);
-	if (node->fh.size != entry->fh->size)
-		goto different;
-	if (strncmp(node->fh.data, entry->fh->data, node->fh.size) != 0)
+	if (nfs_compare_fh(entry->fh, NFS_FH(dentry->d_inode)) != 0)
 		goto different;
 	return 1;
 different:
-- 
1.7.3.2


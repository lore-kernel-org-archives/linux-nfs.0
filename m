Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f169.google.com ([209.85.215.169]:52952 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755517Ab3GUOYb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Jul 2013 10:24:31 -0400
Received: by mail-ea0-f169.google.com with SMTP id h15so3293282eak.14
        for <linux-nfs@vger.kernel.org>; Sun, 21 Jul 2013 07:24:30 -0700 (PDT)
From: Nadav Shemer <nadav@tonian.com>
To: Trond.Myklebust@netapp.com, jlayton@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH V2] nfs: fix open(O_RDONLY|O_TRUNC) in NFS4.0
Date: Sun, 21 Jul 2013 17:21:43 +0300
Message-Id: <1374416503-3693-1-git-send-email-nadav@tonian.com>
In-Reply-To: <CADnca3sTH7XWOsKB1KihR5ig6_DPpZaOak=m75W+nL2JV7dsTw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfs4_proc_setattr removes ATTR_OPEN from sattr->ia_valid, but later
nfs4_do_setattr checks for it
---
v2: Don't break the 'no change, don't RPC' optimization
    Much smaller patch

 fs/nfs/nfs4proc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 6634109..e979f1d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2444,34 +2444,34 @@ static int
 nfs4_proc_setattr(struct dentry *dentry, struct nfs_fattr *fattr,
 		  struct iattr *sattr)
 {
 	struct inode *inode = dentry->d_inode;
 	struct rpc_cred *cred = NULL;
 	struct nfs4_state *state = NULL;
 	int status;
 
 	if (pnfs_ld_layoutret_on_setattr(inode))
 		pnfs_return_layout(inode);
 
 	nfs_fattr_init(fattr);
 	
 	/* Deal with open(O_TRUNC) */
 	if (sattr->ia_valid & ATTR_OPEN)
-		sattr->ia_valid &= ~(ATTR_MTIME|ATTR_CTIME|ATTR_OPEN);
+		sattr->ia_valid &= ~(ATTR_MTIME|ATTR_CTIME);
 
 	/* Optimization: if the end result is no change, don't RPC */
-	if ((sattr->ia_valid & ~(ATTR_FILE)) == 0)
+	if ((sattr->ia_valid & ~(ATTR_FILE|ATTR_OPEN)) == 0)
 		return 0;
 
 	/* Search for an existing open(O_WRITE) file */
 	if (sattr->ia_valid & ATTR_FILE) {
 		struct nfs_open_context *ctx;
 
 		ctx = nfs_file_open_context(sattr->ia_file);
 		if (ctx) {
 			cred = ctx->cred;
 			state = ctx->state;
 		}
 	}
 
 	status = nfs4_do_setattr(inode, cred, fattr, sattr, state);
 	if (status == 0)
-- 
1.7.6.5


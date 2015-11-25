Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36192 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbbKYSuR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2015 13:50:17 -0500
Received: by qgcc31 with SMTP id c31so38654010qgc.3
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2015 10:50:16 -0800 (PST)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@Primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: if we have no valid attrs, then don't declare the attribute cache valid
Date: Wed, 25 Nov 2015 13:50:11 -0500
Message-Id: <1448477411-17721-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we pass in an empty nfs_fattr struct to nfs_update_inode, it will
(correctly) not update any of the attributes, but it then clears the
NFS_INO_INVALID_ATTR flag, which indicates that the attributes are
up to date. Don't clear the flag if the fattr struct has no valid
attrs to apply.

Reviewed-by: Steve French <steve.french@primarydata.com>
Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/inode.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 326d9e10d833..ffdf9b9e88ab 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1824,7 +1824,11 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 		if ((long)fattr->gencount - (long)nfsi->attr_gencount > 0)
 			nfsi->attr_gencount = fattr->gencount;
 	}
-	invalid &= ~NFS_INO_INVALID_ATTR;
+
+	/* Don't declare attrcache up to date if there were no attrs! */
+	if (fattr->valid != 0)
+		invalid &= ~NFS_INO_INVALID_ATTR;
+
 	/* Don't invalidate the data if we were to blame */
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
-- 
2.4.3


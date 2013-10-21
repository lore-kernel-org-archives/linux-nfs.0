Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44741 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab3JURKV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 13:10:21 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 2/5] NFSv4: don't fail on missing fattr in open recover
Date: Mon, 21 Oct 2013 13:10:11 -0400
Message-ID: <1382375414-5854-3-git-send-email-dros@netapp.com>
In-Reply-To: <1382375414-5854-1-git-send-email-dros@netapp.com>
References: <1382375414-5854-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an unneeded check that could cause the client to fail to recover
opens.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/nfs4proc.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 000063e..8140366 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1323,12 +1323,6 @@ _nfs4_opendata_reclaim_to_nfs4_state(struct nfs4_opendata *data)
 		goto err;
 	}
 
-	ret = -ESTALE;
-	if (!(data->f_attr.valid & NFS_ATTR_FATTR_TYPE) ||
-	    !(data->f_attr.valid & NFS_ATTR_FATTR_FILEID) ||
-	    !(data->f_attr.valid & NFS_ATTR_FATTR_CHANGE))
-		goto err;
-
 	ret = -ENOMEM;
 	state = nfs4_get_open_state(inode, data->owner);
 	if (state == NULL)
-- 
1.7.12.4 (Apple Git-37)


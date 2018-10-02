Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway34.websitewelcome.com ([192.185.148.200]:42447 "EHLO
        gateway34.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726244AbeJBRVU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2018 13:21:20 -0400
Received: from cm17.websitewelcome.com (cm17.websitewelcome.com [100.42.49.20])
        by gateway34.websitewelcome.com (Postfix) with ESMTP id D38B02052862
        for <linux-nfs@vger.kernel.org>; Tue,  2 Oct 2018 05:08:51 -0500 (CDT)
Date: Tue, 2 Oct 2018 12:08:48 +0200
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] nfsd: fix fall-through annotations
Message-ID: <20181002100848.GA31166@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace "fallthru" with a proper "fall through" annotation.

Also, add an annotation were it is expected to fall through.

These fixes are part of the ongoing efforts to enabling
-Wimplicit-fallthrough

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 fs/nfsd/vfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d74583f..2751976 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1407,6 +1407,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					*created = 1;
 				break;
 			}
+			/* fall through */
 		case NFS4_CREATE_EXCLUSIVE4_1:
 			if (   d_inode(dchild)->i_mtime.tv_sec == v_mtime
 			    && d_inode(dchild)->i_atime.tv_sec == v_atime
@@ -1415,7 +1416,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					*created = 1;
 				goto set_attr;
 			}
-			 /* fallthru */
+			/* fall through */
 		case NFS3_CREATE_GUARDED:
 			err = nfserr_exist;
 		}
-- 
2.7.4

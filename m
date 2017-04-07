Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46795 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933181AbdDGSPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:52 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 13/34] NFS: Remove nfs_direct_readpage_release()
Date: Fri, 7 Apr 2017 14:15:07 -0400
Message-ID: <20170407181528.2832-14-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Just remove the function and have the caller use nfs_release_request()
instead.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/direct.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index aab32fc3d6a8..0b65e25b71ac 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -392,16 +392,6 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 	nfs_direct_req_release(dreq);
 }
 
-static void nfs_direct_readpage_release(struct nfs_page *req)
-{
-	dprintk("NFS: direct read done (%s/%llu %d@%lld)\n",
-		req->wb_context->dentry->d_sb->s_id,
-		(unsigned long long)NFS_FILEID(d_inode(req->wb_context->dentry)),
-		req->wb_bytes,
-		(long long)req_offset(req));
-	nfs_release_request(req);
-}
-
 static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 {
 	unsigned long bytes = 0;
@@ -426,7 +416,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 			set_page_dirty(page);
 		bytes += req->wb_bytes;
 		nfs_list_remove_request(req);
-		nfs_direct_readpage_release(req);
+		nfs_release_request(req);
 	}
 out_put:
 	if (put_dreq(dreq))
-- 
2.12.2


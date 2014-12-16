Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:51956 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751265AbaLPTC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Dec 2014 14:02:57 -0500
Received: by mail-pa0-f43.google.com with SMTP id kx10so14632837pab.16
        for <linux-nfs@vger.kernel.org>; Tue, 16 Dec 2014 11:02:57 -0800 (PST)
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Trond Myklebust <Trond.Myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 29/50] nfs/filelayout: use pnfs_error_mark_layout_for_return
Date: Tue, 16 Dec 2014 11:01:32 -0800
Message-Id: <1418756513-95187-30-git-send-email-loghyr@primarydata.com>
In-Reply-To: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
References: <1418756513-95187-1-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

Instead of calling layoutreturn directly, call pnfs_error_mark_layout_for_return
to mark layouts for return and let generic code return layout when
layout segments are freed.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
Signed-off-by: Tom Haynes <Thomas.Haynes@primarydata.com>

Conflicts:
	fs/nfs/filelayout/filelayout.c
---
 fs/nfs/filelayout/filelayout.c |  2 +-
 fs/nfs/pnfs_nfsio.c            | 10 ----------
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index bfa8547..5d2eadc 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -200,7 +200,7 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		dprintk("%s DS connection error %d\n", __func__,
 			task->tk_status);
 		nfs4_mark_deviceid_unavailable(devid);
-		set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags);
+		pnfs_error_mark_layout_for_return(inode, lseg);
 		rpc_wake_up(&tbl->slot_tbl_waitq);
 		/* fall through */
 	default:
diff --git a/fs/nfs/pnfs_nfsio.c b/fs/nfs/pnfs_nfsio.c
index 329447c..c6c3efc 100644
--- a/fs/nfs/pnfs_nfsio.c
+++ b/fs/nfs/pnfs_nfsio.c
@@ -13,20 +13,10 @@
 #include "internal.h"
 #include "pnfs.h"
 
-static void pnfs_generic_fenceme(struct inode *inode,
-				 struct pnfs_layout_hdr *lo)
-{
-	if (!test_and_clear_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
-		return;
-	pnfs_return_layout(inode);
-}
-
 void pnfs_generic_rw_release(void *data)
 {
 	struct nfs_pgio_header *hdr = data;
-	struct pnfs_layout_hdr *lo = hdr->lseg->pls_layout;
 
-	pnfs_generic_fenceme(lo->plh_inode, lo);
 	nfs_put_client(hdr->ds_clp);
 	hdr->mds_ops->rpc_release(data);
 }
-- 
1.9.3


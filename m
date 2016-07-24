Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35240 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbcGXVbf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:35 -0400
Received: by mail-io0-f193.google.com with SMTP id q83so10786582iod.2
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/14] pNFS: Clear the layout return tracking on layout reinitialisation
Date: Sun, 24 Jul 2016 17:30:47 -0400
Message-Id: <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we don't carry over layoutreturn info from a previous
incarnation of this layout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0fbe734cc38c..dcccded1aeed 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -873,15 +873,21 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
 	rpc_wake_up(&NFS_SERVER(lo->plh_inode)->roc_rpcwaitq);
 }
 
+static void
+pnfs_clear_layoutreturn_info(struct pnfs_layout_hdr *lo)
+{
+	lo->plh_return_iomode = 0;
+	lo->plh_return_seq = 0;
+	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+}
+
 static bool
 pnfs_prepare_layoutreturn(struct pnfs_layout_hdr *lo)
 {
 	if (test_and_set_bit(NFS_LAYOUT_RETURN, &lo->plh_flags))
 		return false;
-	lo->plh_return_iomode = 0;
-	lo->plh_return_seq = 0;
 	pnfs_get_layout_hdr(lo);
-	clear_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
+	pnfs_clear_layoutreturn_info(lo);
 	return true;
 }
 
@@ -1764,10 +1770,13 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
 	}
 
-	clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg, &free_me);
+	if (!pnfs_layout_is_valid(lo)) {
+		pnfs_clear_layoutreturn_info(lo);
+		clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+	}
+
 
 	if (res->return_on_close)
 		set_bit(NFS_LSEG_ROC, &lseg->pls_flags);
-- 
2.7.4


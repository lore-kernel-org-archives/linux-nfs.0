Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36527 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbcGVTef (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2016 15:34:35 -0400
Received: by mail-io0-f195.google.com with SMTP id y34so8006153ioi.3
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2016 12:34:34 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] pNFS: Clear the layout return tracking on layout reinitialisation
Date: Fri, 22 Jul 2016 15:33:53 -0400
Message-Id: <1469216038-71882-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469216038-71882-1-git-send-email-trond.myklebust@primarydata.com>
References: <1469216038-71882-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we don't carry over layoutreturn info from a previous
incarnation of this layout.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0c7e0d45a4de..27052d4b46ef 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -871,15 +871,21 @@ void pnfs_clear_layoutreturn_waitbit(struct pnfs_layout_hdr *lo)
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
 
@@ -1760,7 +1766,10 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		lo->plh_barrier = be32_to_cpu(res->stateid.seqid);
 	}
 
-	clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+	if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags)) {
+		pnfs_clear_layoutreturn_info(lo);
+		clear_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
+	}
 
 	pnfs_get_lseg(lseg);
 	pnfs_layout_insert_lseg(lo, lseg, &free_me);
-- 
2.7.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36592 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbcGXVbr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:47 -0400
Received: by mail-io0-f196.google.com with SMTP id y34so10760903ioi.3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:46 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 13/14] pNFS: Cleanup - do layout segment initialisation in one place
Date: Sun, 24 Jul 2016 17:30:58 -0400
Message-Id: <1469395859-83194-14-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-13-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-9-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-10-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-11-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-12-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-13-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...instead of splitting the initialisation over init_lseg() and
pnfs_layout_process().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c9a684c128b8..09b77a68422f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -334,7 +334,9 @@ pnfs_layout_io_test_failed(struct pnfs_layout_hdr *lo, u32 iomode)
 }
 
 static void
-init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
+pnfs_init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg,
+		const struct pnfs_layout_range *range,
+		const nfs4_stateid *stateid)
 {
 	INIT_LIST_HEAD(&lseg->pls_list);
 	INIT_LIST_HEAD(&lseg->pls_lc_list);
@@ -342,6 +344,8 @@ init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
 	smp_mb();
 	set_bit(NFS_LSEG_VALID, &lseg->pls_flags);
 	lseg->pls_layout = lo;
+	lseg->pls_range = *range;
+	lseg->pls_seq = be32_to_cpu(stateid->seqid);
 }
 
 static void pnfs_free_lseg(struct pnfs_layout_segment *lseg)
@@ -1760,9 +1764,7 @@ pnfs_layout_process(struct nfs4_layoutget *lgp)
 		return lseg;
 	}
 
-	init_lseg(lo, lseg);
-	lseg->pls_range = res->range;
-	lseg->pls_seq = be32_to_cpu(res->stateid.seqid);
+	pnfs_init_lseg(lo, lseg, &res->range, &res->stateid);
 
 	spin_lock(&ino->i_lock);
 	if (pnfs_layoutgets_blocked(lo)) {
-- 
2.7.4


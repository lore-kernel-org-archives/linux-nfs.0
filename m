Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36769 "EHLO
	mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbcGXVbk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jul 2016 17:31:40 -0400
Received: by mail-it0-f68.google.com with SMTP id j124so6500475ith.3
        for <linux-nfs@vger.kernel.org>; Sun, 24 Jul 2016 14:31:40 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v3 07/14] pNFS: Do not set plh_return_seq for non-callback related layoutreturns
Date: Sun, 24 Jul 2016 17:30:52 -0400
Message-Id: <1469395859-83194-8-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
References: <1469395859-83194-1-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-2-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-3-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-4-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-5-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-6-git-send-email-trond.myklebust@primarydata.com>
 <1469395859-83194-7-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cases where we need to send a layoutreturn in order to propagate
an error, we should not tie that to a specific layout stateid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pnfs.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 878dc4b7085a..c57cbddca760 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1808,14 +1808,14 @@ static void
 pnfs_set_plh_return_info(struct pnfs_layout_hdr *lo, enum pnfs_iomode iomode,
 			 u32 seq)
 {
-	if (lo->plh_return_iomode == iomode)
-		return;
-	if (lo->plh_return_iomode != 0)
+	if (lo->plh_return_iomode != 0 && lo->plh_return_iomode != iomode)
 		iomode = IOMODE_ANY;
 	lo->plh_return_iomode = iomode;
 	set_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags);
-	if (!lo->plh_return_seq || pnfs_seqid_is_newer(seq, lo->plh_return_seq))
+	if (seq != 0) {
+		WARN_ON_ONCE(lo->plh_return_seq != 0 && lo->plh_return_seq != seq);
 		lo->plh_return_seq = seq;
+	}
 }
 
 /**
@@ -1876,14 +1876,13 @@ void pnfs_error_mark_layout_for_return(struct inode *inode,
 	bool return_now = false;
 
 	spin_lock(&inode->i_lock);
-	pnfs_set_plh_return_info(lo, range.iomode, lseg->pls_seq);
+	pnfs_set_plh_return_info(lo, range.iomode, 0);
 	/*
 	 * mark all matching lsegs so that we are sure to have no live
 	 * segments at hand when sending layoutreturn. See pnfs_put_lseg()
 	 * for how it works.
 	 */
-	if (!pnfs_mark_matching_lsegs_return(lo, &free_me,
-						&range, lseg->pls_seq)) {
+	if (!pnfs_mark_matching_lsegs_return(lo, &free_me, &range, 0)) {
 		nfs4_stateid stateid;
 		enum pnfs_iomode iomode;
 
-- 
2.7.4


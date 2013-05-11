Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f177.google.com ([74.125.82.177]:65246 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCoq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:46 -0400
Received: by mail-we0-f177.google.com with SMTP id q58so4589109wes.22
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:45 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id bs20sm1270112wib.0.2013.05.10.19.44.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:45 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 35/38] pnfsd: use layout stateid for is_layout_recalled
Date: Sat, 11 May 2013 05:44:40 +0300
Message-Id: <1368240280-1083-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rather than clientid

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 0b256f5..0ef351d 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -548,10 +548,10 @@ struct super_block *
  */
 static int
 is_layout_recalled(struct nfs4_client *clp,
-		   struct svc_fh *current_fh,
-		   struct nfsd4_layout_seg *seg)
+		   struct nfsd4_pnfs_layoutget *lgp)
 {
 	struct nfs4_layoutrecall *clr;
+	struct nfsd4_layout_seg *seg = &lgp->lg_seg;
 
 	spin_lock(&layout_lock);
 	list_for_each_entry (clr, &clp->cl_layoutrecalls, clr_perclnt) {
@@ -560,13 +560,13 @@ struct super_block *
 		if (clr->cb.cbl_recall_type == RETURN_ALL)
 			goto found;
 		if (clr->cb.cbl_recall_type == RETURN_FSID) {
-			if (same_fsid(&clr->cb.cbl_fsid, current_fh))
+			if (same_fsid(&clr->cb.cbl_fsid, lgp->lg_fhp))
 				goto found;
 			else
 				continue;
 		}
 		BUG_ON(clr->cb.cbl_recall_type != RETURN_FILE);
-		if (clr->cb.cbl_seg.clientid == seg->clientid &&
+		if (same_stid((stateid_t *)&clr->cb.cbl_sid, &lgp->lg_sid) &&
 		    lo_seg_overlapping(&clr->cb.cbl_seg, seg))
 			goto found;
 	}
@@ -704,7 +704,7 @@ struct super_block *
 	if (nfserr)
 		goto out_unlock;
 
-	if (is_layout_recalled(clp, lgp->lg_fhp, &lgp->lg_seg)) {
+	if (is_layout_recalled(clp, lgp)) {
 		nfserr = nfserr_recallconflict;
 		goto out_unlock;
 	}
-- 
1.7.11.7


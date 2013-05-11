Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f182.google.com ([74.125.82.182]:55247 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416Ab3EKCny (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:54 -0400
Received: by mail-we0-f182.google.com with SMTP id t60so4578971wes.41
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:53 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id o3sm1408120wia.2.2013.05.10.19.43.52
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:53 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 21/38] SQUASHME: pnfsd: return bool from merge_layout and fix not found path
Date: Sat, 11 May 2013 05:43:48 +0300
Message-Id: <1368240228-32538-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This also fixes the false return when no layout is found
(previously a non NULL pointer was returned)

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 0bde7b7..ff688cb 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -578,7 +578,7 @@ struct super_block *
 /*
  * are two octet ranges overlapping or adjacent?
  */
-static int
+static bool
 lo_seg_mergeable(struct nfsd4_layout_seg *l1, struct nfsd4_layout_seg *l2)
 {
 	u64 start1 = l1->offset;
@@ -615,25 +615,26 @@ struct super_block *
 		      lo_end : lo_end - lo_start;
 }
 
-static struct nfs4_layout *
+static bool
 merge_layout(struct nfs4_file *fp,
 	     struct nfs4_client *clp,
 	     struct nfsd4_layout_seg *seg)
 {
-	struct nfs4_layout *lp = NULL;
+	bool ret = false;
+	struct nfs4_layout *lp;
 
 	spin_lock(&layout_lock);
 	list_for_each_entry (lp, &fp->fi_layouts, lo_perfile)
 		if (lp->lo_seg.layout_type == seg->layout_type &&
 		    lp->lo_seg.clientid == seg->clientid &&
 		    lp->lo_seg.iomode == seg->iomode &&
-		    lo_seg_mergeable(&lp->lo_seg, seg)) {
+		    (ret = lo_seg_mergeable(&lp->lo_seg, seg))) {
 			extend_layout(&lp->lo_seg, seg);
 			break;
 		}
 	spin_unlock(&layout_lock);
 
-	return lp;
+	return ret;
 }
 
 __be32
-- 
1.7.11.7


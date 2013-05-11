Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f42.google.com ([74.125.82.42]:48487 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416Ab3EKCnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:51 -0400
Received: by mail-wg0-f42.google.com with SMTP id j13so1246557wgh.5
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:49 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id q13sm1342120wie.8.2013.05.10.19.43.48
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:49 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 20/38] SQUASHME: pnfsd: merge_layout needs to acquire the layout_lock for traversing fi_layouts
Date: Sat, 11 May 2013 05:43:45 +0300
Message-Id: <1368240225-32494-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 48104fb..0bde7b7 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -622,6 +622,7 @@ struct super_block *
 {
 	struct nfs4_layout *lp = NULL;
 
+	spin_lock(&layout_lock);
 	list_for_each_entry (lp, &fp->fi_layouts, lo_perfile)
 		if (lp->lo_seg.layout_type == seg->layout_type &&
 		    lp->lo_seg.clientid == seg->clientid &&
@@ -630,6 +631,7 @@ struct super_block *
 			extend_layout(&lp->lo_seg, seg);
 			break;
 		}
+	spin_unlock(&layout_lock);
 
 	return lp;
 }
-- 
1.7.11.7


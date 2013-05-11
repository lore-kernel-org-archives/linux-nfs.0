Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35262 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3EKCox (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:53 -0400
Received: by mail-wi0-f181.google.com with SMTP id ey16so1205922wid.14
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:52 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id je7sm1170147wic.9.2013.05.10.19.44.51
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:52 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 37/38] pnfsd: don't use clientid in merge_layout
Date: Sat, 11 May 2013 05:44:48 +0300
Message-Id: <1368240288-1165-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The layout state is already associated with the clientid
so there is no need to recheck

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 45111fe..0c05a22 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -626,7 +626,6 @@ struct super_block *
 	spin_lock(&layout_lock);
 	list_for_each_entry (lp, &ls->ls_layouts, lo_perstate)
 		if (lp->lo_seg.layout_type == seg->layout_type &&
-		    lp->lo_seg.clientid == seg->clientid &&
 		    lp->lo_seg.iomode == seg->iomode &&
 		    (ret = lo_seg_mergeable(&lp->lo_seg, seg))) {
 			extend_layout(&lp->lo_seg, seg);
-- 
1.7.11.7


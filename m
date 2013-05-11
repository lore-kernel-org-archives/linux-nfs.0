Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f180.google.com ([74.125.82.180]:64603 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab3EKCnJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:09 -0400
Received: by mail-we0-f180.google.com with SMTP id n5so4521948wev.11
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:07 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id s1sm1246974wiz.2.2013.05.10.19.43.06
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:07 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/38] Revert "pnfsd: filelayout: file layout specific callbacks"
Date: Sat, 11 May 2013 05:43:02 +0300
Message-Id: <1368240182-32073-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit c89fe09b70d3e5391db3b645f91ee10d75a31350.
---
 include/linux/nfsd/nfsd4_pnfs.h | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/include/linux/nfsd/nfsd4_pnfs.h b/include/linux/nfsd/nfsd4_pnfs.h
index 95b8b6e..1e6ef66 100644
--- a/include/linux/nfsd/nfsd4_pnfs.h
+++ b/include/linux/nfsd/nfsd4_pnfs.h
@@ -260,13 +260,6 @@ struct pnfsd_cb_operations {
 	/* Generic callbacks */
 	int (*cb_layout_recall) (struct super_block *, struct inode *,
 				 struct nfsd4_pnfs_cb_layout *);
-
-	/* pNFS Files layout specific callbacks */
-
-	/* Callback from fs on MDS only */
-	int (*cb_get_state) (struct super_block *, struct pnfs_get_state *);
-	/* Callback from fs on DS only */
-	int (*cb_change_state) (struct pnfs_get_state *);
 };
 
 #endif /* _LINUX_NFSD_NFSD4_PNFS_H */
-- 
1.7.11.7


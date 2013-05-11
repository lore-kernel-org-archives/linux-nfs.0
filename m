Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f172.google.com ([74.125.82.172]:49226 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757076Ab3EKCnr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:47 -0400
Received: by mail-we0-f172.google.com with SMTP id w60so4517507wes.31
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:46 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id e8sm1217632wic.5.2013.05.10.19.43.44
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:45 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 19/38] SQUASHME: pnfsd: get rid of depdency on nfsd_serv starting 3.8
Date: Sat, 11 May 2013 05:43:41 +0300
Message-Id: <1368240221-32455-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 24c19b3..48104fb 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -1446,11 +1446,6 @@ struct create_recall_list_arg {
 	       cbl->cbl_seg.iomode != IOMODE_RW &&
 	       cbl->cbl_seg.iomode != IOMODE_ANY);
 
-	if (nfsd_serv == NULL) {
-		dprintk("NFSD nfsd_layout_recall_cb: nfsd_serv == NULL\n");
-		return -ENOENT;
-	}
-
 	if (!with_nfs4_state_lock)
 		nfs4_lock_state();
 	status = -ENOENT;
-- 
1.7.11.7


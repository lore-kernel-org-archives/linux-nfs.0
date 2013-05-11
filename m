Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:45246 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757006Ab3EKCnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:35 -0400
Received: by mail-we0-f171.google.com with SMTP id u55so4659493wes.30
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:34 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id u17sm1177240wiv.8.2013.05.10.19.43.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:33 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 16/38] SQUASHME: pnfsd: use nfsd4_init_callback starting v3.8
Date: Sat, 11 May 2013 05:43:29 +0300
Message-Id: <1368240209-32339-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index a15100b..e516eba 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -454,7 +454,7 @@ struct super_block *
 
 	kref_init(&clr->clr_ref);
 	INIT_LIST_HEAD(&clr->clr_perclnt);
-	INIT_WORK(&clr->clr_recall.cb_work, nfsd4_do_callback_rpc);
+	nfsd4_init_callback(&clr->clr_recall);
 
 	dprintk("NFSD %s return %p\n", __func__, clr);
 	return clr;
-- 
1.7.11.7


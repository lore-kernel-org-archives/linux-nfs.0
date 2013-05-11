Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:65513 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab3EKCnU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:43:20 -0400
Received: by mail-wi0-f180.google.com with SMTP id h11so1206034wiv.13
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:43:19 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id ge7sm1365141wib.6.2013.05.10.19.43.18
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:43:18 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 12/38] Revert "pnfsd: decode getdeviceinfo notify types."
Date: Sat, 11 May 2013 05:43:14 +0300
Message-Id: <1368240194-32187-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 367bfe8e26e0753cad8eb6855f4254f803720c9c.
---
 fs/nfsd/nfs4xdr.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a552202..596a2a5 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1474,12 +1474,8 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	READ32(gdev->gd_layout_type);
 	READ32(gdev->gd_maxcount);
 	READ32(num);
-	if (num) {
-		READ_BUF(4);
-		READ32(gdev->gd_notify_types);
-	} else {
-		gdev->gd_notify_types = 0;
-	}
+	if (num)
+		READ_BUF(4); /* TODO: for now, just skip notify_types */
 
 	DECODE_TAIL;
 }
-- 
1.7.11.7


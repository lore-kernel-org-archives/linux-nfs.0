Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f50.google.com ([74.125.82.50]:47963 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664Ab3EKCo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:44:28 -0400
Received: by mail-wg0-f50.google.com with SMTP id m15so4731164wgh.29
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:44:27 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id f2sm1147848wiv.11.2013.05.10.19.44.26
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:44:27 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 30/38] pnfsd-lexp: fixup recall_layout
Date: Sat, 11 May 2013 05:44:23 +0300
Message-Id: <1368240263-880-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/pnfsd_lexp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/pnfsd_lexp.c b/fs/nfsd/pnfsd_lexp.c
index 5d448c2..79a4bc1 100644
--- a/fs/nfsd/pnfsd_lexp.c
+++ b/fs/nfsd/pnfsd_lexp.c
@@ -253,7 +253,7 @@ static int get_stripe_unit(int blocksize)
 static bool
 has_layout(struct nfs4_file *fp)
 {
-	return !list_empty(&fp->fi_layouts);
+	return !list_empty(&fp->fi_lo_states);
 }
 
 /*
-- 
1.7.11.7


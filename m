Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59100 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755869Ab2JFQBI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Oct 2012 12:01:08 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so2767080pad.19
        for <linux-nfs@vger.kernel.org>; Sat, 06 Oct 2012 09:01:08 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 7 Oct 2012 00:01:07 +0800
Message-ID: <CADu=CFoMr0kUcKQsKYAVLk9d15537UHdLEbSt+HkbfCiOJWotQ@mail.gmail.com>
Subject: [PATCH] NFS: fix a typo in fs/nfs/nfs4filelayout.c
From: liang xie <xieliang007@gmail.com>
To: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a typo: "Futher" -> "Further"

Signed-off-by: Liang Xie <xieliang@xiaomi.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 53f94d9..c3933e7 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -720,7 +720,7 @@ filelayout_decode_layout(struct pnfs_layout_hdr *flo,
 		fl->pattern_offset);

 	/* Note that a zero value for num_fh is legal for STRIPE_SPARSE.
-	 * Futher checking is done in filelayout_check_layout */
+	 * Further checking is done in filelayout_check_layout */
 	if (fl->num_fh >
 	    max(NFS4_PNFS_MAX_STRIPE_CNT, NFS4_PNFS_MAX_MULTI_CNT))
 		goto out_err;
-- 
1.7.9.6 (Apple Git-31.1)

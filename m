Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36016 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752043AbbGGCMJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2015 22:12:09 -0400
Received: by pddu5 with SMTP id u5so28516351pdd.3
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jul 2015 19:12:09 -0700 (PDT)
Message-ID: <559B3573.4090307@gmail.com>
Date: Tue, 07 Jul 2015 10:12:03 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Christoph Hellwig <hch@infradead.org>, kinglongmee@gmail.com
Subject: [PATCH 1/3] nfsd: Set lc_size_chg before ops->proc_layoutcommit
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After proc_layoutcommit success, i_size_read(inode) always >= new_size.
Just set lc_size_chg before proc_layoutcommit, if proc_layoutcommit
failed, nfsd will skip the lc_size_chg, so it's no harm.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 90cfda7..d112c8a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1364,10 +1364,6 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
 		goto out;
 	}
 
-	nfserr = ops->proc_layoutcommit(inode, lcp);
-	if (nfserr)
-		goto out_put_stid;
-
 	if (new_size > i_size_read(inode)) {
 		lcp->lc_size_chg = 1;
 		lcp->lc_newsize = new_size;
@@ -1375,7 +1371,7 @@ nfsd4_layoutcommit(struct svc_rqst *rqstp,
 		lcp->lc_size_chg = 0;
 	}
 
-out_put_stid:
+	nfserr = ops->proc_layoutcommit(inode, lcp);
 	nfs4_put_stid(&ls->ls_stid);
 out:
 	return nfserr;
-- 
2.4.3


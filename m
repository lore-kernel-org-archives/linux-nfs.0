Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33158 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbbCOPMX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2015 11:12:23 -0400
Received: by pagr17 with SMTP id r17so38503306pag.0
        for <linux-nfs@vger.kernel.org>; Sun, 15 Mar 2015 08:12:23 -0700 (PDT)
Message-ID: <5505A14F.4090202@gmail.com>
Date: Sun, 15 Mar 2015 23:12:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Put exports after nfsd4_layout_verify fail
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix commit 9cf514ccfa (nfsd: implement pNFS operations).

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d30bea8..92b9d97 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1237,8 +1237,8 @@ nfsd4_getdeviceinfo(struct svc_rqst *rqstp,
 		nfserr = ops->proc_getdeviceinfo(exp->ex_path.mnt->mnt_sb, gdp);
 
 	gdp->gd_notify_types &= ops->notify_types;
-	exp_put(exp);
 out:
+	exp_put(exp);
 	return nfserr;
 }
 
-- 
2.3.1


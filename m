Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33634 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbbCVORT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Mar 2015 10:17:19 -0400
Received: by pabxg6 with SMTP id xg6so150059373pab.0
        for <linux-nfs@vger.kernel.org>; Sun, 22 Mar 2015 07:17:18 -0700 (PDT)
Message-ID: <550ECEE6.7090402@gmail.com>
Date: Sun, 22 Mar 2015 22:17:10 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Take care the return value from nfsd4_encode_stateid
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index dd9302c..5c0aa74 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4135,7 +4135,7 @@ nfsd4_encode_layoutreturn(struct nfsd4_compoundres *resp, __be32 nfserr,
 		return nfserr_resource;
 	*p++ = cpu_to_be32(lrp->lrs_present);
 	if (lrp->lrs_present)
-		nfsd4_encode_stateid(xdr, &lrp->lr_sid);
+		return nfsd4_encode_stateid(xdr, &lrp->lr_sid);
 	return nfs_ok;
 }
 #endif /* CONFIG_NFSD_PNFS */
-- 
2.3.3


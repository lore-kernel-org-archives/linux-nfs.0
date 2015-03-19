Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:33506 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbbCSLEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Mar 2015 07:04:51 -0400
Received: by pdnc3 with SMTP id c3so73269155pdn.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Mar 2015 04:04:50 -0700 (PDT)
Message-ID: <550AAD49.2040906@gmail.com>
Date: Thu, 19 Mar 2015 19:04:41 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: [PATCH] NFSD: Take care the return value from nfsd4_decode_stateid
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return status after nfsd4_decode_stateid failed.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index df5e66c..c76654c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1562,7 +1562,11 @@ nfsd4_decode_layoutget(struct nfsd4_compoundargs *argp,
 	p = xdr_decode_hyper(p, &lgp->lg_seg.offset);
 	p = xdr_decode_hyper(p, &lgp->lg_seg.length);
 	p = xdr_decode_hyper(p, &lgp->lg_minlength);
-	nfsd4_decode_stateid(argp, &lgp->lg_sid);
+
+	status = nfsd4_decode_stateid(argp, &lgp->lg_sid);
+	if (status)
+		return status;
+
 	READ_BUF(4);
 	lgp->lg_maxcount = be32_to_cpup(p++);
 
@@ -1580,7 +1584,11 @@ nfsd4_decode_layoutcommit(struct nfsd4_compoundargs *argp,
 	p = xdr_decode_hyper(p, &lcp->lc_seg.offset);
 	p = xdr_decode_hyper(p, &lcp->lc_seg.length);
 	lcp->lc_reclaim = be32_to_cpup(p++);
-	nfsd4_decode_stateid(argp, &lcp->lc_sid);
+
+	status = nfsd4_decode_stateid(argp, &lcp->lc_sid);
+	if (status)
+		return status;
+
 	READ_BUF(4);
 	lcp->lc_newoffset = be32_to_cpup(p++);
 	if (lcp->lc_newoffset) {
@@ -1628,7 +1636,11 @@ nfsd4_decode_layoutreturn(struct nfsd4_compoundargs *argp,
 		READ_BUF(16);
 		p = xdr_decode_hyper(p, &lrp->lr_seg.offset);
 		p = xdr_decode_hyper(p, &lrp->lr_seg.length);
-		nfsd4_decode_stateid(argp, &lrp->lr_sid);
+
+		status = nfsd4_decode_stateid(argp, &lrp->lr_sid);
+		if (status)
+			return status;
+
 		READ_BUF(4);
 		lrp->lrf_body_len = be32_to_cpup(p++);
 		if (lrp->lrf_body_len > 0) {
-- 
2.3.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35273 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbbG3OWo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 10:22:44 -0400
Received: by pabkd10 with SMTP id kd10so24345213pab.2
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 07:22:44 -0700 (PDT)
Message-ID: <55BA331C.200@gmail.com>
Date: Thu, 30 Jul 2015 22:22:20 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        tigran.mkrtchyan@desy.de, kinglongmee@gmail.com,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH] NFSD: Encode security label as an array
References: <55B76B9B.4090700@gmail.com> <20150729193734.GB21949@fieldses.org> <55BA130C.1050604@gmail.com>
In-Reply-To: <55BA130C.1050604@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According at,
https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-38#section-12.2.4

"The FATTR4_SEC_LABEL contains an array of two components with the
 first component being an LFS."

Only supports one security label now.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5463385..fac05f9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2151,10 +2151,11 @@ nfsd4_encode_security_label(struct xdr_stream *xdr, struct svc_rqst *rqstp,
 {
 	__be32 *p;
 
-	p = xdr_reserve_space(xdr, len + 4 + 4 + 4);
+	p = xdr_reserve_space(xdr, len + 16);
 	if (!p)
 		return nfserr_resource;
 
+	*p++ = cpu_to_be32(1); /* Supports only one security label now */
 	/*
 	 * For now we use a 0 here to indicate the null translation; in
 	 * the future we may place a call to translation code here.
-- 
2.4.3


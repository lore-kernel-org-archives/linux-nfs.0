Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57225 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753875Ab0KIBf7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Nov 2010 20:35:59 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id C14971706DF
	for <linux-nfs@vger.kernel.org>; Tue,  9 Nov 2010 09:35:57 +0800 (CST)
Received: from mailserver.fnst.cn.fujitus.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id oA91VcUo001157
	for <linux-nfs@vger.kernel.org>; Tue, 9 Nov 2010 09:31:38 +0800
Message-ID: <4CD8A64B.20905@cn.fujitsu.com>
Date: Tue, 09 Nov 2010 09:39:23 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: NFSv3 list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4.1: Make sure nfsd can decode SP4_SSV correctly
 at exchange_id
References: <4CD3B362.8070302@cn.fujitsu.com>
In-Reply-To: <4CD3B362.8070302@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

According to RFC, the argument of ssv_sp_parms4 is:

   struct ssv_sp_parms4 {
           state_protect_ops4      ssp_ops;
           sec_oid4                ssp_hash_algs<>;
           sec_oid4                ssp_encr_algs<>;
           uint32_t                ssp_window;
           uint32_t                ssp_num_gss_handles;
   };

If client send a exchange_id with SP4_SSV, server cann't decode
the SP4_SSV's ssp_hash_algs and ssp_encr_algs arguments correctly.

Because the kernel treat the two arguments as a signal 
sec_oid4 struct, but should be a set of sec_oid4 struct.

Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
---
 fs/nfsd/nfs4xdr.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f35a94a..71d7d33 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1005,7 +1005,7 @@ static __be32
 nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 			 struct nfsd4_exchange_id *exid)
 {
-	int dummy;
+	int dummy, tmp;
 	DECODE_HEAD;
 
 	READ_BUF(NFS4_VERIFIER_SIZE);
@@ -1053,15 +1053,23 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 
 		/* ssp_hash_algs<> */
 		READ_BUF(4);
-		READ32(dummy);
-		READ_BUF(dummy);
-		p += XDR_QUADLEN(dummy);
+		READ32(tmp);
+		while (tmp--) {
+			READ_BUF(4);
+			READ32(dummy);
+			READ_BUF(dummy);
+			p += XDR_QUADLEN(dummy);
+		}
 
 		/* ssp_encr_algs<> */
 		READ_BUF(4);
-		READ32(dummy);
-		READ_BUF(dummy);
-		p += XDR_QUADLEN(dummy);
+		READ32(tmp);
+		while (tmp--) {
+			READ_BUF(4);
+			READ32(dummy);
+			READ_BUF(dummy);
+			p += XDR_QUADLEN(dummy);
+		}
 
 		/* ssp_window and ssp_num_gss_handles */
 		READ_BUF(8);
-- 1.7.0.1 


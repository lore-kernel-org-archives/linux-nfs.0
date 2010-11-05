Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57570 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751246Ab0KEHad (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Nov 2010 03:30:33 -0400
Message-ID: <4CD3B362.8070302@cn.fujitsu.com>
Date: Fri, 05 Nov 2010 15:33:54 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "Trond Myklebust(netapp)" <Trond.Myklebust@netapp.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSv4.1: Make sure nfsd can decode SP4_SSV correctly at exchange_id
Content-Type: text/plain; charset=ISO-2022-JP
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
-- 
1.7.0.1



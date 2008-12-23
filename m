From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 49/69] nfs: remove incorrect usage of nfs4 compound
 response hdr.status
Date: Tue, 23 Dec 2008 18:02:20 -0500
Message-ID: <20081223230220.13743.95372.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63750 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710AbYLWXYk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:40 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOclv006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:38 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@panasas.com>

3 call sites look at hdr.status before returning success.
hdr.status must be zero in this case so there's no point in this.

Currently, hdr.status is correctly processed at decode_op_hdr time
if the op status cannot be decoded.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4xdr.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)


diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 3f18a26..7eeed0e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4423,8 +4423,6 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4513,8 +4511,6 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_setclientid(&xdr, clp);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4535,8 +4531,6 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 		status = decode_putrootfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 


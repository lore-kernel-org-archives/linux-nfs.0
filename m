From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfs: remove incorrect usage of nfs4 compound response hdr.status
Date: Thu,  3 Jul 2008 21:42:08 +0300
Message-ID: <1215110528-8178-1-git-send-email-bhalevy@panasas.com>
References: <486D110F.1010608@panasas.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:58309 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbYGCSmV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jul 2008 14:42:21 -0400
In-Reply-To: <486D110F.1010608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

3 call sites look at hdr.status before returning success.
hdr.status must be zero in this case so there's no point in this.

Currently, hdr.status is correctly processed at decode_op_hdr time
if the op status cannot be decoded.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2cf724d..22df89f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4437,8 +4437,6 @@ static int nfs4_xdr_dec_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs_fsinf
 		status = decode_putfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4527,8 +4525,6 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req, __be32 *p,
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
 		status = decode_setclientid(&xdr, clp);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
@@ -4549,8 +4545,6 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 		status = decode_putrootfh(&xdr);
 	if (!status)
 		status = decode_fsinfo(&xdr, fsinfo);
-	if (!status)
-		status = nfs4_stat_to_errno(hdr.status);
 	return status;
 }
 
-- 
1.5.6.GIT


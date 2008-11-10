From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 03/85] nfs: remove incorrect usage of nfs4 compound response hdr.status
Date: Mon, 10 Nov 2008 22:05:19 +0200
Message-ID: <1226347519-6740-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53327 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbYKJUFn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:05:43 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
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
index ac2386b..69b5a56 100644
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
 
-- 
1.6.0.2


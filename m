Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:25085 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753141Ab2DZU4b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 16:56:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v4 1/9] NFS: Fix SECINFO_NO_NAME
Date: Thu, 26 Apr 2012 16:56:04 -0400
Message-Id: <1335473772-4401-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
References: <1335473772-4401-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I was using the same decoder function for SECINFO and SECINFO_NO_NAME,
so it was returning an error when it tried to decode an OP_SECINFO_NO_NAME
header as OP_SECINFO.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4xdr.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 77fc5f9..043c010 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5090,16 +5090,13 @@ out_err:
 	return -EINVAL;
 }
 
-static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
+static int decode_secinfo_common(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 {
 	struct nfs4_secinfo_flavor *sec_flavor;
 	int status;
 	__be32 *p;
 	int i, num_flavors;
 
-	status = decode_op_hdr(xdr, OP_SECINFO);
-	if (status)
-		goto out;
 	p = xdr_inline_decode(xdr, 4);
 	if (unlikely(!p))
 		goto out_overflow;
@@ -5125,6 +5122,7 @@ static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 		res->flavors->num_flavors++;
 	}
 
+	status = 0;
 out:
 	return status;
 out_overflow:
@@ -5132,7 +5130,23 @@ out_overflow:
 	return -EIO;
 }
 
+static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
+{
+	int status = decode_op_hdr(xdr, OP_SECINFO);
+	if (status)
+		return status;
+	return decode_secinfo_common(xdr, res);
+}
+
 #if defined(CONFIG_NFS_V4_1)
+static int decode_secinfo_no_name(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
+{
+	int status = decode_op_hdr(xdr, OP_SECINFO_NO_NAME);
+	if (status)
+		return status;
+	return decode_secinfo_common(xdr, res);
+}
+
 static int decode_exchange_id(struct xdr_stream *xdr,
 			      struct nfs41_exchange_id_res *res)
 {
@@ -6817,7 +6831,7 @@ static int nfs4_xdr_dec_secinfo_no_name(struct rpc_rqst *rqstp,
 	status = decode_putrootfh(xdr);
 	if (status)
 		goto out;
-	status = decode_secinfo(xdr, res);
+	status = decode_secinfo_no_name(xdr, res);
 out:
 	return status;
 }
-- 
1.7.10


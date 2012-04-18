Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64528 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752275Ab2DRRqi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Apr 2012 13:46:38 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 6/6] NFS: Fix SECINFO_NO_NAME
Date: Wed, 18 Apr 2012 13:46:25 -0400
Message-Id: <1334771185-9841-7-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
References: <1334771185-9841-1-git-send-email-bjschuma@netapp.com>
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
index eca81b1..78b71a6 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5087,16 +5087,13 @@ out_err:
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
@@ -5122,6 +5119,7 @@ static int decode_secinfo(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
 		res->flavors->num_flavors++;
 	}
 
+	status = 0;
 out:
 	return status;
 out_overflow:
@@ -5129,6 +5127,22 @@ out_overflow:
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
+static int decode_secinfo_no_name(struct xdr_stream *xdr, struct nfs4_secinfo_res *res)
+{
+	int status = decode_op_hdr(xdr, OP_SECINFO_NO_NAME);
+	if (status)
+		return status;
+	return decode_secinfo_common(xdr, res);
+}
+
 #if defined(CONFIG_NFS_V4_1)
 static int decode_exchange_id(struct xdr_stream *xdr,
 			      struct nfs41_exchange_id_res *res)
@@ -6814,7 +6828,7 @@ static int nfs4_xdr_dec_secinfo_no_name(struct rpc_rqst *rqstp,
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


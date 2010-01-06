From: andros@netapp.com
Subject: [PATCH 2/5] nfs41: directly encode back channel error
Date: Wed,  6 Jan 2010 13:23:30 -0500
Message-ID: <1262802213-2267-3-git-send-email-andros@netapp.com>
References: <1262802213-2267-1-git-send-email-andros@netapp.com>
 <1262802213-2267-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932560Ab0AFSXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 13:23:44 -0500
In-Reply-To: <1262802213-2267-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Skip all other processing when error is encountered.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_xdr.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index e24487d..3637e9a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -613,7 +613,7 @@ static __be32 process_op(uint32_t minorversion, int nop,
 	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
 	if (unlikely(status))
-		goto out;
+		goto encode_hdr;
 
 	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
 		__func__, minorversion, nop, op_nr);
@@ -622,16 +622,19 @@ static __be32 process_op(uint32_t minorversion, int nop,
 				preprocess_nfs4_op(op_nr, &op);
 	if (status == htonl(NFS4ERR_OP_ILLEGAL))
 		op_nr = OP_CB_ILLEGAL;
-out:
+	if (status)
+		goto encode_hdr;
+
 	maxlen = xdr_out->end - xdr_out->p;
 	if (maxlen > 0 && maxlen < PAGE_SIZE) {
-		if (likely(status == 0 && op->decode_args != NULL))
+		if (likely(op->decode_args != NULL))
 			status = op->decode_args(rqstp, xdr_in, argp);
 		if (likely(status == 0 && op->process_op != NULL))
 			status = op->process_op(argp, resp);
 	} else
 		status = htonl(NFS4ERR_RESOURCE);
 
+encode_hdr:
 	res = encode_op_hdr(xdr_out, op_nr, status);
 	if (status == 0)
 		status = res;
-- 
1.6.5.2


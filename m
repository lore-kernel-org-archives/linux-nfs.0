From: andros@netapp.com
Subject: [PATCH 2/7] nfs41: directly encode back channel error
Date: Thu, 14 Jan 2010 17:45:05 -0500
Message-ID: <1263509110-3097-3-git-send-email-andros@netapp.com>
References: <1263509110-3097-1-git-send-email-andros@netapp.com>
 <1263509110-3097-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20512 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756898Ab0ANWpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 17:45:15 -0500
In-Reply-To: <1263509110-3097-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Skip all other processing when error is encountered.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_xdr.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 6ae3278..d3e07f4 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -625,16 +625,19 @@ static __be32 process_op(uint32_t minorversion, int nop,
 				preprocess_nfs4_op(op_nr, &op);
 	if (status == htonl(NFS4ERR_OP_ILLEGAL))
 		op_nr = OP_CB_ILLEGAL;
+	if (status)
+		goto encode_hdr;
 
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
 	if (unlikely(res))
 		return res;
-- 
1.6.5.2


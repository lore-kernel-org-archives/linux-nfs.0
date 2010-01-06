From: andros@netapp.com
Subject: [PATCH 1/5] nfs41: fix wrong error on callback decode hdr overflow
Date: Wed,  6 Jan 2010 13:23:29 -0500
Message-ID: <1262802213-2267-2-git-send-email-andros@netapp.com>
References: <1262802213-2267-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932549Ab0AFSXo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 13:23:44 -0500
In-Reply-To: <1262802213-2267-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

decode_op_hdr returns NFS4ERR_RESOURCE on decode buffer overflow which is
correct for v4.0. Will fix the return for v4.1 along with all the other
NFS4ERR_RESOURCE overflow errors in a later patch.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_xdr.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 8e1a251..e24487d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -605,17 +605,15 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		struct xdr_stream *xdr_out, void *resp)
 {
 	struct callback_op *op = &callback_ops[0];
-	unsigned int op_nr = OP_CB_ILLEGAL;
+	unsigned int op_nr;
 	__be32 status;
 	long maxlen;
 	__be32 res;
 
 	dprintk("%s: start\n", __func__);
 	status = decode_op_hdr(xdr_in, &op_nr);
-	if (unlikely(status)) {
-		status = htonl(NFS4ERR_OP_ILLEGAL);
+	if (unlikely(status))
 		goto out;
-	}
 
 	dprintk("%s: minorversion=%d nop=%d op_nr=%u\n",
 		__func__, minorversion, nop, op_nr);
-- 
1.6.5.2


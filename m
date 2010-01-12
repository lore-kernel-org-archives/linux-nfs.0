From: andros@netapp.com
Subject: [PATCH 3/6] nfs41: remove uneeded checks in callback processing
Date: Tue, 12 Jan 2010 16:48:36 -0500
Message-ID: <1263332919-2900-4-git-send-email-andros@netapp.com>
References: <1263332919-2900-1-git-send-email-andros@netapp.com>
 <1263332919-2900-2-git-send-email-andros@netapp.com>
 <1263332919-2900-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32484 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752079Ab0ALVs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2010 16:48:58 -0500
In-Reply-To: <1263332919-2900-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

All callback operations have arguments to decode and require processing.
The preprocess_nfs4X_op functions catch unsupported or illegal ops so
decode_args and process_op pointers are always non NULL.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/callback_xdr.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index d3e07f4..a6f2ded 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -630,9 +630,8 @@ static __be32 process_op(uint32_t minorversion, int nop,
 
 	maxlen = xdr_out->end - xdr_out->p;
 	if (maxlen > 0 && maxlen < PAGE_SIZE) {
-		if (likely(op->decode_args != NULL))
-			status = op->decode_args(rqstp, xdr_in, argp);
-		if (likely(status == 0 && op->process_op != NULL))
+		status = op->decode_args(rqstp, xdr_in, argp);
+		if (likely(status == 0))
 			status = op->process_op(argp, resp);
 	} else
 		status = htonl(NFS4ERR_RESOURCE);
-- 
1.6.5.2


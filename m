From: andros@netapp.com
Subject: [PATCH 3/5] nfs41: remove uneeded checks in callback processing
Date: Wed,  6 Jan 2010 13:23:31 -0500
Message-ID: <1262802213-2267-4-git-send-email-andros@netapp.com>
References: <1262802213-2267-1-git-send-email-andros@netapp.com>
 <1262802213-2267-2-git-send-email-andros@netapp.com>
 <1262802213-2267-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27393 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932552Ab0AFSXp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 13:23:45 -0500
In-Reply-To: <1262802213-2267-3-git-send-email-andros@netapp.com>
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
index 3637e9a..c64a174 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -627,9 +627,8 @@ static __be32 process_op(uint32_t minorversion, int nop,
 
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


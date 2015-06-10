Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:33102 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176AbbFJOpe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2015 10:45:34 -0400
Date: Wed, 10 Jun 2015 20:15:29 +0530
From: Vaishali Thakkar <vthakkar1994@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
Subject: [PATCH] NFS: Convert use of __constant_htonl to htonl
Message-ID: <20150610144529.GA4435@vaishali-Ideapad-Z570>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In little endian cases, the macro htonl unfolds to __swab32 which
provides special case for constants. In big endian cases,
__constant_htonl and htonl expand directly to the same expression.
So, replace __constant_htonl with htonl with the goal of getting
rid of the definition of __constant_htonl completely.

The semantic patch that performs this transformation is as follows:

@@expression x;@@

- __constant_htonl(x)
+ htonl(x)

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 fs/nfs/callback_xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 19ca95c..6b1697a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -909,7 +909,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	xdr_init_encode(&xdr_out, &rqstp->rq_res, p);
 
 	status = decode_compound_hdr_arg(&xdr_in, &hdr_arg);
-	if (status == __constant_htonl(NFS4ERR_RESOURCE))
+	if (status == htonl(NFS4ERR_RESOURCE))
 		return rpc_garbage_args;
 
 	if (hdr_arg.minorversion == 0) {
-- 
1.9.1


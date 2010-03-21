Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cdptpa-omtalb.mail.rr.com ([75.180.132.123]:64968 "EHLO
	cdptpa-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248Ab0CULRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Mar 2010 07:17:41 -0400
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Subject: [PATCH] NFS: don't try to decode GETATTR if DELEGRETURN returned error
Date: Sun, 21 Mar 2010 07:17:38 -0400
Message-Id: <1269170258-31596-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The reply parsing code attempts to decode the GETATTR response even if
the DELEGRETURN portion of the compound returned an error. The GETATTR
response won't actually exist if that's the case and we're asking the
parser to read past the end of the response.

This bug is fairly benign. The parser catches this without reading past
the end of the response and decode_getfattr returns -EIO. Earlier
kernels however had decode_op_hdr using the READ_BUF macro, and this
bug would make this printk pop any time the client got an error from
a delegreturn:

kernel: decode_op_hdr: reply buffer overflowed in line XXXX

More recent kernels seem to have replaced this printk with a dprintk.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4xdr.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4d338be..dd17713 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5552,6 +5552,8 @@ static int nfs4_xdr_dec_delegreturn(struct rpc_rqst *rqstp, __be32 *p, struct nf
 	if (status != 0)
 		goto out;
 	status = decode_delegreturn(&xdr);
+	if (status != 0)
+		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server,
 			!RPC_IS_ASYNC(rqstp->rq_task));
 out:
-- 
1.6.6.1


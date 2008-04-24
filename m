From: tony-B47dsA4koDqXvyopL2yb9tBPR1lH4CV8@public.gmane.org (Tony Breeds)
Subject: [PATCH] Silence 'may be used uninitialized' warning in fs/nfs/callback_xdr.c
Date: Thu, 24 Apr 2008 14:22:15 +1000
Message-ID: <20080424042215.GO20457@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pythia.bakeyournoodle.com ([203.82.209.197]:36372 "EHLO
	pythia.bakeyournoodle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbYDXEz0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Apr 2008 00:55:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the kernel will issue the following warnings:

fs/nfs/callback_xdr.c: In function 'nfs4_callback_compound':
fs/nfs/callback_xdr.c:404: warning: 'hdr_arg.taglen' may be used uninitialized in this function
fs/nfs/callback_xdr.c:404: warning: 'hdr_arg.tag' may be used uninitialized in this function
fs/nfs/callback_xdr.c:404: warning: 'hdr_arg.nops' may be used uninitialized in this function

It seems that call chain look something like:
nfs4_callback_compound() 
 -> decode_compound_hdr_arg()
  -> decode_string() which may fail and return NFS4ERR_RESOURCE. 
Which decode_compound_hdr_arg() passes on.  Unfortunately
nfs4_callback_compound() doesn't check this status and cheerfully uses
hdr_arg which is basically stack garbage.  The same problem seems to
apply to encode_compound_hdr_res().

Check the return values, and explictly tell gcc to silence that warning.

Signed-off-by: Tony Breeds <tony-B47dsA4koDqXvyopL2yb9tBPR1lH4CV8@public.gmane.org>
---
 fs/nfs/callback_xdr.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 13619d2..d26af3e 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -401,7 +401,7 @@ static __be32 process_op(struct svc_rqst *rqstp,
  */
 static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *resp)
 {
-	struct cb_compound_hdr_arg hdr_arg;
+	struct cb_compound_hdr_arg uninitialized_var(hdr_arg);
 	struct cb_compound_hdr_res hdr_res;
 	struct xdr_stream xdr_in, xdr_out;
 	__be32 *p;
@@ -415,11 +415,15 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 	p = (__be32*)((char *)rqstp->rq_res.head[0].iov_base + rqstp->rq_res.head[0].iov_len);
 	xdr_init_encode(&xdr_out, &rqstp->rq_res, p);
 
-	decode_compound_hdr_arg(&xdr_in, &hdr_arg);
+	status = decode_compound_hdr_arg(&xdr_in, &hdr_arg);
+	if (unlikely(status != 0))
+		return status;
 	hdr_res.taglen = hdr_arg.taglen;
 	hdr_res.tag = hdr_arg.tag;
 	hdr_res.nops = NULL;
-	encode_compound_hdr_res(&xdr_out, &hdr_res);
+	status = encode_compound_hdr_res(&xdr_out, &hdr_res);
+	if (unlikely(status != 0))
+		return status;
 
 	for (;;) {
 		status = process_op(rqstp, &xdr_in, argp, &xdr_out, resp);
-- 
1.5.5.1



Yours Tony

  linux.conf.au    http://www.marchsouth.org/
  Jan 19 - 24 2009 The Australian Linux Technical Conference!


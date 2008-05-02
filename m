From: akpm@linux-foundation.org
Subject: [patch 1/5] fs/nfs/callback_xdr.c: suppress uninitialiized variable warnings
Date: Fri, 02 May 2008 13:42:40 -0700
Message-ID: <200805022042.m42KgfHl013872@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52164 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932658AbYEBUm5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 16:42:57 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

I'm tired of reading this:

fs/nfs/callback_xdr.c: In function 'nfs4_callback_compound':
fs/nfs/callback_xdr.c:404: warning: 'hdr_arg.taglen' may be used uninitialized in this function
fs/nfs/callback_xdr.c:404: warning: 'hdr_arg.tag' may be used uninitialized in this function
fs/nfs/callback_xdr.c:404: warning: 'hdr_arg.nops' may be used uninitialized in this function

Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/nfs/callback_xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN fs/nfs/callback_xdr.c~fs-nfs-callback_xdrc-suppress-uninitialiized-variable-warnings fs/nfs/callback_xdr.c
--- a/fs/nfs/callback_xdr.c~fs-nfs-callback_xdrc-suppress-uninitialiized-variable-warnings
+++ a/fs/nfs/callback_xdr.c
@@ -401,7 +401,7 @@ static __be32 process_op(struct svc_rqst
  */
 static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *resp)
 {
-	struct cb_compound_hdr_arg hdr_arg;
+	struct cb_compound_hdr_arg uninitialized_var(hdr_arg);
 	struct cb_compound_hdr_res hdr_res;
 	struct xdr_stream xdr_in, xdr_out;
 	__be32 *p;
_

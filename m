From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 14/15] svcgss: move init code into separate function
Date: Mon, 27 Aug 2007 16:22:55 -0400
Message-ID: <11882461781295-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
	<1188246177259-git-send-email-bfields@fieldses.org>
	<1188246177192-git-send-email-bfields@fieldses.org>
	<11882461773221-git-send-email-bfields@fieldses.org>
	<11882461773657-git-send-email-bfields@fieldses.org>
	<11882461772689-git-send-email-bfields@fieldses.org>
	<11882461782430-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl73-0004kX-AW
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:05 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl76-0003OG-Iv
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:09 -0700
In-Reply-To: <11882461782430-git-send-email-bfields@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

We've let svcauth_gss_accept() get much too long and hairy.  The
RPC_GSS_PROC_INIT and RPC_GSS_PROC_CONTINUE_INIT cases share very little
with the other cases, so it's very natural to split them off into a
separate function.

This will also nicely isolate the piece of code we need to parametrize
to authenticating gss-protected NFSv4 callbacks on behalf of the NFS
client.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/auth_gss/svcauth_gss.c |  144 ++++++++++++++++++++-----------------
 1 files changed, 77 insertions(+), 67 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index dc2f41e..79a507e 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -632,7 +632,8 @@ svc_safe_putnetobj(struct kvec *resv, struct xdr_netobj *o)
 	return 0;
 }
 
-/* Verify the checksum on the header and return SVC_OK on success.
+/*
+ * Verify the checksum on the header and return SVC_OK on success.
  * Otherwise, return SVC_DROP (in the case of a bad sequence number)
  * or return SVC_DENIED and indicate error in authp.
  */
@@ -962,6 +963,78 @@ gss_write_init_verf(struct svc_rqst *rqstp, struct rsi *rsip)
 }
 
 /*
+ * Having read the cred already and found we're in the context
+ * initiation case, read the verifier and initiate (or check the results
+ * of) upcalls to userspace for help with context initiation.  If
+ * the upcall results are available, write the verifier and result.
+ * Otherwise, drop the request pending an answer to the upcall.
+ */
+static int svcauth_gss_handle_init(struct svc_rqst *rqstp,
+			struct rpc_gss_wire_cred *gc, __be32 *authp)
+{
+	struct kvec *argv = &rqstp->rq_arg.head[0];
+	struct kvec *resv = &rqstp->rq_res.head[0];
+	struct xdr_netobj tmpobj;
+	struct rsi *rsip, rsikey;
+
+	/* Read the verifier; should be NULL: */
+	*authp = rpc_autherr_badverf;
+	if (argv->iov_len < 2 * 4)
+		return SVC_DENIED;
+	if (svc_getnl(argv) != RPC_AUTH_NULL)
+		return SVC_DENIED;
+	if (svc_getnl(argv) != 0)
+		return SVC_DENIED;
+
+	/* Martial context handle and token for upcall: */
+	*authp = rpc_autherr_badcred;
+	if (gc->gc_proc == RPC_GSS_PROC_INIT && gc->gc_ctx.len != 0)
+		return SVC_DENIED;
+	memset(&rsikey, 0, sizeof(rsikey));
+	if (dup_netobj(&rsikey.in_handle, &gc->gc_ctx))
+		return SVC_DROP;
+	*authp = rpc_autherr_badverf;
+	if (svc_safe_getnetobj(argv, &tmpobj)) {
+		kfree(rsikey.in_handle.data);
+		return SVC_DENIED;
+	}
+	if (dup_netobj(&rsikey.in_token, &tmpobj)) {
+		kfree(rsikey.in_handle.data);
+		return SVC_DROP;
+	}
+
+	/* Perform upcall, or find upcall result: */
+	rsip = rsi_lookup(&rsikey);
+	rsi_free(&rsikey);
+	if (!rsip)
+		return SVC_DROP;
+	switch (cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
+	case -EAGAIN:
+	case -ETIMEDOUT:
+	case -ENOENT:
+		/* No upcall result: */
+		return SVC_DROP;
+	case 0:
+		/* Got an answer to the upcall; use it: */
+		if (gss_write_init_verf(rqstp, rsip))
+			return SVC_DROP;
+		if (resv->iov_len + 4 > PAGE_SIZE)
+			return SVC_DROP;
+		svc_putnl(resv, RPC_SUCCESS);
+		if (svc_safe_putnetobj(resv, &rsip->out_handle))
+			return SVC_DROP;
+		if (resv->iov_len + 3 * 4 > PAGE_SIZE)
+			return SVC_DROP;
+		svc_putnl(resv, rsip->major_status);
+		svc_putnl(resv, rsip->minor_status);
+		svc_putnl(resv, GSS_SEQ_WIN);
+		if (svc_safe_putnetobj(resv, &rsip->out_token))
+			return SVC_DROP;
+	}
+	return SVC_COMPLETE;
+}
+
+/*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
  * If data exchange, verify/decrypt
@@ -975,11 +1048,9 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	struct kvec	*argv = &rqstp->rq_arg.head[0];
 	struct kvec	*resv = &rqstp->rq_res.head[0];
 	u32		crlen;
-	struct xdr_netobj tmpobj;
 	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
 	struct rpc_gss_wire_cred *gc;
 	struct rsc	*rsci = NULL;
-	struct rsi	*rsip, rsikey;
 	__be32		*rpcstart;
 	__be32		*reject_stat = resv->iov_base + resv->iov_len;
 	int		ret;
@@ -1024,30 +1095,14 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 	if ((gc->gc_proc != RPC_GSS_PROC_DATA) && (rqstp->rq_proc != 0))
 		goto auth_err;
 
-	/*
-	 * We've successfully parsed the credential. Let's check out the
-	 * verifier.  An AUTH_NULL verifier is allowed (and required) for
-	 * INIT and CONTINUE_INIT requests. AUTH_RPCSEC_GSS is required for
-	 * PROC_DATA and PROC_DESTROY.
-	 *
-	 * AUTH_NULL verifier is 0 (AUTH_NULL), 0 (length).
-	 * AUTH_RPCSEC_GSS verifier is:
-	 *   6 (AUTH_RPCSEC_GSS), length, checksum.
-	 * checksum is calculated over rpcheader from xid up to here.
-	 */
 	*authp = rpc_autherr_badverf;
 	switch (gc->gc_proc) {
 	case RPC_GSS_PROC_INIT:
 	case RPC_GSS_PROC_CONTINUE_INIT:
-		if (argv->iov_len < 2 * 4)
-			goto auth_err;
-		if (svc_getnl(argv) != RPC_AUTH_NULL)
-			goto auth_err;
-		if (svc_getnl(argv) != 0)
-			goto auth_err;
-		break;
+		return svcauth_gss_handle_init(rqstp, gc, authp);
 	case RPC_GSS_PROC_DATA:
 	case RPC_GSS_PROC_DESTROY:
+		/* Look up the context, and check the verifier: */
 		*authp = rpcsec_gsserr_credproblem;
 		rsci = gss_svc_searchbyctx(&gc->gc_ctx);
 		if (!rsci)
@@ -1068,51 +1123,6 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 
 	/* now act upon the command: */
 	switch (gc->gc_proc) {
-	case RPC_GSS_PROC_INIT:
-	case RPC_GSS_PROC_CONTINUE_INIT:
-		*authp = rpc_autherr_badcred;
-		if (gc->gc_proc == RPC_GSS_PROC_INIT && gc->gc_ctx.len != 0)
-			goto auth_err;
-		memset(&rsikey, 0, sizeof(rsikey));
-		if (dup_netobj(&rsikey.in_handle, &gc->gc_ctx))
-			goto drop;
-		*authp = rpc_autherr_badverf;
-		if (svc_safe_getnetobj(argv, &tmpobj)) {
-			kfree(rsikey.in_handle.data);
-			goto auth_err;
-		}
-		if (dup_netobj(&rsikey.in_token, &tmpobj)) {
-			kfree(rsikey.in_handle.data);
-			goto drop;
-		}
-
-		rsip = rsi_lookup(&rsikey);
-		rsi_free(&rsikey);
-		if (!rsip) {
-			goto drop;
-		}
-		switch(cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
-		case -EAGAIN:
-		case -ETIMEDOUT:
-		case -ENOENT:
-			goto drop;
-		case 0:
-			if (gss_write_init_verf(rqstp, rsip))
-				goto drop;
-			if (resv->iov_len + 4 > PAGE_SIZE)
-				goto drop;
-			svc_putnl(resv, RPC_SUCCESS);
-			if (svc_safe_putnetobj(resv, &rsip->out_handle))
-				goto drop;
-			if (resv->iov_len + 3 * 4 > PAGE_SIZE)
-				goto drop;
-			svc_putnl(resv, rsip->major_status);
-			svc_putnl(resv, rsip->minor_status);
-			svc_putnl(resv, GSS_SEQ_WIN);
-			if (svc_safe_putnetobj(resv, &rsip->out_token))
-				goto drop;
-		}
-		goto complete;
 	case RPC_GSS_PROC_DESTROY:
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
@@ -1159,7 +1169,7 @@ svcauth_gss_accept(struct svc_rqst *rqstp, __be32 *authp)
 		goto out;
 	}
 auth_err:
-	/* Restore write pointer to original value: */
+	/* Restore write pointer to its original value: */
 	xdr_ressize_check(rqstp, reject_stat);
 	ret = SVC_DENIED;
 	goto out;
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

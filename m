From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Compilation warning with current git on x86_64
Date: Sat, 14 Jul 2007 11:15:44 -0400
Message-ID: <1184426144.7115.6.camel@heimdal.trondhjem.org>
References: <Line.LNX.4.64.0707141107060.26121@d.namei>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-HGTKE7pnf/i4NnABou/7"
Cc: nfs@lists.sourceforge.net
To: James Morris <jmorris@namei.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9jLa-0003iR-RE
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 08:15:52 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19J+Vnd87P66lE6qzXx2GtKoFwiv4J9z64=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9jLd-0002Zd-MQ
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 08:15:54 -0700
In-Reply-To: <Line.LNX.4.64.0707141107060.26121@d.namei>
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


--=-HGTKE7pnf/i4NnABou/7
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-07-14 at 11:07 -0400, James Morris wrote:
> net/sunrpc/auth_gss/auth_gss.c:1002: warning: implicit declaration of=20
> function =C3=A2lock_kernel
> net/sunrpc/auth_gss/auth_gss.c:1004: warning: implicit declaration of=20
> function =C3=A2unlock_kernel
>=20
>=20
> I think these are fairly new?

Yes. Sorry about that... The attached cleanup from Bruce ought to help.

Cheers
  Trond


--=-HGTKE7pnf/i4NnABou/7
Content-Disposition: inline
Content-Description: Attached message - [PATCH] sunrpc: move bkl locking
	and xdr proc invocation into a common function
Content-Type: message/rfc822

Return-Path: <bfields@fieldses.org>
Received: from mail-imap5.uio.no ([unix socket]) by mail-imap5.uio.no
	(Cyrus v2.2.12) with LMTPA; Thu, 12 Jul 2007 00:39:07 +0200
X-Sieve: CMU Sieve 2.2
Delivery-date: Thu, 12 Jul 2007 00:39:07 +0200
Received: from mail-mx8.uio.no ([129.240.10.38]) by mail-imap5.uio.no with
	esmtp (Exim 4.66) (envelope-from <bfields@fieldses.org>) id
	1I8kpu-0006sb-Tj for trond.myklebust@fys.uio.no;
	Thu, 12 Jul 2007 00:39:06 +0200
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org) by
	mail-mx8.uio.no with esmtps (TLSv1:AES256-SHA:256) (Exim 4.67)
	(envelope-from <bfields@fieldses.org>) id 1I8kpt-00057R-MB for
	trond.myklebust@fys.uio.no; Thu, 12 Jul 2007 00:39:06 +0200
Received: from bfields by fieldses.org with local (Exim 4.67)
	(envelope-from <bfields@fieldses.org>) id 1I8kpq-0000WE-3S; Wed, 11 Jul
	2007 18:39:02 -0400
Date: Wed, 11 Jul 2007 18:39:02 -0400
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: nfsv4@linux-nfs.org
Subject: [PATCH] sunrpc: move bkl locking and xdr proc invocation into a
	common function
Message-ID: <20070711223902.GM4138@fieldses.org>
References: <20070710191926.GI17368@fieldses.org>
	<1184103432.6480.23.camel@heimdal.trondhjem.org>
	<20070710221305.GA13663@fieldses.org>
	<20070710221626.GB13663@fieldses.org>
	<1184107846.6480.31.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1184107846.6480.31.camel@heimdal.trondhjem.org>
User-Agent: Mutt/1.5.16 (2007-06-11)
From: "J. Bruce Fields" <bfields@fieldses.org>
X-UiO-MailScanner: No virus found
X-UiO-Spam-info: not spam, SpamAssassin (score=-0.3, required=12.0,
	autolearn=disabled, AWL=-0.273)
X-UiO-Scanned: B0C3CABDE6284EDEFAB5F80F25E6798CFF8E6D19
X-UiO-SPAM-Test: remote_host: 66.93.2.214 spam_score: -2 maxlevel 60
	minaction 1 bait 0 mail/h: 1 total 69 max/h 6 blacklist 0 greylist 0
	ratelimit 0
X-Evolution-Source: imap://trondmy@imap.uio.no/
Content-Transfer-Encoding: 7bit

From: J. Bruce Fields <bfields@citi.umich.edu>

Since every invocation of xdr encode or decode functions takes the BKL now,
there's a lot of redundant lock_kernel/unlock_kernel pairs that we can pull out
into a common function.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/xdr.h     |   16 ++++++++++++++++
 net/sunrpc/auth.c              |   12 ++----------
 net/sunrpc/auth_gss/auth_gss.c |   20 +++++---------------
 3 files changed, 23 insertions(+), 25 deletions(-)

> It's fine to keep it as a separate patch, but you're going to have to do
> something about the name: do_xdrproc() breaks with the standard sunrpc
> namespace conventions. How about naming it rpc_call_xdrproc().

Sounds fine.  Here's take two, with the new name and an additional
comment.

--b.

diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
index 9e340fa..c6b53d1 100644
--- a/include/linux/sunrpc/xdr.h
+++ b/include/linux/sunrpc/xdr.h
@@ -12,6 +12,7 @@
 #include <linux/uio.h>
 #include <asm/byteorder.h>
 #include <linux/scatterlist.h>
+#include <linux/smp_lock.h>
 
 /*
  * Buffer adjustment
@@ -36,6 +37,21 @@ struct xdr_netobj {
 typedef int	(*kxdrproc_t)(void *rqstp, __be32 *data, void *obj);
 
 /*
+ * We're still requiring the BKL in the xdr code until it's been
+ * more carefully audited, at which point this wrapper will become
+ * unnecessary.
+ */
+static inline int rpc_call_xdrproc(kxdrproc_t xdrproc, void *rqstp, __be32 *data, void *obj)
+{
+	int ret;
+
+	lock_kernel();
+	ret = xdrproc(rqstp, data, obj);
+	unlock_kernel();
+	return ret;
+}
+
+/*
  * Basic structure for transmission/reception of a client XDR message.
  * Features a header (for a linear buffer containing RPC headers
  * and the data payload for short messages), and then an array of
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index e04da66..cd31cbd 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -359,17 +359,13 @@ rpcauth_wrap_req(struct rpc_task *task, kxdrproc_t encode, void *rqstp,
 		__be32 *data, void *obj)
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
-	int ret;
 
 	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
 			task->tk_pid, cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
 	/* By default, we encode the arguments normally. */
-	lock_kernel();
-	ret = encode(rqstp, data, obj);
-	unlock_kernel();
-	return ret;
+	return rpc_call_xdrproc(encode, rqstp, data, obj);
 }
 
 int
@@ -377,7 +373,6 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
 		__be32 *data, void *obj)
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
-	int ret;
 
 	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
 			task->tk_pid, cred->cr_ops->cr_name, cred);
@@ -385,10 +380,7 @@ rpcauth_unwrap_resp(struct rpc_task *task, kxdrproc_t decode, void *rqstp,
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
 						   data, obj);
 	/* By default, we decode the arguments normally. */
-	lock_kernel();
-	ret = decode(rqstp, data, obj);
-	unlock_kernel();
-	return ret;
+	return rpc_call_xdrproc(decode, rqstp, data, obj);
 }
 
 int
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index a001973..73fd24c 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -917,9 +917,7 @@ gss_wrap_req_integ(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	lock_kernel();
-	status = encode(rqstp, p, obj);
-	unlock_kernel();
+	status = rpc_call_xdrproc(encode, rqstp, p, obj);
 	if (status)
 		return status;
 
@@ -1013,9 +1011,7 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	offset = (u8 *)p - (u8 *)snd_buf->head[0].iov_base;
 	*p++ = htonl(rqstp->rq_seqno);
 
-	lock_kernel();
-	status = encode(rqstp, p, obj);
-	unlock_kernel();
+	status = rpc_call_xdrproc(encode, rqstp, p, obj);
 	if (status)
 		return status;
 
@@ -1074,16 +1070,12 @@ gss_wrap_req(struct rpc_task *task,
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
 		 */
-		lock_kernel();
-		status = encode(rqstp, p, obj);
-		unlock_kernel();
+		status = rpc_call_xdrproc(encode, rqstp, p, obj);
 		goto out;
 	}
 	switch (gss_cred->gc_service) {
 		case RPC_GSS_SVC_NONE:
-			lock_kernel();
-			status = encode(rqstp, p, obj);
-			unlock_kernel();
+			status = rpc_call_xdrproc(encode, rqstp, p, obj);
 			break;
 		case RPC_GSS_SVC_INTEGRITY:
 			status = gss_wrap_req_integ(cred, ctx, encode,
@@ -1199,9 +1191,7 @@ gss_unwrap_resp(struct rpc_task *task,
 	task->tk_auth->au_rslack = task->tk_auth->au_verfsize + (p - savedp)
 						+ (savedlen - head->iov_len);
 out_decode:
-	lock_kernel();
-	status = decode(rqstp, p, obj);
-	unlock_kernel();
+	status = rpc_call_xdrproc(decode, rqstp, p, obj);
 out:
 	gss_put_ctx(ctx);
 	dprintk("RPC: %5u gss_unwrap_resp returning %d\n", task->tk_pid,
-- 
1.5.3.rc0.63.gc956


--=-HGTKE7pnf/i4NnABou/7
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--=-HGTKE7pnf/i4NnABou/7
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-HGTKE7pnf/i4NnABou/7--

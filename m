From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 2 of 34 - gss api changes for integrity checking.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006H0-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPqH-0006tQ-AG
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:29 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPeI-0002LN-Iw
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:38:06 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:41 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Doesn't actually add integrity support on the server yet; just adapts
server-side code to the gss api changes necessary to get integrity working on
the client.

 ----------- Diffstat output ------------
 ./net/sunrpc/auth_gss/gss_krb5_seal.c |    3 ---
 ./net/sunrpc/auth_gss/svcauth_gss.c   |   16 ++++++++++------
 2 files changed, 10 insertions(+), 9 deletions(-)

diff ./net/sunrpc/auth_gss/gss_krb5_seal.c~current~ ./net/sunrpc/auth_gss/gss_krb5_seal.c
--- ./net/sunrpc/auth_gss/gss_krb5_seal.c~current~	2004-02-24 10:41:14.000000000 +1100
+++ ./net/sunrpc/auth_gss/gss_krb5_seal.c	2004-02-24 10:41:20.000000000 +1100
@@ -169,8 +169,5 @@ krb5_make_token(struct krb5_ctx *ctx, in
 	return ((ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE);
 out_err:
 	if (md5cksum.data) kfree(md5cksum.data);
-	if (token->data) kfree(token->data);
-	token->data = 0;
-	token->len = 0;
 	return GSS_S_FAILURE;
 }

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-02-24 10:40:29.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-02-24 10:40:36.000000000 +1100
@@ -531,14 +531,16 @@ gss_verify_header(struct svc_rqst *rqstp
 		  u32 *rpcstart, struct rpc_gss_wire_cred *gc, u32 *authp)
 {
 	struct gss_ctx		*ctx_id = rsci->mechctx;
-	struct xdr_netobj	rpchdr;
+	struct xdr_buf		rpchdr;
 	struct xdr_netobj	checksum;
 	u32			flavor = 0;
 	struct iovec		*argv = &rqstp->rq_arg.head[0];
+	struct iovec		iov;
 
 	/* data to compute the checksum over: */
-	rpchdr.data = (u8 *)rpcstart;
-	rpchdr.len = (u8 *)argv->iov_base - (u8 *)rpcstart;
+	iov.iov_base = rpcstart;
+	iov.iov_len = (u8 *)argv->iov_base - (u8 *)rpcstart;
+	xdr_buf_from_iov(&iov, &rpchdr);
 
 	*authp = rpc_autherr_badverf;
 	if (argv->iov_len < 4)
@@ -576,15 +578,17 @@ gss_write_verf(struct svc_rqst *rqstp, s
 {
 	u32			xdr_seq;
 	u32			maj_stat;
-	struct xdr_netobj	verf_data;
+	struct xdr_buf		verf_data;
 	struct xdr_netobj	mic;
 	u32			*p;
+	struct iovec		iov;
 
 	svc_putu32(rqstp->rq_res.head, htonl(RPC_AUTH_GSS));
 	xdr_seq = htonl(seq);
 
-	verf_data.data = (u8 *)&xdr_seq;
-	verf_data.len = sizeof(xdr_seq);
+	iov.iov_base = &xdr_seq;
+	iov.iov_len = sizeof(xdr_seq);
+	xdr_buf_from_iov(&iov, &verf_data);
 	p = rqstp->rq_res.head->iov_base + rqstp->rq_res.head->iov_len;
 	maj_stat = gss_get_mic(ctx_id, 0, &verf_data, &mic);
 	if (maj_stat != GSS_S_COMPLETE)


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 8 of 8 - Add data integrity to serve rside gss
Date: Thu, 25 Mar 2004 12:06:55 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1B6JKh-0007EG-00@notabene>
References: <20040325120312.27644.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6JKv-0006cm-IZ
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:09 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1B6JKu-0002as-Mr
	for nfs@lists.sourceforge.net; Wed, 24 Mar 2004 17:07:08 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 25 Mar 2004 12:07:03 +1100
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


From: "J. Bruce Fields" <bfields@fieldses.org>

rpcsec_gss supports three security levels:
	1. authentication only: sign the header of each rpc request and
	   response.
	2. integrity: sign the header and body of each rpc request and response.
	3. privacy: sign the header and encrypt the body of each rpc request
	   and response.

The first 2 are already supported on the client; this adds integrity support
on the server.


 ----------- Diffstat output ------------
 ./include/linux/sunrpc/svcauth_gss.h  |    9 -
 ./net/sunrpc/auth_gss/gss_krb5_mech.c |    2 
 ./net/sunrpc/auth_gss/svcauth_gss.c   |  172 ++++++++++++++++++++++++++++++++--
 3 files changed, 168 insertions(+), 15 deletions(-)

diff ./include/linux/sunrpc/svcauth_gss.h~current~ ./include/linux/sunrpc/svcauth_gss.h
--- ./include/linux/sunrpc/svcauth_gss.h~current~	2004-03-25 11:45:36.000000000 +1100
+++ ./include/linux/sunrpc/svcauth_gss.h	2004-03-25 11:47:43.000000000 +1100
@@ -22,14 +22,5 @@
 int gss_svc_init(void);
 int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
 
-
-struct gss_svc_data {
-	/* decoded gss client cred: */
-	struct rpc_gss_wire_cred	clcred;
-	/* pointer to the beginning of the procedure-specific results, which
-	 * may be encrypted/checksummed in svcauth_gss_release: */
-	u32				*body_start;
-};
-
 #endif /* __KERNEL__ */
 #endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */

diff ./net/sunrpc/auth_gss/gss_krb5_mech.c~current~ ./net/sunrpc/auth_gss/gss_krb5_mech.c
--- ./net/sunrpc/auth_gss/gss_krb5_mech.c~current~	2004-03-25 11:45:36.000000000 +1100
+++ ./net/sunrpc/auth_gss/gss_krb5_mech.c	2004-03-25 11:47:43.000000000 +1100
@@ -236,6 +236,8 @@ static int __init init_kerberos_module(v
 	gss_register_triple(RPC_AUTH_GSS_KRB5I, gm, 0, RPC_GSS_SVC_INTEGRITY);
 	if (svcauth_gss_register_pseudoflavor(RPC_AUTH_GSS_KRB5, "krb5"))
 		printk("Failed to register %s with server!\n", "krb5");
+	if (svcauth_gss_register_pseudoflavor(RPC_AUTH_GSS_KRB5I, "krb5i"))
+		printk("Failed to register %s with server!\n", "krb5i");
 	gss_mech_put(gm);
 	return 0;
 }

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-03-25 11:45:36.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-03-25 11:47:43.000000000 +1100
@@ -670,6 +670,68 @@ out:
 	return stat;
 }
 
+static inline int
+read_u32_from_xdr_buf(struct xdr_buf *buf, int base, u32 *obj)
+{
+	u32     raw;
+	int     status;
+
+	status = read_bytes_from_xdr_buf(buf, base, &raw, sizeof(*obj));
+	if (status)
+		return status;
+	*obj = ntohl(raw);
+	return 0;
+}
+
+/* It would be nice if this bit of code could be shared with the client.
+ * Obstacles:
+ *	The client shouldn't malloc(), would have to pass in own memory.
+ *	The server uses base of head iovec as read pointer, while the
+ *	client uses separate pointer. */
+static int
+unwrap_integ_data(struct xdr_buf *buf, u32 seq, struct gss_ctx *ctx)
+{
+	int stat = -EINVAL;
+	u32 integ_len, maj_stat;
+	struct xdr_netobj mic;
+	struct xdr_buf integ_buf;
+
+	integ_len = ntohl(svc_getu32(&buf->head[0]));
+	if (integ_len & 3)
+		goto out;
+	if (integ_len > buf->len)
+		goto out;
+	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
+		BUG();
+	/* copy out mic... */
+	if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
+		BUG();
+	if (mic.len > RPC_MAX_AUTH_SIZE)
+		goto out;
+	mic.data = kmalloc(mic.len, GFP_KERNEL);
+	if (!mic.data)
+		goto out;
+	if (read_bytes_from_xdr_buf(buf, integ_len + 4, mic.data, mic.len))
+		goto out;
+	maj_stat = gss_verify_mic(ctx, &integ_buf, &mic, NULL);
+	if (maj_stat != GSS_S_COMPLETE)
+		goto out;
+	if (ntohl(svc_getu32(&buf->head[0])) != seq)
+		goto out;
+	stat = 0;
+out:
+	return stat;
+}
+
+struct gss_svc_data {
+	/* decoded gss client cred: */
+	struct rpc_gss_wire_cred	clcred;
+	/* pointer to the beginning of the procedure-specific results,
+	 * which may be encrypted/checksummed in svcauth_gss_release: */
+	u32				*body_start;
+	struct rsc			*rsci;
+};
+
 /*
  * Accept an rpcsec packet.
  * If context establishment, punt to user space
@@ -701,6 +763,8 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	if (!svcdata)
 		goto auth_err;
 	rqstp->rq_auth_data = svcdata;
+	svcdata->body_start = 0;
+	svcdata->rsci = NULL;
 	gc = &svcdata->clcred;
 
 	/* start of rpc packet is 7 u32's back from here:
@@ -754,9 +818,6 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		break;
 	case RPC_GSS_PROC_DATA:
 	case RPC_GSS_PROC_DESTROY:
-		/* integrity and privacy unsupported: */
-		if (gc->gc_svc != RPC_GSS_SVC_NONE)
-			goto auth_err;
 		*authp = rpcsec_gsserr_credproblem;
 		rsci = gss_svc_searchbyctx(&gc->gc_ctx);
 		if (!rsci)
@@ -841,10 +902,28 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		*authp = rpcsec_gsserr_ctxproblem;
 		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
 			goto auth_err;
-		/* For use when wrapping: */
-		svcdata->body_start = resv->iov_base + 1;
 		rqstp->rq_cred = rsci->cred;
 		get_group_info(rsci->cred.cr_group_info);
+		*authp = rpc_autherr_badcred;
+		switch (gc->gc_svc) {
+		case RPC_GSS_SVC_NONE:
+			break;
+		case RPC_GSS_SVC_INTEGRITY:
+			if (unwrap_integ_data(&rqstp->rq_arg,
+					gc->gc_seq, rsci->mechctx))
+				goto auth_err;
+			svcdata->rsci = rsci;
+			cache_get(&rsci->h);
+			/* placeholders for length and seq. number: */
+			svcdata->body_start = resv->iov_base + resv->iov_len;
+			svc_putu32(resv, 0);
+			svc_putu32(resv, 0);
+			break;
+		case RPC_GSS_SVC_PRIVACY:
+			/* currently unsupported */
+		default:
+			goto auth_err;
+		}
 		ret = SVC_OK;
 		goto out;
 	}
@@ -867,14 +946,95 @@ out:
 static int
 svcauth_gss_release(struct svc_rqst *rqstp)
 {
+	struct gss_svc_data *gsd = (struct gss_svc_data *)rqstp->rq_auth_data;
+	struct rpc_gss_wire_cred *gc = &gsd->clcred;
+	struct xdr_buf *resbuf = &rqstp->rq_res;
+	struct xdr_buf integ_buf;
+	struct xdr_netobj mic;
+	struct iovec *resv;
+	u32 *p;
+	int integ_offset, integ_len;
+	int stat = -EINVAL;
+
+	if (gc->gc_proc != RPC_GSS_PROC_DATA) 
+		goto out;
+	/* Release can be called twice, but we only wrap once. */
+	if (gsd->body_start == 0)
+		goto out;
+	/* normally not set till svc_send, but we need it here: */
+	resbuf->len = resbuf->head[0].iov_len
+		+ resbuf->page_len + resbuf->tail[0].iov_len;
+	switch (gc->gc_svc) {
+	case RPC_GSS_SVC_NONE:
+		break;
+	case RPC_GSS_SVC_INTEGRITY:
+		p = gsd->body_start;
+		gsd->body_start = 0;
+		/* move accept_stat to right place: */
+		memcpy(p, p + 2, 4);
+		/* don't wrap in failure case: */
+		/* Note: counting on not getting here if call was not even
+		 * accepted! */
+		if (*p != rpc_success) {
+			resbuf->head[0].iov_len -= 2 * 4;
+			goto out;
+		}
+		p++;
+		integ_offset = (u8 *)(p + 1) - (u8 *)resbuf->head[0].iov_base;
+		integ_len = resbuf->len - integ_offset;
+		BUG_ON(integ_len % 4);
+		*p++ = htonl(integ_len);
+		*p++ = htonl(gc->gc_seq);
+		if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset,
+					integ_len))
+			BUG();
+		if (resbuf->page_len == 0
+			&& resbuf->tail[0].iov_len + RPC_MAX_AUTH_SIZE
+				< PAGE_SIZE) {
+			BUG_ON(resbuf->tail[0].iov_len);
+			/* Use head for everything */
+			resv = &resbuf->head[0];
+		} else if (resbuf->tail[0].iov_base == NULL) {
+			/* copied from nfsd4_encode_read */
+			svc_take_page(rqstp);
+			resbuf->tail[0].iov_base = page_address(rqstp
+					->rq_respages[rqstp->rq_resused-1]);
+			rqstp->rq_restailpage = rqstp->rq_resused-1;
+			resbuf->tail[0].iov_len = 0;
+			resv = &resbuf->tail[0];
+		} else {
+			resv = &resbuf->tail[0];
+		}
+		mic.data = (u8 *)resv->iov_base + resv->iov_len + 4;
+		if (gss_get_mic(gsd->rsci->mechctx, 0, &integ_buf, &mic))
+			goto out_err;
+		svc_putu32(resv, htonl(mic.len));
+		memset(mic.data + mic.len, 0,
+				round_up_to_quad(mic.len) - mic.len);
+		resv->iov_len += XDR_QUADLEN(mic.len) << 2;
+		/* not strictly required: */
+		resbuf->len += XDR_QUADLEN(mic.len) << 2;
+		BUG_ON(resv->iov_len > PAGE_SIZE);
+		break;
+	case RPC_GSS_SVC_PRIVACY:
+	default:
+		goto out_err;
+	}
+
+out:
+	stat = 0;
+out_err:
 	if (rqstp->rq_client)
 		auth_domain_put(rqstp->rq_client);
 	rqstp->rq_client = NULL;
 	if (rqstp->rq_cred.cr_group_info)
 		put_group_info(rqstp->rq_cred.cr_group_info);
 	rqstp->rq_cred.cr_group_info = NULL;
+	if (gsd->rsci)
+		rsc_put(&gsd->rsci->h, &rsc_cache);
+	gsd->rsci = NULL;
 
-	return 0;
+	return stat;
 }
 
 static void


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

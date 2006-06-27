From: NeilBrown <neilb@suse.de>
Subject: [PATCH 012 of 14] knfsd: svcrpc: Simplify nfsd rpcsec_gss
	integrity code
Date: Tue, 27 Jun 2006 17:20:37 +1000
Message-ID: <1060627072037.26733@suse.de>
References: <20060627171533.26405.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fv7sL-0006Pf-9o
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:45 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fv7sK-0007Q6-Mr
	for nfs@lists.sourceforge.net; Tue, 27 Jun 2006 00:20:45 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>


Pull out some of the integrity code into its own function, otherwise
svcauth_gss_release() is going to become very ungainly after the addition
of privacy code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |  115 ++++++++++++++++++++----------------
 1 file changed, 64 insertions(+), 51 deletions(-)

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2006-06-27 14:59:44.000000000 +1000
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-06-27 15:05:11.000000000 +1000
@@ -1072,8 +1072,8 @@ out:
 	return ret;
 }
 
-static int
-svcauth_gss_release(struct svc_rqst *rqstp)
+static inline int
+svcauth_gss_wrap_resp_integ(struct svc_rqst *rqstp)
 {
 	struct gss_svc_data *gsd = (struct gss_svc_data *)rqstp->rq_auth_data;
 	struct rpc_gss_wire_cred *gc = &gsd->clcred;
@@ -1085,6 +1085,67 @@ svcauth_gss_release(struct svc_rqst *rqs
 	int integ_offset, integ_len;
 	int stat = -EINVAL;
 
+	p = gsd->body_start;
+	gsd->body_start = NULL;
+	/* move accept_stat to right place: */
+	memcpy(p, p + 2, 4);
+	/* don't wrap in failure case: */
+	/* Note: counting on not getting here if call was not even
+	 * accepted! */
+	if (*p != rpc_success) {
+		resbuf->head[0].iov_len -= 2 * 4;
+		goto out;
+	}
+	p++;
+	integ_offset = (u8 *)(p + 1) - (u8 *)resbuf->head[0].iov_base;
+	integ_len = resbuf->len - integ_offset;
+	BUG_ON(integ_len % 4);
+	*p++ = htonl(integ_len);
+	*p++ = htonl(gc->gc_seq);
+	if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset,
+				integ_len))
+		BUG();
+	if (resbuf->page_len == 0
+			&& resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE
+			< PAGE_SIZE) {
+		BUG_ON(resbuf->tail[0].iov_len);
+		/* Use head for everything */
+		resv = &resbuf->head[0];
+	} else if (resbuf->tail[0].iov_base == NULL) {
+		if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE > PAGE_SIZE)
+			goto out_err;
+		resbuf->tail[0].iov_base = resbuf->head[0].iov_base
+						+ resbuf->head[0].iov_len;
+		resbuf->tail[0].iov_len = 0;
+		rqstp->rq_restailpage = 0;
+		resv = &resbuf->tail[0];
+	} else {
+		resv = &resbuf->tail[0];
+	}
+	mic.data = (u8 *)resv->iov_base + resv->iov_len + 4;
+	if (gss_get_mic(gsd->rsci->mechctx, &integ_buf, &mic))
+		goto out_err;
+	svc_putu32(resv, htonl(mic.len));
+	memset(mic.data + mic.len, 0,
+			round_up_to_quad(mic.len) - mic.len);
+	resv->iov_len += XDR_QUADLEN(mic.len) << 2;
+	/* not strictly required: */
+	resbuf->len += XDR_QUADLEN(mic.len) << 2;
+	BUG_ON(resv->iov_len > PAGE_SIZE);
+out:
+	stat = 0;
+out_err:
+	return stat;
+}
+
+static int
+svcauth_gss_release(struct svc_rqst *rqstp)
+{
+	struct gss_svc_data *gsd = (struct gss_svc_data *)rqstp->rq_auth_data;
+	struct rpc_gss_wire_cred *gc = &gsd->clcred;
+	struct xdr_buf *resbuf = &rqstp->rq_res;
+	int stat = -EINVAL;
+
 	if (gc->gc_proc != RPC_GSS_PROC_DATA)
 		goto out;
 	/* Release can be called twice, but we only wrap once. */
@@ -1097,55 +1158,7 @@ svcauth_gss_release(struct svc_rqst *rqs
 	case RPC_GSS_SVC_NONE:
 		break;
 	case RPC_GSS_SVC_INTEGRITY:
-		p = gsd->body_start;
-		gsd->body_start = NULL;
-		/* move accept_stat to right place: */
-		memcpy(p, p + 2, 4);
-		/* don't wrap in failure case: */
-		/* Note: counting on not getting here if call was not even
-		 * accepted! */
-		if (*p != rpc_success) {
-			resbuf->head[0].iov_len -= 2 * 4;
-			goto out;
-		}
-		p++;
-		integ_offset = (u8 *)(p + 1) - (u8 *)resbuf->head[0].iov_base;
-		integ_len = resbuf->len - integ_offset;
-		BUG_ON(integ_len % 4);
-		*p++ = htonl(integ_len);
-		*p++ = htonl(gc->gc_seq);
-		if (xdr_buf_subsegment(resbuf, &integ_buf, integ_offset,
-					integ_len))
-			BUG();
-		if (resbuf->page_len == 0
-			&& resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE
-				< PAGE_SIZE) {
-			BUG_ON(resbuf->tail[0].iov_len);
-			/* Use head for everything */
-			resv = &resbuf->head[0];
-		} else if (resbuf->tail[0].iov_base == NULL) {
-			if (resbuf->head[0].iov_len + RPC_MAX_AUTH_SIZE
-					> PAGE_SIZE)
-				goto out_err;
-			resbuf->tail[0].iov_base =
-				resbuf->head[0].iov_base
-				+ resbuf->head[0].iov_len;
-			resbuf->tail[0].iov_len = 0;
-			rqstp->rq_restailpage = 0;
-			resv = &resbuf->tail[0];
-		} else {
-			resv = &resbuf->tail[0];
-		}
-		mic.data = (u8 *)resv->iov_base + resv->iov_len + 4;
-		if (gss_get_mic(gsd->rsci->mechctx, &integ_buf, &mic))
-			goto out_err;
-		svc_putu32(resv, htonl(mic.len));
-		memset(mic.data + mic.len, 0,
-				round_up_to_quad(mic.len) - mic.len);
-		resv->iov_len += XDR_QUADLEN(mic.len) << 2;
-		/* not strictly required: */
-		resbuf->len += XDR_QUADLEN(mic.len) << 2;
-		BUG_ON(resv->iov_len > PAGE_SIZE);
+		svcauth_gss_wrap_resp_integ(rqstp);
 		break;
 	case RPC_GSS_SVC_PRIVACY:
 	default:

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

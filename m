From: Steve Dickson <SteveD@redhat.com>
Subject: [NFS][PATCH] Adding debugging to svcauth_gss
Date: Mon, 14 Feb 2005 21:42:52 -0500
Message-ID: <421161AC.6090708@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030404090804030306060004"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D0sfK-0008P9-H8
	for nfs@lists.sourceforge.net; Mon, 14 Feb 2005 18:42:18 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D0sfJ-0004B2-VW
	for nfs@lists.sourceforge.net; Mon, 14 Feb 2005 18:42:18 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j1F2gB7a009221
	for <nfs@lists.sourceforge.net>; Mon, 14 Feb 2005 21:42:11 -0500
Received: from [192.168.62.4] (vpn83-125.boston.redhat.com [172.16.83.125])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j1F2gAO00611
	for <nfs@lists.sourceforge.net>; Mon, 14 Feb 2005 21:42:10 -0500
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------030404090804030306060004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

While debugging NFS using krb5 auth, I found the following
debugging statements very useful. You'll notice most of the new
dprintks are covered by if statements so they are not nosily,
but they do show where and how errors are being processed
or drop which was invaluable...

 Please consider adding this patch to upstream....

steved.


--------------030404090804030306060004
Content-Type: text/x-patch;
 name="linux-2.6.10-nfsd-svcauthgssdb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.10-nfsd-svcauthgssdb.patch"

--- linux-2.6.9/net/sunrpc/auth_gss/svcauth_gss.c.orig	2004-10-18 17:54:07.000000000 -0400
+++ linux-2.6.9/net/sunrpc/auth_gss/svcauth_gss.c	2005-02-13 21:35:14.000000000 -0500
@@ -455,14 +455,20 @@ gss_svc_searchbyctx(struct xdr_netobj *h
 	struct rsc *found;
 
 	memset(&rsci, 0, sizeof(rsci));
-	if (dup_to_netobj(&rsci.handle, handle->data, handle->len))
+	if (dup_to_netobj(&rsci.handle, handle->data, handle->len)) {
+		dprintk("RPC:      gss_svc_searchbyctx: dup_to_netobj\n");
 		return NULL;
+	}
 	found = rsc_lookup(&rsci, 0);
 	rsc_free(&rsci);
-	if (!found)
+	if (!found) {
+		dprintk("RPC:      gss_svc_searchbyctx: !found\n");
 		return NULL;
-	if (cache_check(&rsc_cache, &found->h, NULL))
+	}
+	if (cache_check(&rsc_cache, &found->h, NULL)) {
+		dprintk("RPC:      gss_svc_searchbyctx: cache_check\n");
 		return NULL;
+	}
 	return found;
 }
 
@@ -555,21 +561,28 @@ gss_verify_header(struct svc_rqst *rqstp
 	iov.iov_base = rpcstart;
 	iov.iov_len = (u8 *)argv->iov_base - (u8 *)rpcstart;
 	xdr_buf_from_iov(&iov, &rpchdr);
+	dprintk("RPC:      svcauth_gss: rpcstart\n");
 
 	*authp = rpc_autherr_badverf;
-	if (argv->iov_len < 4)
+	if (argv->iov_len < 4) {
+		dprintk("RPC:      svcauth_gss: iov_len %d\n", argv->iov_len);
 		return SVC_DENIED;
+	}
 	flavor = ntohl(svc_getu32(argv));
-	if (flavor != RPC_AUTH_GSS)
+	if (flavor != RPC_AUTH_GSS) {
+		dprintk("RPC:      svcauth_gss: flavor %d\n", flavor);
 		return SVC_DENIED;
-	if (svc_safe_getnetobj(argv, &checksum))
+	}
+	if (svc_safe_getnetobj(argv, &checksum)) {
+		dprintk("RPC:      svcauth_gss: svc_safe_getnetobj\n");
 		return SVC_DENIED;
-
+	}
 	if (rqstp->rq_deferred) /* skip verification of revisited request */
 		return SVC_OK;
 	if (gss_verify_mic(ctx_id, &rpchdr, &checksum, NULL)
 							!= GSS_S_COMPLETE) {
 		*authp = rpcsec_gsserr_credproblem;
+		dprintk("RPC:      svcauth_gss: verification of revisited request\n");
 		return SVC_DENIED;
 	}
 
@@ -758,8 +771,10 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	*authp = rpc_autherr_badcred;
 	if (!svcdata)
 		svcdata = kmalloc(sizeof(*svcdata), GFP_KERNEL);
-	if (!svcdata)
+	if (!svcdata) {
+		dprintk("RPC:      SVCauth_gss: kmalloc()\n");
 		goto auth_err;
+	}
 	rqstp->rq_auth_data = svcdata;
 	svcdata->body_start = NULL;
 	svcdata->rsci = NULL;
@@ -770,6 +785,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	 */
 	rpcstart = argv->iov_base;
 	rpcstart -= 7;
+	dprintk("RPC:      svcauth_gss: rpcstart 0x%p\n",rpcstart);
 
 	/* credential is:
 	 *   version(==1), proc(0,1,2,3), seq, service (1,2,3), handle
@@ -803,6 +819,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	 *   6 (AUTH_RPCSEC_GSS), length, checksum.
 	 * checksum is calculated over rpcheader from xid up to here.
 	 */
+	dprintk("RPC:      svcauth_gss: gc_proc %d\n",gc->gc_proc);
 	*authp = rpc_autherr_badverf;
 	switch (gc->gc_proc) {
 	case RPC_GSS_PROC_INIT:
@@ -818,14 +835,18 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	case RPC_GSS_PROC_DESTROY:
 		*authp = rpcsec_gsserr_credproblem;
 		rsci = gss_svc_searchbyctx(&gc->gc_ctx);
-		if (!rsci)
+		if (!rsci) {
+			dprintk("RPC:      svcauth_gss: gss_svc_searchbyctx\n");
 			goto auth_err;
+		}
 		switch (gss_verify_header(rqstp, rsci, rpcstart, gc, authp)) {
 		case SVC_OK:
 			break;
 		case SVC_DENIED:
+			dprintk("RPC:      svcauth_gss: gss_verify_header DENIED\n");
 			goto auth_err;
 		case SVC_DROP:
+			dprintk("RPC:      svcauth_gss: gss_verify_header DROP\n");
 			goto drop;
 		}
 		break;
@@ -834,6 +855,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		goto auth_err;
 	}
 
+	dprintk("RPC:      svcauth_gss: act gc_proc %d\n",gc->gc_proc);
 	/* now act upon the command: */
 	switch (gc->gc_proc) {
 	case RPC_GSS_PROC_INIT:
@@ -861,8 +883,10 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		}
 		switch(cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
 		case -EAGAIN:
+			dprintk("RPC:      svcauth_gss: cache_check -EAGAIN\n");
 			goto drop;
 		case -ENOENT:
+			dprintk("RPC:      svcauth_gss: cache_check -ENOENT\n");
 			goto drop;
 		case 0:
 			rsci = gss_svc_searchbyctx(&rsip->out_handle);
@@ -904,6 +928,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 		rqstp->rq_cred = rsci->cred;
 		get_group_info(rsci->cred.cr_group_info);
 		*authp = rpc_autherr_badcred;
+		dprintk("RPC:      svcauth_gss: rpc_autherr_badcred %d\n",gc->gc_proc);
 		switch (gc->gc_svc) {
 		case RPC_GSS_SVC_NONE:
 			break;
@@ -928,13 +953,16 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	}
 auth_err:
 	/* Restore write pointer to original value: */
+	dprintk("RPC:      svcauth_gss: auth_err\n");
 	xdr_ressize_check(rqstp, reject_stat);
 	ret = SVC_DENIED;
 	goto out;
 complete:
+	dprintk("RPC:      svcauth_gss: complete\n");
 	ret = SVC_COMPLETE;
 	goto out;
 drop:
+	dprintk("RPC:      svcauth_gss: drop\n");
 	ret = SVC_DROP;
 out:
 	if (rsci)

--------------030404090804030306060004--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

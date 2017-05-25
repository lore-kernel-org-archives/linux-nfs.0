Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763386AbdEYUfp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 16:35:45 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7AD568051D
        for <linux-nfs@vger.kernel.org>; Thu, 25 May 2017 20:35:34 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-122-191.rdu2.redhat.com [10.10.122.191])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 29591189B1
        for <linux-nfs@vger.kernel.org>; Thu, 25 May 2017 20:35:34 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] rpcbproc_callit_com: No need to allocate output buffer
Date: Thu, 25 May 2017 16:35:31 -0400
Message-Id: <20170525203531.4471-2-steved@redhat.com>
In-Reply-To: <20170525203531.4471-1-steved@redhat.com>
References: <20170525203531.4471-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that sendz is a fixed size (UDPMSGSIZE) which
is small then RPC_BUF_MAX, no need to check the
sendz size.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcb_svc_com.c | 33 +++++----------------------------
 1 file changed, 5 insertions(+), 28 deletions(-)

diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
index 1fc2229..d36b090 100644
--- a/src/rpcb_svc_com.c
+++ b/src/rpcb_svc_com.c
@@ -612,8 +612,6 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
 	struct netconfig *nconf;
 	struct netbuf *caller;
 	struct r_rmtcall_args a;
-	char *outbufp;
-	char *outbuf_alloc = NULL;
 	char  outbuf[RPC_BUF_MAX];
 	struct netbuf *na = (struct netbuf *) NULL;
 	struct rpc_msg call_msg;
@@ -674,7 +672,6 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
 
 	rpcbs_rmtcall(versnum - 2, reply_type, a.rmt_prog, a.rmt_vers,
 			a.rmt_proc, transp->xp_netid, rbl);
-
 	if (rbl == (rpcblist_ptr)NULL) {
 #ifdef RPCBIND_DEBUG
 		if (debugging)
@@ -793,24 +790,10 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
 	call_msg.rm_call.cb_rpcvers = RPC_MSG_VERSION;
 	call_msg.rm_call.cb_prog = a.rmt_prog;
 	call_msg.rm_call.cb_vers = a.rmt_vers;
-	if (sendsz > RPC_BUF_MAX) {
-#ifdef	notyet
-		outbuf_alloc = alloca(sendsz);	/* not in IDR2? */
-#else
-		outbuf_alloc = malloc(sendsz);
-#endif	/* notyet */
-		if (outbuf_alloc == NULL) {
-			if (reply_type == RPCBPROC_INDIRECT)
-				svcerr_systemerr(transp);
-			if (debugging)
-				xlog(LOG_DEBUG,
-				"rpcbproc_callit_com:  No memory!\n");
-			goto error;
-		}
-		xdrmem_create(&outxdr, outbuf_alloc, sendsz, XDR_ENCODE);
-	} else {
-		xdrmem_create(&outxdr, outbuf, sendsz, XDR_ENCODE);
-	}
+
+	memset(outbuf, '\0', sendsz); /* Zero out the output buffer */
+	xdrmem_create(&outxdr, outbuf, sendsz, XDR_ENCODE);
+
 	if (!xdr_callhdr(&outxdr, &call_msg)) {
 		if (reply_type == RPCBPROC_INDIRECT)
 			svcerr_systemerr(transp);
@@ -875,10 +858,6 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
 		goto error;
 	}
 	outlen = (int) XDR_GETPOS(&outxdr);
-	if (outbuf_alloc)
-		outbufp = outbuf_alloc;
-	else
-		outbufp = outbuf;
 
 	na = uaddr2taddr(nconf, local_uaddr);
 	if (!na) {
@@ -887,7 +866,7 @@ rpcbproc_callit_com(struct svc_req *rqstp, SVCXPRT *transp,
 		goto error;
 	}
 
-	if (sendto(fd, outbufp, outlen, 0, (struct sockaddr *)na->buf, na->len)
+	if (sendto(fd, outbuf, outlen, 0, (struct sockaddr *)na->buf, na->len)
 	    != outlen) {
 		if (debugging)
 			xlog(LOG_DEBUG,
@@ -912,8 +891,6 @@ out:
 	}
 	if (local_uaddr)
 		free(local_uaddr);
-	if (outbuf_alloc)
-		free(outbuf_alloc);
 	if (na) {
 		free(na->buf);
 		free(na);
-- 
2.9.3


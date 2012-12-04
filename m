Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57629 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263Ab2LDM6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:58:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/5] svcrpc: delay minimum-rpc-size check till later
Date: Tue,  4 Dec 2012 07:58:43 -0500
Message-Id: <1354625926-18527-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1354625926-18527-1-git-send-email-bfields@redhat.com>
References: <1354625926-18527-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Soon we want to support multiple fragments, in which case it may be
legal for a single fragment to be smaller than 8 bytes, so we'll want to
delay this check till we've reached the last fragment.

Also fix an outdated comment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d50de2b..1557179 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -921,10 +921,8 @@ out:
 }
 
 /*
- * Receive data.
+ * Receive fragment record header.
  * If we haven't gotten the record length yet, get the next four bytes.
- * Otherwise try to gobble up as much as possible up to the complete
- * record length.
  */
 static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 {
@@ -968,9 +966,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		}
 	}
 
-	if (svc_sock_reclen(svsk) < 8)
-		goto err_delete; /* client is nuts. */
-
 	return svc_sock_reclen(svsk);
 error:
 	dprintk("RPC: TCP recv_record got %d\n", len);
@@ -1076,12 +1071,15 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (len != want) {
 		svc_tcp_save_pages(svsk, rqstp);
 		if (len < 0 && len != -EAGAIN)
-			goto err_other;
+			goto err_delete;
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
 			svsk->sk_tcplen, svc_sock_reclen(svsk));
 		goto err_noclose;
 	}
 
+	if (svc_sock_reclen(svsk) < 8)
+		goto err_delete; /* client is nuts. */
+
 	rqstp->rq_arg.len = svc_sock_reclen(svsk);
 	rqstp->rq_arg.page_base = 0;
 	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
@@ -1117,10 +1115,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 error:
 	if (len != -EAGAIN)
-		goto err_other;
+		goto err_delete;
 	dprintk("RPC: TCP recvfrom got EAGAIN\n");
 	return 0;
-err_other:
+err_delete:
 	printk(KERN_NOTICE "%s: recvfrom returned errno %d\n",
 	       svsk->sk_xprt.xpt_server->sv_name, -len);
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
-- 
1.7.9.5


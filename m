Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57628 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171Ab2LDM6t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:58:49 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] svcrpc: don't byte-swap sk_reclen in place
Date: Tue,  4 Dec 2012 07:58:42 -0500
Message-Id: <1354625926-18527-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1354625926-18527-1-git-send-email-bfields@redhat.com>
References: <1354625926-18527-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Byte-swapping in place is always a little dubious.

Let's instead define this field to always be big-endian, and do the
swapping on demand where we need it.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svcsock.h |   12 +++++++++++-
 net/sunrpc/svcsock.c           |   26 +++++++++++---------------
 2 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 92ad02f..613cf42 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -26,11 +26,21 @@ struct svc_sock {
 	void			(*sk_owspace)(struct sock *);
 
 	/* private TCP part */
-	u32			sk_reclen;	/* length of record */
+	__be32			sk_reclen;	/* length of record */
 	u32			sk_tcplen;	/* current read length */
 	struct page *		sk_pages[RPCSVC_MAXPAGES];	/* received data */
 };
 
+static inline u32 svc_sock_reclen(struct svc_sock *svsk)
+{
+	return ntohl(svsk->sk_reclen) & RPC_FRAGMENT_SIZE_MASK;
+}
+
+static inline u32 svc_sock_final_rec(struct svc_sock *svsk)
+{
+	return ntohl(svsk->sk_reclen) & RPC_LAST_STREAM_FRAGMENT;
+}
+
 /*
  * Function prototypes.
  */
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 03827ce..d50de2b 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -950,8 +950,7 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 			return -EAGAIN;
 		}
 
-		svsk->sk_reclen = ntohl(svsk->sk_reclen);
-		if (!(svsk->sk_reclen & RPC_LAST_STREAM_FRAGMENT)) {
+		if (!(svc_sock_final_rec(svsk))) {
 			/* FIXME: technically, a record can be fragmented,
 			 *  and non-terminal fragments will not have the top
 			 *  bit set in the fragment length header.
@@ -961,21 +960,18 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 			goto err_delete;
 		}
 
-		svsk->sk_reclen &= RPC_FRAGMENT_SIZE_MASK;
-		dprintk("svc: TCP record, %d bytes\n", svsk->sk_reclen);
-		if (svsk->sk_reclen > serv->sv_max_mesg) {
+		dprintk("svc: TCP record, %d bytes\n", svc_sock_reclen(svsk));
+		if (svc_sock_reclen(svsk) > serv->sv_max_mesg) {
 			net_notice_ratelimited("RPC: fragment too large: 0x%08lx\n",
-					       (unsigned long)svsk->sk_reclen);
+					(unsigned long)svc_sock_reclen(svsk));
 			goto err_delete;
 		}
 	}
 
-	if (svsk->sk_reclen < 8)
+	if (svc_sock_reclen(svsk) < 8)
 		goto err_delete; /* client is nuts. */
 
-	len = svsk->sk_reclen;
-
-	return len;
+	return svc_sock_reclen(svsk);
 error:
 	dprintk("RPC: TCP recv_record got %d\n", len);
 	return len;
@@ -1019,7 +1015,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	if (dst->iov_len < src->iov_len)
 		return -EAGAIN; /* whatever; just giving up. */
 	memcpy(dst->iov_base, src->iov_base, src->iov_len);
-	xprt_complete_rqst(req->rq_task, svsk->sk_reclen);
+	xprt_complete_rqst(req->rq_task, rqstp->rq_arg.len);
 	rqstp->rq_arg.len = 0;
 	return 0;
 }
@@ -1064,12 +1060,12 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		goto error;
 
 	base = svc_tcp_restore_pages(svsk, rqstp);
-	want = svsk->sk_reclen - base;
+	want = svc_sock_reclen(svsk) - base;
 
 	vec = rqstp->rq_vec;
 
 	pnum = copy_pages_to_kvecs(&vec[0], &rqstp->rq_pages[0],
-						svsk->sk_reclen);
+						svc_sock_reclen(svsk));
 
 	rqstp->rq_respages = &rqstp->rq_pages[pnum];
 
@@ -1082,11 +1078,11 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (len < 0 && len != -EAGAIN)
 			goto err_other;
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
-			svsk->sk_tcplen, svsk->sk_reclen);
+			svsk->sk_tcplen, svc_sock_reclen(svsk));
 		goto err_noclose;
 	}
 
-	rqstp->rq_arg.len = svsk->sk_reclen;
+	rqstp->rq_arg.len = svc_sock_reclen(svsk);
 	rqstp->rq_arg.page_base = 0;
 	if (rqstp->rq_arg.len <= rqstp->rq_arg.head[0].iov_len) {
 		rqstp->rq_arg.head[0].iov_len = rqstp->rq_arg.len;
-- 
1.7.9.5


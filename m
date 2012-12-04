Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57633 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab2LDM6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:58:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/5] svcrpc: track rpc data length separately from sk_tcplen
Date: Tue,  4 Dec 2012 07:58:45 -0500
Message-Id: <1354625926-18527-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1354625926-18527-1-git-send-email-bfields@redhat.com>
References: <1354625926-18527-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Keep a separate field, sk_datalen, that tracks only the data contained
in a fragment, not including the fragment header.

For now, this is always just max(0, sk_tcplen - 4), but after we allow
multiple fragments sk_datalen will accumulate the total rpc data size
while sk_tcplen only tracks progress receiving the current fragment.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 include/linux/sunrpc/svcsock.h |   11 +++++++++--
 net/sunrpc/svcsock.c           |   19 ++++++++++++-------
 2 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/svcsock.h b/include/linux/sunrpc/svcsock.h
index 613cf42..62fd1b7 100644
--- a/include/linux/sunrpc/svcsock.h
+++ b/include/linux/sunrpc/svcsock.h
@@ -26,8 +26,15 @@ struct svc_sock {
 	void			(*sk_owspace)(struct sock *);
 
 	/* private TCP part */
-	__be32			sk_reclen;	/* length of record */
-	u32			sk_tcplen;	/* current read length */
+	/* On-the-wire fragment header: */
+	__be32			sk_reclen;
+	/* As we receive a record, this includes the length received so
+	 * far (including the fragment header): */
+	u32			sk_tcplen;
+	/* Total length of the data (not including fragment headers)
+	 * received so far in the fragments making up this rpc: */
+	u32			sk_datalen;
+
 	struct page *		sk_pages[RPCSVC_MAXPAGES];	/* received data */
 };
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1db42b1..2b09e23 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -874,9 +874,9 @@ static unsigned int svc_tcp_restore_pages(struct svc_sock *svsk, struct svc_rqst
 {
 	unsigned int i, len, npages;
 
-	if (svsk->sk_tcplen <= sizeof(rpc_fraghdr))
+	if (svsk->sk_datalen == 0)
 		return 0;
-	len = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < npages; i++) {
 		if (rqstp->rq_pages[i] != NULL)
@@ -893,9 +893,9 @@ static void svc_tcp_save_pages(struct svc_sock *svsk, struct svc_rqst *rqstp)
 {
 	unsigned int i, len, npages;
 
-	if (svsk->sk_tcplen <= sizeof(rpc_fraghdr))
+	if (svsk->sk_datalen == 0)
 		return;
-	len = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < npages; i++) {
 		svsk->sk_pages[i] = rqstp->rq_pages[i];
@@ -907,9 +907,9 @@ static void svc_tcp_clear_pages(struct svc_sock *svsk)
 {
 	unsigned int i, len, npages;
 
-	if (svsk->sk_tcplen <= sizeof(rpc_fraghdr))
+	if (svsk->sk_datalen == 0)
 		goto out;
-	len = svsk->sk_tcplen - sizeof(rpc_fraghdr);
+	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < npages; i++) {
 		BUG_ON(svsk->sk_pages[i] == NULL);
@@ -918,6 +918,7 @@ static void svc_tcp_clear_pages(struct svc_sock *svsk)
 	}
 out:
 	svsk->sk_tcplen = 0;
+	svsk->sk_datalen = 0;
 }
 
 /*
@@ -1066,8 +1067,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	/* Now receive data */
 	len = svc_partial_recvfrom(rqstp, vec, pnum, want, base);
-	if (len >= 0)
+	if (len >= 0) {
 		svsk->sk_tcplen += len;
+		svsk->sk_datalen += len;
+	}
 	if (len != want) {
 		svc_tcp_save_pages(svsk, rqstp);
 		if (len < 0 && len != -EAGAIN)
@@ -1100,6 +1103,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
+	svsk->sk_datalen = 0;
 	/* If we have more data, signal svc_xprt_enqueue() to try again */
 	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
 		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
@@ -1296,6 +1300,7 @@ static void svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 
 		svsk->sk_reclen = 0;
 		svsk->sk_tcplen = 0;
+		svsk->sk_datalen = 0;
 		memset(&svsk->sk_pages[0], 0, sizeof(svsk->sk_pages));
 
 		tcp_sk(sk)->nonagle |= TCP_NAGLE_OFF;
-- 
1.7.9.5


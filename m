From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 054/100] svc: Add xpo_prep_reply_hdr
Date: Fri, 25 Jan 2008 18:16:34 -0500
Message-ID: <1201303040-7779-54-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-21-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-22-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-23-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-24-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-25-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-26-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-27-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-28-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-29-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-30-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-31-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-32-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-33-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-34-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-35-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-36-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-37-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-38-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-39-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-40-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-41-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-42-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-43-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-44-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-45-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-46-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-47-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-48-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-51-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-52-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932100AbYAYXRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:47 -0500
In-Reply-To: <1201303040-7779-53-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

Some transports add fields to the RPC header for replies, e.g. the TCP
record length. This function is called when preparing the reply header
to allow each transport to add whatever fields it requires.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc.c                |    6 +++---
 net/sunrpc/svcsock.c            |   17 +++++++++++++++++
 3 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index f032fb6..199cfcb 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -11,6 +11,7 @@
 
 struct svc_xprt_ops {
 	int		(*xpo_recvfrom)(struct svc_rqst *);
+	void		(*xpo_prep_reply_hdr)(struct svc_rqst *);
 	int		(*xpo_sendto)(struct svc_rqst *);
 	void		(*xpo_release_rqst)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ea3fa86..3cc945d 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -839,9 +839,9 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.tail[0].iov_len = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_splice_ok = 1;
-	/* tcp needs a space for the record length... */
-	if (rqstp->rq_prot == IPPROTO_TCP)
-		svc_putnl(resv, 0);
+
+	/* Setup reply header */
+	rqstp->rq_xprt->xpt_ops->xpo_prep_reply_hdr(rqstp);
 
 	rqstp->rq_xid = svc_getu32(argv);
 	svc_putu32(resv, rqstp->rq_xid);
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 44a729d..492a1dc 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -893,12 +893,17 @@ svc_udp_sendto(struct svc_rqst *rqstp)
 	return error;
 }
 
+static void svc_udp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+}
+
 static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
 	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1350,12 +1355,24 @@ svc_tcp_sendto(struct svc_rqst *rqstp)
 	return sent;
 }
 
+/*
+ * Setup response header. TCP has a 4B record length field.
+ */
+static void svc_tcp_prep_reply_hdr(struct svc_rqst *rqstp)
+{
+	struct kvec *resv = &rqstp->rq_res.head[0];
+
+	/* tcp needs a space for the record length... */
+	svc_putnl(resv, 0);
+}
+
 static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
 	.xpo_release_rqst = svc_release_skb,
 	.xpo_detach = svc_sock_detach,
 	.xpo_free = svc_sock_free,
+	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
-- 
1.5.4.rc2.60.gb2e62


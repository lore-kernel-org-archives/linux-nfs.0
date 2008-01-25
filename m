From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 050/100] svc: Add a max payload value to the transport
Date: Fri, 25 Jan 2008 18:16:30 -0500
Message-ID: <1201303040-7779-50-git-send-email-bfields@citi.umich.edu>
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
Cc: Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759584AbYAYXRo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:44 -0500
In-Reply-To: <1201303040-7779-49-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tom Tucker <tom@opengridcomputing.com>

The svc_max_payload function currently looks at the socket type
to determine the max payload. Add a max payload value to svc_xprt_class
so it can be returned directly.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
Acked-by: Neil Brown <neilb@suse.de>
Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/sunrpc/svc_xprt.h |    1 +
 net/sunrpc/svc.c                |    4 +---
 net/sunrpc/svcsock.c            |    2 ++
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index fe8e787..187dc4e 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -17,6 +17,7 @@ struct svc_xprt_class {
 	struct module		*xcl_owner;
 	struct svc_xprt_ops	*xcl_ops;
 	struct list_head	xcl_list;
+	u32			xcl_max_payload;
 };
 
 struct svc_xprt {
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a4a6bf7..ea3fa86 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1054,10 +1054,8 @@ err_bad:
  */
 u32 svc_max_payload(const struct svc_rqst *rqstp)
 {
-	int max = RPCSVC_MAXPAYLOAD_TCP;
+	u32 max = rqstp->rq_xprt->xpt_class->xcl_max_payload;
 
-	if (rqstp->rq_sock->sk_sock->type == SOCK_DGRAM)
-		max = RPCSVC_MAXPAYLOAD_UDP;
 	if (rqstp->rq_server->sv_max_payload < max)
 		max = rqstp->rq_server->sv_max_payload;
 	return max;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 54f1b3d..c507f6f 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -906,6 +906,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 static struct svc_xprt_class svc_udp_class = {
 	.xcl_name = "udp",
 	.xcl_ops = &svc_udp_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_UDP,
 };
 
 static void
@@ -1359,6 +1360,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 static struct svc_xprt_class svc_tcp_class = {
 	.xcl_name = "tcp",
 	.xcl_ops = &svc_tcp_ops,
+	.xcl_max_payload = RPCSVC_MAXPAYLOAD_TCP,
 };
 
 void svc_init_xprt_sock(void)
-- 
1.5.4.rc2.60.gb2e62


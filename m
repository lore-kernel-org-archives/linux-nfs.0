Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:60530 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965014AbaESRk0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2014 13:40:26 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Ignore client's source port on RDMA transports
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 19 May 2014 13:40:22 -0400
Message-ID: <20140519173258.2828.98254.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An NFS/RDMA client's source port is meaningless for RDMA transports.
The transport layer typically sets the source port value on the
connection to a random ephemeral port.

Currently, NFS server administrators must specify the "insecure"
export option to enable clients to access exports via RDMA.

But this means NFS clients can access such an export via IP using an
ephemeral port, which may not be desirable.

This patch eliminates the need to specify the "insecure" export
option to allow NFS/RDMA clients access to an export.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=250
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Hi Bruce-

I've done some simple testing. "insecure" still behaves correctly
for IP-based clients, and is now unnecessary for RDMA-based clients.
Would you consider this for nfsd-next?


 include/linux/sunrpc/svc_xprt.h          |    1 +
 net/sunrpc/svc_xprt.c                    |    2 +-
 net/sunrpc/svcsock.c                     |    9 +++++++++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    7 +++++++
 4 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index b05963f..0cec1b9 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -24,6 +24,7 @@ struct svc_xprt_ops {
 	void		(*xpo_release_rqst)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
 	void		(*xpo_free)(struct svc_xprt *);
+	int		(*xpo_secure_port)(struct svc_rqst *);
 };
 
 struct svc_xprt_class {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 06c6ff0..614956f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -793,7 +793,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
-	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));
+	rqstp->rq_secure = xprt->xpt_ops->xpo_secure_port(rqstp);
 	rqstp->rq_chandle.defer = svc_defer;
 
 	if (serv->sv_stats)
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 43bcb46..0cb34f5 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -400,6 +400,12 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	release_sock(sock->sk);
 #endif
 }
+
+static int svc_sock_secure_port(struct svc_rqst *rqstp)
+{
+	return svc_port_is_privileged(svc_addr(rqstp));
+}
+
 /*
  * INET callback when data has been received on the socket.
  */
@@ -678,6 +684,7 @@ static struct svc_xprt_ops svc_udp_ops = {
 	.xpo_prep_reply_hdr = svc_udp_prep_reply_hdr,
 	.xpo_has_wspace = svc_udp_has_wspace,
 	.xpo_accept = svc_udp_accept,
+	.xpo_secure_port = svc_sock_secure_port,
 };
 
 static struct svc_xprt_class svc_udp_class = {
@@ -1234,6 +1241,7 @@ static struct svc_xprt_ops svc_tcp_bc_ops = {
 	.xpo_detach = svc_bc_tcp_sock_detach,
 	.xpo_free = svc_bc_sock_free,
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
+	.xpo_secure_port = svc_sock_secure_port,
 };
 
 static struct svc_xprt_class svc_tcp_bc_class = {
@@ -1272,6 +1280,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_prep_reply_hdr = svc_tcp_prep_reply_hdr,
 	.xpo_has_wspace = svc_tcp_has_wspace,
 	.xpo_accept = svc_tcp_accept,
+	.xpo_secure_port = svc_sock_secure_port,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 25688fa..02db8d9 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -65,6 +65,7 @@ static void dto_tasklet_func(unsigned long data);
 static void svc_rdma_detach(struct svc_xprt *xprt);
 static void svc_rdma_free(struct svc_xprt *xprt);
 static int svc_rdma_has_wspace(struct svc_xprt *xprt);
+static int svc_rdma_secure_port(struct svc_rqst *);
 static void rq_cq_reap(struct svcxprt_rdma *xprt);
 static void sq_cq_reap(struct svcxprt_rdma *xprt);
 
@@ -82,6 +83,7 @@ static struct svc_xprt_ops svc_rdma_ops = {
 	.xpo_prep_reply_hdr = svc_rdma_prep_reply_hdr,
 	.xpo_has_wspace = svc_rdma_has_wspace,
 	.xpo_accept = svc_rdma_accept,
+	.xpo_secure_port = svc_rdma_secure_port,
 };
 
 struct svc_xprt_class svc_rdma_class = {
@@ -1207,6 +1209,11 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
+static int svc_rdma_secure_port(struct svc_rqst *rqstp)
+{
+	return 1;
+}
+
 /*
  * Attempt to register the kvec representing the RPC memory with the
  * device.


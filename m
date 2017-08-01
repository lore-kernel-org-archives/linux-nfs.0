Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:34294 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdHAP7v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 11:59:51 -0400
Received: by mail-it0-f65.google.com with SMTP id t78so1936399ita.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Aug 2017 08:59:51 -0700 (PDT)
Subject: [PATCH v1 1/4] sunrpc: Const-ify instances of struct svc_xprt_ops
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 01 Aug 2017 11:59:49 -0400
Message-ID: <20170801155949.14944.99067.stgit@klimt.1015granger.net>
In-Reply-To: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
References: <20170801155738.14944.10842.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Close an attack vector by moving the arrays of server-side transport
methods to read-only memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_xprt.h          |    4 ++--
 net/sunrpc/svcsock.c                     |    6 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index ddb7f94..6a2ad38 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -31,7 +31,7 @@ struct svc_xprt_ops {
 struct svc_xprt_class {
 	const char		*xcl_name;
 	struct module		*xcl_owner;
-	struct svc_xprt_ops	*xcl_ops;
+	const struct svc_xprt_ops *xcl_ops;
 	struct list_head	xcl_list;
 	u32			xcl_max_payload;
 	int			xcl_ident;
@@ -49,7 +49,7 @@ struct svc_xpt_user {
 
 struct svc_xprt {
 	struct svc_xprt_class	*xpt_class;
-	struct svc_xprt_ops	*xpt_ops;
+	const struct svc_xprt_ops *xpt_ops;
 	struct kref		xpt_ref;
 	struct list_head	xpt_list;
 	struct list_head	xpt_ready;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2b720fa..b434f52 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -687,7 +687,7 @@ static struct svc_xprt *svc_udp_create(struct svc_serv *serv,
 	return svc_create_socket(serv, IPPROTO_UDP, net, sa, salen, flags);
 }
 
-static struct svc_xprt_ops svc_udp_ops = {
+static const struct svc_xprt_ops svc_udp_ops = {
 	.xpo_create = svc_udp_create,
 	.xpo_recvfrom = svc_udp_recvfrom,
 	.xpo_sendto = svc_udp_sendto,
@@ -1229,7 +1229,7 @@ static void svc_bc_tcp_sock_detach(struct svc_xprt *xprt)
 {
 }
 
-static struct svc_xprt_ops svc_tcp_bc_ops = {
+static const struct svc_xprt_ops svc_tcp_bc_ops = {
 	.xpo_create = svc_bc_tcp_create,
 	.xpo_detach = svc_bc_tcp_sock_detach,
 	.xpo_free = svc_bc_sock_free,
@@ -1263,7 +1263,7 @@ static void svc_cleanup_bc_xprt_sock(void)
 }
 #endif /* CONFIG_SUNRPC_BACKCHANNEL */
 
-static struct svc_xprt_ops svc_tcp_ops = {
+static const struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_create = svc_tcp_create,
 	.xpo_recvfrom = svc_tcp_recvfrom,
 	.xpo_sendto = svc_tcp_sendto,
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index e660d49..2aa8473 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -70,7 +70,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 static int svc_rdma_secure_port(struct svc_rqst *);
 static void svc_rdma_kill_temp_xprt(struct svc_xprt *);
 
-static struct svc_xprt_ops svc_rdma_ops = {
+static const struct svc_xprt_ops svc_rdma_ops = {
 	.xpo_create = svc_rdma_create,
 	.xpo_recvfrom = svc_rdma_recvfrom,
 	.xpo_sendto = svc_rdma_sendto,
@@ -98,7 +98,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *, struct net *,
 static void svc_rdma_bc_detach(struct svc_xprt *);
 static void svc_rdma_bc_free(struct svc_xprt *);
 
-static struct svc_xprt_ops svc_rdma_bc_ops = {
+static const struct svc_xprt_ops svc_rdma_bc_ops = {
 	.xpo_create = svc_rdma_bc_create,
 	.xpo_detach = svc_rdma_bc_detach,
 	.xpo_free = svc_rdma_bc_free,


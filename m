Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36200 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935016AbeCMPnw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2018 11:43:52 -0400
Received: by mail-io0-f194.google.com with SMTP id e30so639616ioc.3
        for <linux-nfs@vger.kernel.org>; Tue, 13 Mar 2018 08:43:52 -0700 (PDT)
Subject: [PATCH 02/15] svc: Simplify ->xpo_secure_port
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 13 Mar 2018 11:43:50 -0400
Message-ID: <20180313154350.21531.82838.stgit@klimt.1015granger.net>
In-Reply-To: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
References: <20180313154053.21531.86316.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Instead of returning a value that is used to set or clear
a bit, just make ->xpo_secure_port mangle that bit, and return void.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/linux/sunrpc/svc_xprt.h          |    2 +-
 net/sunrpc/svc_xprt.c                    |    5 +----
 net/sunrpc/svcsock.c                     |    7 +++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    6 +++---
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 1caf7bc..19475ac 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -25,7 +25,7 @@ struct svc_xprt_ops {
 	void		(*xpo_release_rqst)(struct svc_rqst *);
 	void		(*xpo_detach)(struct svc_xprt *);
 	void		(*xpo_free)(struct svc_xprt *);
-	int		(*xpo_secure_port)(struct svc_rqst *);
+	void		(*xpo_secure_port)(struct svc_rqst *rqstp);
 	void		(*xpo_kill_temp_xprt)(struct svc_xprt *);
 };
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 6dca0f5..4e3b4c5 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -844,10 +844,7 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 
 	clear_bit(XPT_OLD, &xprt->xpt_flags);
 
-	if (xprt->xpt_ops->xpo_secure_port(rqstp))
-		set_bit(RQ_SECURE, &rqstp->rq_flags);
-	else
-		clear_bit(RQ_SECURE, &rqstp->rq_flags);
+	xprt->xpt_ops->xpo_secure_port(rqstp);
 	rqstp->rq_chandle.defer = svc_defer;
 	rqstp->rq_xid = svc_getu32(&rqstp->rq_arg.head[0]);
 
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 943f2a7..9b67035 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -391,9 +391,12 @@ static void svc_sock_setbufsize(struct socket *sock, unsigned int snd,
 	release_sock(sock->sk);
 }
 
-static int svc_sock_secure_port(struct svc_rqst *rqstp)
+static void svc_sock_secure_port(struct svc_rqst *rqstp)
 {
-	return svc_port_is_privileged(svc_addr(rqstp));
+	if (svc_port_is_privileged(svc_addr(rqstp)))
+		set_bit(RQ_SECURE, &rqstp->rq_flags);
+	else
+		clear_bit(RQ_SECURE, &rqstp->rq_flags);
 }
 
 /*
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 9ad12a2..b083ac8 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -69,7 +69,7 @@ static struct svc_xprt *svc_rdma_create(struct svc_serv *serv,
 static void svc_rdma_detach(struct svc_xprt *xprt);
 static void svc_rdma_free(struct svc_xprt *xprt);
 static int svc_rdma_has_wspace(struct svc_xprt *xprt);
-static int svc_rdma_secure_port(struct svc_rqst *);
+static void svc_rdma_secure_port(struct svc_rqst *);
 static void svc_rdma_kill_temp_xprt(struct svc_xprt *);
 
 static const struct svc_xprt_ops svc_rdma_ops = {
@@ -992,9 +992,9 @@ static int svc_rdma_has_wspace(struct svc_xprt *xprt)
 	return 1;
 }
 
-static int svc_rdma_secure_port(struct svc_rqst *rqstp)
+static void svc_rdma_secure_port(struct svc_rqst *rqstp)
 {
-	return 1;
+	set_bit(RQ_SECURE, &rqstp->rq_flags);
 }
 
 static void svc_rdma_kill_temp_xprt(struct svc_xprt *xprt)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:42628 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbaHCRDT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 13:03:19 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so5944323qae.6
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 10:03:18 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 03/11] SUNRPC: Allow svc_reserve() to notify TCP socket that space has been freed
Date: Sun,  3 Aug 2014 13:03:05 -0400
Message-Id: <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
References: <1407085393-3175-1-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-2-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/linux/sunrpc/svc_xprt.h | 1 +
 net/sunrpc/svc_xprt.c           | 2 ++
 net/sunrpc/svcsock.c            | 9 +++++++++
 3 files changed, 12 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 7235040a19b2..8f241ac6934b 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -25,6 +25,7 @@ struct svc_xprt_ops {
 	void		(*xpo_detach)(struct svc_xprt *);
 	void		(*xpo_free)(struct svc_xprt *);
 	int		(*xpo_secure_port)(struct svc_rqst *);
+	void		(*xpo_adjust_wspace)(struct svc_xprt *);
 };
 
 struct svc_xprt_class {
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 54a761fa6351..32647b2a6a34 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -448,6 +448,8 @@ void svc_reserve(struct svc_rqst *rqstp, int space)
 		atomic_sub((rqstp->rq_reserved - space), &xprt->xpt_reserved);
 		rqstp->rq_reserved = space;
 
+		if (xprt->xpt_ops->xpo_adjust_wspace)
+			xprt->xpt_ops->xpo_adjust_wspace(xprt);
 		svc_xprt_enqueue(xprt);
 	}
 }
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 7322ea1164fd..72597d7fe60a 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -475,6 +475,14 @@ static void svc_tcp_write_space(struct sock *sk)
 	svc_write_space(sk);
 }
 
+static void svc_tcp_adjust_wspace(struct svc_xprt *xprt)
+{
+	struct svc_sock *svsk = container_of(xprt, struct svc_sock, sk_xprt);
+
+	if (svc_tcp_has_wspace(xprt))
+		clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
+}
+
 /*
  * See net/ipv6/ip_sockglue.c : ip_cmsg_recv_pktinfo
  */
@@ -1288,6 +1296,7 @@ static struct svc_xprt_ops svc_tcp_ops = {
 	.xpo_has_wspace = svc_tcp_has_wspace,
 	.xpo_accept = svc_tcp_accept,
 	.xpo_secure_port = svc_sock_secure_port,
+	.xpo_adjust_wspace = svc_tcp_adjust_wspace,
 };
 
 static struct svc_xprt_class svc_tcp_class = {
-- 
1.9.3


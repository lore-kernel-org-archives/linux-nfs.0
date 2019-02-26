Return-Path: <SRS0=yawm=RB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5BFCC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 20:42:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7734021850
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Feb 2019 20:42:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pmKJwJb8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727981AbfBZUmn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 15:42:43 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:55161 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727823AbfBZUmn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Feb 2019 15:42:43 -0500
Received: by mail-it1-f194.google.com with SMTP id w18so5950964itj.4
        for <linux-nfs@vger.kernel.org>; Tue, 26 Feb 2019 12:42:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DJtQzlvUjEjb/qXqdIe0qJsb0WBXglNnAte8sQrX5T4=;
        b=pmKJwJb8saNarUFy7KFVhEFSfnbFkyX4IEh4gbvumOacmRmnvoiIDY7wgujjA1SV3g
         gjoDjIVc8tjoUfn/Hj7ODSAVow2u5NsgS2+sKnXQN77uL5Qnzyr/ImoO9okB23sQXzTg
         4GKc/vz5ZY5lMdTn6/kFjfIJoM4d3SP1ypLADR9uxFA33Vj1YPveEgahRNdmZLPzElD8
         7+gaTKbNxfn5hARhnM3fZeJErUKC1tJteyKb8fdQUiF1HPkjfNegZ4lWbQce6WM9l82R
         mQCk+PFq/sIg3R5/Pb+pRR0C0nd33EWIwOX/9GJl65s84h+iSTjn2iUJ/XbDxfA4eiRf
         q1fw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=DJtQzlvUjEjb/qXqdIe0qJsb0WBXglNnAte8sQrX5T4=;
        b=M6+tCC6J4bSG+P5ES3WcJhcdYTw982pvHwklm9Dk8iXHZNYf7PcFaPCjslyWw7MZNa
         12j2BkE4JLp9rCY+2bUypIdIvgCqmEDxhwGqbWNolKL5motFAK6L9HZ+tdw6gHXkRi9j
         7FPuyo3kQdast3uSXGVrp+k3s8kHS/IsSY15BMSrFXIJmyvS2FT9EYwB5k2cPn1zhePO
         RTG2dRVd81Fn2xJaKzPIVJpiIdbTOkG0wC/RIfYZAQixUyB0/4Mp+x3LMVZn+SClgdFn
         jtmdYZOeNpOu9QK3Q8nS+J9ezzDe09zQNvFO5rFfZzh6DWVdZmyHW3tllOBMjL7RwHjm
         qoPQ==
X-Gm-Message-State: AHQUAua6jQsaiiKh/UC8wqCPE3tt0p7qBCnt5MO2qfVfc5wwLiY4OeXL
        YzGuvObZ88l++lCYBYMBitLlZUk=
X-Google-Smtp-Source: AHgI3IYcFjlU/gFSOlOBc3OAgepk4zTvYty1uwizEl8PXI3kZFpvMGv23wUxnbpBf4HEnflfiuNOCQ==
X-Received: by 2002:a05:660c:382:: with SMTP id x2mr3292730itj.98.1551213761899;
        Tue, 26 Feb 2019 12:42:41 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id k77sm97619itb.7.2019.02.26.12.42.40
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 12:42:41 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix an Oops in udp_poll()
Date:   Tue, 26 Feb 2019 15:41:33 -0500
Message-Id: <20190226204133.128139-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

udp_poll() checks the struct file for the O_NONBLOCK flag, so we must not
call it with a NULL file pointer.

Fixes: 0ffe86f48026 ("SUNRPC: Use poll() to fix up the socket requeue races")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/xprtsock.h |  1 +
 net/sunrpc/xprtsock.c           | 21 +++++++++++++++++++--
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
index 458bfe0137f5..b81d0b3e0799 100644
--- a/include/linux/sunrpc/xprtsock.h
+++ b/include/linux/sunrpc/xprtsock.h
@@ -26,6 +26,7 @@ struct sock_xprt {
 	 */
 	struct socket *		sock;
 	struct sock *		inet;
+	struct file *		file;
 
 	/*
 	 * State of TCP reply receive
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 53de72d2dded..e829036ed81f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -670,7 +670,8 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 
 static __poll_t xs_poll_socket(struct sock_xprt *transport)
 {
-	return transport->sock->ops->poll(NULL, transport->sock, NULL);
+	return transport->sock->ops->poll(transport->file, transport->sock,
+			NULL);
 }
 
 static bool xs_poll_socket_readable(struct sock_xprt *transport)
@@ -1253,6 +1254,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	struct socket *sock = transport->sock;
 	struct sock *sk = transport->inet;
 	struct rpc_xprt *xprt = &transport->xprt;
+	struct file *filp = transport->file;
 
 	if (sk == NULL)
 		return;
@@ -1266,6 +1268,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
 	transport->sock = NULL;
+	transport->file = NULL;
 
 	sk->sk_user_data = NULL;
 
@@ -1278,7 +1281,7 @@ static void xs_reset_transport(struct sock_xprt *transport)
 	mutex_unlock(&transport->recv_mutex);
 
 	trace_rpc_socket_close(xprt, sock);
-	sock_release(sock);
+	fput(filp);
 
 	xprt_disconnect_done(xprt);
 }
@@ -1873,6 +1876,7 @@ static struct socket *xs_create_sock(struct rpc_xprt *xprt,
 		struct sock_xprt *transport, int family, int type,
 		int protocol, bool reuseport)
 {
+	struct file *filp;
 	struct socket *sock;
 	int err;
 
@@ -1893,6 +1897,11 @@ static struct socket *xs_create_sock(struct rpc_xprt *xprt,
 		goto out;
 	}
 
+	filp = sock_alloc_file(sock, O_NONBLOCK, NULL);
+	if (IS_ERR(filp))
+		return ERR_CAST(filp);
+	transport->file = filp;
+
 	return sock;
 out:
 	return ERR_PTR(err);
@@ -1938,6 +1947,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 static int xs_local_setup_socket(struct sock_xprt *transport)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
+	struct file *filp;
 	struct socket *sock;
 	int status = -EIO;
 
@@ -1950,6 +1960,13 @@ static int xs_local_setup_socket(struct sock_xprt *transport)
 	}
 	xs_reclassify_socket(AF_LOCAL, sock);
 
+	filp = sock_alloc_file(sock, O_NONBLOCK, NULL);
+	if (IS_ERR(filp)) {
+		status = PTR_ERR(filp);
+		goto out;
+	}
+	transport->file = filp;
+
 	dprintk("RPC:       worker connecting xprt %p via AF_LOCAL to %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ADDR]);
 
-- 
2.20.1


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:32951 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbcFXO40 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jun 2016 10:56:26 -0400
Received: by mail-io0-f193.google.com with SMTP id t74so15637357ioi.0
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jun 2016 07:56:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 05/10] SUNRPC: lock the socket while detaching it
Date: Fri, 24 Jun 2016 10:55:47 -0400
Message-Id: <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Prevent callbacks from triggering while we're detaching the socket.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/svcsock.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index dadfec66dbd8..abe2da602fb8 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1611,9 +1611,12 @@ static void svc_sock_detach(struct svc_xprt *xprt)
 	dprintk("svc: svc_sock_detach(%p)\n", svsk);
 
 	/* put back the old socket callbacks */
+	lock_sock(sk);
 	sk->sk_state_change = svsk->sk_ostate;
 	sk->sk_data_ready = svsk->sk_odata;
 	sk->sk_write_space = svsk->sk_owspace;
+	sk->sk_user_data = NULL;
+	release_sock(sk);
 
 	wq = sk_sleep(sk);
 	if (sunrpc_waitqueue_active(wq))
-- 
2.7.4


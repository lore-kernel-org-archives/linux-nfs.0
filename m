From: Xiaotian Feng <dfeng@redhat.com>
Subject: [PATCH] sunrpc: fix peername failed on closed listener
Date: Thu, 31 Dec 2009 10:52:36 +0800
Message-ID: <1262227956-21470-1-git-send-email-dfeng@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xiaotian Feng <dfeng@redhat.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243AbZLaCy4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2009 21:54:56 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There're some warnings of "nfsd: peername failed (err 107)!"
socket error -107 means Transport endpoint is not connected.
This warning message was outputed by svc_tcp_accept() [net/sunrpc/svcsock.c],
when kernel_getpeername returns -107. This means socket might be CLOSED.

And svc_tcp_accept was called by svc_recv() [net/sunrpc/svc_xprt.c]

        if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
        <snip>
                newxpt = xprt->xpt_ops->xpo_accept(xprt);
        <snip>

So this might happen when xprt->xpt_flags has both XPT_LISTENER and XPT_CLOSE.

Let's take a look at commit b0401d72, this commit has moved the close
processing after do recvfrom method, but this commit also introduces this
warnings, if the xpt_flags has both XPT_LISTENER and XPT_CLOSED, we should
close it, not accpet then close.

Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: David S. Miller <davem@davemloft.net>
---
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 1c924ee..187f0f4 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -699,7 +699,8 @@ int svc_recv(struct svc_rqst *rqstp, long timeout)
 	spin_unlock_bh(&pool->sp_lock);
 
 	len = 0;
-	if (test_bit(XPT_LISTENER, &xprt->xpt_flags)) {
+	if (test_bit(XPT_LISTENER, &xprt->xpt_flags) &&
+	    !test_bit(XPT_CLOSE, &xprt->xpt_flags)) {
 		struct svc_xprt *newxpt;
 		newxpt = xprt->xpt_ops->xpo_accept(xprt);
 		if (newxpt) {

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39851 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756968Ab1DFXGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:33 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/7] SUNRPC: requeue tcp socket less frequently
Date: Wed,  6 Apr 2011 19:06:20 -0400
Message-Id: <1302131186-6578-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Don't requeue the socket in some cases where we know it's unnecessary.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d802e94..29b31df 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -959,7 +959,6 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		goto err_again;	/* record not complete */
 	}
 	len = svsk->sk_reclen;
-	set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
 
 	return len;
  error:
@@ -1109,6 +1108,10 @@ out:
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
+	/* If we have more data, signal svc_xprt_enqueue() to try again */
+	if (svc_recv_available(svsk) > sizeof(rpc_fraghdr))
+		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
+
 
 	svc_xprt_copy_addrs(rqstp, &svsk->sk_xprt);
 	if (serv->sv_stats)
-- 
1.7.1


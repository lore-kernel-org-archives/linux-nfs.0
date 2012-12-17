Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60267 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab2LQPhk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:37:40 -0500
Received: from bfields by fieldses.org with local (Exim 4.76)
	(envelope-from <bfields@fieldses.org>)
	id 1TkclA-0007V0-HW
	for linux-nfs@vger.kernel.org; Mon, 17 Dec 2012 10:37:40 -0500
Date: Mon, 17 Dec 2012 10:37:40 -0500
To: linux-nfs@vger.kernel.org
Subject: [PATCH] svcrpc: fix some printks
Message-ID: <20121217153740.GE23546@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Hopefully I got this right this time.  Queueing up for 3.8.--b.

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 38ec968..b250e27 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -952,8 +952,8 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		dprintk("svc: TCP record, %d bytes\n", svc_sock_reclen(svsk));
 		if (svc_sock_reclen(svsk) + svsk->sk_datalen >
 							serv->sv_max_mesg) {
-			net_notice_ratelimited("RPC: fragment too large: 0x%08lx\n",
-					       (unsigned long)svsk->sk_reclen);
+			net_notice_ratelimited("RPC: fragment too large: 0x%08x\n",
+					svc_sock_reclen(svsk));
 			goto err_delete;
 		}
 	}
@@ -1080,8 +1080,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (len == want)
 			svc_tcp_fragment_received(svsk);
 		else
-			dprintk("svc: incomplete TCP record (%ld of %d)\n",
-				svsk->sk_tcplen - sizeof(rpc_fraghdr),
+			dprintk("svc: incomplete TCP record (%d of %d)\n",
+				svsk->sk_tcplen - (int)sizeof(rpc_fraghdr),
 				svc_sock_reclen(svsk));
 		goto err_noclose;
 	}
-- 
1.7.9.5


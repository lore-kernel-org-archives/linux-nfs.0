From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 8/9] SUNRPC: Fix an Oops due to socket not set up yet...
Date: Wed, 11 Mar 2009 14:25:26 -0400
Message-ID: <20090311182526.403.88514.stgit@heimdal.trondhjem.org>
References: <20090311182525.403.42026.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52465 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321AbZCKS3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 14:29:52 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id n2BIThF2008166
	for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2009 11:29:51 -0700 (PDT)
In-Reply-To: <20090311182525.403.42026.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can Oops in both xs_udp_send_request() and xs_tcp_send_request() if the
call to xs_sendpages() returns an error due to the socket not yet being
set up.
Deal with that situation by returning a new error: ENOTSOCK, so that we
know to avoid dereferencing transport->sock.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/xprtsock.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 5cbb404..a71fefd 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -467,7 +467,7 @@ static int xs_sendpages(struct socket *sock, struct sockaddr *addr, int addrlen,
 	int err, sent = 0;
 
 	if (unlikely(!sock))
-		return -ENOTCONN;
+		return -ENOTSOCK;
 
 	clear_bit(SOCK_ASYNC_NOSPACE, &sock->flags);
 	if (base != 0) {
@@ -594,6 +594,10 @@ static int xs_udp_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -ENOTSOCK:
+		status = -ENOTCONN;
+		/* Should we call xs_close() here? */
+		break;
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
@@ -693,6 +697,10 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	}
 
 	switch (status) {
+	case -ENOTSOCK:
+		status = -ENOTCONN;
+		/* Should we call xs_close() here? */
+		break;
 	case -EAGAIN:
 		xs_nospace(task);
 		break;


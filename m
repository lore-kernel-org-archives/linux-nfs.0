Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38421 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993141AbbEEOSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 10:18:02 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] SUNRPC: drop stale setup_socket doc comments
Date: Tue,  5 May 2015 15:18:00 +0100
Message-Id: <1430835480-29982-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xs_local_setup_socket() and xs_tcp_setup_socket() have outdated
arguments listed in the doc comments.  Drop arguments that no longer
exist.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/xprtsock.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 66891e3..a8d6c6e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1886,9 +1886,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 
 /**
  * xs_local_setup_socket - create AF_LOCAL socket, connect to a local endpoint
- * @xprt: RPC transport to connect
  * @transport: socket transport to connect
- * @create_sock: function to create a socket of the correct type
  */
 static int xs_local_setup_socket(struct sock_xprt *transport)
 {
@@ -2125,9 +2123,6 @@ out:
 
 /**
  * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
- * @xprt: RPC transport to connect
- * @transport: socket transport to connect
- * @create_sock: function to create a socket of the correct type
  *
  * Invoked by a work queue tasklet.
  */
-- 
2.1.0


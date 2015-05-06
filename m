Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655AbbEFIcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2015 04:32:14 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v2] SUNRPC: drop stale doc comments in xprtsock.c
Date: Wed,  6 May 2015 09:32:03 +0100
Message-Id: <1430901123-24555-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several functions have outdated arguments listed in the doc comments.
Drop documentation for arguments that no longer exist.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 net/sunrpc/xprtsock.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 66891e3..b142fee 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -900,9 +900,8 @@ static int xs_local_copy_to_xdr(struct xdr_buf *xdr, struct sk_buff *skb)
 
 /**
  * xs_local_data_ready - "data ready" callback for AF_LOCAL sockets
  * @sk: socket with data to read
- * @len: how much data to read
  *
  * Currently this assumes we can read the whole reply in a single gulp.
  */
 static void xs_local_data_ready(struct sock *sk)
@@ -964,9 +963,8 @@ static void xs_local_data_ready(struct sock *sk)
 
 /**
  * xs_udp_data_ready - "data ready" callback for UDP sockets
  * @sk: socket with data to read
- * @len: how much data to read
  *
  */
 static void xs_udp_data_ready(struct sock *sk)
 {
@@ -1388,9 +1386,8 @@ static int xs_tcp_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb, uns
 
 /**
  * xs_tcp_data_ready - "data ready" callback for TCP sockets
  * @sk: socket with data to read
- * @bytes: how much data to read
  *
  */
 static void xs_tcp_data_ready(struct sock *sk)
 {
@@ -1885,11 +1882,9 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 }
 
 /**
  * xs_local_setup_socket - create AF_LOCAL socket, connect to a local endpoint
- * @xprt: RPC transport to connect
  * @transport: socket transport to connect
- * @create_sock: function to create a socket of the correct type
  */
 static int xs_local_setup_socket(struct sock_xprt *transport)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
@@ -2124,11 +2119,8 @@ out:
 }
 
 /**
  * xs_tcp_setup_socket - create a TCP socket and connect to a remote endpoint
- * @xprt: RPC transport to connect
- * @transport: socket transport to connect
- * @create_sock: function to create a socket of the correct type
  *
  * Invoked by a work queue tasklet.
  */
 static void xs_tcp_setup_socket(struct work_struct *work)
-- 
2.1.0


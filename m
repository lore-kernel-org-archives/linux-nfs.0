Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:51200 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727411AbeIJUDe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:03:34 -0400
Subject: [PATCH v1 01/22] xprtrdma: Reset credit grant properly after a
 disconnect
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:09:00 -0400
Message-ID: <20180910150900.10564.91528.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On a fresh connection, an RPC/RDMA client is supposed to send only
one RPC Call until it gets a credit grant in the first RPC Reply
from the server [RFC 8166, Section 3.3.3].

There is a bug in the Linux client's credit accounting mechanism
introduced by commit e7ce710a8802 ("xprtrdma: Avoid deadlock when
credit window is reset"). On connect, it simply dumps all pending
RPC Calls onto the new connection.

Servers have been tolerant of this bad behavior. Currently no server
implementation ever changes its credit grant over reconnects, and
servers always repost enough Receives before connections are fully
established.

To correct this issue, ensure that the client resets both the credit
grant _and_ the congestion window when handling a reconnect.

Fixes: e7ce710a8802 ("xprtrdma: Avoid deadlock when credit ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
---
 net/sunrpc/xprtrdma/transport.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 143ce25..98cbc7b 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -468,6 +468,12 @@
 		xprt->reestablish_timeout = 0;
 	xprt_disconnect_done(xprt);
 	rpcrdma_ep_disconnect(ep, ia);
+
+	/* Prepare @xprt for the next connection by reinitializing
+	 * its credit grant to one (see RFC 8166, Section 3.3.3).
+	 */
+	r_xprt->rx_buf.rb_credits = 1;
+	xprt->cwnd = RPC_CWNDSHIFT;
 }
 
 /**

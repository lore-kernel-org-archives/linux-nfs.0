Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:35397 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934181AbZGQHxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jul 2009 03:53:42 -0400
From: Neil Brown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>
Date: Fri, 17 Jul 2009 17:53:37 +1000
Content-Type: text/plain; charset=us-ascii
Message-ID: <19040.11777.346898.322780@notabene.brown>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: reset TCP reconnect exponential back-off on successful connection.
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi.
 A customer of ours has been testing NFS failover and has been
 experiencing unexpected delays before the client starts writing
 again.   It turns out there are a number of issues here, some client
 and some server.

 This patch fixes two client issues, one that causes the failover time
 to double on each migration (or each time the NFS server is stopped
 and restarted), and one that causes the client to spam the server
 with SYN requests until it accepts the connection (I have a trace
 showing over 100 SYN requests, each followed by a RST,ACK reply, in
 the space for 300 milliseconds).

 I am able to simulate the first failure and have tested that the
 patch fixes it.  I have not managed to simulate the second failure,
 but I think that fix is clearly safe.

 I'm not sure that the patch fits the original definition for -stable,
 but it seems to fit the current practice and I would appreciate if
 (assuming the patch passes review) it could be submitted for -stable.

Thanks,
NeilBrown



The sunrpc/TCP transport has an exponential back-off for reconnection,
starting at 3 seconds and with a maximum of 300 seconds.  On every
connection attempt the timeout is doubled.
It is only reset when the client deliberately closes the connection.
If the server closes the connection but a subsequent reconnect
succeeds, the timeout remains elevated.

This means that if the server resets the connection several times, as
can happen with server migration in a clustered environment, each
reconnect takes longer than the previous one - unnecessarily so.

This patch resets the timeout on a successful connection so that every
time the server resets the connection we start with a basic 3 second
timeout.

There is also the possibility for the reverse problem.  When the
client closes the connection it sets the timeout to 0 (so that a
reconnect - when required - is instant).  When 0 is doubled it remains
at 0, so if the server refused the reconnect, the client will try
again instantly and indefinitely.  To avoid this we ensure that after
doubling the timeout it is at least the minimum.

Cc: stable@vger.kernel.org
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/xprtsock.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 83c73c4..b032e06 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1403,6 +1403,7 @@ static void xs_tcp_state_change(struct sock *sk)
 				TCP_RCV_COPY_FRAGHDR | TCP_RCV_COPY_XID;
 
 			xprt_wake_pending_tasks(xprt, -EAGAIN);
+			xprt->reestablish_timeout = 0;
 		}
 		spin_unlock_bh(&xprt->transport_lock);
 		break;
@@ -2090,6 +2091,8 @@ static void xs_connect(struct rpc_task *task)
 				   &transport->connect_worker,
 				   xprt->reestablish_timeout);
 		xprt->reestablish_timeout <<= 1;
+		if (xprt->reestablish_timeout < XS_TCP_INIT_REEST_TO)
+			xprt->reestablish_timeout = XS_TCP_INIT_REEST_TO;
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
-- 
1.6.3.3


From: Neil Brown <neilb@suse.de>
Subject: [PATCH] NFS/RPC: fix problems with reestablish_timeout and related code.
Date: Sat, 12 Sep 2009 09:27:48 +1000
Message-ID: <19114.56564.845241.525591@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:33173 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753114AbZIKX0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 19:26:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


[[resending with correct cc:  - "vfs.kernel.org" just isn't right!]]

xprt->reestablish_timeout is used to cause TCP connection attempts to
back off if the connection fails so as not to hammer the network,
but to still allow immediate connections when there is no reason to
believe there is a problem.

It is not used for the first connection (when transport->sock is NULL)
but only on reconnects.

It is currently set:

 a/ to 0 when xs_tcp_state_change finds a state of TCP_FIN_WAIT1
    on the assumption that the client has closed the connection
    so the reconnect should be immediate when needed.
 b/ to at least XS_TCP_INIT_REEST_TO when xs_tcp_state_change
    detects TCP_CLOSING or TCP_CLOSE_WAIT on the assumption that the
    server closed the connection so a small delay at least is
    required.
 c/ as above when xs_tcp_state_change detects TCP_SYN_SENT, so that
    it is never 0 while a connection has been attempted, else
    the doubling will produce 0 and there will be no backoff.
 d/ to double is value (up to a limit) when delaying a connection,
    thus providing exponential backoff and
 e/ to XS_TCP_INIT_REEST_TO in xs_setup_tcp as simple initialisation.

So you can see it is highly dependant on xs_tcp_state_change being
called as expected.  However experimental evidence shows that
xs_tcp_state_change does not see all state changes.
("rpcdebug -m rpc trans" can help show what actually happens).

Results show:
 TCP_ESTABLISHED is reported when a connection is made.  TCP_SYN_SENT
 is never reported, so rule 'c' above is never effective.

 When the server closes the connection, TCP_CLOSE_WAIT and
 TCP_LAST_ACK *might* be reported, and TCP_CLOSE is always
 reported.  This rule 'b' above will sometimes be effective, but
 not reliably.

 When the client closes the connection, it used to result in
 TCP_FIN_WAIT1, TCP_FIN_WAIT2, TCP_CLOSE.  However since commit
 f75e674 (SUNRPC: Fix the problem of EADDRNOTAVAIL syslog floods on
 reconnect) we don't see *any* events on client-close.  I think this
 is because xs_restore_old_callbacks is called to disconnect
 xs_tcp_state_change before the socket is closed.
 In any case, rule 'a' no longer applies.

So all that is left are rule d, which successfully doubles the
timeout which is never rest, and rule e which initialises the timeout.

Even if the rules worked as expected, there would be a problem because
a successful connection does not reset the timeout, so a sequence
of events where the server closes the connection (e.g. during failover
testing) will cause longer and longer timeouts with no good reason.

This patch:

 - sets reestablish_timeout to 0 in xs_close thus effecting rule 'a'
 - sets it to 0 in xs_tcp_data_ready to ensure that a successful
   connection resets the timeout
 - sets it to at least XS_TCP_INIT_REEST_TO after it is doubled,
   thus effecting rule c

I have not reimplemented rule b and the new version of rule c
seems sufficient.

I suspect other code in xs_tcp_data_ready needs to be revised as well.
For example I don't think connect_cookie is being incremented as often
as it should be.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/xprtsock.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 83c73c4..24c9605 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -828,6 +828,7 @@ static void xs_close(struct rpc_xprt *xprt)
 	dprintk("RPC:       xs_close xprt %p\n", xprt);
 
 	xs_reset_transport(transport);
+	xprt->reestablish_timeout = 0;
 
 	smp_mb__before_clear_bit();
 	clear_bit(XPRT_CONNECTION_ABORT, &xprt->state);
@@ -1319,6 +1320,12 @@ static void xs_tcp_data_ready(struct sock *sk, int bytes)
 	if (xprt->shutdown)
 		goto out;
 
+	/* Any data means we had a useful conversation, so
+	 * the we don't need to delay the next reconnect
+	 */
+	if (xprt->reestablish_timeout)
+		xprt->reestablish_timeout = 0;
+
 	/* We use rd_desc to pass struct xprt to xs_tcp_data_recv */
 	rd_desc.arg.data = xprt;
 	do {
@@ -2090,6 +2097,8 @@ static void xs_connect(struct rpc_task *task)
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


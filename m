Return-Path: linux-nfs-owner@vger.kernel.org
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:35242 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750940AbaIXSIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 14:08:05 -0400
To: trond.myklebust@primarydata.com
Cc: bfields@fieldses.org, Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <678673b5e64d7b6bee0668053ee0d3a7a5316711.1411580799.git.jbaron@akamai.com>
In-Reply-To: <cover.1411580799.git.jbaron@akamai.com>
References: <cover.1411580799.git.jbaron@akamai.com>
From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 2/2] rpc: Add -EPERM processing for xs_udp_send_request()
Date: Wed, 24 Sep 2014 18:08:04 +0000 (GMT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an iptables drop rule is added for an nfs server, the client can end up in
a softlockup. Because of the way that xs_sendpages() is structured, the -EPERM
is ignored since the prior bits of the packet may have been successfully queued
and thus xs_sendpages() returns a non-zero value. Then, xs_udp_send_request()
thinks that because some bits were queued it should return -EAGAIN. We then try
the request again and again, resulting in cpu spinning. Reproducer:

1) open a file on the nfs server '/nfs/foo' (mounted using udp)
2) iptables -A OUTPUT -d <nfs server ip> -j DROP
3) write to /nfs/foo
4) close /nfs/foo
5) iptables -D OUTPUT -d <nfs server ip> -j DROP

The softlockup occurs in step 4 above.

The previous patch, allows xs_sendpages() to return both a sent count and
any error values that may have occurred. Thus, if we get an -EPERM, return
that to the higher level code.

With this patch in place we can successfully abort the above sequence and
avoid the softlockup.

I also tried the above test case on an nfs mount on tcp and although the system
does not softlockup, I still ended up with the 'hung_task' firing after 120
seconds, due to the i/o being stuck. The tcp case appears a bit harder to fix,
since -EPERM appears to get ignored much lower down in the stack and does not
propogate up to xs_sendpages(). This case is not quite as insidious as the
softlockup and it is not addressed here.

Reported-by: Yigong Lou <ylou@akamai.com>
Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/sunrpc/clnt.c     | 2 ++
 net/sunrpc/xprtsock.c | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 488ddee..c4c6069 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1913,6 +1913,7 @@ call_transmit_status(struct rpc_task *task)
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
+	case -EPERM:
 		if (RPC_IS_SOFTCONN(task)) {
 			xprt_end_transmit(task);
 			rpc_exit(task, task->tk_status);
@@ -2018,6 +2019,7 @@ call_status(struct rpc_task *task)
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
+	case -EPERM:
 		if (RPC_IS_SOFTCONN(task)) {
 			rpc_exit(task, status);
 			break;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 348c786..a19e9e7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -644,6 +644,10 @@ static int xs_udp_send_request(struct rpc_task *task)
 	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
 
+	/* firewall is blocking us, don't return -EAGAIN or we end up looping */
+	if (status == -EPERM)
+		goto process_status;
+
 	if (sent > 0 || status == 0) {
 		req->rq_xmit_bytes_sent += sent;
 		if (sent >= req->rq_slen)
@@ -652,6 +656,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 		status = -EAGAIN;
 	}
 
+process_status:
 	switch (status) {
 	case -ENOTSOCK:
 		status = -ENOTCONN;
@@ -667,6 +672,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 	case -ENOBUFS:
 	case -EPIPE:
 	case -ECONNREFUSED:
+	case -EPERM:
 		/* When the server has died, an ICMP port unreachable message
 		 * prompts ECONNREFUSED. */
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
-- 
1.8.2.rc2


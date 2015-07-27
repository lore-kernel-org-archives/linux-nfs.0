Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38156 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448AbbG0Azo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Jul 2015 20:55:44 -0400
Date: Mon, 27 Jul 2015 10:55:35 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: translate -EAGAIN to -ENOBUFS when socket is
 writable.
Message-ID: <20150727105535.50dff481@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


The networking layer does not reliably report the distinction between
a non-block write failing because:
 1/ the queue is too full already and
 2/ a memory allocation attempt failed.

The distinction is important because in the first case it is
appropriate to retry as soon as the socket reports that it is
writable, and in the second case a small delay is required as the
socket will most likely report as writable but kmalloc could still
fail.

sk_stream_wait_memory() exhibits this distinction nicely, setting
'vm_wait' if a small wait is needed.  However in the non-blocking case
it always returns -EAGAIN no matter the cause of the failure.  This
-EAGAIN call get all the way to sunrpc.

The sunrpc layer expects EAGAIN to indicate the first cause, and
ENOBUFS to indicate the second.  Various documentation suggests that
this is not unreasonable, but does not guarantee the desired error
codes.

The result of getting -EAGAIN when -ENOBUFS is expected is that the
send is tried again in a tight loop and soft lockups are reported.

so: add tests after calls to xs_sendpages() to translate -EAGAIN into
-ENOBUFS if the socket is writable.  This cannot happen inside
xs_sendpages() as the test for "is socket writable" is different
between TCP and UDP.

With this change, the tight loop retrying xs_sendpages() becomes a
loop which only retries every 250ms, and so will not trigger a
soft-lockup warning.

It is possible that the write did fail because the queue was too full
and by the time xs_sendpages() completed, the queue was writable
again.  In this case an extra 250ms delay is inserted that isn't
really needed.  This circumstance suggests a degree of congestion so a
delay is not necessarily a bad thing, and it can only cause a single
250ms delay, not a series of them.

Signed-off-by: NeilBrown <neilb@suse.com>

---
Hi Trond,
sorry for the delay in getting back to this.
This patch on top of your
 [PATCH 1/2] SUNRPC: Don't reencode message if transmission failed with ENOBUFS
 [PATCH 2/2] SUNRPC: Don't confuse ENOBUFS with a write_space issue

produces appropriate behaviour when sk_stream_alloc_skb() fails to allocate
memory in do_tcp_sendpages.  The send is retried after 250ms instead of immediately.

Thanks,
NeilBrown


diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b9fe8459dc84..2d1cd3918390 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -527,6 +527,10 @@ static int xs_local_send_request(struct rpc_task *task)
 			      true, &sent);
 	dprintk("RPC:       %s(%u) = %d\n",
 			__func__, xdr->len - req->rq_bytes_sent, status);
+
+	if (status == -EAGAIN && sock_writeable(transport->inet))
+		status = -ENOBUFS;
+
 	if (likely(sent > 0) || status == 0) {
 		req->rq_bytes_sent += sent;
 		req->rq_xmit_bytes_sent += sent;
@@ -590,6 +594,9 @@ static int xs_udp_send_request(struct rpc_task *task)
 	if (status == -EPERM)
 		goto process_status;
 
+	if (status == -EAGAIN && sock_writeable(transport->inet))
+		status = -ENOBUFS;
+
 	if (sent > 0 || status == 0) {
 		req->rq_xmit_bytes_sent += sent;
 		if (sent >= req->rq_slen)
@@ -687,6 +694,8 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -EAGAIN;
 		break;
 	}
+	if (status == -EAGAIN && sk_stream_is_writeable(transport->inet))
+		status = -ENOBUFS;
 
 	switch (status) {
 	case -ENOTSOCK:

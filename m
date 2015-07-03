Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38759 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444AbbGCNto (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jul 2015 09:49:44 -0400
Received: by igrv9 with SMTP id v9so77721770igr.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 Jul 2015 06:49:44 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Neil Brown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] SUNRPC: Don't confuse ENOBUFS with a write_space issue
Date: Fri,  3 Jul 2015 09:49:39 -0400
Message-Id: <1435931379-6654-3-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1435931379-6654-2-git-send-email-trond.myklebust@primarydata.com>
References: <20150629142623.5afc0e6d@noble>
 <1435931379-6654-1-git-send-email-trond.myklebust@primarydata.com>
 <1435931379-6654-2-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ENOBUFS means that memory allocations are failing due to an actual
low memory situation. It should not be confused with being out of
socket buffer space.

Handle the problem by just punting to the delay in call_status.

Reported-by: Neil Brown <neilb@suse.com>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee359fc7af16..44c1927b68c7 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -539,6 +539,7 @@ static int xs_local_send_request(struct rpc_task *task)
 
 	switch (status) {
 	case -ENOBUFS:
+		break;
 	case -EAGAIN:
 		status = xs_nospace(task);
 		break;
@@ -692,7 +693,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -ENOTCONN;
 		/* Should we call xs_close() here? */
 		break;
-	case -ENOBUFS:
 	case -EAGAIN:
 		status = xs_nospace(task);
 		break;
@@ -703,6 +703,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -ECONNREFUSED:
 	case -ENOTCONN:
 	case -EADDRINUSE:
+	case -ENOBUFS:
 	case -EPIPE:
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 	}
-- 
2.4.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:45411 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756427Ab3LaTkF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Dec 2013 14:40:05 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so13365043ief.20
        for <linux-nfs@vger.kernel.org>; Tue, 31 Dec 2013 11:40:05 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>, Chuck Lever <chuck.lever@oracle.com>,
        Bruce Fields <bfields@fieldses.com>,
        Gareth Williams <gareth@garethwilliams.me.uk>
Subject: [PATCH 4/4] SUNRPC: Add tracepoint for socket errors
Date: Tue, 31 Dec 2013 14:39:41 -0500
Message-Id: <1388518781-33571-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1388518781-33571-3-git-send-email-trond.myklebust@primarydata.com>
References: <CAB6yy379-A8fgLpQo+ppx5V93P9pXcabvmBJNTZ5hXxeJMuxBg@mail.gmail.com>
 <1388518781-33571-1-git-send-email-trond.myklebust@primarydata.com>
 <1388518781-33571-2-git-send-email-trond.myklebust@primarydata.com>
 <1388518781-33571-3-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 include/trace/events/sunrpc.h | 1 +
 net/sunrpc/xprtsock.c         | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index d51d16c7afd8..ddc179b7a105 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -301,6 +301,7 @@ DECLARE_EVENT_CLASS(xs_socket_event_done,
 
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_state_change);
 DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_connect);
+DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_error);
 DEFINE_RPC_SOCKET_EVENT_DONE(rpc_socket_reset_connection);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_close);
 DEFINE_RPC_SOCKET_EVENT(rpc_socket_shutdown);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ab006b7b7ab8..25dbfa971948 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -837,6 +837,7 @@ static void xs_error_report(struct sock *sk)
 		goto out;
 	dprintk("RPC:       xs_error_report client %p, error=%d...\n",
 			xprt, -err);
+	trace_rpc_socket_error(xprt, sk->sk_socket, err);
 	xprt_wake_pending_tasks(xprt, err);
  out:
 	read_unlock_bh(&sk->sk_callback_lock);
-- 
1.8.4.2


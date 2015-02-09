Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:40956 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933229AbbBIRS5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2015 12:18:57 -0500
Received: by iecrp18 with SMTP id rp18so11691562iec.7
        for <linux-nfs@vger.kernel.org>; Mon, 09 Feb 2015 09:18:57 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 06/14] SUNRPC: TCP/UDP always close the old socket before reconnecting
Date: Mon,  9 Feb 2015 12:18:36 -0500
Message-Id: <1423502324-25981-7-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1423502324-25981-6-git-send-email-trond.myklebust@primarydata.com>
References: <1423502324-25981-1-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-2-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-3-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-4-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-5-git-send-email-trond.myklebust@primarydata.com>
 <1423502324-25981-6-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It is not safe to call xs_reset_transport() from inside xs_udp_setup_socket()
or xs_tcp_setup_socket(), since they do not own the correct locks. Instead,
do it in xs_connect().

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtsock.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index e57d8ed2c4d8..e53a5ca03daf 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2081,8 +2081,6 @@ static void xs_udp_setup_socket(struct work_struct *work)
 	struct socket *sock = transport->sock;
 	int status = -EIO;
 
-	/* Start by resetting any existing state */
-	xs_reset_transport(transport);
 	sock = xs_create_sock(xprt, transport,
 			xs_addr(xprt)->sa_family, SOCK_DGRAM,
 			IPPROTO_UDP, false);
@@ -2328,6 +2326,9 @@ static void xs_connect(struct rpc_xprt *xprt, struct rpc_task *task)
 
 	WARN_ON_ONCE(!xprt_lock_connect(xprt, task, transport));
 
+	/* Start by resetting any existing state */
+	xs_reset_transport(transport);
+
 	if (transport->sock != NULL && !RPC_IS_SOFTCONN(task)) {
 		dprintk("RPC:       xs_connect delayed xprt %p for %lu "
 				"seconds\n",
-- 
2.1.0


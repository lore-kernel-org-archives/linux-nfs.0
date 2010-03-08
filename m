Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57026 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750972Ab0CHGtX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 01:49:23 -0500
Message-ID: <4B949DDD.1040407@cn.fujitsu.com>
Date: Mon, 08 Mar 2010 14:49:01 +0800
From: Bian Naimeng <biannm@cn.fujitsu.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH][V3]rpc client can not deal with ENOSOCK, so translate it
 into ENOCONN
References: <4B91D01A.5010800@cn.fujitsu.com> <1267885392.4688.5.camel@localhost.localdomain> <4B944F41.1000503@cn.fujitsu.com>
In-Reply-To: <4B944F41.1000503@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry, I need remove the unused lable "out:".

---

If NFSv4 client send a request before connect, or the old connection was broken
because a ETIMEOUT error catched by call_status, ->send_request will return
ENOSOCK, but rpc layer can not deal with it, so make sure ->send_request can
translate ENOSOCK into ENOCONN.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 net/sunrpc/xprtsock.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d739e5..df82795 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -549,8 +549,6 @@ static int xs_udp_send_request(struct rpc_task *task)
 		/* Still some bytes left; set up for a retry later. */
 		status = -EAGAIN;
 	}
-	if (!transport->sock)
-		goto out;
 
 	switch (status) {
 	case -ENOTSOCK:
@@ -570,7 +568,7 @@ static int xs_udp_send_request(struct rpc_task *task)
 		 * prompts ECONNREFUSED. */
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 	}
-out:
+
 	return status;
 }
 
@@ -652,8 +650,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -EAGAIN;
 		break;
 	}
-	if (!transport->sock)
-		goto out;
 
 	switch (status) {
 	case -ENOTSOCK:
@@ -673,7 +669,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -ENOTCONN:
 		clear_bit(SOCK_ASYNC_NOSPACE, &transport->sock->flags);
 	}
-out:
+
 	return status;
 }
 
-- 
1.6.4


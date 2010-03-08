From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: [PATCH][V2]rpc client can not deal with ENOSOCK, so translate it
 into ENOCONN
Date: Mon, 08 Mar 2010 09:13:37 +0800
Message-ID: <4B944F41.1000503@cn.fujitsu.com>
References: <4B91D01A.5010800@cn.fujitsu.com> <1267885392.4688.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53188 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751843Ab0CHBNv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 20:13:51 -0500
In-Reply-To: <1267885392.4688.5.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If NFSv4 client send a request before connect, or the old connection was broken
because a ETIMEOUT error catched by call_status, ->send_request will return
ENOSOCK, but rpc layer can not deal with it, so make sure ->send_request can
translate ENOSOCK into ENOCONN.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 net/sunrpc/xprtsock.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d739e5..9b9e653 100644
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
@@ -652,8 +650,6 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -EAGAIN;
 		break;
 	}
-	if (!transport->sock)
-		goto out;
 
 	switch (status) {
 	case -ENOTSOCK:
-- 
1.6.4


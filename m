From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: [PATCH]rpc client can not deal with ENOSOCK, so translate it into
 ENOCONN
Date: Sat, 06 Mar 2010 11:46:34 +0800
Message-ID: <4B91D01A.5010800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50722 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754089Ab0CFDqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Mar 2010 22:46:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If NFSv4 client send a request before connect, or the old connection was broken
because a ETIMEOUT error catched by call_status, ->send_request will return
ENOSOCK, but rpc layer can not deal with it, so translate it into ENOCONN.

Signed-off-by: Bian Naimeng <biannm@cn.fujitsu.com>

---
 net/sunrpc/xprtsock.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d739e5..45e5fd8 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -549,14 +549,13 @@ static int xs_udp_send_request(struct rpc_task *task)
 		/* Still some bytes left; set up for a retry later. */
 		status = -EAGAIN;
 	}
-	if (!transport->sock)
+	if (!transport->sock || status == -ENOTSOCK) {
+		/* Should we call xs_close() here? */
+		status = -ENOTCONN;
 		goto out;
+	}
 
 	switch (status) {
-	case -ENOTSOCK:
-		status = -ENOTCONN;
-		/* Should we call xs_close() here? */
-		break;
 	case -EAGAIN:
 		status = xs_nospace(task);
 		break;
@@ -652,14 +651,13 @@ static int xs_tcp_send_request(struct rpc_task *task)
 		status = -EAGAIN;
 		break;
 	}
-	if (!transport->sock)
+	if (!transport->sock || status == -ENOTSOCK) {
+		/* Should we call xs_close() here? */
+		status = -ENOTCONN;
 		goto out;
+	}
 
 	switch (status) {
-	case -ENOTSOCK:
-		status = -ENOTCONN;
-		/* Should we call xs_close() here? */
-		break;
 	case -EAGAIN:
 		status = xs_nospace(task);
 		break;
-- 
1.6.4


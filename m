Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:46586 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbdK3MVi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Nov 2017 07:21:38 -0500
Received: by mail-it0-f67.google.com with SMTP id t1so8041428ite.5
        for <linux-nfs@vger.kernel.org>; Thu, 30 Nov 2017 04:21:38 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Handle ENETDOWN errors
Date: Thu, 30 Nov 2017 07:21:33 -0500
Message-Id: <20171130122133.39471-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/clnt.c     | 5 +++++
 net/sunrpc/xprtsock.c | 1 +
 2 files changed, 6 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a801da812f86..e2a4184f3c5d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1841,6 +1841,7 @@ call_bind_status(struct rpc_task *task)
 	case -ECONNABORTED:
 	case -ENOTCONN:
 	case -EHOSTDOWN:
+	case -ENETDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
 	case -ENOBUFS:
@@ -1917,6 +1918,7 @@ call_connect_status(struct rpc_task *task)
 		/* fall through */
 	case -ECONNRESET:
 	case -ECONNABORTED:
+	case -ENETDOWN:
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
 	case -EADDRINUSE:
@@ -2022,6 +2024,7 @@ call_transmit_status(struct rpc_task *task)
 		 */
 	case -ECONNREFUSED:
 	case -EHOSTDOWN:
+	case -ENETDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
 	case -EPERM:
@@ -2071,6 +2074,7 @@ call_bc_transmit(struct rpc_task *task)
 	switch (task->tk_status) {
 	case 0:
 		/* Success */
+	case -ENETDOWN:
 	case -EHOSTDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
@@ -2139,6 +2143,7 @@ call_status(struct rpc_task *task)
 	task->tk_status = 0;
 	switch(status) {
 	case -EHOSTDOWN:
+	case -ENETDOWN:
 	case -EHOSTUNREACH:
 	case -ENETUNREACH:
 	case -EPERM:
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index fdf42cfa9121..6d0cc3b8f932 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2440,6 +2440,7 @@ static void xs_tcp_setup_socket(struct work_struct *work)
 		 */
 	case -ECONNREFUSED:
 	case -ECONNRESET:
+	case -ENETDOWN:
 	case -ENETUNREACH:
 	case -EHOSTUNREACH:
 	case -EADDRINUSE:
-- 
2.14.3


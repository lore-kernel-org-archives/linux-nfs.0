Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f52.google.com ([209.85.220.52]:65401 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755056AbaAGElP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 23:41:15 -0500
Received: by mail-pa0-f52.google.com with SMTP id ld10so19519791pab.39
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 20:41:15 -0800 (PST)
Message-ID: <52CB8564.6040002@gmail.com>
Date: Tue, 07 Jan 2014 12:41:08 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If try_module_get failed, xpt_bc_xprt should be set to NULL,
because xprt will be free.

Don't needed using xprt_put to free xprt, because it is always new.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprtsock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4fcdf74..5ed124f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2986,10 +2986,10 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	 */
 	xprt_set_connected(xprt);
 
-
 	if (try_module_get(THIS_MODULE))
 		return xprt;
-	xprt_put(xprt);
+
+	args->bc_xprt->xpt_bc_xprt = NULL;
 	ret = ERR_PTR(-EINVAL);
 out_err:
 	xs_xprt_free(xprt);
-- 
1.8.4.2

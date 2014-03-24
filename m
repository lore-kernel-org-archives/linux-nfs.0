Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:60093 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaCXEAg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Mar 2014 00:00:36 -0400
Received: by mail-pb0-f53.google.com with SMTP id rp16so4827672pbb.26
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 21:00:35 -0700 (PDT)
Message-ID: <532FADDC.6090101@gmail.com>
Date: Mon, 24 Mar 2014 12:00:28 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/5][RESEND] SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp
 failed
References: <532FAC85.20909@gmail.com>
In-Reply-To: <532FAC85.20909@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't move the assign of args->bc_xprt->xpt_bc_xprt out of xs_setup_bc_tcp,
because rpc_ping (which is in rpc_create) will using it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprtsock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 252a56e..e8acd9b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2986,6 +2986,8 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+
+	args->bc_xprt->xpt_bc_xprt = NULL;
 	xprt_put(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
-- 
1.8.5.3

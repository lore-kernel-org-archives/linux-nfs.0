Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f41.google.com ([209.85.160.41]:41737 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbaAIKdi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 05:33:38 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so2875823pbb.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 02:33:38 -0800 (PST)
Message-ID: <52CE7AFD.1020209@gmail.com>
Date: Thu, 09 Jan 2014 18:33:33 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/5] SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com> <52CE7A76.3080101@gmail.com>
In-Reply-To: <52CE7A76.3080101@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't move the assign of args->bc_xprt->xpt_bc_xprt out of xs_setup_bc_tcp,
because rpc_ping (which is in rpc_create) will using it.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprtsock.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 37ea15a..c996ace 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2981,9 +2981,10 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	 */
 	xprt_set_connected(xprt);
 
-
 	if (try_module_get(THIS_MODULE))
 		return xprt;
+
+	args->bc_xprt->xpt_bc_xprt = NULL;
 	xprt_put(xprt);
 	ret = ERR_PTR(-EINVAL);
 out_err:
-- 
1.8.4.2

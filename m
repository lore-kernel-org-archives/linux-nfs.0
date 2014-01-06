Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f53.google.com ([209.85.160.53]:45306 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753382AbaAFJd2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jan 2014 04:33:28 -0500
Received: by mail-pb0-f53.google.com with SMTP id ma3so18171785pbc.26
        for <linux-nfs@vger.kernel.org>; Mon, 06 Jan 2014 01:33:28 -0800 (PST)
Message-ID: <52CA7862.1020203@gmail.com>
Date: Mon, 06 Jan 2014 17:33:22 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] SUNRPC: fix a memory leak for tcp NFSv4.1 backchannel
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xs_setup_bc_tcp may return an existing xprt with non-NULL servername.
xprt_create_transport should not kstrdup servername for it.
Otherwise, those memory for servername will be leaked.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprt.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index ddd198e..6fa966f 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1339,7 +1339,11 @@ found:
 		xprt_destroy(xprt);
 		return ERR_PTR(-EINVAL);
 	}
-	xprt->servername = kstrdup(args->servername, GFP_KERNEL);
+
+	/* servername may not be NULL for tcp NFSv4.1 backchannel */
+	if (xprt->servername == NULL)
+		xprt->servername = kstrdup(args->servername, GFP_KERNEL);
+
 	if (xprt->servername == NULL) {
 		xprt_destroy(xprt);
 		return ERR_PTR(-ENOMEM);
-- 
1.8.4.2

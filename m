Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f173.google.com ([209.85.192.173]:54296 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbaCXD61 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 23:58:27 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so4763857pdj.18
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 20:58:27 -0700 (PDT)
Message-ID: <532FAD58.5080802@gmail.com>
Date: Mon, 24 Mar 2014 11:58:16 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/5][RESEND] NFSD: Free backchannel xprt in bc_destroy
References: <532FAC85.20909@gmail.com>
In-Reply-To: <532FAC85.20909@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Backchannel xprt isn't freed right now.
Free it in bc_destroy, and put the reference of THIS_MODULE.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprtsock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 2cbafa7..da882af 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2549,6 +2549,10 @@ static void bc_close(struct rpc_xprt *xprt)
 
 static void bc_destroy(struct rpc_xprt *xprt)
 {
+	dprintk("RPC:       bc_destroy xprt %p\n", xprt);
+
+	xs_xprt_free(xprt);
+	module_put(THIS_MODULE);
 }
 
 static struct rpc_xprt_ops xs_local_ops = {
-- 
1.8.5.3

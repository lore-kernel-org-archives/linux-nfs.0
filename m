Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f179.google.com ([209.85.192.179]:33741 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168AbaAIKcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 05:32:19 -0500
Received: by mail-pd0-f179.google.com with SMTP id y13so485632pdi.24
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 02:32:19 -0800 (PST)
Message-ID: <52CE7AAE.7040701@gmail.com>
Date: Thu, 09 Jan 2014 18:32:14 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Dr Fields James Bruce <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/5] NFSD: Free backchannel xprt in bc_destroy
References: <52CA7862.1020203@gmail.com> <20140106184926.GC31764@fieldses.org> <24D159B0-C13D-43A6-B307-2B967E154353@primarydata.com> <20140106225346.GB3342@fieldses.org> <FAC96643-8DBB-4CC8-9D43-73C69E8E6125@primarydata.com> <52CB8B79.6040907@gmail.com> <52CE7A76.3080101@gmail.com>
In-Reply-To: <52CE7A76.3080101@gmail.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Backchannel xprt isnot freed right now.
Free it in bc_destroy, and put the reference of THIS_MODULE.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/xprtsock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4fcdf74..7289e3c 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2545,6 +2545,10 @@ static void bc_close(struct rpc_xprt *xprt)
 
 static void bc_destroy(struct rpc_xprt *xprt)
 {
+	dprintk("RPC:       bc_destroy xprt %p\n", xprt);
+
+	xs_xprt_free(xprt);
+	module_put(THIS_MODULE);
 }
 
 static struct rpc_xprt_ops xs_local_ops = {
-- 
1.8.4.2

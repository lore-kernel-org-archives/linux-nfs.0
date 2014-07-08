Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f174.google.com ([209.85.192.174]:38172 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752540AbaGHDrD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 23:47:03 -0400
Received: by mail-pd0-f174.google.com with SMTP id y10so6461825pdj.33
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 20:47:00 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 2/2] nfs: check hostname in nfs_get_client
Date: Tue,  8 Jul 2014 11:45:48 +0800
Message-Id: <1404791148-10202-2-git-send-email-tao.peng@primarydata.com>
In-Reply-To: <1404791148-10202-1-git-send-email-tao.peng@primarydata.com>
References: <1404791148-10202-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We reference cl_hostname in many places. Add a check to make
sure it exists.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/client.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 1d09289..b213ee8 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -482,8 +482,13 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	struct nfs_net *nn = net_generic(cl_init->net, nfs_net_id);
 	const struct nfs_rpc_ops *rpc_ops = cl_init->nfs_mod->rpc_ops;
 
+	if (cl_init->hostname == NULL) {
+		WARN_ON(1);
+		return NULL;
+	}
+
 	dprintk("--> nfs_get_client(%s,v%u)\n",
-		cl_init->hostname ?: "", rpc_ops->version);
+		cl_init->hostname, rpc_ops->version);
 
 	/* see if the client already exists */
 	do {
@@ -510,7 +515,7 @@ nfs_get_client(const struct nfs_client_initdata *cl_init,
 	} while (!IS_ERR(new));
 
 	dprintk("<-- nfs_get_client() Failed to find %s (%ld)\n",
-		cl_init->hostname ?: "", PTR_ERR(new));
+		cl_init->hostname, PTR_ERR(new));
 	return new;
 }
 EXPORT_SYMBOL_GPL(nfs_get_client);
-- 
1.9.1


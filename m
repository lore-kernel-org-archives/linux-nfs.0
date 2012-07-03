Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:19223 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123Ab2GCQYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Jul 2012 12:24:00 -0400
Subject: [PATCH v3 11/11] NFS: get net after idr allocation
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 03 Jul 2012 20:20:44 +0400
Message-ID: <20120703162044.11911.6064.stgit@localhost.localdomain>
In-Reply-To: <20120703161844.11911.92996.stgit@localhost.localdomain>
References: <20120703161844.11911.92996.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allocation can fail. So instead of put net in case of failure, get net after
allocation.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfs/client.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d8c918b..d17aa10 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -175,7 +175,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_rpcclient = ERR_PTR(-EINVAL);
 
 	clp->cl_proto = cl_init->proto;
-	clp->cl_net = get_net(cl_init->net);
+	clp->cl_net = cl_init->net;
 
 #ifdef CONFIG_NFS_V4
 	err = nfs_get_cb_ident_idr(clp, cl_init->minorversion);
@@ -189,6 +189,7 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_minorversion = cl_init->minorversion;
 	clp->cl_mvops = nfs_v4_minor_ops[cl_init->minorversion];
 #endif
+	get_net(clp->cl_net);
 	cred = rpc_lookup_machine_cred("*");
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;


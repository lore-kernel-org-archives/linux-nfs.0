Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:42217 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933472Ab2AKPSr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 10:18:47 -0500
Subject: [PATCH v2 4/6] SUNRPC: remove RPC client pipefs dentries after
 unregister
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 11 Jan 2012 19:18:26 +0400
Message-ID: <20120111151826.5891.87727.stgit@localhost6.localdomain6>
In-Reply-To: <20120111151051.5891.1830.stgit@localhost6.localdomain6>
References: <20120111151051.5891.1830.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Without this patch we have races:

rpc_fill_super				rpc_free_client
rpc_pipefs_event(MOUNT)			rpc_remove_pipedir
spin_lock(&rpc_client_lock);
rpc_setup_pipedir_sb
spin_unlock(&rpc_client_lock);
					spin_lock(&rpc_client_lock);
					(remove from list)
					spin_unlock(&rpc_client_lock);
					MEAMORY LEAKED

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4170745..c89ceb8 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -578,7 +578,6 @@ rpc_free_client(struct rpc_clnt *clnt)
 {
 	dprintk("RPC:       destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
-	rpc_clnt_remove_pipedir(clnt);
 	if (clnt->cl_parent != clnt) {
 		rpc_release_client(clnt->cl_parent);
 		goto out_free;
@@ -587,6 +586,7 @@ rpc_free_client(struct rpc_clnt *clnt)
 		kfree(clnt->cl_server);
 out_free:
 	rpc_unregister_client(clnt);
+	rpc_clnt_remove_pipedir(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
 	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;


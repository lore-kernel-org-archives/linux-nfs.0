From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 65/69] rpc: pass target name down to rpc level on callbacks
Date: Tue, 23 Dec 2008 18:02:26 -0500
Message-ID: <20081223230225.13743.32176.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbYLWXYq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:24:46 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNOcm9006401
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:24:41 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Olga Kornievskaia <aglo@citi.umich.edu>

The rpc client needs to know the principal that the setclientid was done
as, so it can tell gssd who to authenticate to.

Signed-off-by: Olga Kornievskaia <aglo@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/nfs4callback.c      |    6 ++++++
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/clnt.c           |   16 ++++++++++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)


diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 094747a..3ca1417 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -384,6 +384,7 @@ static int do_probe_callback(void *data)
 		.version	= nfs_cb_version[1]->number,
 		.authflavor	= RPC_AUTH_UNIX, /* XXX: need AUTH_GSS... */
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
+		.client_name    = clp->cl_principal,
 	};
 	struct rpc_message msg = {
 		.rpc_proc       = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_NULL],
@@ -392,6 +393,11 @@ static int do_probe_callback(void *data)
 	struct rpc_clnt *client;
 	int status;
 
+	if (!clp->cl_principal && (clp->cl_flavor >= RPC_AUTH_GSS_KRB5)) {
+		status = nfserr_cb_path_down;
+		goto out_err;
+	}
+
 	/* Initialize address */
 	memset(&addr, 0, sizeof(addr));
 	addr.sin_family = AF_INET;
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 6f0ee1b..c39a210 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -58,6 +58,7 @@ struct rpc_clnt {
 	struct rpc_timeout	cl_timeout_default;
 	struct rpc_program *	cl_program;
 	char			cl_inline_name[32];
+	char			*cl_principal;	/* target to authenticate to */
 };
 
 /*
@@ -108,6 +109,7 @@ struct rpc_create_args {
 	u32			version;
 	rpc_authflavor_t	authflavor;
 	unsigned long		flags;
+	char			*client_name;
 };
 
 /* Values for "flags" field */
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 4895c34..347f2a2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -197,6 +197,12 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 
 	clnt->cl_rtt = &clnt->cl_rtt_default;
 	rpc_init_rtt(&clnt->cl_rtt_default, clnt->cl_timeout->to_initval);
+	clnt->cl_principal = NULL;
+	if (args->client_name) {
+		clnt->cl_principal = kstrdup(args->client_name, GFP_KERNEL);
+		if (!clnt->cl_principal)
+			goto out_no_principal;
+	}
 
 	kref_init(&clnt->cl_kref);
 
@@ -226,6 +232,8 @@ out_no_auth:
 		rpc_put_mount();
 	}
 out_no_path:
+	kfree(clnt->cl_principal);
+out_no_principal:
 	rpc_free_iostats(clnt->cl_metrics);
 out_no_stats:
 	if (clnt->cl_server != clnt->cl_inline_name)
@@ -354,6 +362,11 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	new->cl_metrics = rpc_alloc_iostats(clnt);
 	if (new->cl_metrics == NULL)
 		goto out_no_stats;
+	if (clnt->cl_principal) {
+		new->cl_principal = kstrdup(clnt->cl_principal, GFP_KERNEL);
+		if (new->cl_principal == NULL)
+			goto out_no_principal;
+	}
 	kref_init(&new->cl_kref);
 	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
 	if (err != 0)
@@ -366,6 +379,8 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	rpciod_up();
 	return new;
 out_no_path:
+	kfree(new->cl_principal);
+out_no_principal:
 	rpc_free_iostats(new->cl_metrics);
 out_no_stats:
 	kfree(new);
@@ -417,6 +432,7 @@ rpc_free_client(struct kref *kref)
 out_free:
 	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
+	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;
 	xprt_put(clnt->cl_xprt);
 	rpciod_down();


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:31454 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109Ab2HMLZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Aug 2012 07:25:07 -0400
Subject: [PATCH] SUNRPC: check current nsproxy before set of node name on
	client creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 13 Aug 2012 15:21:56 +0400
Message-ID: <20120813112156.8459.54793.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When child reaper exits, it can destroy mount namespace it belong to, and if
there are NFS mounts inside, then it will try to umount them. But in this
point current->nsproxy is set to NULL and all namespaces will be destroyed one
by one. I.e. we can't dereference current->nsproxy to obtain uts namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 net/sunrpc/clnt.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9a9676e..28ac940 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -279,6 +279,16 @@ void rpc_clients_notifier_unregister(void)
 
 static void rpc_clnt_set_nodename(struct rpc_clnt *clnt, const char *nodename)
 {
+	const char *nodename;
+
+	/*
+	 * We have to protect against dying chilp reaper, which has released
+	 * it's nsproxy already and is trying to destroy mount namespace.
+	 */
+	if (current->nsproxy == NULL)
+		return;
+
+	nodename = utsname()->nodename;
 	clnt->cl_nodelen = strlen(nodename);
 	if (clnt->cl_nodelen > UNX_MAXNODENAME)
 		clnt->cl_nodelen = UNX_MAXNODENAME;
@@ -365,7 +375,7 @@ static struct rpc_clnt * rpc_new_client(const struct rpc_create_args *args, stru
 	}
 
 	/* save the nodename */
-	rpc_clnt_set_nodename(clnt, utsname()->nodename);
+	rpc_clnt_set_nodename(clnt);
 	rpc_register_client(clnt);
 	return clnt;
 
@@ -524,7 +534,7 @@ rpc_clone_client(struct rpc_clnt *clnt)
 	err = rpc_setup_pipedir(new, clnt->cl_program->pipe_dir_name);
 	if (err != 0)
 		goto out_no_path;
-	rpc_clnt_set_nodename(new, utsname()->nodename);
+	rpc_clnt_set_nodename(new);
 	if (new->cl_auth)
 		atomic_inc(&new->cl_auth->au_count);
 	atomic_inc(&clnt->cl_count);


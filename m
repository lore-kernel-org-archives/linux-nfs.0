From: NeilBrown <neilb@suse.de>
Subject: [PATCH 2/2] NFS: support changing timeout and retransmit values with
	remount
Date: Fri, 11 Sep 2009 16:56:03 +1000
Message-ID: <20090911065603.8193.19468.stgit@notabene.brown>
References: <20090911065428.8193.8170.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58860 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbZIKGzm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2009 02:55:42 -0400
In-Reply-To: <20090911065428.8193.8170.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changing either timeo or retrans in
  mount -o remount

will now work.  Requests that are currently pending will not
have their timeouts changed.  However once they do timeout, the
next timeout will be based on the new values.

Signed-off-by: NeilBrown <neilb@suse.de>
---

 fs/nfs/client.c   |    4 ++--
 fs/nfs/internal.h |    2 ++
 fs/nfs/super.c    |   12 ++++++++++--
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8d25ccb..056e0ce 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -551,8 +551,8 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 /*
  * Initialise the timeout values for a connection
  */
-static void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
-				    unsigned int timeo, unsigned int retrans)
+void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
+			     unsigned int timeo, unsigned int retrans)
 {
 	to->to_initval = timeo * HZ / 10;
 	to->to_retries = retrans;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 7dd90a6..8395a7a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -123,6 +123,8 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
+extern void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
+				    unsigned int timeo, unsigned int retrans);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 76b28ca..b064895 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1846,17 +1846,16 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	 * to change.
 	 * Currently they are:
 	 *   flags: NFS_MOUNT_SOFT
+	 *   timeo and retrans
 	 */
 	if (((data->flags ^ nfss->flags) & ~(NFS_MOUNT_SOFT)) ||
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
-	    data->retrans != nfss->client->cl_timeout->to_retries ||
 	    data->auth_flavors[0] != nfss->client->cl_auth->au_flavor ||
 	    data->acregmin != nfss->acregmin / HZ ||
 	    data->acregmax != nfss->acregmax / HZ ||
 	    data->acdirmin != nfss->acdirmin / HZ ||
 	    data->acdirmax != nfss->acdirmax / HZ ||
-	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ) ||
 	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
 	    memcmp(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
 		   data->nfs_server.addrlen) != 0)
@@ -1933,6 +1932,15 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 			nfss->flags &= ~NFS_MOUNT_SOFT;
 	}
 
+	if (data->retrans != nfss->client->cl_timeout->to_retries ||
+	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ)) {
+		struct rpc_timeout timeparms;
+		nfs_init_timeout_values(&timeparms, nfss->client->cl_xprt->prot,
+					data->timeo, data->retrans);
+		memcpy(&nfss->client->cl_timeout_default,
+		       &timeparms, sizeof(timeparms));
+		nfss->client->cl_timeout = &nfss->client->cl_timeout_default;
+	}
 out:
 	kfree(data);
 	unlock_kernel();



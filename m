Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44284 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756183Ab2AJMNQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jan 2012 07:13:16 -0500
Subject: [PATCH v2 3/6] NFS: pass NFS client owner network namespace to RPC
 client creation routine
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 10 Jan 2012 16:12:54 +0400
Message-ID: <20120110121254.7307.59834.stgit@localhost6.localdomain6>
In-Reply-To: <20120110120946.7307.60098.stgit@localhost6.localdomain6>
References: <20120110120946.7307.60098.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces static "init_net" with nfs_client->net pointer in RPC
client creation calls.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/client.c     |    2 +-
 fs/nfs/internal.h   |    1 +
 fs/nfs/mount_clnt.c |    4 ++--
 fs/nfs/super.c      |    1 +
 4 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 4fb5cae..18153c2 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -642,7 +642,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= clp->net,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c60fa0b..e07627d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -138,6 +138,7 @@ struct nfs_mount_request {
 	int			noresvport;
 	unsigned int		*auth_flav_len;
 	rpc_authflavor_t	*auth_flavs;
+	struct net		*net;
 };
 
 extern int nfs_mount(struct nfs_mount_request *info);
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index d4c2d6b..4fbe3a8 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -153,7 +153,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.rpc_resp	= &result,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= info->net,
 		.protocol	= info->protocol,
 		.address	= info->sap,
 		.addrsize	= info->salen,
@@ -225,7 +225,7 @@ void nfs_umount(const struct nfs_mount_request *info)
 		.to_retries = 2,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= info->net,
 		.protocol	= IPPROTO_UDP,
 		.address	= info->sap,
 		.addrsize	= info->salen,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7495039..9395136 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1612,6 +1612,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 		.noresvport	= args->flags & NFS_MOUNT_NORESVPORT,
 		.auth_flav_len	= &server_authlist_len,
 		.auth_flavs	= server_authlist,
+		.net		= args->net,
 	};
 	int status;
 


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25111 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754467Ab3JRTPg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Oct 2013 15:15:36 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 3/5] NFS: cache parsed auth_info in nfs_server
Date: Fri, 18 Oct 2013 15:15:17 -0400
Message-ID: <1382123719-25194-4-git-send-email-dros@netapp.com>
In-Reply-To: <1382123719-25194-1-git-send-email-dros@netapp.com>
References: <1382123719-25194-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cache the auth_info structure in nfs_server and pass these values to submounts.

This lays the groundwork for supporting multiple sec= options.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/client.c           | 2 ++
 fs/nfs/nfs4client.c       | 1 +
 fs/nfs/super.c            | 3 +--
 include/linux/nfs_fs_sb.h | 1 +
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index abc535f..006fd52 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -786,6 +786,7 @@ static int nfs_init_server(struct nfs_server *server,
 		goto error;
 
 	server->port = data->nfs_server.port;
+	server->auth_info = data->auth_info;
 
 	error = nfs_init_server_rpcclient(server, &timeparms,
 					  data->selected_flavor);
@@ -929,6 +930,7 @@ void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *sour
 	target->acdirmax = source->acdirmax;
 	target->caps = source->caps;
 	target->options = source->options;
+	target->auth_info = source->auth_info;
 }
 EXPORT_SYMBOL_GPL(nfs_server_copy_userdata);
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 6a0661f..73899c0 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -961,6 +961,7 @@ static int nfs4_init_server(struct nfs_server *server,
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
 	server->options = data->options;
+	server->auth_info = data->auth_info;
 
 	if (data->auth_info.flavor_len >= 1)
 		data->selected_flavor = data->auth_info.flavors[0];
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7cd2d57..6c38c2a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2185,8 +2185,7 @@ nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 	data->wsize = nfss->wsize;
 	data->retrans = nfss->client->cl_timeout->to_retries;
 	data->selected_flavor = nfss->client->cl_auth->au_flavor;
-	data->auth_info.flavors[0] = nfss->client->cl_auth->au_flavor;
-	data->auth_info.flavor_len = 1;
+	data->auth_info = nfss->auth_info;
 	data->acregmin = nfss->acregmin / HZ;
 	data->acregmax = nfss->acregmax / HZ;
 	data->acdirmin = nfss->acdirmin / HZ;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index f9c0a6c..ee37167 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -149,6 +149,7 @@ struct nfs_server {
 	struct timespec		time_delta;	/* smallest time granularity */
 	unsigned long		mount_time;	/* when this fs was mounted */
 	dev_t			s_dev;		/* superblock dev numbers */
+	struct nfs_auth_info	auth_info;	/* parsed auth flavors */
 
 #ifdef CONFIG_NFS_FSCACHE
 	struct nfs_fscache_key	*fscache_key;	/* unique key for superblock */
-- 
1.7.12.4 (Apple Git-37)


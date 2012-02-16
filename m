Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31468 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753675Ab2BPVLc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 16:11:32 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 1/1] NFSv4.1 set the cl_hostname for data servers
Date: Thu, 16 Feb 2012 16:10:46 -0500
Message-Id: <1329426646-2074-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Used by /proc/fs/nfsfs/servers

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |    3 ++-
 fs/nfs/internal.h          |    3 ++-
 fs/nfs/nfs4filelayoutdev.c |   11 ++++++++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d0f850f..c625284 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1443,7 +1443,7 @@ error:
  */
 struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		const struct sockaddr *ds_addr,
-		int ds_addrlen, int ds_proto)
+		int ds_addrlen, int ds_proto, char *ds_hostname)
 {
 	struct nfs_client_initdata cl_init = {
 		.addr = ds_addr,
@@ -1452,6 +1452,7 @@ struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 		.proto = ds_proto,
 		.minorversion = mds_clp->cl_minorversion,
 		.net = mds_clp->net,
+		.hostname = ds_hostname,
 	};
 	struct rpc_timeout ds_timeout = {
 		.to_initval = 15 * HZ,
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 0c3648a..b870695 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -170,7 +170,8 @@ extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
 extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
 					     const struct sockaddr *ds_addr,
-					     int ds_addrlen, int ds_proto);
+					     int ds_addrlen, int ds_proto,
+					     char *ds_hostname);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 41677f0..a0b1fc5 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -153,6 +153,7 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 {
 	struct nfs_client *clp = ERR_PTR(-EIO);
 	struct nfs4_pnfs_ds_addr *da;
+	char *ds_hostname = NULL;
 	int status = 0;
 
 	dprintk("--> %s DS %s au_flavor %d\n", __func__, ds->ds_remotestr,
@@ -164,9 +165,17 @@ nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		dprintk("%s: DS %s: trying address %s\n",
 			__func__, ds->ds_remotestr, da->da_remotestr);
 
+		/* For debug: OK if ds_remotestr or ds_hostname is NULL */
+		if (da->da_remotestr) {
+			char *end = strchr(da->da_remotestr, ':');
+			ds_hostname = kstrndup(da->da_remotestr,
+					       end - da->da_remotestr,
+					       GFP_KERNEL);
+		}
 		clp = nfs4_set_ds_client(mds_srv->nfs_client,
 				 (struct sockaddr *)&da->da_addr,
-				 da->da_addrlen, IPPROTO_TCP);
+				 da->da_addrlen, IPPROTO_TCP, ds_hostname);
+		kfree(ds_hostname);
 		if (!IS_ERR(clp))
 			break;
 	}
-- 
1.7.6.4


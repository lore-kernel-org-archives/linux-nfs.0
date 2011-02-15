Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26933 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735Ab1BPSjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Feb 2011 13:39:04 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 2 05/18] NFSv4.1: new flag for state renewal check
Date: Tue, 15 Feb 2011 03:38:50 -0500
Message-Id: <1297759143-2045-6-git-send-email-andros@netapp.com>
In-Reply-To: <1297759143-2045-1-git-send-email-andros@netapp.com>
References: <1297759143-2045-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Data servers not sharing a session with the mount MDS always have an empty
cl_superblocks list.
Replace the cl_superblocks empty list check to see if it is time to shut down
renewd with the NFS_CS_STOP_RENEW bit which is not set by such a data server.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c           |    5 +++++
 fs/nfs/nfs4renewd.c       |    6 +-----
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b9ed2a8..a86698c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1019,14 +1019,19 @@ static void nfs_server_insert_lists(struct nfs_server *server)
 	spin_lock(&nfs_client_lock);
 	list_add_tail_rcu(&server->client_link, &clp->cl_superblocks);
 	list_add_tail(&server->master_link, &nfs_volume_list);
+	clear_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state);
 	spin_unlock(&nfs_client_lock);
 
 }
 
 static void nfs_server_remove_lists(struct nfs_server *server)
 {
+	struct nfs_client *clp = server->nfs_client;
+
 	spin_lock(&nfs_client_lock);
 	list_del_rcu(&server->client_link);
+	if (clp && list_empty(&clp->cl_superblocks))
+		set_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state);
 	list_del(&server->master_link);
 	spin_unlock(&nfs_client_lock);
 
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 402143d..df8e7f3 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -64,12 +64,8 @@ nfs4_renew_state(struct work_struct *work)
 	ops = clp->cl_mvops->state_renewal_ops;
 	dprintk("%s: start\n", __func__);
 
-	rcu_read_lock();
-	if (list_empty(&clp->cl_superblocks)) {
-		rcu_read_unlock();
+	if (test_bit(NFS_CS_STOP_RENEW, &clp->cl_res_state))
 		goto out;
-	}
-	rcu_read_unlock();
 
 	spin_lock(&clp->cl_lock);
 	lease = clp->cl_lease_time;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index b197563..2c2dc18 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -30,6 +30,7 @@ struct nfs_client {
 #define NFS_CS_CALLBACK		1		/* - callback started */
 #define NFS_CS_IDMAP		2		/* - idmap started */
 #define NFS_CS_RENEWD		3		/* - renewd started */
+#define NFS_CS_STOP_RENEW	4		/* no more state to renew */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
-- 
1.7.2.3


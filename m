Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253Ab1BDVep (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:45 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 26/40] pnfs-submit: wave3 refactor data server session initialization
Date: Fri,  4 Feb 2011 16:33:48 -0500
Message-Id: <1296855242-2592-27-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-26-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Follow nfs4_init_session convention.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/internal.h          |    2 +-
 fs/nfs/nfs4_fs.h           |   12 ++++++++++++
 fs/nfs/nfs4filelayoutdev.c |   30 +++++++++++-------------------
 fs/nfs/nfs4proc.c          |   22 +++++++++++++++++++++-
 4 files changed, 45 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 764a235..5518d61 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -216,7 +216,7 @@ extern const u32 nfs41_maxwrite_overhead;
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
-extern int nfs4_recover_expired_lease(struct nfs_client *clp);
+extern int nfs4_init_ds_session(struct nfs_client *clp);
 
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 5d84642..5dc378e 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -266,6 +266,12 @@ is_ds_only_client(struct nfs_client *clp)
 	return (clp->cl_exchange_flags & EXCHGID4_FLAG_MASK_PNFS) ==
 		EXCHGID4_FLAG_USE_PNFS_DS;
 }
+
+static inline bool
+is_ds_client(struct nfs_client *clp)
+{
+	return clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS;
+}
 #else /* CONFIG_NFS_v4_1 */
 static inline struct nfs4_session *nfs4_get_session(const struct nfs_server *server)
 {
@@ -289,6 +295,12 @@ is_ds_only_client(struct nfs_client *clp)
 {
 	return false;
 }
+
+static inline bool
+is_ds_client(struct nfs_client *clp)
+{
+	return false;
+}
 #endif /* CONFIG_NFS_V4_1 */
 
 extern const struct nfs4_minor_version_ops *nfs_v4_minor_ops[];
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index c46cb00..6557d1c 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -113,7 +113,7 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 {
 	struct nfs_client *clp;
 	struct sockaddr_in sin;
-	int err = 0;
+	int status = 0;
 
 	dprintk("--> %s ip:port %x:%hu au_flavor %d\n", __func__,
 		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
@@ -126,7 +126,7 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	clp = nfs4_set_ds_client(mds_srv->nfs_client, (struct sockaddr *)&sin,
 				 sizeof(sin), IPPROTO_TCP);
 	if (IS_ERR(clp)) {
-		err = PTR_ERR(clp);
+		status = PTR_ERR(clp);
 		goto out;
 	}
 
@@ -134,27 +134,13 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 		dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
 			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
 
-		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
-			err = -ENODEV;
+		if (!is_ds_client(clp)) {
+			status = -ENODEV;
 			goto out_put;
 		}
 		goto out;
 	}
 
-	/* Ask for only the EXCHGID4_FLAG_USE_PNFS_DS pNFS role */
-	dprintk("%s EXCHANGE_ID for clp %p\n", __func__, clp);
-	clp->cl_exchange_flags = EXCHGID4_FLAG_USE_PNFS_DS;
-
-	err = nfs4_recover_expired_lease(clp);
-	if (!err)
-		err = nfs4_check_client_ready(clp);
-	if (err)
-		goto out_put;
-
-	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
-		err = -ENODEV;
-		goto out_put;
-	}
 	/*
 	 * Set DS lease equal to the MDS lease, renewal is scheduled in
 	 * create_session
@@ -164,12 +150,18 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	spin_unlock(&mds_srv->nfs_client->cl_lock);
 	clp->cl_last_renewal = jiffies;
 
+	/* New nfs_client */
+	status = nfs4_init_ds_session(clp);
+	if (status)
+		goto out_put;
+
+
 	ds->ds_clp = clp;
 
 	dprintk("%s [new] ip=%x, port=%hu\n", __func__, ntohl(ds->ds_ip_addr),
 		ntohs(ds->ds_port));
 out:
-	return err;
+	return status;
 out_put:
 	nfs_put_client(clp);
 	goto out;
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fb22cbf..1da0ebf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1591,7 +1591,6 @@ static int nfs4_client_recover_expired_lease(struct nfs_client *clp)
 	}
 	return ret;
 }
-EXPORT_SYMBOL(nfs4_recover_expired_lease);
 
 static int nfs4_recover_expired_lease(struct nfs_server *server)
 {
@@ -5086,6 +5085,27 @@ int nfs4_init_session(struct nfs_server *server)
 	return ret;
 }
 
+int nfs4_init_ds_session(struct nfs_client *clp)
+{
+	struct nfs4_session *session = clp->cl_session;
+	int ret;
+
+	if (!test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state))
+		return 0;
+
+	ret = nfs4_client_recover_expired_lease(clp);
+	if (!ret)
+		/* Test for the DS role */
+		if (!is_ds_client(clp))
+			ret = -ENODEV;
+	if (!ret)
+		ret = nfs4_check_client_ready(clp);
+	return ret;
+
+}
+EXPORT_SYMBOL_GPL(nfs4_init_ds_session);
+
+
 /*
  * Renew the cl_session lease.
  */
-- 
1.6.6


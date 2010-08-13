Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14051 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754362Ab0HMVce (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 17:32:34 -0400
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 35/50] pnfs_submit: filelayout i/o helpers
Date: Fri, 13 Aug 2010 17:31:47 -0400
Message-Id: <1281735122-1496-36-git-send-email-andros@netapp.com>
In-Reply-To: <1281735122-1496-35-git-send-email-andros@netapp.com>
References: <1281735122-1496-1-git-send-email-andros@netapp.com>
 <1281735122-1496-2-git-send-email-andros@netapp.com>
 <1281735122-1496-3-git-send-email-andros@netapp.com>
 <1281735122-1496-4-git-send-email-andros@netapp.com>
 <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <1281735122-1496-13-git-send-email-andros@netapp.com>
 <1281735122-1496-14-git-send-email-andros@netapp.com>
 <1281735122-1496-15-git-send-email-andros@netapp.com>
 <1281735122-1496-16-git-send-email-andros@netapp.com>
 <1281735122-1496-17-git-send-email-andros@netapp.com>
 <1281735122-1496-18-git-send-email-andros@netapp.com>
 <1281735122-1496-19-git-send-email-andros@netapp.com>
 <1281735122-1496-20-git-send-email-andros@netapp.com>
 <1281735122-1496-21-git-send-email-andros@netapp.com>
 <1281735122-1496-22-git-send-email-andros@netapp.com>
 <1281735122-1496-23-git-send-email-andros@netapp.com>
 <1281735122-1496-24-git-send-email-andros@netapp.com>
 <1281735122-1496-25-git-send-email-andros@netapp.com>
 <1281735122-1496-26-git-send-email-andros@netapp.com>
 <1281735122-1496-27-git-send-email-andros@netapp.com>
 <1281735122-1496-28-git-send-email-andros@netapp.com>
 <1281735122-1496-29-git-send-email-andros@netapp.com>
 <1281735122-1496-30-git-send-email-andros@netapp.com>
 <1281735122-1496-31-git-send-email-andros@netapp.com>
 <1281735122-1496-32-git-send-email-andros@netapp.com>
 <1281735122-1496-33-git-send-email-andros@netapp.com>
 <1281735122-1496-34-git-send-email-andros@netapp.com>
 <1281735122-1496-35-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |    7 +-
 fs/nfs/internal.h          |   12 +++
 fs/nfs/nfs4filelayout.c    |   42 ++++++++++-
 fs/nfs/nfs4filelayout.h    |   10 +++
 fs/nfs/nfs4filelayoutdev.c |  180 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          |    8 +-
 6 files changed, 252 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 09ee926..b53f61c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -348,7 +348,7 @@ static int nfs_sockaddr_match_ipaddr(const struct sockaddr *sa1,
  * Test if two socket addresses represent the same actual socket,
  * by comparing (only) relevant fields, including the port number.
  */
-static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 			    const struct sockaddr *sa2)
 {
 	if (sa1->sa_family != sa2->sa_family)
@@ -362,6 +362,7 @@ static int nfs_sockaddr_cmp(const struct sockaddr *sa1,
 	}
 	return 0;
 }
+EXPORT_SYMBOL(nfs_sockaddr_cmp);
 
 /*
  * Find a client by IP address and protocol version
@@ -553,6 +554,7 @@ int nfs4_check_client_ready(struct nfs_client *clp)
 		return -EPROTONOSUPPORT;
 	return 0;
 }
+EXPORT_SYMBOL(nfs4_check_client_ready);
 
 /*
  * Initialise the timeout values for a connection
@@ -1250,7 +1252,7 @@ error:
 /*
  * Set up an NFS4 client
  */
-static int nfs4_set_client(struct nfs_server *server,
+int nfs4_set_client(struct nfs_server *server,
 		const char *hostname,
 		const struct sockaddr *addr,
 		const size_t addrlen,
@@ -1293,6 +1295,7 @@ error:
 	dprintk("<-- nfs4_set_client() = xerror %d\n", error);
 	return error;
 }
+EXPORT_SYMBOL(nfs4_set_client);
 
 
 /*
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index e70f44b..eba1cc0 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -139,6 +139,16 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
+extern int nfs_sockaddr_cmp(const struct sockaddr *sa1,
+		const struct sockaddr *sa2);
+extern int nfs4_set_client(struct nfs_server *server,
+		const char *hostname,
+		const struct sockaddr *addr,
+		const size_t addrlen,
+		const char *ip_addr,
+		rpc_authflavor_t authflavour,
+		int proto, const struct rpc_timeout *timeparms,
+		u32 minorversion);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
@@ -201,6 +211,8 @@ extern const u32 nfs41_maxwrite_overhead;
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
+extern int nfs4_recover_expired_lease(struct nfs_client *clp);
+
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 4af089c..d1c0d35 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -38,9 +38,17 @@
 
 #include <linux/module.h>
 #include <linux/init.h>
-
+#include <linux/time.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/string.h>
+#include <linux/vmalloc.h>
+#include <linux/stat.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
 #include <linux/nfs_fs.h>
 #include <linux/nfs_page.h>
+#include <linux/pnfs_xdr.h>
 #include <linux/nfs4_pnfs.h>
 
 #include "nfs4filelayout.h"
@@ -83,6 +91,38 @@ filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
 	return 0;
 }
 
+/* This function is used by the layout driver to calculate the
+ * offset of the file on the dserver based on whether the
+ * layout type is STRIPE_DENSE or STRIPE_SPARSE
+ */
+static loff_t
+filelayout_get_dserver_offset(struct pnfs_layout_segment *lseg, loff_t offset)
+{
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
+
+	switch (flseg->stripe_type) {
+	case STRIPE_SPARSE:
+		return offset;
+
+	case STRIPE_DENSE:
+	{
+		u32 stripe_width;
+		u64 tmp, off;
+		u32 unit = flseg->stripe_unit;
+
+		stripe_width = unit * FILE_DSADDR(lseg)->stripe_count;
+		tmp = off = offset - flseg->pattern_offset;
+		do_div(tmp, stripe_width);
+		return tmp * unit + do_div(off, unit);
+	}
+	default:
+		BUG();
+	}
+
+	/* We should never get here... just to stop the gcc warning */
+	return 0;
+}
+
 /*
  * Create a filelayout layout structure and return it.  The pNFS client
  * will use the pnfs_layout_type type to refer to the layout for this
diff --git a/fs/nfs/nfs4filelayout.h b/fs/nfs/nfs4filelayout.h
index aeb2147..f8f7c05 100644
--- a/fs/nfs/nfs4filelayout.h
+++ b/fs/nfs/nfs4filelayout.h
@@ -23,6 +23,10 @@
 #define NFS4_PNFS_MAX_STRIPE_CNT 4096
 #define NFS4_PNFS_MAX_MULTI_CNT  64 /* 256 fit into a u8 stripe_index */
 
+#define FILE_DSADDR(lseg) (container_of(lseg->deviceid, \
+					struct nfs4_file_layout_dsaddr, \
+					deviceid))
+
 enum stripetype4 {
 	STRIPE_SPARSE = 1,
 	STRIPE_DENSE = 2
@@ -62,6 +66,9 @@ struct nfs4_filelayout {
 	u32 stripe_unit;
 };
 
+extern struct nfs_fh *
+nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset);
+
 static inline struct nfs4_filelayout *
 FILE_LO(struct pnfs_layout_type *lo)
 {
@@ -73,6 +80,9 @@ extern struct pnfs_client_operations *pnfs_callback_ops;
 extern void nfs4_fl_free_deviceid_callback(struct kref *);
 extern void print_ds(struct nfs4_pnfs_ds *ds);
 char *deviceid_fmt(const struct pnfs_deviceid *dev_id);
+u32 nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset);
+struct nfs4_pnfs_ds *nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg,
+					u32 ds_idx);
 extern struct nfs4_file_layout_dsaddr *
 nfs4_pnfs_device_item_find(struct nfs_client *, struct pnfs_deviceid *dev_id);
 struct nfs4_file_layout_dsaddr *
diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f7614f6..1452710 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -117,6 +117,112 @@ _data_server_lookup(u32 ip_addr, u32 port)
 	return NULL;
 }
 
+/* Create an rpc to the data server defined in 'dev_list' */
+static int
+nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
+{
+	struct nfs_server	*tmp;
+	struct sockaddr_in	sin;
+	struct rpc_clnt 	*mds_clnt = mds_srv->client;
+	struct nfs_client	*clp = mds_srv->nfs_client;
+	struct sockaddr		*mds_addr;
+	int err = 0;
+
+	dprintk("--> %s ip:port %s au_flavor %d\n", __func__,
+		ds->r_addr, mds_clnt->cl_auth->au_flavor);
+
+	sin.sin_family = AF_INET;
+	sin.sin_addr.s_addr = ds->ds_ip_addr;
+	sin.sin_port = ds->ds_port;
+
+	/*
+	 * If this DS is also the MDS, use the MDS session only if the
+	 * MDS exchangeid flags show the EXCHGID4_FLAG_USE_PNFS_DS pNFS role.
+	 */
+	mds_addr = (struct sockaddr *)&clp->cl_addr;
+	if (nfs_sockaddr_cmp((struct sockaddr *)&sin, mds_addr)) {
+		if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
+			printk(KERN_INFO "ip:port %s is not a pNFS Data "
+				"Server\n", ds->r_addr);
+			err = -ENODEV;
+		} else {
+			atomic_inc(&clp->cl_count);
+			ds->ds_clp = clp;
+			dprintk("%s Using MDS Session for DS\n", __func__);
+		}
+		goto out;
+	}
+
+	/* Temporay server for nfs4_set_client */
+	tmp = kzalloc(sizeof(struct nfs_server), GFP_KERNEL);
+	if (!tmp)
+		goto out;
+
+	/*
+	 * Set a retrans, timeout interval, and authflavor equual to the MDS
+	 * values. Use the MDS nfs_client cl_ipaddr field so as to use the
+	 * same co_ownerid as the MDS.
+	 */
+	err = nfs4_set_client(tmp,
+			      mds_srv->nfs_client->cl_hostname,
+			      (struct sockaddr *)&sin,
+			      sizeof(struct sockaddr),
+			      mds_srv->nfs_client->cl_ipaddr,
+			      mds_clnt->cl_auth->au_flavor,
+			      IPPROTO_TCP,
+			      mds_clnt->cl_xprt->timeout,
+			      1 /* minorversion */);
+	if (err < 0)
+		goto out_free;
+
+	clp = tmp->nfs_client;
+
+	/* Ask for only the EXCHGID4_FLAG_USE_PNFS_DS pNFS role */
+	dprintk("%s EXCHANGE_ID for clp %p\n", __func__, clp);
+	clp->cl_exchange_flags = EXCHGID4_FLAG_USE_PNFS_DS;
+
+	err = nfs4_recover_expired_lease(clp);
+	if (!err)
+		err = nfs4_check_client_ready(clp);
+	if (err)
+		goto out_put;
+
+	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
+		printk(KERN_INFO "ip:port %s is not a pNFS Data Server\n",
+			ds->r_addr);
+		err = -ENODEV;
+		goto out_put;
+	}
+	/*
+	 * Mask the (possibly) returned EXCHGID4_FLAG_USE_PNFS_MDS pNFS role
+	 * The is_ds_only_session depends on this.
+	 */
+	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;
+	/*
+	 * Set DS lease equal to the MDS lease, renewal is scheduled in
+	 * create_session
+	 */
+	spin_lock(&mds_srv->nfs_client->cl_lock);
+	clp->cl_lease_time = mds_srv->nfs_client->cl_lease_time;
+	spin_unlock(&mds_srv->nfs_client->cl_lock);
+	clp->cl_last_renewal = jiffies;
+
+	clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
+	ds->ds_clp = clp;
+
+	dprintk("%s: ip=%x, port=%hu, rpcclient %p\n", __func__,
+				ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
+				clp->cl_rpcclient);
+out_free:
+	kfree(tmp);
+out:
+	dprintk("%s Returns %d\n", __func__, err);
+	return err;
+out_put:
+	nfs_put_client(clp);
+	goto out_free;
+}
+
 static void
 destroy_ds(struct nfs4_pnfs_ds *ds)
 {
@@ -454,3 +560,77 @@ nfs4_pnfs_device_item_find(struct nfs_client *clp, struct pnfs_deviceid *id)
 	return (d == NULL) ? NULL :
 		container_of(d, struct nfs4_file_layout_dsaddr, deviceid);
 }
+
+/*
+ * Want res = (offset - layout->pattern_offset)/ layout->stripe_unit
+ * Then: ((res + fsi) % dsaddr->stripe_count)
+ */
+static inline u32
+_nfs4_fl_calc_j_index(struct pnfs_layout_segment *lseg, loff_t offset)
+{
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
+	u64 tmp;
+
+	tmp = offset - flseg->pattern_offset;
+	do_div(tmp, flseg->stripe_unit);
+	tmp += flseg->first_stripe_index;
+	return do_div(tmp, FILE_DSADDR(lseg)->stripe_count);
+}
+
+u32
+nfs4_fl_calc_ds_index(struct pnfs_layout_segment *lseg, loff_t offset)
+{
+	u32 j;
+
+	j = _nfs4_fl_calc_j_index(lseg, offset);
+	return FILE_DSADDR(lseg)->stripe_indices[j];
+}
+
+struct nfs_fh *
+nfs4_fl_select_ds_fh(struct pnfs_layout_segment *lseg, loff_t offset)
+{
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
+	u32 i;
+
+	if (flseg->stripe_type == STRIPE_SPARSE) {
+		if (flseg->num_fh == 1)
+			i = 0;
+		else if (flseg->num_fh == 0)
+			return NULL;
+		else
+			i = nfs4_fl_calc_ds_index(lseg, offset);
+	} else
+		i = _nfs4_fl_calc_j_index(lseg, offset);
+	return &flseg->fh_array[i];
+}
+
+struct nfs4_pnfs_ds *
+nfs4_fl_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx)
+{
+	struct nfs4_filelayout_segment *flseg = LSEG_LD_DATA(lseg);
+	struct nfs4_file_layout_dsaddr *dsaddr;
+
+	dsaddr = FILE_DSADDR(lseg);
+	if (dsaddr->ds_list[ds_idx] == NULL) {
+		printk(KERN_ERR "%s: No data server for device id (%s)!!\n",
+			__func__, deviceid_fmt(&flseg->dev_id));
+		return NULL;
+	}
+
+	if (!dsaddr->ds_list[ds_idx]->ds_clp) {
+		int err;
+
+		err = nfs4_pnfs_ds_create(PNFS_NFS_SERVER(lseg->layout),
+					  dsaddr->ds_list[ds_idx]);
+		if (err) {
+			printk(KERN_ERR "%s nfs4_pnfs_ds_create error %d\n",
+			       __func__, err);
+			return NULL;
+		}
+	}
+	dprintk("%s: dev_id=%s, ds_idx=%u\n",
+		__func__, deviceid_fmt(&flseg->dev_id), ds_idx);
+
+	return dsaddr->ds_list[ds_idx];
+}
+
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 353c2fb..d7d193b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1576,9 +1576,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	return 0;
 }
 
-static int nfs4_recover_expired_lease(struct nfs_server *server)
+int nfs4_recover_expired_lease(struct nfs_client *clp)
 {
-	struct nfs_client *clp = server->nfs_client;
 	unsigned int loop;
 	int ret;
 
@@ -1594,6 +1593,7 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
 	}
 	return ret;
 }
+EXPORT_SYMBOL(nfs4_recover_expired_lease);
 
 /*
  * OPEN_EXPIRED:
@@ -1683,7 +1683,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 		dprintk("nfs4_do_open: nfs4_get_state_owner failed!\n");
 		goto out_err;
 	}
-	status = nfs4_recover_expired_lease(server);
+	status = nfs4_recover_expired_lease(server->nfs_client);
 	if (status != 0)
 		goto err_put_state_owner;
 	if (path->dentry->d_inode != NULL)
@@ -5121,7 +5121,7 @@ int nfs4_init_session(struct nfs_server *server)
 	session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
 	session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
 
-	ret = nfs4_recover_expired_lease(server);
+	ret = nfs4_recover_expired_lease(server->nfs_client);
 	if (!ret)
 		ret = nfs4_check_client_ready(clp);
 	return ret;
-- 
1.6.2.5


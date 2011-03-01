Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:39366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757120Ab1CAR3w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 12:29:52 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH pNFS wave 3 Version 3 12/18] NFSv4.1: data server connection
Date: Mon, 28 Feb 2011 20:34:17 -0500
Message-Id: <1298943263-2886-13-git-send-email-andros@netapp.com>
In-Reply-To: <1298943263-2886-12-git-send-email-andros@netapp.com>
References: <1298943263-2886-1-git-send-email-andros@netapp.com>
 <1298943263-2886-2-git-send-email-andros@netapp.com>
 <1298943263-2886-3-git-send-email-andros@netapp.com>
 <1298943263-2886-4-git-send-email-andros@netapp.com>
 <1298943263-2886-5-git-send-email-andros@netapp.com>
 <1298943263-2886-6-git-send-email-andros@netapp.com>
 <1298943263-2886-7-git-send-email-andros@netapp.com>
 <1298943263-2886-8-git-send-email-andros@netapp.com>
 <1298943263-2886-9-git-send-email-andros@netapp.com>
 <1298943263-2886-10-git-send-email-andros@netapp.com>
 <1298943263-2886-11-git-send-email-andros@netapp.com>
 <1298943263-2886-12-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Introduce a data server set_client and init session following the
nfs4_set_client and  nfs4_init_session convention.

Once a new nfs_client is on the nfs_client_list, the nfs_client cl_cons_state
serializes access to creating an nfs_client struct with matching properties.

Use the new nfs_get_client() that initializes new clients.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c            |   41 +++++++++++++++++++++++++++++
 fs/nfs/internal.h          |    5 +++
 fs/nfs/nfs4_fs.h           |   12 ++++++++
 fs/nfs/nfs4filelayoutdev.c |   61 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c          |   29 +++++++++++++++++++-
 include/linux/nfs_xdr.h    |    1 +
 6 files changed, 147 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d5c5bdf..6dd50ac 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1417,6 +1417,47 @@ error:
 	return error;
 }
 
+/*
+ * Set up a pNFS Data Server client.
+ *
+ * Return any existing nfs_client that matches server address,port,version
+ * and minorversion.
+ *
+ * For a new nfs_client, use a soft mount (default), a low retrans and a
+ * low timeout interval so that if a connection is lost, we retry through
+ * the MDS.
+ */
+struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+		const struct sockaddr *ds_addr,
+		int ds_addrlen, int ds_proto)
+{
+	struct nfs_client_initdata cl_init = {
+		.addr = ds_addr,
+		.addrlen = ds_addrlen,
+		.rpc_ops = &nfs_v4_clientops,
+		.proto = ds_proto,
+		.minorversion = mds_clp->cl_minorversion,
+	};
+	struct rpc_timeout ds_timeout = {
+		.to_initval = 15 * HZ,
+		.to_maxval = 15 * HZ,
+		.to_retries = 1,
+		.to_exponential = 1,
+	};
+	struct nfs_client *clp;
+
+	/*
+	 * Set an authflavor equual to the MDS value. Use the MDS nfs_client
+	 * cl_ipaddr so as to use the same EXCHANGE_ID co_ownerid as the MDS
+	 * (section 13.1 RFC 5661).
+	 */
+	clp = nfs_get_client(&cl_init, &ds_timeout, mds_clp->cl_ipaddr,
+			     mds_clp->cl_rpcclient->cl_auth->au_flavor, 0);
+
+	dprintk("<-- %s %p\n", __func__, clp);
+	return clp;
+}
+EXPORT_SYMBOL(nfs4_set_ds_client);
 
 /*
  * Session has been established, and the client marked ready.
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 4d7b3a9..5cc9201 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -148,6 +148,9 @@ extern struct nfs_server *nfs_clone_server(struct nfs_server *,
 					   struct nfs_fattr *);
 extern void nfs_mark_client_ready(struct nfs_client *clp, int state);
 extern int nfs4_check_client_ready(struct nfs_client *clp);
+extern struct nfs_client *nfs4_set_ds_client(struct nfs_client* mds_clp,
+					     const struct sockaddr *ds_addr,
+					     int ds_addrlen, int ds_proto);
 #ifdef CONFIG_PROC_FS
 extern int __init nfs_fs_proc_init(void);
 extern void nfs_fs_proc_exit(void);
@@ -213,6 +216,8 @@ extern const u32 nfs41_maxwrite_overhead;
 extern struct rpc_procinfo nfs4_procedures[];
 #endif
 
+extern int nfs4_init_ds_session(struct nfs_client *clp);
+
 /* proc.c */
 void nfs_close_context(struct nfs_open_context *ctx, int is_sync);
 extern int nfs_init_client(struct nfs_client *clp,
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
index f5c9b12..8e21e65 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -104,6 +104,67 @@ _data_server_lookup_locked(u32 ip_addr, u32 port)
 	return NULL;
 }
 
+/*
+ * Create an rpc connection to the nfs4_pnfs_ds data server
+ * Currently only support IPv4
+ */
+static int
+nfs4_ds_connect(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
+{
+	struct nfs_client *clp;
+	struct sockaddr_in sin;
+	int status = 0;
+
+	dprintk("--> %s ip:port %x:%hu au_flavor %d\n", __func__,
+		ntohl(ds->ds_ip_addr), ntohs(ds->ds_port),
+		mds_srv->nfs_client->cl_rpcclient->cl_auth->au_flavor);
+
+	sin.sin_family = AF_INET;
+	sin.sin_addr.s_addr = ds->ds_ip_addr;
+	sin.sin_port = ds->ds_port;
+
+	clp = nfs4_set_ds_client(mds_srv->nfs_client, (struct sockaddr *)&sin,
+				 sizeof(sin), IPPROTO_TCP);
+	if (IS_ERR(clp)) {
+		status = PTR_ERR(clp);
+		goto out;
+	}
+
+	if ((clp->cl_exchange_flags & EXCHGID4_FLAG_MASK_PNFS) != 0) {
+		if (!is_ds_client(clp)) {
+			status = -ENODEV;
+			goto out_put;
+		}
+		ds->ds_clp = clp;
+		dprintk("%s [existing] ip=%x, port=%hu\n", __func__,
+			ntohl(ds->ds_ip_addr), ntohs(ds->ds_port));
+		goto out;
+	}
+
+	/*
+	 * Do not set NFS_CS_CHECK_LEASE_TIME instead set the DS lease to
+	 * be equal to the MDS lease. Renewal is scheduled in create_session.
+	 */
+	spin_lock(&mds_srv->nfs_client->cl_lock);
+	clp->cl_lease_time = mds_srv->nfs_client->cl_lease_time;
+	spin_unlock(&mds_srv->nfs_client->cl_lock);
+	clp->cl_last_renewal = jiffies;
+
+	/* New nfs_client */
+	status = nfs4_init_ds_session(clp);
+	if (status)
+		goto out_put;
+
+	ds->ds_clp = clp;
+	dprintk("%s [new] ip=%x, port=%hu\n", __func__, ntohl(ds->ds_ip_addr),
+		ntohs(ds->ds_port));
+out:
+	return status;
+out_put:
+	nfs_put_client(clp);
+	goto out;
+}
+
 static void
 destroy_ds(struct nfs4_pnfs_ds *ds)
 {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7faec0f..df7d617 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1574,9 +1574,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 	return 0;
 }
 
-static int nfs4_recover_expired_lease(struct nfs_server *server)
+static int nfs4_client_recover_expired_lease(struct nfs_client *clp)
 {
-	struct nfs_client *clp = server->nfs_client;
 	unsigned int loop;
 	int ret;
 
@@ -1593,6 +1592,11 @@ static int nfs4_recover_expired_lease(struct nfs_server *server)
 	return ret;
 }
 
+static int nfs4_recover_expired_lease(struct nfs_server *server)
+{
+	return nfs4_client_recover_expired_lease(server->nfs_client);
+}
+
 /*
  * OPEN_EXPIRED:
  * 	reclaim state on the server after a network partition.
@@ -5073,6 +5077,27 @@ int nfs4_init_session(struct nfs_server *server)
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
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9d2b9da..c66ff7f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1018,6 +1018,7 @@ struct nfs_read_data {
 	struct nfs_readres  res;
 	unsigned long		timestamp;	/* For lease renewal */
 	struct pnfs_layout_segment *lseg;
+	struct nfs_client	*ds_clp;	/* pNFS data server */
 	const struct rpc_call_ops *mds_ops;
 	struct page		*page_array[NFS_PAGEVEC_SIZE];
 };
-- 
1.6.6


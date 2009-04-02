From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 09/67] nfs41: sessions client infrastructure
Date: Thu,  2 Apr 2009 16:51:35 +0300
Message-ID: <1238680295-13681-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:1546 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756115AbZDBNvw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:52 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSv4.1 Sessions basic data types, initialization, and destruction.

The session is always associated with a struct nfs_client that holds
the exchange_id results.

Signed-off-by: Rahul Iyer <iyer@netapp.com>
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[remove extraneous rpc_clnt pointer, use the struct nfs_client cl_rpcclient.
remove the rpc_clnt parameter from nfs4 nfs4_init_session]
Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Use the presence of a session to determine behaviour instead of the
minorversion number.]
Signed-off-by: Andy Adamson <andros@netapp.com>
[constified nfs4_has_session's struct nfs_client parameter]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Rename nfs4_put_session() to nfs4_destroy_session() and call it from nfs4_free_client() not nfs4_free_server().
Also get rid of nfs4_get_session() and the ref_count in nfs4_session struct as keeping track of nfs_client should be sufficient]
Signed-off-by: Alexandros Batsakis <Alexandros.Batsakis@netapp.com>
[nfs41: pass rsize and wsize into nfs4_init_session]
Signed-off-by: Andy Adamson <andros@netapp.com>
[separated out removal of rpc_clnt parameter from nfs4_init_session ot a
 patch of its own]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Pass the nfs_client pointer into nfs4_alloc_session]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: don't assign to session->clp->cl_session in nfs4_destroy_session]
[nfs41: fixup nfs4_clear_client_minor_version]
[introduce nfs4_clear_client_minor_version() in this patch]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Refactor nfs4_init_session]
    Moved session allocation into nfs4_init_client_minor_version, called from
    nfs4_init_client.
    Leave rwise and wsize initialization in nfs4_init_session, called from
    nfs4_init_server.
    Reverted moving of nfs_fsid definition to nfs_fs_sb.h
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Move NFS4_MAX_SLOT_TABLE define from under CONFIG_NFS_V4_1]
[Fix comile error when CONFIG_NFS_V4_1 is not set.]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[moved nfs4_init_slot_table definition to "create_session operation"]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: alloc session with GFP_KERNEL]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |   60 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/internal.h         |   12 +++++++++
 fs/nfs/nfs4_fs.h          |    4 +++
 fs/nfs/nfs4proc.c         |   34 +++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |   49 ++++++++++++++++++++++++++++++++++++
 include/linux/nfs_xdr.h   |   15 +++++++++++
 6 files changed, 174 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 3aabf1b..efbaba3 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -184,12 +184,27 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 }
 
 /*
+ * Clears/puts all minor version specific parts from an nfs_client struct
+ * reverting it to minorversion 0.
+ */
+static void nfs4_clear_client_minor_version(struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (nfs4_has_session(clp)) {
+		nfs4_destroy_session(clp->cl_session);
+		clp->cl_session = NULL;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+/*
  * Destroy a shared client record
  */
 static void nfs_free_client(struct nfs_client *clp)
 {
 	dprintk("--> nfs_free_client(%u)\n", clp->rpc_ops->version);
 
+	nfs4_clear_client_minor_version(clp);
 	nfs4_shutdown_client(clp);
 
 	nfs_fscache_release_client_cookie(clp);
@@ -1054,6 +1069,30 @@ error:
 
 #ifdef CONFIG_NFS_V4
 /*
+ * Initialize the minor version specific parts of an NFS4 client record
+ */
+static int nfs4_init_client_minor_version(struct nfs_client *clp)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (clp->cl_minorversion) {
+		struct nfs4_session *session = NULL;
+		/*
+		 * Create the session and mark it expired.
+		 * When a SEQUENCE operation encounters the expired session
+		 * it will do session recovery to initialize it.
+		 */
+		session = nfs4_alloc_session(clp);
+		if (!session)
+			return -ENOMEM;
+
+		clp->cl_session = session;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+
+	return 0;
+}
+
+/*
  * Initialise an NFS4 client record
  */
 static int nfs4_init_client(struct nfs_client *clp,
@@ -1087,6 +1126,10 @@ static int nfs4_init_client(struct nfs_client *clp,
 	}
 	__set_bit(NFS_CS_IDMAP, &clp->cl_res_state);
 
+	error = nfs4_init_client_minor_version(clp);
+	if (error < 0)
+		goto error;
+
 	nfs_mark_client_ready(clp, NFS_CS_READY);
 	return 0;
 
@@ -1144,6 +1187,21 @@ error:
 }
 
 /*
+ * Initialize a session.
+ * Note: save the mount rsize and wsize for create_server negotiation.
+ */
+static void nfs4_init_session(struct nfs_client *clp,
+			      unsigned int wsize, unsigned int rsize)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (nfs4_has_session(clp)) {
+		clp->cl_session->fc_attrs.max_rqst_sz = wsize;
+		clp->cl_session->fc_attrs.max_resp_sz = rsize;
+	}
+#endif /* CONFIG_NFS_V4_1 */
+}
+
+/*
  * Create a version 4 volume record
  */
 static int nfs4_init_server(struct nfs_server *server,
@@ -1221,6 +1279,8 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 	BUG_ON(!server->nfs_client->rpc_ops);
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
+	nfs4_init_session(server->nfs_client, server->wsize, server->rsize);
+
 	/* Probe the root fh to retrieve its FSID */
 	error = nfs4_path_walk(server, mntfh, data->nfs_server.export_path);
 	if (error < 0)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ffa6bd5..7cef45d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -207,6 +207,18 @@ extern int nfs4_path_walk(struct nfs_server *server,
 #endif
 
 /*
+ * Determine if sessions are in use.
+ */
+static inline int nfs4_has_session(const struct nfs_client *clp)
+{
+#ifdef CONFIG_NFS_V4_1
+	if (clp->cl_session)
+		return 1;
+#endif /* CONFIG_NFS_V4_1 */
+	return 0;
+}
+
+/*
  * Determine the device name as a string
  */
 static inline char *nfs_devname(const struct vfsmount *mnt_parent,
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4e4d332..5d7b036 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -202,6 +202,10 @@ extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 
 extern struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops;
 extern struct nfs4_state_recovery_ops nfs4_nograce_recovery_ops;
+#if defined(CONFIG_NFS_V4_1)
+extern void nfs4_destroy_session(struct nfs4_session *session);
+extern struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp);
+#endif /* CONFIG_NFS_V4_1 */
 
 extern const u32 nfs4_fattr_bitmap[2];
 extern const u32 nfs4_statfs_bitmap[2];
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 97baccc..884bbe0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3726,6 +3726,40 @@ int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 	return status;
 }
 
+#ifdef CONFIG_NFS_V4_1
+/* Destroy the slot table */
+static void nfs4_destroy_slot_table(struct nfs4_session *session)
+{
+	if (session->fc_slot_table.slots == NULL)
+		return;
+	kfree(session->fc_slot_table.slots);
+	session->fc_slot_table.slots = NULL;
+	return;
+}
+
+struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
+{
+	struct nfs4_session *session;
+	struct nfs4_slot_table *tbl;
+
+	session = kzalloc(sizeof(struct nfs4_session), GFP_KERNEL);
+	if (!session)
+		return NULL;
+	tbl = &session->fc_slot_table;
+	spin_lock_init(&tbl->slot_tbl_lock);
+	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "Slot table");
+	session->clp = clp;
+	return session;
+}
+
+void nfs4_destroy_session(struct nfs4_session *session)
+{
+	nfs4_destroy_slot_table(session);
+	kfree(session);
+}
+
+#endif /* CONFIG_NFS_V4_1 */
+
 struct nfs4_state_recovery_ops nfs4_reboot_recovery_ops = {
 	.owner_flag_bit = NFS_OWNER_RECLAIM_REBOOT,
 	.state_flag_bit	= NFS_STATE_RECLAIM_REBOOT,
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 477de6c..283ef0a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -4,9 +4,12 @@
 #include <linux/list.h>
 #include <linux/backing-dev.h>
 #include <linux/wait.h>
+#include <linux/nfs_xdr.h>
+#include <linux/sunrpc/xprt.h>
 
 #include <asm/atomic.h>
 
+struct nfs4_session;
 struct nfs_iostats;
 struct nlm_host;
 
@@ -66,6 +69,10 @@ struct nfs_client {
 	u32			cl_minorversion;
 #endif /* CONFIG_NFS_V4 */
 
+#ifdef CONFIG_NFS_V4_1
+	struct nfs4_session	*cl_session; 	/* sharred session */
+#endif /* CONFIG_NFS_V4_1 */
+
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;	/* client index cache cookie */
 #endif
@@ -146,4 +153,46 @@ struct nfs_server {
 #define NFS_CAP_ACLS		(1U << 3)
 #define NFS_CAP_ATOMIC_OPEN	(1U << 4)
 
+
+/* maximum number of slots to use */
+#define NFS4_MAX_SLOT_TABLE RPC_MAX_SLOT_TABLE
+
+#if defined(CONFIG_NFS_V4_1)
+
+/* Sessions */
+#define SLOT_TABLE_SZ (NFS4_MAX_SLOT_TABLE/(8*sizeof(long)))
+struct nfs4_slot_table {
+	struct nfs4_slot *slots;		/* seqid per slot */
+	unsigned long   used_slots[SLOT_TABLE_SZ]; /* used/unused bitmap */
+	spinlock_t	slot_tbl_lock;
+	struct rpc_wait_queue	slot_tbl_waitq;	/* allocators may wait here */
+	int		max_slots;		/* # slots in table */
+	int		highest_used_slotid;	/* sent to server on each SEQ.
+						 * op for dynamic resizing */
+};
+
+static inline int slot_idx(struct nfs4_slot_table *tbl, struct nfs4_slot *sp)
+{
+	return sp - tbl->slots;
+}
+
+/*
+ * Session related parameters
+ */
+struct nfs4_session {
+	struct nfs4_sessionid		sess_id;
+	u32				flags;
+	unsigned long			session_state;
+	u32				hash_alg;
+	u32				ssv_len;
+
+	/* The fore and back channel */
+	struct nfs4_channel_attrs	fc_attrs;
+	struct nfs4_slot_table		fc_slot_table;
+	struct nfs4_channel_attrs	bc_attrs;
+					/* back channel has one slot */
+	struct nfs_client		*clp;
+};
+
+#endif /* CONFIG_NFS_V4_1 */
 #endif
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 00a0a1d..9480a32 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -146,6 +146,21 @@ struct nfs4_change_info {
 
 struct nfs_seqid;
 
+/* nfs41 sessions channel attributes */
+struct nfs4_channel_attrs {
+	u32			headerpadsz;
+	u32			max_rqst_sz;
+	u32			max_resp_sz;
+	u32			max_resp_sz_cached;
+	u32			max_ops;
+	u32			max_reqs;
+};
+
+/* nfs41 sessions slot seqid */
+struct nfs4_slot {
+	u32		 	seq_nr;
+};
+
 struct nfs4_sequence_args {
 	/* stub */
 };
-- 
1.6.2.1


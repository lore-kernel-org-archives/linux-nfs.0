Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e36.co.us.ibm.com ([32.97.110.154]:49931 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299Ab2A3Tar (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:47 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:46 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2D48E1FF004A
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:01 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTx6j176342
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:30:00 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTwr6007347
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:59 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTvJI007268
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 08/13] NFS: Store server locations for replication
Date: Mon, 30 Jan 2012 13:29:50 -0600
Message-Id: <1327951795-16400-9-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/client.c           |    4 +++
 fs/nfs/nfs4_fs.h          |    3 ++
 fs/nfs/nfs4proc.c         |   36 +++++++++++++++++++++++++++++++
 fs/nfs/nfs4xdr.c          |   16 +++++++++----
 fs/nfs/super.c            |   51 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    2 +
 include/linux/nfs_xdr.h   |    3 ++
 7 files changed, 110 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2045baa..54de25a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1096,6 +1096,8 @@ static struct nfs_server *nfs_alloc_server(void)
  */
 void nfs_free_server(struct nfs_server *server)
 {
+	int i;
+
 	dprintk("--> nfs_free_server()\n");
 
 	nfs_server_remove_lists(server);
@@ -1113,6 +1115,8 @@ void nfs_free_server(struct nfs_server *server)
 
 	nfs_free_iostats(server->io_stats);
 	nfs_free_fhandle(server->rootfh);
+	for (i = 0; i < NFS_MAX_REPLI_SERVERS; i++)
+		kfree(server->repli_servers[i]);
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
 	nfs_release_automount_timer();
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 4d7d0ae..7ff0177 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -224,6 +224,9 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, boo
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_get_fs_locations(struct nfs_server *server,
+		struct nfs4_fs_locations *locations, struct page *page);
+
 extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 09674cc..775adb3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4814,6 +4814,42 @@ int nfs4_proc_secinfo(struct inode *dir, const struct qstr *name, struct nfs4_se
 	return err;
 }
 
+int nfs4_get_fs_locations(struct nfs_server *server,
+		struct nfs4_fs_locations *locations, struct page *page)
+{
+	u32 bitmask[2] = {
+		[0] = FATTR4_WORD0_FSID | FATTR4_WORD0_FS_LOCATIONS,
+	};
+	struct nfs4_fs_locations_arg args = {
+		.fh = server->rootfh,
+		.page = page,
+		.bitmask = bitmask,
+		.replication = 1,
+	};
+	struct nfs4_fs_locations_res res = {
+		.fs_locations = locations,
+		.replication = 1,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FS_LOCATIONS],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	int status;
+
+	dprintk("--> %s: FSID %llx:%llx on \"%s\"\n", __func__,
+		(unsigned long long)server->fsid.major,
+		(unsigned long long)server->fsid.minor,
+		server->nfs_client->cl_hostname);
+
+	nfs_fattr_init(&locations->fattr);
+	locations->server = server;
+	locations->nlocations = 0;
+	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 0);
+	dprintk("<-- %s status=%d\n", __func__, status);
+	return status;
+}
+
 #ifdef CONFIG_NFS_V4_1
 /*
  * Check the exchange flags returned by the server for invalid flags, having
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 95e92e4..b2fff0f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2723,8 +2723,12 @@ static void nfs4_xdr_enc_fs_locations(struct rpc_rqst *req,
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_sequence(xdr, &args->seq_args, &hdr);
-	encode_putfh(xdr, args->dir_fh, &hdr);
-	encode_lookup(xdr, args->name, &hdr);
+	if (args->replication) {
+		encode_putfh(xdr, args->fh, &hdr);
+	} else {
+		encode_putfh(xdr, args->dir_fh, &hdr);
+		encode_lookup(xdr, args->name, &hdr);
+	}
 	replen = hdr.replen;	/* get the attribute into args->page */
 	encode_fs_locations(xdr, args->bitmask, &hdr);
 
@@ -6576,9 +6580,11 @@ static int nfs4_xdr_dec_fs_locations(struct rpc_rqst *req,
 	status = decode_putfh(xdr);
 	if (status)
 		goto out;
-	status = decode_lookup(xdr);
-	if (status)
-		goto out;
+	if (!res->replication) {
+		status = decode_lookup(xdr);
+		if (status)
+			goto out;
+	}
 	xdr_enter_page(xdr, PAGE_SIZE);
 	status = decode_getfattr(xdr, &res->fs_locations->fattr,
 				 res->fs_locations->server);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f2e7d7c..3b20fc4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -322,6 +322,7 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 static struct dentry *nfs4_remote_referral_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data);
 static void nfs4_kill_super(struct super_block *sb);
+static void nfs4_store_repli_locations(struct dentry *dentry);
 
 static struct file_system_type nfs4_fs_type = {
 	.owner		= THIS_MODULE,
@@ -2829,6 +2830,11 @@ static struct dentry *nfs4_try_mount(int flags, const char *dev_name,
 	dfprintk(MOUNT, "<-- nfs4_try_mount() = %ld%s\n",
 			IS_ERR(res) ? PTR_ERR(res) : 0,
 			IS_ERR(res) ? " [error]" : "");
+
+	/* Add replication locations */
+	if (!IS_ERR(root_mnt))
+		nfs4_store_repli_locations(res);
+
 	return res;
 }
 
@@ -3087,4 +3093,49 @@ static struct dentry *nfs4_referral_mount(struct file_system_type *fs_type,
 	return res;
 }
 
+static void nfs4_store_repli_locations(struct dentry *dentry)
+{
+	struct nfs4_fs_locations *locations;
+	struct nfs_server *server;
+	struct page *page;
+	unsigned int i, s, loc, n;
+	int err;
+
+	page = alloc_page(GFP_KERNEL);
+	locations = kmalloc(sizeof(struct nfs4_fs_locations), GFP_KERNEL);
+	if (!page || !locations)
+		goto free;
+
+	server = NFS_SERVER(dentry->d_inode);
+
+	/* Free old locations */
+	for (i = 0; i < NFS_MAX_REPLI_SERVERS; i++) {
+		kfree(server->repli_servers[i]);
+		server->repli_servers[i] = NULL;
+	}
+
+	err = nfs4_get_fs_locations(server, locations, page);
+	if (err)
+		goto free;
+
+	for (n = 0, loc = 0; loc < locations->nlocations &&
+	     n < NFS_MAX_REPLI_SERVERS; loc++) {
+		const struct nfs4_fs_location *location =
+			&locations->locations[loc];
+		for (s = 0; s < location->nservers &&
+		     n < NFS_MAX_REPLI_SERVERS; s++) {
+			const struct nfs4_string *buf = &location->servers[s];
+			if (buf->len <= 0 || buf->len > PAGE_SIZE)
+				continue;
+			server->repli_servers[n++] = kstrndup(buf->data,
+							      buf->len,
+							      GFP_KERNEL);
+		}
+	}
+
+free:
+	if (page)
+		__free_page(page);
+	kfree(locations);
+}
 #endif /* CONFIG_NFS_V4 */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6532d7b..4970c58 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -158,6 +158,8 @@ struct nfs_server {
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
 	struct nfs_fh		*rootfh;
+#define NFS_MAX_REPLI_SERVERS 2
+	char *repli_servers[NFS_MAX_REPLI_SERVERS];
 
 	atomic_t active; /* Keep trace of any activity to this server */
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a764cef..ca6debd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1004,15 +1004,18 @@ struct nfs4_fs_locations {
 
 struct nfs4_fs_locations_arg {
 	const struct nfs_fh *dir_fh;
+	const struct nfs_fh *fh;
 	const struct qstr *name;
 	struct page *page;
 	const u32 *bitmask;
 	struct nfs4_sequence_args	seq_args;
+	unsigned char replication:1;
 };
 
 struct nfs4_fs_locations_res {
 	struct nfs4_fs_locations       *fs_locations;
 	struct nfs4_sequence_res	seq_res;
+	unsigned char			replication:1;
 };
 
 struct nfs4_secinfo_oid {
-- 
1.7.8.3


Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E271C43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 41E52206BA
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 14:04:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728562AbfDYOEZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 10:04:25 -0400
Received: from fieldses.org ([173.255.197.46]:50910 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727212AbfDYOEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 10:04:25 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id E730820AE; Thu, 25 Apr 2019 10:04:22 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org, abe@purdue.edu,
        lsof-l@lists.purdue.edu, util-linux@vger.kernel.org,
        jlayton@redhat.com, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 07/10] nfsd4: add a client info file
Date:   Thu, 25 Apr 2019 10:04:17 -0400
Message-Id: <1556201060-7947-8-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556201060-7947-1-git-send-email-bfields@redhat.com>
References: <1556201060-7947-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

Add a new nfsd/clients/#/info file with some basic information about
each NFSv4 client.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  38 ++++++++++++++-
 fs/nfsd/nfsctl.c    | 115 +++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsd.h      |   4 +-
 3 files changed, 148 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index de99bfe3e6e2..928705fc8ff5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2193,6 +2193,41 @@ find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 	return s;
 }
 
+static int client_info_show(struct seq_file *m, void *v)
+{
+	struct inode *inode = m->private;
+	struct nfsdfs_client *nc;
+	struct nfs4_client *clp;
+	u64 clid;
+
+	nc = get_nfsdfs_client(inode);
+	if (!nc)
+		return -ENXIO;
+	clp = container_of(nc, struct nfs4_client, cl_nfsdfs);
+	memcpy(&clid, &clp->cl_clientid, sizeof(clid));
+	seq_printf(m, "clientid: %llx\n", clid);
+	drop_client(clp);
+
+	return 0;
+}
+
+static int client_info_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, client_info_show, inode);
+}
+
+static const struct file_operations client_info_fops = {
+	.open		= client_info_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static const struct tree_descr client_files[] = {
+	[0] = {"info", &client_info_fops, S_IRUSR},
+	[1] = {""},
+};
+
 static struct nfs4_client *create_client(struct xdr_netobj name,
 		struct svc_rqst *rqstp, nfs4_verifier *verf)
 {
@@ -2221,7 +2256,8 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	clp->cl_cb_session = NULL;
 	clp->net = net;
 	clp->cl_nfsd_dentry = nfsd_client_mkdir(nn, &clp->cl_nfsdfs,
-			clp->cl_clientid.cl_id - nn->clientid_base);
+			clp->cl_clientid.cl_id - nn->clientid_base,
+			client_files);
 	if (!clp->cl_nfsd_dentry) {
 		free_client(clp);
 		return NULL;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index edf4dada42bf..205a56718f3a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1207,14 +1207,116 @@ static struct dentry *nfsd_mkdir(struct dentry *parent, struct nfsdfs_client *nc
 	goto out;
 }
 
+static void clear_ncl(struct inode *inode)
+{
+	struct nfsdfs_client *ncl = inode->i_private;
+
+	inode->i_private = NULL;
+	synchronize_rcu();
+	kref_put(&ncl->cl_ref, ncl->cl_release);
+}
+
+
+struct nfsdfs_client *__get_nfsdfs_client(struct inode *inode)
+{
+	struct nfsdfs_client *nc = inode->i_private;
+
+	if (nc)
+		kref_get(&nc->cl_ref);
+	return nc;
+}
+
+struct nfsdfs_client *get_nfsdfs_client(struct inode *inode)
+{
+	struct nfsdfs_client *nc;
+
+	rcu_read_lock();
+	nc = __get_nfsdfs_client(inode);
+	rcu_read_unlock();
+	return nc;
+}
+/* from __rpc_unlink */
+static void nfsdfs_remove_file(struct inode *dir, struct dentry *dentry)
+{
+	int ret;
+
+	clear_ncl(d_inode(dentry));
+	dget(dentry);
+	ret = simple_unlink(dir, dentry);
+	d_delete(dentry);
+	dput(dentry);
+	WARN_ON_ONCE(ret);
+}
+
+static void nfsdfs_remove_files(struct dentry *root)
+{
+	struct dentry *dentry, *tmp;
+
+	list_for_each_entry_safe(dentry, tmp, &root->d_subdirs, d_child) {
+		if (!simple_positive(dentry)) {
+			WARN_ON_ONCE(1); /* I think this can't happen? */
+			continue;
+		}
+		nfsdfs_remove_file(d_inode(root), dentry);
+	}
+}
+
+/* XXX: cut'n'paste from simple_fill_super; figure out if we could share
+ * code instead. */
+static  int nfsdfs_create_files(struct dentry *root,
+					const struct tree_descr *files)
+{
+	struct inode *dir = d_inode(root);
+	struct inode *inode;
+	struct dentry *dentry;
+	int i;
+
+	inode_lock(dir);
+	for (i = 0; files->name && files->name[0]; i++, files++) {
+		if (!files->name)
+			continue;
+		dentry = d_alloc_name(root, files->name);
+		if (!dentry)
+			goto out;
+		inode = nfsd_get_inode(d_inode(root)->i_sb,
+					S_IFREG | files->mode);
+		if (!inode) {
+			dput(dentry);
+			goto out;
+		}
+		inode->i_fop = files->ops;
+		inode->i_private = __get_nfsdfs_client(dir);
+		d_add(dentry, inode);
+		fsnotify_create(dir, dentry);
+	}
+	inode_unlock(dir);
+	return 0;
+out:
+	nfsdfs_remove_files(root);
+	inode_unlock(dir);
+	return -ENOMEM;
+}
+
 /* on success, returns positive number unique to that client. */
-struct dentry *nfsd_client_mkdir(struct nfsd_net *nn, struct nfsdfs_client *ncl, u32 id)
+struct dentry *nfsd_client_mkdir(struct nfsd_net *nn,
+		struct nfsdfs_client *ncl, u32 id,
+		const struct tree_descr *files)
 {
+	struct dentry *dentry;
 	char name[11];
+	int ret;
 
 	sprintf(name, "%u", id);
 
-	return nfsd_mkdir(nn->nfsd_client_dir, ncl, name);
+	dentry = nfsd_mkdir(nn->nfsd_client_dir, ncl, name);
+	if (IS_ERR(dentry)) /* XXX: tossing errors? */
+		return NULL;
+	ret = nfsdfs_create_files(dentry, files);
+	if (ret) {
+		nfsd_client_rmdir(dentry);
+		return NULL;
+	}
+	return dentry;
 }
 
 /* Taken from __rpc_rmdir: */
@@ -1222,16 +1324,16 @@ void nfsd_client_rmdir(struct dentry *dentry)
 {
 	struct inode *dir = d_inode(dentry->d_parent);
 	struct inode *inode = d_inode(dentry);
-	struct nfsdfs_client *ncl = inode->i_private;
 	int ret;
 
-	inode->i_private = NULL;
-	synchronize_rcu();
-	kref_put(&ncl->cl_ref, ncl->cl_release);
+	inode_lock(dir);
+	nfsdfs_remove_files(dentry);
+	clear_ncl(inode);
 	dget(dentry);
 	ret = simple_rmdir(dir, dentry);
 	WARN_ON_ONCE(ret);
 	d_delete(dentry);
+	inode_unlock(dir);
 }
 
 static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
@@ -1275,7 +1377,6 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		return ret;
 	dentry = nfsd_mkdir(sb->s_root, NULL, "clients");
 	if (IS_ERR(dentry)) {
-		/* XXX: test: */
 		d_genocide(sb->s_root);
 		shrink_dcache_parent(sb->s_root);
 		dput(sb->s_root);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index fe7418c2b88f..a60a2ee2e8c1 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -91,7 +91,9 @@ struct nfsdfs_client {
 	void (*cl_release)(struct kref *kref);
 };
 
-struct dentry *nfsd_client_mkdir(struct nfsd_net *nn, struct nfsdfs_client *ncl, u32 id);
+struct nfsdfs_client *get_nfsdfs_client(struct inode *);
+struct dentry *nfsd_client_mkdir(struct nfsd_net *nn,
+		struct nfsdfs_client *ncl, u32 id, const struct tree_descr *);
 void nfsd_client_rmdir(struct dentry *dentry);
 
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
-- 
2.20.1


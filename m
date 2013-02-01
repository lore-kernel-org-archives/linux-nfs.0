Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:28391 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753885Ab3BAMzS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Feb 2013 07:55:18 -0500
Subject: [PATCH 1/4] nfsd: containerize NFSd filesystem
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 01 Feb 2013 15:56:12 +0300
Message-ID: <20130201125611.3257.11180.stgit@localhost.localdomain>
In-Reply-To: <20130201125210.3257.46454.stgit@localhost.localdomain>
References: <20130201125210.3257.46454.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch makes NFSD file system superblock to be created per net.
This makes possible to get proper network namespace from superblock instead of
using hard-coded "init_net".

Note: NFSd fs super-block holds network namespace. This garantees, that
network namespace won't disappear from underneath of it.
This, obviously, means, that in case of kill of a container's "init" (which is not a mount
namespace, but network namespace creator) netowrk namespace won't be
destroyed.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfsctl.c |   46 +++++++++++++++++++++++++++++++++-------------
 fs/nfsd/nfssvc.c |    5 ++---
 2 files changed, 35 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 65889ec..2eb03c1 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -220,6 +220,7 @@ static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 	struct sockaddr *sap = (struct sockaddr *)&address;
 	size_t salen = sizeof(address);
 	char *fo_path;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 
 	/* sanity check */
 	if (size == 0)
@@ -232,7 +233,7 @@ static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 	if (qword_get(&buf, fo_path, size) < 0)
 		return -EINVAL;
 
-	if (rpc_pton(&init_net, fo_path, size, sap, salen) == 0)
+	if (rpc_pton(net, fo_path, size, sap, salen) == 0)
 		return -EINVAL;
 
 	return nlmsvc_unlock_all_by_ip(sap);
@@ -317,6 +318,7 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 	int len;
 	struct auth_domain *dom;
 	struct knfsd_fh fh;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 
 	if (size == 0)
 		return -EINVAL;
@@ -352,7 +354,7 @@ static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 	if (!dom)
 		return -ENOMEM;
 
-	len = exp_rootfh(&init_net, dom, path, &fh,  maxsize);
+	len = exp_rootfh(net, dom, path, &fh,  maxsize);
 	auth_domain_put(dom);
 	if (len)
 		return len;
@@ -396,7 +398,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
 	int rv;
-	struct net *net = &init_net;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 
 	if (size > 0) {
 		int newthreads;
@@ -447,7 +449,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	int len;
 	int npools;
 	int *nthreads;
-	struct net *net = &init_net;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 
 	mutex_lock(&nfsd_mutex);
 	npools = nfsd_nrpools(net);
@@ -510,7 +512,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	unsigned minor;
 	ssize_t tlen = 0;
 	char *sep;
-	struct net *net = &init_net;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (size>0) {
@@ -792,7 +794,7 @@ static ssize_t __write_ports(struct file *file, char *buf, size_t size,
 static ssize_t write_ports(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
-	struct net *net = &init_net;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 
 	mutex_lock(&nfsd_mutex);
 	rv = __write_ports(file, buf, size, net);
@@ -827,7 +829,7 @@ int nfsd_max_blksize;
 static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
-	struct net *net = &init_net;
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	if (size > 0) {
@@ -923,7 +925,8 @@ static ssize_t nfsd4_write_time(struct file *file, char *buf, size_t size,
  */
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
 {
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	return nfsd4_write_time(file, buf, size, &nn->nfsd4_lease, nn);
 }
 
@@ -939,7 +942,8 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
  */
 static ssize_t write_gracetime(struct file *file, char *buf, size_t size)
 {
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	return nfsd4_write_time(file, buf, size, &nn->nfsd4_grace, nn);
 }
 
@@ -995,7 +999,8 @@ static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size,
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 {
 	ssize_t rv;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct net *net = file->f_dentry->d_sb->s_fs_info;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	mutex_lock(&nfsd_mutex);
 	rv = __write_recoverydir(file, buf, size, nn);
@@ -1037,20 +1042,35 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 #endif
 		/* last one */ {""}
 	};
-	return simple_fill_super(sb, 0x6e667364, nfsd_files);
+	struct net *net = data;
+	int ret;
+
+	ret = simple_fill_super(sb, 0x6e667364, nfsd_files);
+	if (ret)
+		return ret;
+	sb->s_fs_info = get_net(net);
+	return 0;
 }
 
 static struct dentry *nfsd_mount(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *data)
 {
-	return mount_single(fs_type, flags, data, nfsd_fill_super);
+	return mount_ns(fs_type, flags, current->nsproxy->net_ns, nfsd_fill_super);
+}
+
+static void nfsd_umount(struct super_block *sb)
+{
+	struct net *net = sb->s_fs_info;
+
+	kill_litter_super(sb);
+	put_net(net);
 }
 
 static struct file_system_type nfsd_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "nfsd",
 	.mount		= nfsd_mount,
-	.kill_sb	= kill_litter_super,
+	.kill_sb	= nfsd_umount,
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index cee62ab..9b539c3 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -703,8 +703,7 @@ nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp)
 int nfsd_pool_stats_open(struct inode *inode, struct file *file)
 {
 	int ret;
-	struct net *net = &init_net;
-	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(inode->i_sb->s_fs_info, nfsd_net_id);
 
 	mutex_lock(&nfsd_mutex);
 	if (nn->nfsd_serv == NULL) {
@@ -721,7 +720,7 @@ int nfsd_pool_stats_open(struct inode *inode, struct file *file)
 int nfsd_pool_stats_release(struct inode *inode, struct file *file)
 {
 	int ret = seq_release(inode, file);
-	struct net *net = &init_net;
+	struct net *net = inode->i_sb->s_fs_info;
 
 	mutex_lock(&nfsd_mutex);
 	/* this function really, really should have been called svc_put() */


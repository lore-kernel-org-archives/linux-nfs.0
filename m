Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:40236 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423825Ab2LFPeY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Dec 2012 10:34:24 -0500
Subject: [PATCH 4/6] nfsd: use proper net while reading "exports" file
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Thu, 06 Dec 2012 18:34:57 +0300
Message-ID: <20121206153457.30693.90262.stgit@localhost.localdomain>
In-Reply-To: <20121206153204.30693.11408.stgit@localhost.localdomain>
References: <20121206153204.30693.11408.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Functuon "exports_open" is used for both "/proc/fs/nfs/exports" and
"/proc/fs/nfsd/exports" files.
Now NFSd filesystem is containerised, so proper net can be taken from
superblock for "/proc/fs/nfsd/exports" reader.
But for "/proc/fs/nfsd/exports" only current->nsproxy->net_ns can be used.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfsctl.c |   31 +++++++++++++++++++++++++------
 1 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 873438f..c36510e 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -125,11 +125,11 @@ static const struct file_operations transaction_ops = {
 	.llseek		= default_llseek,
 };
 
-static int exports_open(struct inode *inode, struct file *file)
+static int exports_net_open(struct net *net, struct file *file)
 {
 	int err;
 	struct seq_file *seq;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	err = seq_open(file, &nfs_exports_op);
 	if (err)
@@ -140,8 +140,26 @@ static int exports_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static const struct file_operations exports_operations = {
-	.open		= exports_open,
+static int exports_proc_open(struct inode *inode, struct file *file)
+{
+	return exports_net_open(current->nsproxy->net_ns, file);
+}
+
+static const struct file_operations exports_proc_operations = {
+	.open		= exports_proc_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+	.owner		= THIS_MODULE,
+};
+
+static int exports_nfsd_open(struct inode *inode, struct file *file)
+{
+	return exports_net_open(inode->i_sb->s_fs_info, file);
+}
+
+static const struct file_operations exports_nfsd_operations = {
+	.open		= exports_nfsd_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
 	.release	= seq_release,
@@ -1018,7 +1036,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size)
 static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 {
 	static struct tree_descr nfsd_files[] = {
-		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
+		[NFSD_List] = {"exports", &exports_nfsd_operations, S_IRUGO},
 		[NFSD_Export_features] = {"export_features",
 					&export_features_operations, S_IRUGO},
 		[NFSD_FO_UnlockIP] = {"unlock_ip",
@@ -1081,7 +1099,8 @@ static int create_proc_exports_entry(void)
 	entry = proc_mkdir("fs/nfs", NULL);
 	if (!entry)
 		return -ENOMEM;
-	entry = proc_create("exports", 0, entry, &exports_operations);
+	entry = proc_create("exports", 0, entry,
+				 &exports_proc_operations);
 	if (!entry)
 		return -ENOMEM;
 	return 0;


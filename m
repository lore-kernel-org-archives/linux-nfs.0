From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] NFS: implement option checking when remounting NFS filesystems (try #2)
Date: Sat, 12 Apr 2008 10:33:17 -0400
Message-ID: <1208010798-22782-1-git-send-email-jlayton@redhat.com>
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37137 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbYDLOdU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Apr 2008 10:33:20 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When remounting an NFS or NFS4 filesystem, the new NFS options are not
respected, yet the remount will still return success. This patch adds
a remount_fs sb op for NFS that checks any new nfs mount options against
the existing ones and fails the mount if any have changed.

This is only implemented for string-based mount options since doing
this with binary options isn't really feasible.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |   70 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f4ee9d9..b49f90f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -207,6 +207,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt);
 static void nfs_kill_super(struct super_block *);
 static void nfs_put_super(struct super_block *);
+static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -234,6 +235,7 @@ static const struct super_operations nfs_sops = {
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
 	.show_stats	= nfs_show_stats,
+	.remount_fs	= nfs_remount,
 };
 
 #ifdef CONFIG_NFS_V4
@@ -278,6 +280,7 @@ static const struct super_operations nfs4_sops = {
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
 	.show_stats	= nfs_show_stats,
+	.remount_fs	= nfs_remount,
 };
 #endif
 
@@ -1327,6 +1330,73 @@ out_invalid_fh:
 	return -EINVAL;
 }
 
+static int
+nfs_compare_remount_data(struct nfs_server *nfss,
+			 struct nfs_parsed_mount_data *data)
+{
+	if (data->flags != nfss->flags ||
+	    data->rsize != nfss->rsize ||
+	    data->wsize != nfss->wsize ||
+	    data->retrans != nfss->client->cl_timeout->to_retries ||
+	    data->auth_flavors[0] != nfss->client->cl_auth->au_flavor ||
+	    data->acregmin != nfss->acregmin / HZ ||
+	    data->acregmax != nfss->acregmax / HZ ||
+	    data->acdirmin != nfss->acdirmin / HZ ||
+	    data->acdirmax != nfss->acdirmax / HZ ||
+	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ))
+		return -EINVAL;
+	else
+		return 0;
+}
+
+static int
+nfs_remount(struct super_block *sb, int *flags, char *raw_data)
+{
+	int error;
+	struct nfs_server *nfss = sb->s_fs_info;
+	struct nfs_parsed_mount_data *data;
+	struct nfs_mount_data *options = (struct nfs_mount_data *)raw_data;
+	struct nfs4_mount_data *options4 = (struct nfs4_mount_data *)raw_data;
+
+	/*
+	 * Userspace mount programs that send binary options generally send
+	 * them populated with default values. We have no way to know which
+	 * ones were explicitly specified. Fall back to legacy behavior and
+	 * just return success.
+	 */
+	if ((sb->s_type == &nfs4_fs_type && options4->version == 1) ||
+	    (sb->s_type == &nfs_fs_type && options->version >= 1 &&
+	     options->version <= 6))
+		return 0;
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (data == NULL)
+		return -ENOMEM;
+
+	/* fill out struct with values from existing mount */
+	data->flags = nfss->flags;
+	data->rsize = nfss->rsize;
+	data->wsize = nfss->wsize;
+	data->retrans = nfss->client->cl_timeout->to_retries;
+	data->auth_flavors[0] = nfss->client->cl_auth->au_flavor;
+	data->acregmin = nfss->acregmin / HZ;
+	data->acregmax = nfss->acregmax / HZ;
+	data->acdirmin = nfss->acdirmin / HZ;
+	data->acdirmax = nfss->acdirmax / HZ;
+	data->timeo = 10U * nfss->client->cl_timeout->to_initval / HZ;
+
+	/* overwrite those values with any that were specified */
+	error = nfs_parse_mount_options((char *)options, data);
+	if (error < 0)
+		goto out;
+
+	/* compare new mount options with old ones */
+	error = nfs_compare_remount_data(nfss, data);
+out:
+	kfree(data);
+	return error;
+}
+
 /*
  * Initialise the common bits of the superblock
  */
-- 
1.5.3.6


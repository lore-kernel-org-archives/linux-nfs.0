From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 24/37] NFS: implement option checking when remounting NFS
	filesystems (resend)
Date: Thu, 12 Jun 2008 15:22:01 -0400
Message-ID: <20080612192201.24528.74417.stgit@localhost.localdomain>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:40624 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755125AbYFLTeJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Jun 2008 15:34:09 -0400
In-Reply-To: <20080612192159.24528.43756.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

When remounting an NFS or NFS4 filesystem, the new NFS options are not
respected, yet the remount will still return success. This patch adds
a remount_fs sb op for NFS that checks any new nfs mount options against
the existing ones and fails the mount if any have changed.

This is only implemented for string-based mount options since doing
this with binary options isn't really feasible.

This is essentially the same as the original patch I sent out, but
adds a check to see if the addr= option has changed.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   76 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2a4a024..4461c00 100644
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
 
@@ -1398,6 +1401,79 @@ out_invalid_fh:
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
+	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ) ||
+	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
+	    memcmp(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
+		   data->nfs_server.addrlen) != 0)
+		return -EINVAL;
+
+	return 0;
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
+	data->nfs_server.addrlen = nfss->nfs_client->cl_addrlen;
+	memcpy(&data->nfs_server.address, &nfss->nfs_client->cl_addr,
+		data->nfs_server.addrlen);
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


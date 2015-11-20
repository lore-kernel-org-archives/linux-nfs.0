Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40929 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162997AbbKTO4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Nov 2015 09:56:46 -0500
Subject: [PATCH 11/12] fsinfo: NFS: Return information through the
 filesystem info syscall
From: David Howells <dhowells@redhat.com>
To: arnd@arndb.de
Cc: linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org
Date: Fri, 20 Nov 2015 14:56:39 +0000
Message-ID: <20151120145639.18930.13368.stgit@warthog.procyon.org.uk>
In-Reply-To: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Return NFS filesystem information through the filesystem info retrieval
system call.  This includes the following:

 (1) information about the capacity and resolution of the inode timestamps;

 (2) the client hostname as the domain name, setting FSINFO_DOMAIN_NAME;

 (3) the remote FSID as the volume ID, setting FSINFO_VOLUME_ID;

and unless AT_NO_ATTR_SYNC is specified:

 (4) the statfs information retrieved from the server.

Note that the NFS FSID value is *not* returned as the local FSID since the
FSID value is a local handle used by NFSD; see the volume ID field instead.

Example output:

	[root@andromeda ~]# ./test-fsinfo /warthog/
	fsinfo(/warthog/) = 0
	mask  : 12f
	dev   : 00:27
	fs    : type=6969 name=nfs4
	ioc   : 0
	nameln: 255
	flags : 1020
	times : range=8000000000000000-7fffffffffffffff
	atime : gran=1e-09s
	btime : gran=1e-09s
	ctime : gran=1e-09s
	mtime : gran=1e-09s
	blocks: n=503841 fr=48261 av=22645
	files : n=32776192 fr=18903243 av=18903243
	bsize : 1048576
	frsize: 0
	volid : 8c494c34 de5688ac 2e61e05d 5f144b8e
	domain: 'warthog'

Note that NFS4 potentially provides a separate value for f_favail that could
be provided through this interface.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/internal.h  |    1 +
 fs/nfs/nfs4super.c |    1 +
 fs/nfs/super.c     |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 60 insertions(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 56cfde26fb9c..6c7bb9c9e5c6 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -442,6 +442,7 @@ extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 void nfs_clone_super(struct super_block *, struct nfs_mount_info *);
 void nfs_umount_begin(struct super_block *);
 int  nfs_statfs(struct dentry *, struct kstatfs *);
+int  nfs_get_fsinfo(struct dentry *, struct fsinfo *, unsigned);
 int  nfs_show_options(struct seq_file *, struct dentry *);
 int  nfs_show_devname(struct seq_file *, struct dentry *);
 int  nfs_show_path(struct seq_file *, struct dentry *);
diff --git a/fs/nfs/nfs4super.c b/fs/nfs/nfs4super.c
index 6fb7cb6b3f4b..1c15c5884ac4 100644
--- a/fs/nfs/nfs4super.c
+++ b/fs/nfs/nfs4super.c
@@ -54,6 +54,7 @@ static const struct super_operations nfs4_sops = {
 	.write_inode	= nfs4_write_inode,
 	.drop_inode	= nfs_drop_inode,
 	.statfs		= nfs_statfs,
+	.get_fsinfo	= nfs_get_fsinfo,
 	.evict_inode	= nfs4_evict_inode,
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 383a027de452..bbd33b121b48 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -311,6 +311,7 @@ const struct super_operations nfs_sops = {
 	.write_inode	= nfs_write_inode,
 	.drop_inode	= nfs_drop_inode,
 	.statfs		= nfs_statfs,
+	.get_fsinfo	= nfs_get_fsinfo,
 	.evict_inode	= nfs_evict_inode,
 	.umount_begin	= nfs_umount_begin,
 	.show_options	= nfs_show_options,
@@ -494,6 +495,63 @@ int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 EXPORT_SYMBOL_GPL(nfs_statfs);
 
 /*
+ * Read filesystem information.
+ */
+int nfs_get_fsinfo(struct dentry *dentry, struct fsinfo *f, unsigned flags)
+{
+	struct nfs_server *server = NFS_SB(dentry->d_sb);
+	struct nfs_client *client = server->nfs_client;
+	int ret;
+
+	f->f_bsize	= dentry->d_sb->s_blocksize;
+	f->f_namelen	= server->namelen;
+
+	if (client->rpc_ops->version < 4) {
+		f->f_min_time = 0;
+		f->f_max_time = U32_MAX;
+	} else {
+		f->f_min_time = S64_MIN;
+		f->f_max_time = S64_MAX;
+	}
+
+	f->f_atime_gran_exponent = -6;
+	f->f_ctime_gran_exponent = -6;
+	f->f_mtime_gran_exponent = -6;
+	if (client->rpc_ops->version >= 3) {
+		f->f_atime_gran_exponent = -9;
+		f->f_ctime_gran_exponent = -9;
+		f->f_mtime_gran_exponent = -9;
+	}
+
+	if (client->cl_hostname) {
+		strncpy(f->f_domain_name, client->cl_hostname,
+			sizeof(f->f_domain_name));
+		f->f_domain_name[sizeof(f->f_domain_name) - 1] = 0;
+		f->f_mask |= FSINFO_DOMAIN_NAME;
+	}
+
+	/* Treat the remote FSID as the volume ID since we don't support
+	 * reexportation through NFSD.
+	 */
+	memcpy(f->f_volume_id, &server->fsid,
+	       min(sizeof(f->f_volume_id), sizeof(server->fsid)));
+	f->f_mask |= FSINFO_VOLUME_ID;
+	
+	if (flags & AT_NO_ATTR_SYNC)
+		return 0;
+
+	ret = vfs_get_fsinfo_from_statfs(dentry, f, flags);
+	if (ret < 0)
+		return ret;
+
+	/* Don't pass the FSID to userspace since this isn't exportable */
+	memset(&f->f_fsid, 0, sizeof(f->f_fsid));
+	f->f_mask &= ~FSINFO_FSID;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nfs_get_fsinfo);
+
+/*
  * Map the security flavour number to a name
  */
 static const char *nfs_pseudoflavour_to_name(rpc_authflavor_t flavour)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:2654 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932739Ab2AMULg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 15:11:36 -0500
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 36/44] NFS: Export functions from super.c
Date: Fri, 13 Jan 2012 15:10:45 -0500
Message-Id: <1326485453-1350-37-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
References: <1326485453-1350-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

I change these functions to be non-static and then export them for the
v4 module to use.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs.h   |   24 +++++++++++++++++
 fs/nfs/super.c |   76 +++++++++++++++++++++++++++++--------------------------
 2 files changed, 64 insertions(+), 36 deletions(-)

diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 2cdcbcf..55ea4d7 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -51,6 +51,11 @@ struct nfs_subversion {
 					   struct nfs_clone_mount *);
 };
 
+struct nfs_sb_mountdata {
+	struct nfs_server *server;
+	int mntflags;
+};
+
 struct nfs_subversion *get_nfs_version(unsigned int);
 struct nfs_subversion *get_nfs_client_version(struct nfs_client *);
 struct nfs_subversion *get_nfs_server_version(struct nfs_server *);
@@ -117,5 +122,24 @@ struct dentry *generic_nfs_fs_mount(struct file_system_type *, int,
 				    struct nfs_parsed_mount_data *);
 int nfs_validate_text_mount_data(void *, struct nfs_parsed_mount_data *,
 				 struct nfs_fh *, const char *);
+void nfs_umount_begin(struct super_block *);
+int  nfs_statfs(struct dentry *, struct kstatfs *);
+int  nfs_show_options(struct seq_file *, struct vfsmount *);
+int  nfs_show_devname(struct seq_file *, struct vfsmount *);
+int  nfs_show_path(struct seq_file *, struct vfsmount *);
+int  nfs_show_stats(struct seq_file *, struct vfsmount *);
+void nfs_put_super(struct super_block *);
+int nfs_remount(struct super_block *, int *, char *);
+void nfs_initialise_sb(struct super_block *);
+void nfs_set_port(struct sockaddr *, int *, const unsigned short);
+void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *);
+int nfs_parse_devname(const char *, char **, size_t, char **, size_t);
+int nfs_verify_server_address(struct sockaddr *);
+int nfs_parse_mount_options(char *, struct nfs_parsed_mount_data *);
+int nfs_compare_super(struct super_block *, void *);
+int nfs_bdi_register(struct nfs_server *);
+int nfs_set_super(struct super_block *, void *);
+struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int);
+void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *);
 
 #endif /* __LINUX_INTERNAL_NFS_H */
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f5c5cd9..a06347d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -262,20 +262,11 @@ static match_table_t nfs_local_lock_tokens = {
 	{ Opt_local_lock_err, NULL }
 };
 
-
-static void nfs_umount_begin(struct super_block *);
-static int  nfs_statfs(struct dentry *, struct kstatfs *);
-static int  nfs_show_options(struct seq_file *, struct vfsmount *);
-static int  nfs_show_devname(struct seq_file *, struct vfsmount *);
-static int  nfs_show_path(struct seq_file *, struct vfsmount *);
-static int  nfs_show_stats(struct seq_file *, struct vfsmount *);
 static struct dentry *nfs_fs_mount(struct file_system_type *,
 		int, const char *, void *);
 static struct dentry *nfs_xdev_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *raw_data);
-static void nfs_put_super(struct super_block *);
 static void nfs_kill_super(struct super_block *);
-static int nfs_remount(struct super_block *sb, int *flags, char *raw_data);
 
 static struct file_system_type nfs_fs_type = {
 	.owner		= THIS_MODULE,
@@ -446,7 +437,7 @@ void nfs_sb_deactive(struct super_block *sb)
 /*
  * Deliver file system statistics to userspace
  */
-static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
+int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 {
 	struct nfs_server *server = NFS_SB(dentry->d_sb);
 	unsigned char blockbits;
@@ -507,6 +498,7 @@ static int nfs_statfs(struct dentry *dentry, struct kstatfs *buf)
 	dprintk("%s: statfs error = %d\n", __func__, -error);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_statfs);
 
 /*
  * Map the security flavour number to a name
@@ -719,7 +711,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 /*
  * Describe the mount options on this VFS mountpoint
  */
-static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
+int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 {
 	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
 
@@ -731,6 +723,7 @@ static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_options);
 
 #ifdef CONFIG_NFS_V4
 #ifdef CONFIG_NFS_V4_1
@@ -759,7 +752,7 @@ static void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
 #endif
 #endif
 
-static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
+int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
 {
 	char *page = (char *) __get_free_page(GFP_KERNEL);
 	char *devname, *dummy;
@@ -774,17 +767,19 @@ static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
 	free_page((unsigned long)page);
 	return err;
 }
+EXPORT_SYMBOL_GPL(nfs_show_devname);
 
-static int nfs_show_path(struct seq_file *m, struct vfsmount *mnt)
+int nfs_show_path(struct seq_file *m, struct vfsmount *mnt)
 {
 	seq_puts(m, "/");
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_path);
 
 /*
  * Present statistical information for this VFS mountpoint
  */
-static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
+int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 {
 	int i, cpu;
 	struct nfs_server *nfss = NFS_SB(mnt->mnt_sb);
@@ -870,12 +865,13 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_show_stats);
 
 /*
  * Begin unmount by attempting to remove all automounted mountpoints we added
  * in response to xdev traversals and referrals
  */
-static void nfs_umount_begin(struct super_block *sb)
+void nfs_umount_begin(struct super_block *sb)
 {
 	struct nfs_server *server;
 	struct rpc_clnt *rpc;
@@ -889,8 +885,9 @@ static void nfs_umount_begin(struct super_block *sb)
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
 }
+EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
-static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
+struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
 {
 	struct nfs_parsed_mount_data *data;
 
@@ -911,8 +908,9 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int ve
 	}
 	return data;
 }
+EXPORT_SYMBOL_GPL(nfs_alloc_parsed_mount_data);
 
-static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
+void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 {
 	if (data) {
 		kfree(data->client_address);
@@ -924,6 +922,7 @@ static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
 		kfree(data);
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_free_parsed_mount_data);
 
 /*
  * Sanity-check a server address provided by the mount command.
@@ -931,7 +930,7 @@ static void nfs_free_parsed_mount_data(struct nfs_parsed_mount_data *data)
  * Address family must be initialized, and address must not be
  * the ANY address for that family.
  */
-static int nfs_verify_server_address(struct sockaddr *addr)
+int nfs_verify_server_address(struct sockaddr *addr)
 {
 	switch (addr->sa_family) {
 	case AF_INET: {
@@ -947,12 +946,13 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 	dfprintk(MOUNT, "NFS: Invalid IP address specified\n");
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_verify_server_address);
 
 /*
  * Select between a default port value and a user-specified port value.
  * If a zero value is set, then autobind will be used.
  */
-static void nfs_set_port(struct sockaddr *sap, int *port,
+void nfs_set_port(struct sockaddr *sap, int *port,
 				 const unsigned short default_port)
 {
 	if (*port == NFS_UNSPEC_PORT)
@@ -960,12 +960,13 @@ static void nfs_set_port(struct sockaddr *sap, int *port,
 
 	rpc_set_port(sap, *port);
 }
+EXPORT_SYMBOL_GPL(nfs_set_port);
 
 /*
  * Sanity check the NFS transport protocol.
  *
  */
-static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
+void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 {
 	switch (mnt->nfs_server.protocol) {
 	case XPRT_TRANSPORT_UDP:
@@ -976,6 +977,7 @@ static void nfs_validate_transport_protocol(struct nfs_parsed_mount_data *mnt)
 		mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 	}
 }
+EXPORT_SYMBOL_GPL(nfs_validate_transport_protocol);
 
 /*
  * For text based NFSv2/v3 mounts, the mount protocol transport default
@@ -1078,8 +1080,7 @@ static int nfs_get_option_ul(substring_t args[], unsigned long *option)
  * skipped as they are encountered.  If there were no errors, return 1;
  * otherwise return 0 (zero).
  */
-static int nfs_parse_mount_options(char *raw,
-				   struct nfs_parsed_mount_data *mnt)
+int nfs_parse_mount_options(char *raw, struct nfs_parsed_mount_data *mnt)
 {
 	char *p, *string, *secdata;
 	int rc, sloppy = 0, invalid_option = 0;
@@ -1556,6 +1557,7 @@ out_security_failure:
 	printk(KERN_INFO "NFS: security options invalid: %d\n", rc);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(nfs_parse_mount_options);
 
 /*
  * Match the requested auth flavors with the list returned by
@@ -1679,9 +1681,9 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
  *
  * Note: caller frees hostname and export path, even on error.
  */
-static int nfs_parse_devname(const char *dev_name,
-			     char **hostname, size_t maxnamlen,
-			     char **export_path, size_t maxpathlen)
+int nfs_parse_devname(const char *dev_name,
+		      char **hostname, size_t maxnamlen,
+		      char **export_path, size_t maxpathlen)
 {
 	size_t len;
 	char *end;
@@ -1741,6 +1743,7 @@ out_path:
 	dfprintk(MOUNT, "NFS: export pathname too long\n");
 	return -ENAMETOOLONG;
 }
+EXPORT_SYMBOL_GPL(nfs_parse_devname);
 
 int nfs_validate_text_mount_data(void *options,
 				 struct nfs_parsed_mount_data *args,
@@ -1974,7 +1977,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	return 0;
 }
 
-static int
+int
 nfs_remount(struct super_block *sb, int *flags, char *raw_data)
 {
 	int error;
@@ -2035,11 +2038,12 @@ out:
 	kfree(data);
 	return error;
 }
+EXPORT_SYMBOL_GPL(nfs_remount);
 
 /*
  * Initialise the common bits of the superblock
  */
-static inline void nfs_initialise_sb(struct super_block *sb)
+inline void nfs_initialise_sb(struct super_block *sb)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -2057,6 +2061,7 @@ static inline void nfs_initialise_sb(struct super_block *sb)
 
 	nfs_super_set_maxbytes(sb, server->maxfilesize);
 }
+EXPORT_SYMBOL_GPL(nfs_initialise_sb);
 
 /*
  * Finish setting up an NFS2/3 superblock
@@ -2138,12 +2143,7 @@ Ebusy:
 	return 0;
 }
 
-struct nfs_sb_mountdata {
-	struct nfs_server *server;
-	int mntflags;
-};
-
-static int nfs_set_super(struct super_block *s, void *data)
+int nfs_set_super(struct super_block *s, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server;
@@ -2157,6 +2157,7 @@ static int nfs_set_super(struct super_block *s, void *data)
 		server->s_dev = s->s_dev;
 	return ret;
 }
+EXPORT_SYMBOL_GPL(nfs_set_super);
 
 static int nfs_compare_super_address(struct nfs_server *server1,
 				     struct nfs_server *server2)
@@ -2195,7 +2196,7 @@ static int nfs_compare_super_address(struct nfs_server *server1,
 	return 1;
 }
 
-static int nfs_compare_super(struct super_block *sb, void *data)
+int nfs_compare_super(struct super_block *sb, void *data)
 {
 	struct nfs_sb_mountdata *sb_mntdata = data;
 	struct nfs_server *server = sb_mntdata->server, *old = NFS_SB(sb);
@@ -2210,11 +2211,13 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 		return 0;
 	return nfs_compare_mount_options(sb, server, mntflags);
 }
+EXPORT_SYMBOL_GPL(nfs_compare_super);
 
-static int nfs_bdi_register(struct nfs_server *server)
+int nfs_bdi_register(struct nfs_server *server)
 {
 	return bdi_register_dev(&server->backing_dev_info, server->s_dev);
 }
+EXPORT_SYMBOL_GPL(nfs_bdi_register);
 
 struct dentry *generic_nfs_fs_mount(struct file_system_type *fs_type, int flags,
 				    const char *dev_name, struct nfs_fh *mntfh,
@@ -2340,7 +2343,7 @@ out:
  * Ensure that we unregister the bdi before kill_anon_super
  * releases the device name
  */
-static void nfs_put_super(struct super_block *s)
+void nfs_put_super(struct super_block *s)
 {
 	struct nfs_server *server = NFS_SB(s);
 	struct nfs_subversion *nfs_mod = get_nfs_server_version(server);
@@ -2350,6 +2353,7 @@ static void nfs_put_super(struct super_block *s)
 
 	bdi_unregister(&server->backing_dev_info);
 }
+EXPORT_SYMBOL_GPL(nfs_put_super);
 
 /*
  * Destroy an NFS2/3 superblock
-- 
1.7.8.3


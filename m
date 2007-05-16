From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS: Add the mount option nosharedcache
Date: Tue, 15 May 2007 21:36:56 -0400
Message-ID: <20070516013656.26323.55568.stgit@heimdal.trondhjem.org>
References: <17992.63372.522494.519874@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Ian Kent <raven@themaw.net>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ho8Rp-0005uV-1a
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 18:37:01 -0700
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ho8Rr-0007uM-2W
	for nfs@lists.sourceforge.net; Tue, 15 May 2007 18:37:04 -0700
In-Reply-To: <17992.63372.522494.519874@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Add a flag to allow users to elect not to share the NFS super block with
another mount point, even if the fsids are the same. This will allow
users to set different mount options for the two different super blocks,
and is safe as long as they do not have inodes in common.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c             |   34 +++++++++++++++++++++++++++++-----
 include/linux/nfs4_mount.h |    1 +
 include/linux/nfs_mount.h  |    1 +
 3 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ca20d3c..c03120a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -291,6 +291,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		{ NFS_MOUNT_NONLM, ",nolock", "" },
 		{ NFS_MOUNT_NOACL, ",noacl", "" },
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
+		{ NFS_MOUNT_UNSHARED, ",nosharecache", ""},
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -602,6 +603,9 @@ static int nfs_compare_super(struct super_block *sb, void *data)
 
 	if (old->nfs_client != server->nfs_client)
 		return 0;
+	/* Note: NFS_MOUNT_UNSHARED == NFS4_MOUNT_UNSHARED */
+	if (old->flags & NFS_MOUNT_UNSHARED)
+		return 0;
 	if (memcmp(&old->fsid, &server->fsid, sizeof(old->fsid)) != 0)
 		return 0;
 	return 1;
@@ -615,6 +619,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	struct nfs_fh mntfh;
 	struct nfs_mount_data *data = raw_data;
 	struct dentry *mntroot;
+	int (*compare_super)(struct super_block *,void *) = nfs_compare_super;
 	int error;
 
 	/* Validate the mount data */
@@ -629,8 +634,11 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 		goto out_err_noserver;
 	}
 
+	if (server->flags & NFS_MOUNT_UNSHARED)
+		compare_super = NULL;
+
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
+	s = sget(fs_type, compare_super, nfs_set_super, server);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
@@ -691,6 +699,7 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	struct super_block *s;
 	struct nfs_server *server;
 	struct dentry *mntroot;
+	int (*compare_super)(struct super_block *,void *) = nfs_compare_super;
 	int error;
 
 	dprintk("--> nfs_xdev_get_sb()\n");
@@ -702,8 +711,11 @@ static int nfs_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		goto out_err_noserver;
 	}
 
+	if (server->flags & NFS_MOUNT_UNSHARED)
+		compare_super = NULL;
+
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, nfs_compare_super, nfs_set_super, server);
+	s = sget(&nfs_fs_type, compare_super, nfs_set_super, server);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
@@ -808,6 +820,7 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	struct dentry *mntroot;
 	char *mntpath = NULL, *hostname = NULL, ip_addr[16];
 	void *p;
+	int (*compare_super)(struct super_block *,void *) = nfs_compare_super;
 	int error;
 
 	if (data == NULL) {
@@ -879,8 +892,11 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		goto out_err_noserver;
 	}
 
+	if (server->flags & NFS4_MOUNT_UNSHARED)
+		compare_super = NULL;
+
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
+	s = sget(fs_type, compare_super, nfs_set_super, server);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_free;
@@ -949,6 +965,7 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 	struct super_block *s;
 	struct nfs_server *server;
 	struct dentry *mntroot;
+	int (*compare_super)(struct super_block *,void *) = nfs_compare_super;
 	int error;
 
 	dprintk("--> nfs4_xdev_get_sb()\n");
@@ -960,8 +977,11 @@ static int nfs4_xdev_get_sb(struct file_system_type *fs_type, int flags,
 		goto out_err_noserver;
 	}
 
+	if (server->flags & NFS4_MOUNT_UNSHARED)
+		compare_super = NULL;
+
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, nfs_compare_super, nfs_set_super, server);
+	s = sget(&nfs_fs_type, compare_super, nfs_set_super, server);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
@@ -1016,6 +1036,7 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 	struct nfs_server *server;
 	struct dentry *mntroot;
 	struct nfs_fh mntfh;
+	int (*compare_super)(struct super_block *,void *) = nfs_compare_super;
 	int error;
 
 	dprintk("--> nfs4_referral_get_sb()\n");
@@ -1027,8 +1048,11 @@ static int nfs4_referral_get_sb(struct file_system_type *fs_type, int flags,
 		goto out_err_noserver;
 	}
 
+	if (server->flags & NFS4_MOUNT_UNSHARED)
+		compare_super = NULL;
+
 	/* Get a superblock - note that we may end up sharing one that already exists */
-	s = sget(&nfs_fs_type, nfs_compare_super, nfs_set_super, server);
+	s = sget(&nfs_fs_type, compare_super, nfs_set_super, server);
 	if (IS_ERR(s)) {
 		error = PTR_ERR(s);
 		goto out_err_nosb;
diff --git a/include/linux/nfs4_mount.h b/include/linux/nfs4_mount.h
index 26b4c83..ad1bd4a 100644
--- a/include/linux/nfs4_mount.h
+++ b/include/linux/nfs4_mount.h
@@ -65,6 +65,7 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_NOCTO	0x0010	/* 1 */
 #define NFS4_MOUNT_NOAC		0x0020	/* 1 */
 #define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
+#define NFS4_MOUNT_UNSHARED	0x8000	/* 1 */
 #define NFS4_MOUNT_FLAGMASK	0xFFFF
 
 #endif
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index cc8b9c5..3e3b521 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -62,6 +62,7 @@ struct nfs_mount_data {
 #define NFS_MOUNT_STRICTLOCK	0x1000	/* reserved for NFSv4 */
 #define NFS_MOUNT_SECFLAVOUR	0x2000	/* 5 */
 #define NFS_MOUNT_NORDIRPLUS	0x4000	/* 5 */
+#define NFS_MOUNT_UNSHARED	0x8000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF
 
 #endif

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

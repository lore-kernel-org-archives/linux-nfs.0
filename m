From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 4/6] NFS: Store the file system "fsid" value in the NFS
	super block.
Date: Tue, 11 Apr 2006 14:05:37 -0400
Message-ID: <20060411180537.12579.66535.stgit@lade.trondhjem.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

This should enable us to detect if we are crossing a mountpoint in the
case where the server is exporting "nohide" mounts.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/idmap.c            |    1 -
 fs/nfs/inode.c            |    8 ++++++++
 fs/nfs/nfs2xdr.c          |    3 ++-
 fs/nfs/nfs3xdr.c          |    3 ++-
 fs/nfs/nfs4xdr.c          |    4 ++--
 include/linux/nfs_fs.h    |    5 +++--
 include/linux/nfs_fs_sb.h |    1 +
 include/linux/nfs_page.h  |    1 -
 include/linux/nfs_xdr.h   |   19 ++++++++++++-------
 9 files changed, 30 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 3fab5b0..b81e7ed 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -47,7 +47,6 @@ #include <linux/sunrpc/clnt.h>
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
=20
-#include <linux/nfs_fs_sb.h>
 #include <linux/nfs_fs.h>
=20
 #include <linux/nfs_idmap.h>
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index cfcc585..bf9d404 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -253,6 +253,7 @@ nfs_get_root(struct super_block *sb, str
 		return ERR_PTR(error);
 	}
=20
+	server->fsid =3D fsinfo->fattr->fsid;
 	return nfs_fhget(sb, rootfh, fsinfo->fattr);
 }
=20
@@ -1514,6 +1515,7 @@ out:
  */
 static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr=
)
 {
+	struct nfs_server *server;
 	struct nfs_inode *nfsi =3D NFS_I(inode);
 	loff_t cur_isize, new_isize;
 	unsigned int	invalid =3D 0;
@@ -1531,6 +1533,12 @@ static int nfs_update_inode(struct inode
 	 */
 	if ((inode->i_mode & S_IFMT) !=3D (fattr->mode & S_IFMT))
 		goto out_changed;
+
+	server =3D NFS_SERVER(inode);
+	/* Update the fsid if and only if this is the root directory */
+	if (inode =3D=3D inode->i_sb->s_root->d_inode
+			&& !nfs_fsid_equal(&server->fsid, &fattr->fsid))
+		server->fsid =3D fattr->fsid;
=20
 	/*
 	 * Update the read time so we don't revalidate too often.
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index f0015fa..a7ed88f 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -131,7 +131,8 @@ xdr_decode_fattr(u32 *p, struct nfs_fatt
 	fattr->du.nfs2.blocksize =3D ntohl(*p++);
 	rdev =3D ntohl(*p++);
 	fattr->du.nfs2.blocks =3D ntohl(*p++);
-	fattr->fsid_u.nfs3 =3D ntohl(*p++);
+	fattr->fsid.major =3D ntohl(*p++);
+	fattr->fsid.minor =3D 0;
 	fattr->fileid =3D ntohl(*p++);
 	p =3D xdr_decode_time(p, &fattr->atime);
 	p =3D xdr_decode_time(p, &fattr->mtime);
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index ec23361..f70eee2 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -166,7 +166,8 @@ xdr_decode_fattr(u32 *p, struct nfs_fatt
 	if (MAJOR(fattr->rdev) !=3D major || MINOR(fattr->rdev) !=3D minor)
 		fattr->rdev =3D 0;
=20
-	p =3D xdr_decode_hyper(p, &fattr->fsid_u.nfs3);
+	p =3D xdr_decode_hyper(p, &fattr->fsid.major);
+	fattr->fsid.minor =3D 0;
 	p =3D xdr_decode_hyper(p, &fattr->fileid);
 	p =3D xdr_decode_time3(p, &fattr->atime);
 	p =3D xdr_decode_time3(p, &fattr->mtime);
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 7c5d70e..7270d12 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2217,7 +2217,7 @@ static int decode_attr_symlink_support(s
 	return 0;
 }
=20
-static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, st=
ruct nfs4_fsid *fsid)
+static int decode_attr_fsid(struct xdr_stream *xdr, uint32_t *bitmap, st=
ruct nfs_fsid *fsid)
 {
 	uint32_t *p;
=20
@@ -2863,7 +2863,7 @@ static int decode_getfattr(struct xdr_st
 		goto xdr_error;
 	if ((status =3D decode_attr_size(xdr, bitmap, &fattr->size)) !=3D 0)
 		goto xdr_error;
-	if ((status =3D decode_attr_fsid(xdr, bitmap, &fattr->fsid_u.nfs4)) !=3D=
 0)
+	if ((status =3D decode_attr_fsid(xdr, bitmap, &fattr->fsid)) !=3D 0)
 		goto xdr_error;
 	if ((status =3D decode_attr_fileid(xdr, bitmap, &fattr->fileid)) !=3D 0=
)
 		goto xdr_error;
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index c71227d..83e2b8a 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -16,8 +16,6 @@ #include <linux/pagemap.h>
 #include <linux/rwsem.h>
 #include <linux/wait.h>
=20
-#include <linux/nfs_fs_sb.h>
-
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/clnt.h>
@@ -27,6 +25,9 @@ #include <linux/nfs2.h>
 #include <linux/nfs3.h>
 #include <linux/nfs4.h>
 #include <linux/nfs_xdr.h>
+
+#include <linux/nfs_fs_sb.h>
+
 #include <linux/rwsem.h>
 #include <linux/mempool.h>
=20
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 65dec21..6b4a13c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -35,6 +35,7 @@ struct nfs_server {
 	char *			hostname;	/* remote hostname */
 	struct nfs_fh		fh;
 	struct sockaddr_in	addr;
+	struct nfs_fsid		fsid;
 	unsigned long		mount_time;	/* when this fs was mounted */
 #ifdef CONFIG_NFS_V4
 	/* Our own IP address, as a null-terminated string.
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 66e2ed6..4cee1f8 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -13,7 +13,6 @@ #define _LINUX_NFS_PAGE_H
 #include <linux/list.h>
 #include <linux/pagemap.h>
 #include <linux/wait.h>
-#include <linux/nfs_fs_sb.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/nfs_xdr.h>
=20
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c483e23..906c462 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -14,11 +14,19 @@ #define NFS_MAX_FILE_IO_SIZE	(1048576U)
 #define NFS_DEF_FILE_IO_SIZE	(4096U)
 #define NFS_MIN_FILE_IO_SIZE	(1024U)
=20
-struct nfs4_fsid {
-	__u64 major;
-	__u64 minor;
+struct nfs_fsid {
+	uint64_t		major;
+	uint64_t		minor;
 };
=20
+/*
+ * Helper for checking equality between 2 fsids.
+ */
+static inline int nfs_fsid_equal(const struct nfs_fsid *a, const struct =
nfs_fsid *b)
+{
+	return a->major =3D=3D b->major && a->minor =3D=3D b->minor;
+}
+
 struct nfs_fattr {
 	unsigned short		valid;		/* which fields are valid */
 	__u64			pre_size;	/* pre_op_attr.size	  */
@@ -40,10 +48,7 @@ struct nfs_fattr {
 		} nfs3;
 	} du;
 	dev_t			rdev;
-	union {
-		__u64		nfs3;		/* also nfs2 */
-		struct nfs4_fsid nfs4;
-	} fsid_u;
+	struct nfs_fsid		fsid;
 	__u64			fileid;
 	struct timespec		atime;
 	struct timespec		mtime;

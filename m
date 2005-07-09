From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: [PATCH 2/3]: NFS: use atomic bitops to manipulate flags in nfsi->flags
Date: Sat, 9 Jul 2005 08:33:06 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539D86@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrHKL-0001Qn-UU
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:33:13 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrHKL-0006Ha-JD
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:33:14 -0700
To: "Nick Wilson" <njw@osdl.org>,
	"Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

 Introduce atomic bitops to manipulate the bits in the nfs_inode
structure's
 "flags" field.

 Using bitops means we can use a generic wait_on_bit call instead of an
ad
 hoc locking scheme in fs/nfs/inode.c, so we can remove the "nfs_i_wait"
 field from nfs_inode at the same time.

 The other new flags field will continue to use bitmask and logic AND
and
 OR.  This permits several flags to be set at the same time efficiently.
 The following patch adds a spin lock to protect these flags, and this
spin
 lock will later cover other fields in the nfs_inode structure,
amortizing
 the cost of using this type of serialization.

 Test plan:
 Millions of fsx ops on SMP clients.

 Version: Fri, 08 Jul 2005 23:27:47 -0400
=20
 Signed-off-by: Chuck Lever <cel@netapp.com>
---
=20
 fs/nfs/dir.c           |    4 +-
 fs/nfs/inode.c         |   69 +++++++++++++++++++++++++----------------
 include/linux/nfs_fs.h |   19 ++++-------
 3 files changed, 53 insertions(+), 39 deletions(-)
=20
=20
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 10-nfs-cache-state/fs/nfs/dir.c
11-nfs-bitops/fs/nfs/dir.c
--- 10-nfs-cache-state/fs/nfs/dir.c	2005-07-08 22:30:24.555858000
-0400
+++ 11-nfs-bitops/fs/nfs/dir.c	2005-07-08 22:50:07.807258000 -0400
@@ -181,9 +181,9 @@ int nfs_readdir_filler(nfs_readdir_descr
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok
it */
 		if (error =3D=3D -ENOTSUPP && desc->plus) {
 			NFS_SERVER(inode)->caps &=3D ~NFS_CAP_READDIRPLUS;
-			NFS_FLAGS(inode) &=3D ~NFS_INO_ADVISE_RDPLUS;
+			clear_bit(NFS_INO_ADVISE_RDPLUS,
&NFS_FLAGS(inode));
 			desc->plus =3D 0;
 			goto again;
 		}
 		goto error;
@@ -544,9 +544,9 @@ static int nfs_readdir(struct file *filp
 			res =3D 0;
 			break;
 		}
 		if (res =3D=3D -ETOOSMALL && desc->plus) {
-			NFS_FLAGS(inode) &=3D ~NFS_INO_ADVISE_RDPLUS;
+			clear_bit(NFS_INO_ADVISE_RDPLUS,
&NFS_FLAGS(inode));
 			nfs_zap_caches(inode);
 			desc->plus =3D 0;
 			desc->entry->eof =3D 0;
 			continue;
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 10-nfs-cache-state/fs/nfs/inode.c
11-nfs-bitops/fs/nfs/inode.c
--- 10-nfs-cache-state/fs/nfs/inode.c	2005-07-08 22:46:36.162239000
-0400
+++ 11-nfs-bitops/fs/nfs/inode.c	2005-07-08 22:52:01.057431000
-0400
@@ -738,9 +738,9 @@ nfs_fhget(struct super_block *sb, struct
 			inode->i_op =3D
NFS_SB(sb)->rpc_ops->dir_inode_ops;
 			inode->i_fop =3D &nfs_dir_operations;
 			if (nfs_server_capable(inode,
NFS_CAP_READDIRPLUS)
 			    && fattr->size <=3D NFS_LIMIT_READDIRPLUS)
-				NFS_FLAGS(inode) |=3D
NFS_INO_ADVISE_RDPLUS;
+				set_bit(NFS_INO_ADVISE_RDPLUS,
&NFS_FLAGS(inode));
 		} else if (S_ISLNK(inode->i_mode))
 			inode->i_op =3D &nfs_symlink_inode_operations;
 		else
 			init_special_inode(inode, inode->i_mode,
fattr->rdev);
@@ -837,28 +837,45 @@ nfs_setattr(struct dentry *dentry, struc
 	unlock_kernel();
 	return error;
 }
=20
+static int nfs_wait_schedule(void *word)
+{
+	if (signal_pending(current))
+		return -ERESTARTSYS;
+	schedule();
+	return 0;
+}
+
 /*
  * Wait for the inode to get unlocked.
- * (Used for NFS_INO_LOCKED and NFS_INO_REVALIDATING).
  */
-static int
-nfs_wait_on_inode(struct inode *inode, int flag)
+static int nfs_wait_on_inode(struct inode *inode)
 {
 	struct rpc_clnt	*clnt =3D NFS_CLIENT(inode);
 	struct nfs_inode *nfsi =3D NFS_I(inode);
-
+	sigset_t oldmask;
 	int error;
-	if (!(NFS_FLAGS(inode) & flag))
-		return 0;
+
 	atomic_inc(&inode->i_count);
-	error =3D nfs_wait_event(clnt, nfsi->nfs_i_wait,
-				!(NFS_FLAGS(inode) & flag));
+	rpc_clnt_sigmask(clnt, &oldmask);
+	error =3D wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
+					nfs_wait_schedule,
TASK_INTERRUPTIBLE);
+	rpc_clnt_sigunmask(clnt, &oldmask);
 	iput(inode);
+
 	return error;
 }
=20
+static void nfs_wake_up_inode(struct inode *inode)
+{
+	struct nfs_inode *nfsi =3D NFS_I(inode);
+
+	clear_bit(NFS_INO_REVALIDATING, &nfsi->flags);
+	smp_mb__after_clear_bit();
+	wake_up_bit(&nfsi->flags, NFS_INO_REVALIDATING);
+}
+
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct
kstat *stat)
 {
 	struct inode *inode =3D dentry->d_inode;
 	int need_atime =3D NFS_I(inode)->cache_validity &
NFS_INO_INVALID_ATIME;
@@ -1017,20 +1034,21 @@ __nfs_revalidate_inode(struct nfs_server
  		goto out_nowait;
 	if (NFS_STALE(inode))
  		goto out_nowait;
=20
-	while (NFS_REVALIDATING(inode)) {
-		status =3D nfs_wait_on_inode(inode, NFS_INO_REVALIDATING);
-		if (status < 0)
-			goto out_nowait;
-		if (NFS_ATTRTIMEO(inode) =3D=3D 0)
-			continue;
-		if (nfsi->cache_validity &
(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATIME))
-			continue;
-		status =3D NFS_STALE(inode) ? -ESTALE : 0;
-		goto out_nowait;
+	status =3D nfs_wait_on_inode(inode);
+	if (status < 0)
+		goto out;
+	if (NFS_STALE(inode)) {
+		status =3D -ESTALE;
+		/* Do we trust the cached ESTALE? */
+		if (NFS_ATTRTIMEO(inode) !=3D 0) {
+			if (nfsi->cache_validity &
(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATIME)) {
+				/* no */
+			} else
+				goto out;
+		}
 	}
-	NFS_FLAGS(inode) |=3D NFS_INO_REVALIDATING;
=20
 	/* Protect against RPC races by saving the change attribute */
 	verifier =3D nfs_save_change_attribute(inode);
 	status =3D NFS_PROTO(inode)->getattr(server, NFS_FH(inode),
&fattr);
@@ -1040,9 +1058,9 @@ __nfs_revalidate_inode(struct nfs_server
 			 (long long)NFS_FILEID(inode), status);
 		if (status =3D=3D -ESTALE) {
 			nfs_zap_caches(inode);
 			if (!S_ISDIR(inode->i_mode))
-				NFS_FLAGS(inode) |=3D NFS_INO_STALE;
+				set_bit(NFS_INO_STALE,
&NFS_FLAGS(inode));
 		}
 		goto out;
 	}
=20
@@ -1071,11 +1089,11 @@ __nfs_revalidate_inode(struct nfs_server
 	dfprintk(PAGECACHE, "NFS: (%s/%Ld) revalidation complete\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode));
=20
-out:
-	NFS_FLAGS(inode) &=3D ~NFS_INO_REVALIDATING;
-	wake_up(&nfsi->nfs_i_wait);
+ out:
+	nfs_wake_up_inode(inode);
+
  out_nowait:
 	unlock_kernel();
 	return status;
 }
@@ -1392,9 +1410,9 @@ static int nfs_update_inode(struct inode
 	 * (But we fall through to invalidate the caches.)
 	 */
 	nfs_invalidate_inode(inode);
  out_err:
-	NFS_FLAGS(inode) |=3D NFS_INO_STALE;
+	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
 	return -ESTALE;
 }
=20
 /*
@@ -1984,9 +2002,8 @@ static void init_once(void * foo, kmem_c
 		atomic_set(&nfsi->data_updates, 0);
 		nfsi->ndirty =3D 0;
 		nfsi->ncommit =3D 0;
 		nfsi->npages =3D 0;
-		init_waitqueue_head(&nfsi->nfs_i_wait);
 		nfs4_init_once(nfsi);
 	}
 }
 =20
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 10-nfs-cache-state/include/linux/nfs_fs.h
11-nfs-bitops/include/linux/nfs_fs.h
--- 10-nfs-cache-state/include/linux/nfs_fs.h	2005-07-08
22:29:36.471730000 -0400
+++ 11-nfs-bitops/include/linux/nfs_fs.h	2005-07-08
22:52:57.387130000 -0400
@@ -111,10 +111,10 @@ struct nfs_inode {
=20
 	/*
 	 * Various flags
 	 */
-	unsigned int		flags;
-	unsigned long		cache_validity;
+	unsigned long		flags;			/* atomic bit
ops */
+	unsigned long		cache_validity;		/* bit mask */
=20
 	/*
 	 * read_cache_jiffies is when we started read-caching this
inode,
 	 * and read_cache_mtime is the mtime of the inode at that time.
@@ -174,10 +174,8 @@ struct nfs_inode {
=20
 	/* Open contexts for shared mmap writes */
 	struct list_head	open_files;
=20
-	wait_queue_head_t	nfs_i_wait;
-
 #ifdef CONFIG_NFS_V4
 	struct nfs4_cached_acl	*nfs4_acl;
         /* NFSv4 state */
 	struct list_head	open_states;
@@ -198,13 +196,13 @@ struct nfs_inode {
 #define NFS_INO_INVALID_ACL	0x0010		/* cached acls are
invalid */
 #define NFS_INO_REVAL_PAGECACHE	0x0020		/* must
revalidate pagecache */
=20
 /*
- * Legal values of flags field
+ * Bit offsets in flags field
  */
-#define NFS_INO_REVALIDATING	0x0001		/* revalidating attrs */
-#define NFS_INO_ADVISE_RDPLUS	0x0002		/* advise readdirplus */
-#define NFS_INO_STALE		0x0004		/* possible stale inode
*/
+#define NFS_INO_REVALIDATING	(0)		/* revalidating attrs */
+#define NFS_INO_ADVISE_RDPLUS	(1)		/* advise readdirplus */
+#define NFS_INO_STALE		(2)		/* possible stale inode
*/
=20
 static inline struct nfs_inode *NFS_I(struct inode *inode)
 {
 	return container_of(inode, struct nfs_inode, vfs_inode);
@@ -228,10 +226,9 @@ static inline struct nfs_inode *NFS_I(st
 			       : NFS_SERVER(inode)->acregmax)
 #define NFS_ATTRTIMEO_UPDATE(inode)
(NFS_I(inode)->attrtimeo_timestamp)
=20
 #define NFS_FLAGS(inode)		(NFS_I(inode)->flags)
-#define NFS_REVALIDATING(inode)		(NFS_FLAGS(inode) &
NFS_INO_REVALIDATING)
-#define NFS_STALE(inode)		(NFS_FLAGS(inode) &
NFS_INO_STALE)
+#define NFS_STALE(inode)		(test_bit(NFS_INO_STALE,
&NFS_FLAGS(inode)))
=20
 #define NFS_FILEID(inode)		(NFS_I(inode)->fileid)
=20
 static inline int nfs_caches_unstable(struct inode *inode)
@@ -251,9 +248,9 @@ static inline int nfs_server_capable(str
 }
=20
 static inline int NFS_USE_READDIRPLUS(struct inode *inode)
 {
-	return NFS_FLAGS(inode) & NFS_INO_ADVISE_RDPLUS;
+	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
 }
=20
 /**
  * nfs_save_change_attribute - Returns the inode attribute change
cookie


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

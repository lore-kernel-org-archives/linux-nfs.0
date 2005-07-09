From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: [PATCH 1/3]: NFS: split nfsi->flags into two fields
Date: Sat, 9 Jul 2005 08:32:31 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539D85@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrHJm-0001PN-Lb
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:32:38 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrHJm-0006BY-2g
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:32:38 -0700
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

 Certain bits in nfsi->flags can be manipulated with atomic bitops, and
some
 are better manipulated via logical bitmask operations.

 This patch splits the flags field into two.  The next patch introduces
 atomic bitops for one of the fields.

 Test plan:
 Millions of fsx ops on SMP clients.

 Version: Fri, 08 Jul 2005 23:27:35 -0400
=20
 Signed-off-by: Chuck Lever <cel@netapp.com>
---
=20
 fs/nfs/dir.c           |   16 ++++++----
 fs/nfs/file.c          |    5 ++-
 fs/nfs/inode.c         |   61 +++++++++++++++++++++--------------------
 fs/nfs/nfs3acl.c       |    2 -
 fs/nfs/read.c          |    4 +-
 include/linux/nfs_fs.h |   27 ++++++++++--------
 6 files changed, 63 insertions(+), 52 deletions(-)
=20
=20
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 00-stock/fs/nfs/dir.c
10-nfs-cache-state/fs/nfs/dir.c
--- 00-stock/fs/nfs/dir.c	2005-07-06 14:53:39.221803000 -0400
+++ 10-nfs-cache-state/fs/nfs/dir.c	2005-07-08 22:30:24.555858000
-0400
@@ -188,9 +188,9 @@ int nfs_readdir_filler(nfs_readdir_descr
 		}
 		goto error;
 	}
 	SetPageUptodate(page);
-	NFS_FLAGS(inode) |=3D NFS_INO_INVALID_ATIME;
+	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
 	/* Ensure consistent page alignment of the data.
 	 * Note: assumes we have exclusive access to this mapping either
 	 *	 through inode->i_sem or some other mechanism.
 	 */
@@ -461,9 +461,9 @@ int uncached_readdir(nfs_readdir_descrip
 	desc->error =3D NFS_PROTO(inode)->readdir(file->f_dentry, cred,
*desc->dir_cookie,
 						page,
=20
NFS_SERVER(inode)->dtsize,
 						desc->plus);
-	NFS_FLAGS(inode) |=3D NFS_INO_INVALID_ATIME;
+	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
 	desc->page =3D page;
 	desc->ptr =3D kmap(page);		/* matching kunmap in
nfs_do_filldir */
 	if (desc->error >=3D 0) {
 		if ((status =3D dir_decode(desc)) =3D=3D 0)
@@ -607,9 +607,9 @@ int nfs_fsync_dir(struct file *filp, str
 static inline int nfs_check_verifier(struct inode *dir, struct dentry
*dentry)
 {
 	if (IS_ROOT(dentry))
 		return 1;
-	if ((NFS_FLAGS(dir) & NFS_INO_INVALID_ATTR) !=3D 0
+	if ((NFS_I(dir)->cache_validity & NFS_INO_INVALID_ATTR) !=3D 0
 			|| nfs_attribute_timeout(dir))
 		return 0;
 	return nfs_verify_change_attribute(dir, (unsigned
long)dentry->d_fsdata);
 }
@@ -1574,28 +1574,30 @@ out:
 }
=20
 int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred,
struct nfs_access_entry *res)
 {
-	struct nfs_access_entry *cache =3D &NFS_I(inode)->cache_access;
+	struct nfs_inode *nfsi =3D NFS_I(inode);
+	struct nfs_access_entry *cache =3D &nfsi->cache_access;
=20
 	if (cache->cred !=3D cred
 			|| time_after(jiffies, cache->jiffies +
NFS_ATTRTIMEO(inode))
-			|| (NFS_FLAGS(inode) & NFS_INO_INVALID_ACCESS))
+			|| (nfsi->cache_validity &
NFS_INO_INVALID_ACCESS))
 		return -ENOENT;
 	memcpy(res, cache, sizeof(*res));
 	return 0;
 }
=20
 void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry
*set)
 {
-	struct nfs_access_entry *cache =3D &NFS_I(inode)->cache_access;
+	struct nfs_inode *nfsi =3D NFS_I(inode);
+	struct nfs_access_entry *cache =3D &nfsi->cache_access;
=20
 	if (cache->cred !=3D set->cred) {
 		if (cache->cred)
 			put_rpccred(cache->cred);
 		cache->cred =3D get_rpccred(set->cred);
 	}
-	NFS_FLAGS(inode) &=3D ~NFS_INO_INVALID_ACCESS;
+	nfsi->cache_validity &=3D ~NFS_INO_INVALID_ACCESS;
 	cache->jiffies =3D set->jiffies;
 	cache->mask =3D set->mask;
 }
=20
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 00-stock/fs/nfs/file.c
10-nfs-cache-state/fs/nfs/file.c
--- 00-stock/fs/nfs/file.c	2005-07-06 14:53:39.293802000 -0400
+++ 10-nfs-cache-state/fs/nfs/file.c	2005-07-08 22:25:22.570136000
-0400
@@ -133,11 +133,12 @@ nfs_file_release(struct inode *inode, st
  * @file - pointer to file
  */
 static int nfs_revalidate_file(struct inode *inode, struct file *filp)
 {
+	struct nfs_inode *nfsi =3D NFS_I(inode);
 	int retval =3D 0;
=20
-	if ((NFS_FLAGS(inode) & NFS_INO_REVAL_PAGECACHE) ||
nfs_attribute_timeout(inode))
+	if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE) ||
nfs_attribute_timeout(inode))
 		retval =3D __nfs_revalidate_inode(NFS_SERVER(inode),
inode);
 	nfs_revalidate_mapping(inode, filp->f_mapping);
 	return 0;
 }
@@ -163,9 +164,9 @@ static int nfs_revalidate_file_size(stru
 	if (filp->f_flags & O_DIRECT)
 		goto force_reval;
 	if (nfsi->npages !=3D 0)
 		return 0;
-	if (!(NFS_FLAGS(inode) & NFS_INO_REVAL_PAGECACHE) &&
!nfs_attribute_timeout(inode))
+	if (!(nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE) &&
!nfs_attribute_timeout(inode))
 		return 0;
 force_reval:
 	return __nfs_revalidate_inode(server, inode);
 }
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 00-stock/fs/nfs/inode.c
10-nfs-cache-state/fs/nfs/inode.c
--- 00-stock/fs/nfs/inode.c	2005-07-06 14:53:39.300802000 -0400
+++ 10-nfs-cache-state/fs/nfs/inode.c	2005-07-08 22:46:36.162239000
-0400
@@ -619,11 +619,11 @@ nfs_zap_caches(struct inode *inode)
 	NFS_ATTRTIMEO_UPDATE(inode) =3D jiffies;
=20
 	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))
-		nfsi->flags |=3D
NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO
_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
+		nfsi->cache_validity |=3D
NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO
_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
 	else
-		nfsi->flags |=3D
NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_
REVAL_PAGECACHE;
+		nfsi->cache_validity |=3D
NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_
REVAL_PAGECACHE;
 }
=20
 static void nfs_zap_acl_cache(struct inode *inode)
 {
@@ -631,9 +631,9 @@ static void nfs_zap_acl_cache(struct ino
=20
 	clear_acl_cache =3D NFS_PROTO(inode)->clear_acl_cache;
 	if (clear_acl_cache !=3D NULL)
 		clear_acl_cache(inode);
-	NFS_I(inode)->flags &=3D ~NFS_INO_INVALID_ACL;
+	NFS_I(inode)->cache_validity &=3D ~NFS_INO_INVALID_ACL;
 }
=20
 /*
  * Invalidate, but do not unhash, the inode
@@ -831,9 +831,9 @@ nfs_setattr(struct dentry *dentry, struc
 			vmtruncate(inode, attr->ia_size);
 		}
 	}
 	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0)
-		NFS_FLAGS(inode) |=3D
NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+		NFS_I(inode)->cache_validity |=3D
NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
 	nfs_end_data_update(inode);
 	unlock_kernel();
 	return error;
 }
@@ -860,10 +860,9 @@ nfs_wait_on_inode(struct inode *inode, i
=20
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct
kstat *stat)
 {
 	struct inode *inode =3D dentry->d_inode;
-	struct nfs_inode *nfsi =3D NFS_I(inode);
-	int need_atime =3D nfsi->flags & NFS_INO_INVALID_ATIME;
+	int need_atime =3D NFS_I(inode)->cache_validity &
NFS_INO_INVALID_ATIME;
 	int err;
=20
 	if (__IS_FLG(inode, MS_NOATIME))
 		need_atime =3D 0;
@@ -1007,9 +1006,9 @@ __nfs_revalidate_inode(struct nfs_server
 	int		 status =3D -ESTALE;
 	struct nfs_fattr fattr;
 	struct nfs_inode *nfsi =3D NFS_I(inode);
 	unsigned long verifier;
-	unsigned int flags;
+	unsigned long cache_validity;
=20
 	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
 		inode->i_sb->s_id, (long long)NFS_FILEID(inode));
=20
@@ -1024,9 +1023,9 @@ __nfs_revalidate_inode(struct nfs_server
 		if (status < 0)
 			goto out_nowait;
 		if (NFS_ATTRTIMEO(inode) =3D=3D 0)
 			continue;
-		if (NFS_FLAGS(inode) &
(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATIME))
+		if (nfsi->cache_validity &
(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ATIME))
 			continue;
 		status =3D NFS_STALE(inode) ? -ESTALE : 0;
 		goto out_nowait;
 	}
@@ -1053,20 +1052,23 @@ __nfs_revalidate_inode(struct nfs_server
 			 inode->i_sb->s_id,
 			 (long long)NFS_FILEID(inode), status);
 		goto out;
 	}
-	flags =3D nfsi->flags;
-	nfsi->flags &=3D ~NFS_INO_REVAL_PAGECACHE;
+	cache_validity =3D nfsi->cache_validity;
+	nfsi->cache_validity &=3D ~NFS_INO_REVAL_PAGECACHE;
+
 	/*
 	 * We may need to keep the attributes marked as invalid if
 	 * we raced with nfs_end_attr_update().
 	 */
 	if (verifier =3D=3D nfsi->cache_change_attribute)
-		nfsi->flags &=3D
~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME);
-	/* Do the page cache invalidation */
+		nfsi->cache_validity &=3D
~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME);
+
 	nfs_revalidate_mapping(inode, inode->i_mapping);
-	if (flags & NFS_INO_INVALID_ACL)
+
+	if (cache_validity & NFS_INO_INVALID_ACL)
 		nfs_zap_acl_cache(inode);
+
 	dfprintk(PAGECACHE, "NFS: (%s/%Ld) revalidation complete\n",
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode));
=20
@@ -1095,9 +1097,9 @@ int nfs_attribute_timeout(struct inode *
  * Updates inode attribute information by retrieving the data from the
server.
  */
 int nfs_revalidate_inode(struct nfs_server *server, struct inode
*inode)
 {
-	if (!(NFS_FLAGS(inode) &
(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
+	if (!(NFS_I(inode)->cache_validity &
(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA))
 			&& !nfs_attribute_timeout(inode))
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
@@ -1110,16 +1112,16 @@ int nfs_revalidate_inode(struct nfs_serv
 void nfs_revalidate_mapping(struct inode *inode, struct address_space
*mapping)
 {
 	struct nfs_inode *nfsi =3D NFS_I(inode);
=20
-	if (nfsi->flags & NFS_INO_INVALID_DATA) {
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA) {
 		if (S_ISREG(inode->i_mode)) {
 			if (filemap_fdatawrite(mapping) =3D=3D 0)
 				filemap_fdatawait(mapping);
 			nfs_wb_all(inode);
 		}
 		invalidate_inode_pages2(mapping);
-		nfsi->flags &=3D ~NFS_INO_INVALID_DATA;
+		nfsi->cache_validity &=3D ~NFS_INO_INVALID_DATA;
 		if (S_ISDIR(inode->i_mode)) {
 			memset(nfsi->cookieverf, 0,
sizeof(nfsi->cookieverf));
 			/* This ensures we revalidate child dentries */
 			nfsi->cache_change_attribute++;
@@ -1152,12 +1154,12 @@ void nfs_end_data_update(struct inode *i
 	struct nfs_inode *nfsi =3D NFS_I(inode);
=20
 	if (!nfs_have_delegation(inode, FMODE_READ)) {
 		/* Mark the attribute cache for revalidation */
-		nfsi->flags |=3D NFS_INO_INVALID_ATTR;
+		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
 		/* Directories and symlinks: invalidate page cache too
*/
 		if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode))
-			nfsi->flags |=3D NFS_INO_INVALID_DATA;
+			nfsi->cache_validity |=3D NFS_INO_INVALID_DATA;
 	}
 	nfsi->cache_change_attribute ++;
 	atomic_dec(&nfsi->data_updates);
 }
@@ -1188,11 +1190,11 @@ int nfs_refresh_inode(struct inode *inod
 		if ((fattr->valid & NFS_ATTR_PRE_CHANGE) !=3D 0
 				&& nfsi->change_attr =3D=3D
fattr->pre_change_attr)
 			nfsi->change_attr =3D fattr->change_attr;
 		if (nfsi->change_attr !=3D fattr->change_attr) {
-			nfsi->flags |=3D NFS_INO_INVALID_ATTR;
+			nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
 			if (!data_unstable)
-				nfsi->flags |=3D NFS_INO_REVAL_PAGECACHE;
+				nfsi->cache_validity |=3D
NFS_INO_REVAL_PAGECACHE;
 		}
 	}
=20
 	if ((fattr->valid & NFS_ATTR_FATTR) =3D=3D 0)
@@ -1215,30 +1217,30 @@ int nfs_refresh_inode(struct inode *inod
 	}
=20
 	/* Verify a few of the more important attributes */
 	if (!timespec_equal(&inode->i_mtime, &fattr->mtime)) {
-		nfsi->flags |=3D NFS_INO_INVALID_ATTR;
+		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
 		if (!data_unstable)
-			nfsi->flags |=3D NFS_INO_REVAL_PAGECACHE;
+			nfsi->cache_validity |=3D NFS_INO_REVAL_PAGECACHE;
 	}
 	if (cur_size !=3D new_isize) {
-		nfsi->flags |=3D NFS_INO_INVALID_ATTR;
+		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
 		if (nfsi->npages =3D=3D 0)
-			nfsi->flags |=3D NFS_INO_REVAL_PAGECACHE;
+			nfsi->cache_validity |=3D NFS_INO_REVAL_PAGECACHE;
 	}
=20
 	/* Have any file permissions changed? */
 	if ((inode->i_mode & S_IALLUGO) !=3D (fattr->mode & S_IALLUGO)
 			|| inode->i_uid !=3D fattr->uid
 			|| inode->i_gid !=3D fattr->gid)
-		nfsi->flags |=3D NFS_INO_INVALID_ATTR |
NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
+		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR |
NFS_INO_INVALID_ACCESS | NFS_INO_INVALID_ACL;
=20
 	/* Has the link count changed? */
 	if (inode->i_nlink !=3D fattr->nlink)
-		nfsi->flags |=3D NFS_INO_INVALID_ATTR;
+		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
=20
 	if (!timespec_equal(&inode->i_atime, &fattr->atime))
-		nfsi->flags |=3D NFS_INO_INVALID_ATIME;
+		nfsi->cache_validity |=3D NFS_INO_INVALID_ATIME;
=20
 	nfsi->read_cache_jiffies =3D fattr->timestamp;
 	return 0;
 }
@@ -1372,9 +1374,9 @@ static int nfs_update_inode(struct inode
 	if (!(S_ISREG(inode->i_mode) || S_ISDIR(inode->i_mode)
 				|| S_ISLNK(inode->i_mode)))
 		invalid &=3D ~NFS_INO_INVALID_DATA;
 	if (!nfs_have_delegation(inode, FMODE_READ))
-		nfsi->flags |=3D invalid;
+		nfsi->cache_validity |=3D invalid;
=20
 	return 0;
  out_changed:
 	/*
@@ -1949,9 +1951,10 @@ static struct inode *nfs_alloc_inode(str
 	struct nfs_inode *nfsi;
 	nfsi =3D (struct nfs_inode *)kmem_cache_alloc(nfs_inode_cachep,
SLAB_KERNEL);
 	if (!nfsi)
 		return NULL;
-	nfsi->flags =3D 0;
+	nfsi->flags =3D 0UL;
+	nfsi->cache_validity =3D 0UL;
 #ifdef CONFIG_NFS_V3_ACL
 	nfsi->acl_access =3D ERR_PTR(-EAGAIN);
 	nfsi->acl_default =3D ERR_PTR(-EAGAIN);
 #endif
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 00-stock/fs/nfs/nfs3acl.c
10-nfs-cache-state/fs/nfs/nfs3acl.c
--- 00-stock/fs/nfs/nfs3acl.c	2005-07-06 14:53:39.304803000 -0400
+++ 10-nfs-cache-state/fs/nfs/nfs3acl.c	2005-07-08 22:27:51.880050000
-0400
@@ -307,9 +307,9 @@ static int nfs3_proc_setacls(struct inod
 	dprintk("NFS call setacl\n");
 	nfs_begin_data_update(inode);
 	status =3D rpc_call(server->client_acl, ACLPROC3_SETACL,
 			  &args, &fattr, 0);
-	NFS_FLAGS(inode) |=3D NFS_INO_INVALID_ACCESS;
+	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ACCESS;
 	nfs_end_data_update(inode);
 	dprintk("NFS reply setacl: %d\n", status);
=20
 	/* pages may have been allocated at the xdr layer. */
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 00-stock/fs/nfs/read.c
10-nfs-cache-state/fs/nfs/read.c
--- 00-stock/fs/nfs/read.c	2005-07-06 14:53:39.337802000 -0400
+++ 10-nfs-cache-state/fs/nfs/read.c	2005-07-08 22:28:45.368469000
-0400
@@ -139,9 +139,9 @@ static int nfs_readpage_sync(struct nfs_
 		 */
 		if (rdata->res.eof !=3D 0 || result =3D=3D 0)
 			break;
 	} while (count);
-	NFS_FLAGS(inode) |=3D NFS_INO_INVALID_ATIME;
+	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
=20
 	if (count)
 		memclear_highpage_flush(page, rdata->args.pgbase,
count);
 	SetPageUptodate(page);
@@ -472,9 +472,9 @@ void nfs_readpage_result(struct rpc_task
 			return;
 		}
 		task->tk_status =3D -EIO;
 	}
-	NFS_FLAGS(data->inode) |=3D NFS_INO_INVALID_ATIME;
+	NFS_I(data->inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
 	data->complete(data, status);
 }
=20
 /*
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 00-stock/include/linux/nfs_fs.h
10-nfs-cache-state/include/linux/nfs_fs.h
--- 00-stock/include/linux/nfs_fs.h	2005-07-06 14:53:43.882452000
-0400
+++ 10-nfs-cache-state/include/linux/nfs_fs.h	2005-07-08
22:29:36.471730000 -0400
@@ -112,8 +112,9 @@ struct nfs_inode {
 	/*
 	 * Various flags
 	 */
 	unsigned int		flags;
+	unsigned long		cache_validity;
=20
 	/*
 	 * read_cache_jiffies is when we started read-caching this
inode,
 	 * and read_cache_mtime is the mtime of the inode at that time.
@@ -187,19 +188,23 @@ struct nfs_inode {
 	struct inode		vfs_inode;
 };
=20
 /*
- * Legal inode flag values
+ * Cache validity bit flags
  */
-#define NFS_INO_STALE		0x0001		/* possible stale inode
*/
-#define NFS_INO_ADVISE_RDPLUS   0x0002          /* advise readdirplus
*/
-#define NFS_INO_REVALIDATING	0x0004		/* revalidating attrs */
-#define NFS_INO_INVALID_ATTR	0x0008		/* cached attrs are
invalid */
-#define NFS_INO_INVALID_DATA	0x0010		/* cached data is
invalid */
-#define NFS_INO_INVALID_ATIME	0x0020		/* cached atime is
invalid */
-#define NFS_INO_INVALID_ACCESS	0x0040		/* cached access cred
invalid */
-#define NFS_INO_INVALID_ACL	0x0080		/* cached acls are
invalid */
-#define NFS_INO_REVAL_PAGECACHE	0x1000		/* must
revalidate pagecache */
+#define NFS_INO_INVALID_ATTR	0x0001		/* cached attrs are
invalid */
+#define NFS_INO_INVALID_DATA	0x0002		/* cached data is
invalid */
+#define NFS_INO_INVALID_ATIME	0x0004		/* cached atime is
invalid */
+#define NFS_INO_INVALID_ACCESS	0x0008		/* cached access cred
invalid */
+#define NFS_INO_INVALID_ACL	0x0010		/* cached acls are
invalid */
+#define NFS_INO_REVAL_PAGECACHE	0x0020		/* must
revalidate pagecache */
+
+/*
+ * Legal values of flags field
+ */
+#define NFS_INO_REVALIDATING	0x0001		/* revalidating attrs */
+#define NFS_INO_ADVISE_RDPLUS	0x0002		/* advise readdirplus */
+#define NFS_INO_STALE		0x0004		/* possible stale inode
*/
=20
 static inline struct nfs_inode *NFS_I(struct inode *inode)
 {
 	return container_of(inode, struct nfs_inode, vfs_inode);
@@ -236,9 +241,9 @@ static inline int nfs_caches_unstable(st
=20
 static inline void NFS_CACHEINV(struct inode *inode)
 {
 	if (!nfs_caches_unstable(inode))
-		NFS_FLAGS(inode) |=3D NFS_INO_INVALID_ATTR |
NFS_INO_INVALID_ACCESS;
+		NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATTR |
NFS_INO_INVALID_ACCESS;
 }
=20
 static inline int nfs_server_capable(struct inode *inode, int cap)
 {


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

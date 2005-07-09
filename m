From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: [PATCH 3/3]: NFS: Introduce the use of inode->i_lock to protect fields in nfsi
Date: Sat, 9 Jul 2005 08:33:58 -0700
Message-ID: <482A3FA0050D21419C269D13989C611308539D87@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrHLD-0001TQ-Qo
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:34:07 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrHLD-0006RJ-EA
	for nfs@lists.sourceforge.net; Sat, 09 Jul 2005 08:34:07 -0700
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

 Down the road we want to eliminate the use of the global kernel lock
 entirely from the NFS client.  To do this, we need to protect the
fields
 in the nfs_inode structure adequately.  Start by serializing updates to
 the "cache_validity" field.

 Note this change addresses an SMP hang found by njw@osdl.org, where
 processes deadlock because nfs_end_data_update and
nfs_revalidate_mapping
 update the "cache_validity" field without proper serialization.

 Test plan:
 Millions of fsx ops on SMP clients.  Run Nick Wilson's breaknfs program
on
 large SMP clients.

 Version: Fri, 08 Jul 2005 23:27:59 -0400
=20
 Signed-off-by: Chuck Lever <cel@netapp.com>
---
=20
 fs/nfs/dir.c           |    6 ++++++
 fs/nfs/inode.c         |   37 +++++++++++++++++++++++++++++++++----
 fs/nfs/nfs3acl.c       |    2 ++
 fs/nfs/read.c          |    4 ++++
 include/linux/nfs_fs.h |    5 ++++-
 5 files changed, 49 insertions(+), 5 deletions(-)
=20
=20
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 11-nfs-bitops/fs/nfs/dir.c
12-nfs-i_lock/fs/nfs/dir.c
--- 11-nfs-bitops/fs/nfs/dir.c	2005-07-08 22:50:07.807258000 -0400
+++ 12-nfs-i_lock/fs/nfs/dir.c	2005-07-08 23:09:58.071448000 -0400
@@ -188,9 +188,11 @@ int nfs_readdir_filler(nfs_readdir_descr
 		}
 		goto error;
 	}
 	SetPageUptodate(page);
+	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
+	spin_unlock(&inode->i_lock);
 	/* Ensure consistent page alignment of the data.
 	 * Note: assumes we have exclusive access to this mapping either
 	 *	 through inode->i_sem or some other mechanism.
 	 */
@@ -461,9 +463,11 @@ int uncached_readdir(nfs_readdir_descrip
 	desc->error =3D NFS_PROTO(inode)->readdir(file->f_dentry, cred,
*desc->dir_cookie,
 						page,
=20
NFS_SERVER(inode)->dtsize,
 						desc->plus);
+	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
+	spin_unlock(&inode->i_lock);
 	desc->page =3D page;
 	desc->ptr =3D kmap(page);		/* matching kunmap in
nfs_do_filldir */
 	if (desc->error >=3D 0) {
 		if ((status =3D dir_decode(desc)) =3D=3D 0)
@@ -1595,9 +1599,11 @@ void nfs_access_add_cache(struct inode *
 		if (cache->cred)
 			put_rpccred(cache->cred);
 		cache->cred =3D get_rpccred(set->cred);
 	}
+	spin_lock(&inode->i_lock);
 	nfsi->cache_validity &=3D ~NFS_INO_INVALID_ACCESS;
+	spin_unlock(&inode->i_lock);
 	cache->jiffies =3D set->jiffies;
 	cache->mask =3D set->mask;
 }
=20
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 11-nfs-bitops/fs/nfs/inode.c
12-nfs-i_lock/fs/nfs/inode.c
--- 11-nfs-bitops/fs/nfs/inode.c	2005-07-08 22:52:01.057431000
-0400
+++ 12-nfs-i_lock/fs/nfs/inode.c	2005-07-08 23:11:53.639214000
-0400
@@ -614,16 +614,20 @@ nfs_zap_caches(struct inode *inode)
 {
 	struct nfs_inode *nfsi =3D NFS_I(inode);
 	int mode =3D inode->i_mode;
=20
+	spin_lock(&inode->i_lock);
+
 	NFS_ATTRTIMEO(inode) =3D NFS_MINATTRTIMEO(inode);
 	NFS_ATTRTIMEO_UPDATE(inode) =3D jiffies;
=20
 	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
 	if (S_ISREG(mode) || S_ISDIR(mode) || S_ISLNK(mode))
 		nfsi->cache_validity |=3D
NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO
_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
 	else
 		nfsi->cache_validity |=3D
NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_
REVAL_PAGECACHE;
+
+	spin_unlock(&inode->i_lock);
 }
=20
 static void nfs_zap_acl_cache(struct inode *inode)
 {
@@ -631,9 +635,11 @@ static void nfs_zap_acl_cache(struct ino
=20
 	clear_acl_cache =3D NFS_PROTO(inode)->clear_acl_cache;
 	if (clear_acl_cache !=3D NULL)
 		clear_acl_cache(inode);
+	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity &=3D ~NFS_INO_INVALID_ACL;
+	spin_unlock(&inode->i_lock);
 }
=20
 /*
  * Invalidate, but do not unhash, the inode
@@ -830,10 +836,13 @@ nfs_setattr(struct dentry *dentry, struc
 			inode->i_size =3D attr->ia_size;
 			vmtruncate(inode, attr->ia_size);
 		}
 	}
-	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0)
+	if ((attr->ia_valid & (ATTR_MODE|ATTR_UID|ATTR_GID)) !=3D 0) {
+		spin_lock(&inode->i_lock);
 		NFS_I(inode)->cache_validity |=3D
NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
+		spin_unlock(&inode->i_lock);
+	}
 	nfs_end_data_update(inode);
 	unlock_kernel();
 	return error;
 }
@@ -1070,8 +1079,9 @@ __nfs_revalidate_inode(struct nfs_server
 			 inode->i_sb->s_id,
 			 (long long)NFS_FILEID(inode), status);
 		goto out;
 	}
+	spin_lock(&inode->i_lock);
 	cache_validity =3D nfsi->cache_validity;
 	nfsi->cache_validity &=3D ~NFS_INO_REVAL_PAGECACHE;
=20
 	/*
@@ -1079,8 +1089,9 @@ __nfs_revalidate_inode(struct nfs_server
 	 * we raced with nfs_end_attr_update().
 	 */
 	if (verifier =3D=3D nfsi->cache_change_attribute)
 		nfsi->cache_validity &=3D
~(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ATIME);
+	spin_unlock(&inode->i_lock);
=20
 	nfs_revalidate_mapping(inode, inode->i_mapping);
=20
 	if (cache_validity & NFS_INO_INVALID_ACL)
@@ -1137,14 +1148,18 @@ void nfs_revalidate_mapping(struct inode
 				filemap_fdatawait(mapping);
 			nfs_wb_all(inode);
 		}
 		invalidate_inode_pages2(mapping);
+
+		spin_lock(&inode->i_lock);
 		nfsi->cache_validity &=3D ~NFS_INO_INVALID_DATA;
 		if (S_ISDIR(inode->i_mode)) {
 			memset(nfsi->cookieverf, 0,
sizeof(nfsi->cookieverf));
 			/* This ensures we revalidate child dentries */
 			nfsi->cache_change_attribute++;
 		}
+		spin_unlock(&inode->i_lock);
+
 		dfprintk(PAGECACHE, "NFS: (%s/%Ld) data cache
invalidated\n",
 				inode->i_sb->s_id,
 				(long long)NFS_FILEID(inode));
 	}
@@ -1172,12 +1187,14 @@ void nfs_end_data_update(struct inode *i
 	struct nfs_inode *nfsi =3D NFS_I(inode);
=20
 	if (!nfs_have_delegation(inode, FMODE_READ)) {
 		/* Mark the attribute cache for revalidation */
+		spin_lock(&inode->i_lock);
 		nfsi->cache_validity |=3D NFS_INO_INVALID_ATTR;
 		/* Directories and symlinks: invalidate page cache too
*/
 		if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode))
 			nfsi->cache_validity |=3D NFS_INO_INVALID_DATA;
+		spin_unlock(&inode->i_lock);
 	}
 	nfsi->cache_change_attribute ++;
 	atomic_dec(&nfsi->data_updates);
 }
@@ -1200,8 +1217,10 @@ int nfs_refresh_inode(struct inode *inod
 	/* Do we hold a delegation? */
 	if (nfs_have_delegation(inode, FMODE_READ))
 		return 0;
=20
+	spin_lock(&inode->i_lock);
+
 	/* Are we in the process of updating data on the server? */
 	data_unstable =3D nfs_caches_unstable(inode);
=20
 	if (fattr->valid & NFS_ATTR_FATTR_V4) {
@@ -1214,15 +1233,19 @@ int nfs_refresh_inode(struct inode *inod
 				nfsi->cache_validity |=3D
NFS_INO_REVAL_PAGECACHE;
 		}
 	}
=20
-	if ((fattr->valid & NFS_ATTR_FATTR) =3D=3D 0)
+	if ((fattr->valid & NFS_ATTR_FATTR) =3D=3D 0) {
+		spin_unlock(&inode->i_lock);
 		return 0;
+	}
=20
 	/* Has the inode gone and changed behind our back? */
 	if (nfsi->fileid !=3D fattr->fileid
-			|| (inode->i_mode & S_IFMT) !=3D (fattr->mode &
S_IFMT))
+			|| (inode->i_mode & S_IFMT) !=3D (fattr->mode &
S_IFMT)) {
+		spin_unlock(&inode->i_lock);
 		return -EIO;
+	}
=20
 	cur_size =3D i_size_read(inode);
  	new_isize =3D nfs_size_to_loff_t(fattr->size);
=20
@@ -1259,8 +1282,9 @@ int nfs_refresh_inode(struct inode *inod
 	if (!timespec_equal(&inode->i_atime, &fattr->atime))
 		nfsi->cache_validity |=3D NFS_INO_INVALID_ATIME;
=20
 	nfsi->read_cache_jiffies =3D fattr->timestamp;
+	spin_unlock(&inode->i_lock);
 	return 0;
 }
=20
 /*
@@ -1297,13 +1321,17 @@ static int nfs_update_inode(struct inode
 		       inode->i_sb->s_id, (long long)fattr->fileid);
 		goto out_err;
 	}
=20
+	spin_lock(&inode->i_lock);
+
 	/*
 	 * Make sure the inode's type hasn't changed.
 	 */
-	if ((inode->i_mode & S_IFMT) !=3D (fattr->mode & S_IFMT))
+	if ((inode->i_mode & S_IFMT) !=3D (fattr->mode & S_IFMT)) {
+		spin_unlock(&inode->i_lock);
 		goto out_changed;
+	}
=20
 	/*
 	 * Update the read time so we don't revalidate too often.
 	 */
@@ -1394,8 +1422,9 @@ static int nfs_update_inode(struct inode
 		invalid &=3D ~NFS_INO_INVALID_DATA;
 	if (!nfs_have_delegation(inode, FMODE_READ))
 		nfsi->cache_validity |=3D invalid;
=20
+	spin_unlock(&inode->i_lock);
 	return 0;
  out_changed:
 	/*
 	 * Big trouble! The inode has become a different object.
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 11-nfs-bitops/fs/nfs/nfs3acl.c
12-nfs-i_lock/fs/nfs/nfs3acl.c
--- 11-nfs-bitops/fs/nfs/nfs3acl.c	2005-07-08 22:27:51.880050000
-0400
+++ 12-nfs-i_lock/fs/nfs/nfs3acl.c	2005-07-08 23:12:39.545920000
-0400
@@ -307,9 +307,11 @@ static int nfs3_proc_setacls(struct inod
 	dprintk("NFS call setacl\n");
 	nfs_begin_data_update(inode);
 	status =3D rpc_call(server->client_acl, ACLPROC3_SETACL,
 			  &args, &fattr, 0);
+	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ACCESS;
+	spin_unlock(&inode->i_lock);
 	nfs_end_data_update(inode);
 	dprintk("NFS reply setacl: %d\n", status);
=20
 	/* pages may have been allocated at the xdr layer. */
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 11-nfs-bitops/fs/nfs/read.c
12-nfs-i_lock/fs/nfs/read.c
--- 11-nfs-bitops/fs/nfs/read.c	2005-07-08 22:28:45.368469000 -0400
+++ 12-nfs-i_lock/fs/nfs/read.c	2005-07-08 23:13:37.623157000 -0400
@@ -139,9 +139,11 @@ static int nfs_readpage_sync(struct nfs_
 		 */
 		if (rdata->res.eof !=3D 0 || result =3D=3D 0)
 			break;
 	} while (count);
+	spin_lock(&inode->i_lock);
 	NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
+	spin_unlock(&inode->i_lock);
=20
 	if (count)
 		memclear_highpage_flush(page, rdata->args.pgbase,
count);
 	SetPageUptodate(page);
@@ -472,9 +474,11 @@ void nfs_readpage_result(struct rpc_task
 			return;
 		}
 		task->tk_status =3D -EIO;
 	}
+	spin_lock(&data->inode->i_lock);
 	NFS_I(data->inode)->cache_validity |=3D NFS_INO_INVALID_ATIME;
+	spin_unlock(&data->inode->i_lock);
 	data->complete(data, status);
 }
=20
 /*
diff -X /home/cel/src/linux/dont-diff --new-file --text --unified=3D4
--recursive --show-c-function 11-nfs-bitops/include/linux/nfs_fs.h
12-nfs-i_lock/include/linux/nfs_fs.h
--- 11-nfs-bitops/include/linux/nfs_fs.h	2005-07-08
22:52:57.387130000 -0400
+++ 12-nfs-i_lock/include/linux/nfs_fs.h	2005-07-08
23:07:58.220127000 -0400
@@ -237,10 +237,13 @@ static inline int nfs_caches_unstable(st
 }
=20
 static inline void NFS_CACHEINV(struct inode *inode)
 {
-	if (!nfs_caches_unstable(inode))
+	if (!nfs_caches_unstable(inode)) {
+		spin_lock(&inode->i_lock);
 		NFS_I(inode)->cache_validity |=3D NFS_INO_INVALID_ATTR |
NFS_INO_INVALID_ACCESS;
+		spin_unlock(&inode->i_lock);
+	}
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

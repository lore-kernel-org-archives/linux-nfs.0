From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH 3/3] enhanced NFS ESTALE error handling (v3)
Date: Mon, 10 Mar 2008 16:23:45 -0400
Message-ID: <47D598D1.1040307@redhat.com>
References: <4790C76F.2050105@redhat.com> <47A387D9.1070206@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000303090308070402070003"
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756626AbYCJUYh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2008 16:24:37 -0400
In-Reply-To: <47A387D9.1070206@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000303090308070402070003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

The patch enhanced the ESTALE error handling for NFS mounted
file systems.  It expands the number of places that the NFS
client checks for ESTALE returns from the server.

It also enhances the ESTALE handling for directories by
occasionally retrying revalidation to check to see whether the
directory becomes valid again.  This sounds odd, but can occur
when a systems administrator, accidently or unknowingly,
unexports a file system which is in use.  All active
non-directory files become permanently inaccessible, but
directories can be become accessible again after the
administrator re-exports the file system.  This is a situation
that users have been complaining about for years and this
support can help to alleviate their situations.

    Thanx...

        ps

Signed-off-by: Peter Staubach <staubach@redhat.com>

--------------000303090308070402070003
Content-Type: text/plain;
 name="estale.nfs.3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="estale.nfs.3"

--- linux-2.6.24.i686/fs/nfs/inode.c.org
+++ linux-2.6.24.i686/fs/nfs/inode.c
@@ -192,7 +192,7 @@ void nfs_invalidate_atime(struct inode *
  */
 static void nfs_invalidate_inode(struct inode *inode)
 {
-	set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+	nfs_handle_estale(-ESTALE, inode);
 	nfs_zap_caches_locked(inode);
 }
 
@@ -386,6 +386,8 @@ nfs_setattr(struct dentry *dentry, struc
 	error = NFS_PROTO(inode)->setattr(dentry, &fattr, attr);
 	if (error == 0)
 		nfs_refresh_inode(inode, &fattr);
+	else
+		nfs_handle_estale(error, inode);
 	unlock_kernel();
 	return error;
 }
@@ -635,7 +637,7 @@ int nfs_release(struct inode *inode, str
 int
 __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
-	int		 status = -ESTALE;
+	int status = -ESTALE;
 	struct nfs_fattr fattr;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
@@ -646,15 +648,25 @@ __nfs_revalidate_inode(struct nfs_server
 	lock_kernel();
 	if (is_bad_inode(inode))
  		goto out_nowait;
-	if (NFS_STALE(inode))
+	if (NFS_STALE(inode) && !S_ISDIR(inode->i_mode))
  		goto out_nowait;
 
 	status = nfs_wait_on_inode(inode);
 	if (status < 0)
 		goto out;
 
+	/*
+	 * Do we believe that the file handle is still stale?
+	 * For non-directories, once stale, always stale.
+	 * For directories, believe the stale status for the
+	 * attribute cache timeout period, and then try again.
+	 * This will help to address the problem of the server
+	 * admin "accidently" unexporting a file system without
+	 * stopping the NFS server first.
+	 */
 	status = -ESTALE;
-	if (NFS_STALE(inode))
+	if (NFS_STALE(inode) &&
+	    (!S_ISDIR(inode->i_mode) || !nfs_attribute_timeout(inode)))
 		goto out;
 
 	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), &fattr);
@@ -663,9 +675,8 @@ __nfs_revalidate_inode(struct nfs_server
 			 inode->i_sb->s_id,
 			 (long long)NFS_FILEID(inode), status);
 		if (status == -ESTALE) {
+			nfs_handle_estale(status, inode);
 			nfs_zap_caches(inode);
-			if (!S_ISDIR(inode->i_mode))
-				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
 		}
 		goto out;
 	}
@@ -993,14 +1004,28 @@ static int nfs_update_inode(struct inode
 			__FUNCTION__, inode->i_sb->s_id, inode->i_ino,
 			atomic_read(&inode->i_count), fattr->valid);
 
-	if (nfsi->fileid != fattr->fileid)
-		goto out_fileid;
+	if (nfsi->fileid != fattr->fileid) {
+		printk(KERN_ERR "NFS: server %s error: fileid changed\n"
+			"fsid %s: expected fileid 0x%Lx, got 0x%Lx\n",
+			NFS_SERVER(inode)->nfs_client->cl_hostname,
+			inode->i_sb->s_id,
+			(long long)nfsi->fileid, (long long)fattr->fileid);
+		goto out_err;
+	}
 
 	/*
 	 * Make sure the inode's type hasn't changed.
 	 */
-	if ((inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT))
-		goto out_changed;
+	if ((inode->i_mode & S_IFMT) != (fattr->mode & S_IFMT)) {
+		/*
+		 * Big trouble! The inode has become a different object.
+		 */
+		printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
+			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
+		goto out_err;
+	}
+
+	nfs_clear_estale(inode);
 
 	server = NFS_SERVER(inode);
 	/* Update the fsid? */
@@ -1109,12 +1134,7 @@ static int nfs_update_inode(struct inode
 	nfsi->cache_validity &= ~NFS_INO_REVAL_FORCED;
 
 	return 0;
- out_changed:
-	/*
-	 * Big trouble! The inode has become a different object.
-	 */
-	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
-			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
+
  out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
@@ -1123,13 +1143,6 @@ static int nfs_update_inode(struct inode
 	 */
 	nfs_invalidate_inode(inode);
 	return -ESTALE;
-
- out_fileid:
-	printk(KERN_ERR "NFS: server %s error: fileid changed\n"
-		"fsid %s: expected fileid 0x%Lx, got 0x%Lx\n",
-		NFS_SERVER(inode)->nfs_client->cl_hostname, inode->i_sb->s_id,
-		(long long)nfsi->fileid, (long long)fattr->fileid);
-	goto out_err;
 }
 
 
--- linux-2.6.24.i686/fs/nfs/dir.c.org
+++ linux-2.6.24.i686/fs/nfs/dir.c
@@ -185,8 +185,9 @@ int nfs_readdir_filler(nfs_readdir_descr
 
  again:
 	timestamp = jiffies;
-	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, desc->entry->cookie, page,
-					  NFS_SERVER(inode)->dtsize, desc->plus);
+	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred,
+			desc->entry->cookie, page,
+			NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
 		if (error == -ENOTSUPP && desc->plus) {
@@ -212,6 +213,7 @@ int nfs_readdir_filler(nfs_readdir_descr
 	return 0;
  error:
 	unlock_page(page);
+	nfs_handle_estale(error, inode);
 	return -EIO;
 }
 
@@ -492,8 +494,10 @@ int uncached_readdir(nfs_readdir_descrip
 		desc->timestamp_valid = 1;
 		if ((status = dir_decode(desc)) == 0)
 			desc->entry->prev_cookie = *desc->dir_cookie;
-	} else
+	} else {
+		nfs_handle_estale(status, inode);
 		status = -EIO;
+	}
 	if (status < 0)
 		goto out_release;
 
@@ -762,7 +766,7 @@ static int nfs_lookup_revalidate(struct 
 	struct inode *dir;
 	struct inode *inode;
 	struct dentry *parent;
-	int error;
+	int error = 0;
 	struct nfs_fh fhandle;
 	struct nfs_fattr fattr;
 
@@ -793,13 +797,16 @@ static int nfs_lookup_revalidate(struct 
 	}
 
 	if (NFS_STALE(inode))
-		goto out_bad;
+		goto out_zap_parent;
 
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
-	if (error)
+	if (error) {
+		if (error == -ESTALE)
+			goto out_zap_parent;
 		goto out_bad;
+	}
 	if (nfs_compare_fh(NFS_FH(inode), &fhandle))
-		goto out_bad;
+		goto out_zap_parent;
 	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
 		goto out_bad;
 
@@ -814,6 +821,7 @@ static int nfs_lookup_revalidate(struct 
 out_zap_parent:
 	nfs_zap_caches(dir);
  out_bad:
+	nfs_handle_estale(error, dir);
 	nfs_mark_for_revalidate(dir);
 	if (inode && S_ISDIR(inode->i_mode)) {
 		/* Purge readdir caches. */
@@ -900,7 +908,10 @@ static struct dentry *nfs_lookup(struct 
 	if (dentry->d_name.len > NFS_SERVER(dir)->namelen)
 		goto out;
 
-	res = ERR_PTR(-ENOMEM);
+	res = ERR_PTR(-ESTALE);
+	if (NFS_STALE(dir))
+		goto out;
+
 	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
 
 	lock_kernel();
@@ -919,9 +930,10 @@ static struct dentry *nfs_lookup(struct 
 	/* Protect against concurrent sillydeletes */
 	nfs_block_sillyrename(parent);
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
-	if (error == -ENOENT)
-		goto no_entry;
 	if (error < 0) {
+		if (error == -ENOENT)
+			goto no_entry;
+		nfs_handle_estale(error, dir);
 		res = ERR_PTR(error);
 		goto out_unblock_sillyrename;
 	}
@@ -1171,8 +1183,10 @@ int nfs_instantiate(struct dentry *dentr
 		goto out;
 	if (fhandle->size == 0) {
 		error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
-		if (error)
+		if (error) {
+			nfs_handle_estale(error, dir);
 			goto out_error;
+		}
 	}
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	if (!(fattr->valid & NFS_ATTR_FATTR)) {
@@ -1224,6 +1238,7 @@ static int nfs_create(struct inode *dir,
 	unlock_kernel();
 	return 0;
 out_err:
+	nfs_handle_estale(error, dir);
 	unlock_kernel();
 	d_drop(dentry);
 	return error;
@@ -1254,6 +1269,7 @@ nfs_mknod(struct inode *dir, struct dent
 	unlock_kernel();
 	return 0;
 out_err:
+	nfs_handle_estale(status, dir);
 	unlock_kernel();
 	d_drop(dentry);
 	return status;
@@ -1280,6 +1296,7 @@ static int nfs_mkdir(struct inode *dir, 
 	unlock_kernel();
 	return 0;
 out_err:
+	nfs_handle_estale(error, dir);
 	d_drop(dentry);
 	unlock_kernel();
 	return error;
@@ -1305,6 +1322,8 @@ static int nfs_rmdir(struct inode *dir, 
 		clear_nlink(dentry->d_inode);
 	else if (error == -ENOENT)
 		nfs_dentry_handle_enoent(dentry);
+	else
+		nfs_handle_estale(error, dir);
 	unlock_kernel();
 
 	return error;
@@ -1374,7 +1393,8 @@ static int nfs_sillyrename(struct inode 
 		d_move(dentry, sdentry);
 		error = nfs_async_unlink(dir, dentry);
  		/* If we return 0 we don't unlink */
-	}
+	} else
+		nfs_handle_estale(error, dir);
 	dput(sdentry);
 out:
 	return error;
@@ -1413,6 +1433,8 @@ static int nfs_safe_remove(struct dentry
 		error = NFS_PROTO(dir)->remove(dir, &dentry->d_name);
 	if (error == -ENOENT)
 		nfs_dentry_handle_enoent(dentry);
+	else
+		nfs_handle_estale(error, dir);
 out:
 	return error;
 }
@@ -1509,6 +1531,7 @@ static int nfs_symlink(struct inode *dir
 		dfprintk(VFS, "NFS: symlink(%s/%ld, %s, %s) error %d\n",
 			dir->i_sb->s_id, dir->i_ino,
 			dentry->d_name.name, symname, error);
+		nfs_handle_estale(error, dir);
 		d_drop(dentry);
 		__free_page(page);
 		unlock_kernel();
@@ -1901,8 +1924,10 @@ static int nfs_do_access(struct inode *i
 	cache.cred = cred;
 	cache.jiffies = jiffies;
 	status = NFS_PROTO(inode)->access(inode, &cache);
-	if (status != 0)
+	if (status != 0) {
+		nfs_handle_estale(status, inode);
 		return status;
+	}
 	nfs_access_add_cache(inode, &cache);
 out:
 	if ((cache.mask & mask) == mask)
--- linux-2.6.24.i686/fs/nfs/nfs4proc.c.org
+++ linux-2.6.24.i686/fs/nfs/nfs4proc.c
@@ -3604,11 +3604,14 @@ int nfs4_setxattr(struct dentry *dentry,
 		size_t buflen, int flags)
 {
 	struct inode *inode = dentry->d_inode;
+	int error;
 
 	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
 		return -EOPNOTSUPP;
 
-	return nfs4_proc_set_acl(inode, buf, buflen);
+	error = nfs4_proc_set_acl(inode, buf, buflen);
+	nfs_handle_estale(error, inode);
+	return error;
 }
 
 /* The getxattr man page suggests returning -ENODATA for unknown attributes,
@@ -3619,11 +3622,14 @@ ssize_t nfs4_getxattr(struct dentry *den
 		size_t buflen)
 {
 	struct inode *inode = dentry->d_inode;
+	int error;
 
 	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
 		return -EOPNOTSUPP;
 
-	return nfs4_proc_get_acl(inode, buf, buflen);
+	error = nfs4_proc_get_acl(inode, buf, buflen);
+	nfs_handle_estale(error, inode);
+	return error;
 }
 
 ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
--- linux-2.6.24.i686/fs/nfs/namespace.c.org
+++ linux-2.6.24.i686/fs/nfs/namespace.c
@@ -115,6 +115,7 @@ static void * nfs_follow_mountpoint(stru
 	err = server->nfs_client->rpc_ops->lookup(parent->d_inode,
 						  &nd->path.dentry->d_name,
 						  &fh, &fattr);
+	nfs_handle_estale(err, parent->d_inode);
 	dput(parent);
 	if (err != 0)
 		goto out_err;
--- linux-2.6.24.i686/fs/nfs/symlink.c.org
+++ linux-2.6.24.i686/fs/nfs/symlink.c
@@ -40,6 +40,7 @@ static int nfs_symlink_filler(struct ino
 	return 0;
 
 error:
+	nfs_handle_estale(error, inode);
 	SetPageError(page);
 	unlock_page(page);
 	return -EIO;
--- linux-2.6.24.i686/fs/nfs/nfs3acl.c.org
+++ linux-2.6.24.i686/fs/nfs/nfs3acl.c
@@ -22,8 +22,10 @@ ssize_t nfs3_listxattr(struct dentry *de
 		} while(0)
 
 	acl = nfs3_proc_getacl(inode, ACL_TYPE_ACCESS);
-	if (IS_ERR(acl))
+	if (IS_ERR(acl)) {
+		nfs_handle_estale(PTR_ERR(acl), inode);
 		return PTR_ERR(acl);
+	}
 	if (acl) {
 		output("system.posix_acl_access");
 		posix_acl_release(acl);
@@ -31,8 +33,10 @@ ssize_t nfs3_listxattr(struct dentry *de
 
 	if (S_ISDIR(inode->i_mode)) {
 		acl = nfs3_proc_getacl(inode, ACL_TYPE_DEFAULT);
-		if (IS_ERR(acl))
+		if (IS_ERR(acl)) {
+			nfs_handle_estale(PTR_ERR(acl), inode);
 			return PTR_ERR(acl);
+		}
 		if (acl) {
 			output("system.posix_acl_default");
 			posix_acl_release(acl);
@@ -61,9 +65,11 @@ ssize_t nfs3_getxattr(struct dentry *den
 		return -EOPNOTSUPP;
 
 	acl = nfs3_proc_getacl(inode, type);
-	if (IS_ERR(acl))
+	if (IS_ERR(acl)) {
+		nfs_handle_estale(PTR_ERR(acl), inode);
 		return PTR_ERR(acl);
-	else if (acl) {
+	}
+	if (acl) {
 		if (type == ACL_TYPE_ACCESS && acl->a_count == 0)
 			error = -ENODATA;
 		else
@@ -92,6 +98,7 @@ int nfs3_setxattr(struct dentry *dentry,
 	acl = posix_acl_from_xattr(value, size);
 	if (IS_ERR(acl))
 		return PTR_ERR(acl);
+
 	error = nfs3_proc_setacl(inode, type, acl);
 	posix_acl_release(acl);
 
@@ -355,16 +362,22 @@ int nfs3_proc_setacl(struct inode *inode
 			case ACL_TYPE_ACCESS:
 				alloc = dfacl = nfs3_proc_getacl(inode,
 						ACL_TYPE_DEFAULT);
-				if (IS_ERR(alloc))
+				if (IS_ERR(alloc)) {
+					nfs_handle_estale(PTR_ERR(alloc),
+							inode);
 					goto fail;
+				}
 				break;
 
 			case ACL_TYPE_DEFAULT:
 				dfacl = acl;
 				alloc = acl = nfs3_proc_getacl(inode,
 						ACL_TYPE_ACCESS);
-				if (IS_ERR(alloc))
+				if (IS_ERR(alloc)) {
+					nfs_handle_estale(PTR_ERR(alloc),
+							inode);
 					goto fail;
+				}
 				break;
 
 			default:
@@ -380,6 +393,7 @@ int nfs3_proc_setacl(struct inode *inode
 	}
 	status = nfs3_proc_setacls(inode, acl, dfacl);
 	posix_acl_release(alloc);
+	nfs_handle_estale(status, inode);
 	return status;
 
 fail:
@@ -395,6 +409,7 @@ int nfs3_proc_set_default_acl(struct ino
 	dfacl = nfs3_proc_getacl(dir, ACL_TYPE_DEFAULT);
 	if (IS_ERR(dfacl)) {
 		error = PTR_ERR(dfacl);
+		nfs_handle_estale(error, dir);
 		return (error == -EOPNOTSUPP) ? 0 : error;
 	}
 	if (!dfacl)
@@ -408,6 +423,7 @@ int nfs3_proc_set_default_acl(struct ino
 		goto out_release_acl;
 	error = nfs3_proc_setacls(inode, acl, S_ISDIR(inode->i_mode) ?
 						      dfacl : NULL);
+	nfs_handle_estale(error, inode);
 out_release_acl:
 	posix_acl_release(acl);
 out_release_dfacl:
--- linux-2.6.24.i686/include/linux/nfs_fs.h.org
+++ linux-2.6.24.i686/include/linux/nfs_fs.h
@@ -259,6 +259,31 @@ static inline void set_nfs_fileid(struct
 	NFS_I(inode)->fileid = fileid;
 }
 
+static inline void nfs_handle_estale(int error, struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+
+	if (error == -ESTALE) {
+		if (!NFS_STALE(inode))
+			set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+		/*
+		 * If a directory is being marked as stale, then
+		 * reset the attribute cache timeout.  This controls
+		 * the duration that the stale condition is believed
+		 * before being verified again with another call to
+		 * the server.
+		 */
+		if (S_ISDIR(inode->i_mode))
+			nfsi->read_cache_jiffies = jiffies;
+	}
+}
+
+static inline void nfs_clear_estale(struct inode *inode)
+{
+	if (NFS_STALE(inode))
+		clear_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
+}
+
 static inline void nfs_mark_for_revalidate(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);

--------------000303090308070402070003--

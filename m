From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: do_IRQ: stack overflow
Date: Mon, 06 Oct 2003 07:57:38 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F8158B2.9070108@RedHat.com>
References: <765B6B38B4D29D498077F8E644E23B7F023C1161@nlhoe2k02.europe.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804050002000904020403"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A6U0J-0007SL-00
	for <nfs@lists.sourceforge.net>; Mon, 06 Oct 2003 04:58:19 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A6U0H-0003vf-QR
	for nfs@lists.sourceforge.net; Mon, 06 Oct 2003 04:58:17 -0700
To: "Kiernan, Michael" <mkiernan@netapp.com>
In-Reply-To: <765B6B38B4D29D498077F8E644E23B7F023C1161@nlhoe2k02.europe.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------040804050002000904020403
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Kiernan, Michael wrote:

>Can anyone help me debug/(fix!) a stack overflow? (see attachment). 
>
>redhat 7.3, dual xeon 2.8GHz
>2.4.20-20.7bigmem, but also occurs with 2.4.18-27.7bigmem and 
>non-bigmem versions. 
>  
>
See if this helps....

SteveD.

--------------040804050002000904020403
Content-Type: text/plain;
 name="linux-2.4.20-nfs-stackoverflow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.20-nfs-stackoverflow.patch"

--- linux-2.4.20/fs/nfs/inode.c.orig	2003-10-06 07:35:33.000000000 -0400
+++ linux-2.4.20/fs/nfs/inode.c	2003-10-06 07:38:35.000000000 -0400
@@ -1139,6 +1139,8 @@ extern int nfs_init_readpagecache(void);
 extern int nfs_destroy_readpagecache(void);
 extern int nfs_init_writepagecache(void);
 extern int nfs_destroy_writepagecache(void);
+extern int nfs_init_diroppagecache(void);
+extern void nfs_destroy_diroppagecache(void);
 
 /*
  * Initialize NFS
@@ -1159,6 +1161,10 @@ static int __init init_nfs_fs(void)
 	if (err)
 		return err;
 
+	err = nfs_init_diroppagecache();
+	if (err)
+		return err;
+
 #ifdef CONFIG_PROC_FS
 	rpc_proc_register(&nfs_rpcstat);
 #endif
@@ -1167,6 +1173,7 @@ static int __init init_nfs_fs(void)
 
 static void __exit exit_nfs_fs(void)
 {
+	nfs_destroy_diroppagecache();
 	nfs_destroy_writepagecache();
 	nfs_destroy_readpagecache();
 	nfs_destroy_nfspagecache();
--- linux-2.4.20/fs/nfs/dir.c.orig	2003-10-06 07:35:31.000000000 -0400
+++ linux-2.4.20/fs/nfs/dir.c	2003-10-06 07:38:35.000000000 -0400
@@ -71,6 +71,51 @@ struct inode_operations nfs_dir_inode_op
 	revalidate:	nfs_revalidate,
 	setattr:	nfs_notify_change,
 };
+static kmem_cache_t *nfs_ddata_cachep;
+
+int nfs_init_diroppagecache(void)
+{
+	nfs_ddata_cachep = kmem_cache_create("nfs_diropt_data",
+					     sizeof(struct nfs_fh) + sizeof(struct nfs_fattr),
+					     0, SLAB_HWCACHE_ALIGN,
+					     NULL, NULL);
+	if (nfs_ddata_cachep == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void nfs_destroy_diroppagecache(void)
+{
+	if (kmem_cache_destroy(nfs_ddata_cachep))
+		printk(KERN_INFO "nfs_diropt_data: not all structures were freed\n");
+}
+static __inline__ int 
+nfs_dirop_alloc(struct nfs_fh **fh, struct nfs_fattr **fattr)
+{
+	void *mem;
+	static int len = sizeof(struct nfs_fh) + sizeof(struct nfs_fattr);
+
+	mem = kmem_cache_alloc(nfs_ddata_cachep, GFP_NOFS);
+	if (mem == NULL)
+		return -ENOMEM;
+
+	memset(mem, 0, len);
+	*fh = (struct nfs_fh *)mem;
+	*fattr = (struct nfs_fattr *) (mem + sizeof(struct nfs_fh));
+
+	return 0;
+}
+static __inline__ void 
+nfs_dirop_free(struct nfs_fh *fh, struct nfs_fattr *fattr)
+{
+	void *mem = ((void *)fh < (void *)fattr ? 
+		(void *)fh : (void *)fattr);
+
+	kmem_cache_free(nfs_ddata_cachep, mem);
+
+	return;
+}
 
 static loff_t nfs_dir_llseek(struct file *file, loff_t offset, int origin)
 {
@@ -373,12 +418,16 @@ static int nfs_readdir(struct file *filp
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
 	struct nfs_entry my_entry;
+	struct nfs_fh   *fh;
+	struct nfs_fattr *fattr;
 	long		res;
 
 	res = nfs_revalidate(dentry);
 	if (res < 0)
 		return res;
 
+	if (nfs_dirop_alloc(&fh, &fattr))
+		return -ENOMEM;
 	/*
 	 * filp->f_pos points to the file offset in the page cache.
 	 * but if the cache has meanwhile been zapped, we need to
@@ -387,6 +436,8 @@ static int nfs_readdir(struct file *filp
 	 */
 	memset(desc, 0, sizeof(*desc));
 	memset(&my_entry, 0, sizeof(my_entry));
+	my_entry.fh = fh;
+	my_entry.fattr = fattr;
 
 	desc->file = filp;
 	desc->target = filp->f_pos;
@@ -414,6 +465,8 @@ static int nfs_readdir(struct file *filp
 			break;
 		}
 	}
+	nfs_dirop_free(fh, fattr);
+
 	if (desc->error < 0)
 		return desc->error;
 	if (res < 0)
@@ -497,8 +550,11 @@ static int nfs_lookup_revalidate(struct 
 	struct inode *dir;
 	struct inode *inode;
 	int error;
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
+	struct nfs_fh *fhandle;
+	struct nfs_fattr *fattr;
+
+	if (nfs_dirop_alloc(&fhandle, &fattr))
+		return 0;
 
 	lock_kernel();
 	dir = dentry->d_parent->d_inode;
@@ -526,17 +582,18 @@ static int nfs_lookup_revalidate(struct 
 	if (NFS_STALE(inode))
 		goto out_bad;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 	if (error)
 		goto out_bad;
-	if (memcmp(NFS_FH(inode), &fhandle, sizeof(struct nfs_fh))!= 0)
+	if (memcmp(NFS_FH(inode), fhandle, sizeof(struct nfs_fh))!= 0)
 		goto out_bad;
-	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
+	if ((error = nfs_refresh_inode(inode, fattr)) != 0)
 		goto out_bad;
 
 	nfs_renew_times(dentry);
  out_valid:
 	unlock_kernel();
+	nfs_dirop_free(fhandle, fattr);
 	return 1;
  out_bad:
 	NFS_CACHEINV(dir);
@@ -550,6 +607,7 @@ static int nfs_lookup_revalidate(struct 
 	}
 	d_drop(dentry);
 	unlock_kernel();
+	nfs_dirop_free(fhandle, fattr);
 	return 0;
 }
 
@@ -596,8 +654,8 @@ static struct dentry *nfs_lookup(struct 
 {
 	struct inode *inode;
 	int error;
-	struct nfs_fh fhandle;
-	struct nfs_fattr fattr;
+	struct nfs_fh *fhandle;
+	struct nfs_fattr *fattr;
 
 	dfprintk(VFS, "NFS: lookup(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
@@ -607,15 +665,17 @@ static struct dentry *nfs_lookup(struct 
 		goto out;
 
 	error = -ENOMEM;
+	if (nfs_dirop_alloc(&fhandle, &fattr))
+		goto out;
 	dentry->d_op = &nfs_dentry_operations;
 
-	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
+	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, fhandle, fattr);
 	inode = NULL;
 	if (error == -ENOENT)
 		goto no_entry;
 	if (!error) {
 		error = -EACCES;
-		inode = nfs_fhget(dentry, &fhandle, &fattr);
+		inode = nfs_fhget(dentry, fhandle, fattr);
 		if (inode) {
 	    no_entry:
 			d_add(dentry, inode);
@@ -624,6 +684,7 @@ static struct dentry *nfs_lookup(struct 
 		nfs_renew_times(dentry);
 	}
 out:
+	nfs_dirop_free(fhandle, fattr);
 	return ERR_PTR(error);
 }
 
@@ -663,13 +724,16 @@ out_err:
 static int nfs_create(struct inode *dir, struct dentry *dentry, int mode)
 {
 	struct iattr attr;
-	struct nfs_fattr fattr;
-	struct nfs_fh fhandle;
+	struct nfs_fattr *fattr;
+	struct nfs_fh *fhandle;
 	int error;
 
 	dfprintk(VFS, "NFS: create(%x/%ld, %s\n",
 		dir->i_dev, dir->i_ino, dentry->d_name.name);
 
+	if (nfs_dirop_alloc(&fhandle, &fattr))
+		return -ENOMEM;
+
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
@@ -681,11 +745,13 @@ static int nfs_create(struct inode *dir,
 	 */
 	nfs_zap_caches(dir);
 	error = NFS_PROTO(dir)->create(dir, &dentry->d_name,
-					 &attr, 0, &fhandle, &fattr);
+					 &attr, 0, fhandle, fattr);
 	if (!error)
-		error = nfs_instantiate(dentry, &fhandle, &fattr);
+		error = nfs_instantiate(dentry, fhandle, fattr);
 	else
 		d_drop(dentry);
+
+	nfs_dirop_free(fhandle, fattr);
 	return error;
 }
 
@@ -695,23 +761,28 @@ static int nfs_create(struct inode *dir,
 static int nfs_mknod(struct inode *dir, struct dentry *dentry, int mode, int rdev)
 {
 	struct iattr attr;
-	struct nfs_fattr fattr;
-	struct nfs_fh fhandle;
+	struct nfs_fattr *fattr;
+	struct nfs_fh *fhandle;
 	int error;
 
 	dfprintk(VFS, "NFS: mknod(%x/%ld, %s\n",
 		dir->i_dev, dir->i_ino, dentry->d_name.name);
 
+	if (nfs_dirop_alloc(&fhandle, &fattr))
+		return -ENOMEM;
+
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
 	nfs_zap_caches(dir);
 	error = NFS_PROTO(dir)->mknod(dir, &dentry->d_name, &attr, rdev,
-					&fhandle, &fattr);
+					fhandle, fattr);
 	if (!error)
-		error = nfs_instantiate(dentry, &fhandle, &fattr);
+		error = nfs_instantiate(dentry, fhandle, fattr);
 	else
 		d_drop(dentry);
+
+	nfs_dirop_free(fhandle, fattr);
 	return error;
 }
 
@@ -721,13 +792,16 @@ static int nfs_mknod(struct inode *dir, 
 static int nfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 {
 	struct iattr attr;
-	struct nfs_fattr fattr;
-	struct nfs_fh fhandle;
+	struct nfs_fattr *fattr;
+	struct nfs_fh *fhandle;
 	int error;
 
 	dfprintk(VFS, "NFS: mkdir(%x/%ld, %s\n",
 		dir->i_dev, dir->i_ino, dentry->d_name.name);
 
+	if (nfs_dirop_alloc(&fhandle, &fattr))
+		return -ENOMEM;
+
 	attr.ia_valid = ATTR_MODE;
 	attr.ia_mode = mode | S_IFDIR;
 
@@ -741,12 +815,14 @@ static int nfs_mkdir(struct inode *dir, 
 	d_drop(dentry);
 #endif
 	nfs_zap_caches(dir);
-	error = NFS_PROTO(dir)->mkdir(dir, &dentry->d_name, &attr, &fhandle,
-					&fattr);
+	error = NFS_PROTO(dir)->mkdir(dir, &dentry->d_name, &attr, fhandle,
+					fattr);
 	if (!error)
-		error = nfs_instantiate(dentry, &fhandle, &fattr);
+		error = nfs_instantiate(dentry, fhandle, fattr);
 	else
 		d_drop(dentry);
+
+	nfs_dirop_free(fhandle, fattr);
 	return error;
 }
 
--- linux-2.4.20/fs/nfs/nfs3xdr.c.orig	2003-10-06 07:35:31.000000000 -0400
+++ linux-2.4.20/fs/nfs/nfs3xdr.c	2003-10-06 07:38:35.000000000 -0400
@@ -625,10 +625,10 @@ nfs3_decode_dirent(u32 *p, struct nfs_en
 	entry->cookie = nfs_transform_cookie64(cookie);
 
 	if (plus) {
-		p = xdr_decode_post_op_attr(p, &entry->fattr);
+		p = xdr_decode_post_op_attr(p, entry->fattr);
 		/* In fact, a post_op_fh3: */
 		if (*p++) {
-			p = xdr_decode_fhandle(p, &entry->fh);
+			p = xdr_decode_fhandle(p, entry->fh);
 			/* Ugh -- server reply was truncated */
 			if (p == NULL) {
 				dprintk("NFS: FH truncated\n");
@@ -638,7 +638,7 @@ nfs3_decode_dirent(u32 *p, struct nfs_en
 		} else {
 			/* If we don't get a file handle, the attrs
 			 * aren't worth a lot. */
-			entry->fattr.valid = 0;
+			entry->fattr->valid = 0;
 		}
 	}
 
--- linux-2.4.20/include/linux/nfs_xdr.h.orig	2002-11-28 18:53:15.000000000 -0500
+++ linux-2.4.20/include/linux/nfs_xdr.h	2003-10-06 07:38:35.000000000 -0400
@@ -109,8 +109,8 @@ struct nfs_entry {
 	const char *		name;
 	unsigned int		len;
 	int			eof;
-	struct nfs_fh		fh;
-	struct nfs_fattr	fattr;
+	struct nfs_fh		*fh;
+	struct nfs_fattr	*fattr;
 };
 
 /*

--------------040804050002000904020403--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

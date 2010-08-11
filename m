Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6790 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932736Ab0HKIjC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Aug 2010 04:39:02 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 3/3] AFS: Implement an autocell mount capability [ver #2]
To: smfrench@gmail.com, torvalds@osdl.org, akpm@linux-foundation.org
Cc: linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Wang Lei <wang840925@gmail.com>, David Howells <dhowells@redhat.com>
Date: Wed, 11 Aug 2010 09:38:04 +0100
Message-ID: <20100811083803.19001.65727.stgit@warthog.procyon.org.uk>
In-Reply-To: <20100811083753.19001.28878.stgit@warthog.procyon.org.uk>
References: <20100811083753.19001.28878.stgit@warthog.procyon.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: wanglei <wang840925@gmail.com>

Implement the ability for the root directory of a mounted AFS filesystem to
accept lookups of arbitrary directory names, to interpet the names as the names
of cells, to look the cell names up in the DNS for AFSDB records and to mount
the root.cell volume of the nominated cell on the pseudo-directory created by
lookup.

This facility is requested by passing:

	-o autocell

to the mountpoint for which this is desired, usually the /afs mount.


To use this facility, a DNS upcall program is required for AFSDB records.  This
can be obtained from:

	http://people.redhat.com/~dhowells/afs/dns.afsdb.c

It should be compiled with -lresolv and -lkeyutils and installed as, say:

	/usr/sbin/dns.afsdb

Then the following line needs to be added to /sbin/request-key.conf:

	create	dns_resolver afsdb:*	*	/usr/sbin/dns.afsdb %k

This can be tested by mounting AFS, say:

	insmod dns_resolver.ko
	insmod af-rxrpc.ko
	insmod kafs.ko rootcell=grand.central.org
	mount -t afs "#grand.central.org:root.cell." /afs -o autocell

and doing:

	ls /afs/grand.central.org/

which should show:

	archive/  cvs/  doc/  local/  project/  service/  software/  user/  www/

if it works.

Signed-off-by: Wang Lei <wang840925@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/cell.c     |   52 +++++++++++++++++++++++---------
 fs/afs/dir.c      |   47 ++++++++++++++++++++++++++++-
 fs/afs/inode.c    |   86 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/afs/internal.h |   11 ++++++-
 fs/afs/mntpt.c    |   78 ++++++++++++++++++++++++++++++++++--------------
 fs/afs/proc.c     |    2 +
 fs/afs/super.c    |   20 ++++++++++--
 7 files changed, 250 insertions(+), 46 deletions(-)

diff --git a/fs/afs/cell.c b/fs/afs/cell.c
index d076588..0d5eead 100644
--- a/fs/afs/cell.c
+++ b/fs/afs/cell.c
@@ -31,21 +31,20 @@ static struct afs_cell *afs_cell_root;
  * allocate a cell record and fill in its name, VL server address list and
  * allocate an anonymous key
  */
-static struct afs_cell *afs_cell_alloc(const char *name, char *vllist)
+static struct afs_cell *afs_cell_alloc(const char *name, unsigned namelen,
+				       char *vllist)
 {
 	struct afs_cell *cell;
 	struct key *key;
-	size_t namelen;
 	char keyname[4 + AFS_MAXCELLNAME + 1], *cp, *dp, *next;
 	char  *dvllist = NULL, *_vllist = NULL;
 	char  delimiter = ':';
 	int ret;
 
-	_enter("%s,%s", name, vllist);
+	_enter("%*.*s,%s", namelen, namelen, name ?: "", vllist);
 
 	BUG_ON(!name); /* TODO: want to look up "this cell" in the cache */
 
-	namelen = strlen(name);
 	if (namelen > AFS_MAXCELLNAME) {
 		_leave(" = -ENAMETOOLONG");
 		return ERR_PTR(-ENAMETOOLONG);
@@ -142,26 +141,29 @@ error:
 }
 
 /*
- * create a cell record
- * - "name" is the name of the cell
- * - "vllist" is a colon separated list of IP addresses in "a.b.c.d" format
+ * afs_cell_crate() - create a cell record
+ * @name:	is the name of the cell.
+ * @namsesz:	is the strlen of the cell name.
+ * @vllist:	is a colon separated list of IP addresses in "a.b.c.d" format.
+ * @retref:	is T to return the cell reference when the cell exists.
  */
-struct afs_cell *afs_cell_create(const char *name, char *vllist)
+struct afs_cell *afs_cell_create(const char *name, unsigned namesz,
+				 char *vllist, bool retref)
 {
 	struct afs_cell *cell;
 	int ret;
 
-	_enter("%s,%s", name, vllist);
+	_enter("%*.*s,%s", namesz, namesz, name ?: "", vllist);
 
 	down_write(&afs_cells_sem);
 	read_lock(&afs_cells_lock);
 	list_for_each_entry(cell, &afs_cells, link) {
-		if (strcasecmp(cell->name, name) == 0)
+		if (strncasecmp(cell->name, name, namesz) == 0)
 			goto duplicate_name;
 	}
 	read_unlock(&afs_cells_lock);
 
-	cell = afs_cell_alloc(name, vllist);
+	cell = afs_cell_alloc(name, namesz, vllist);
 	if (IS_ERR(cell)) {
 		_leave(" = %ld", PTR_ERR(cell));
 		up_write(&afs_cells_sem);
@@ -201,8 +203,18 @@ error:
 	return ERR_PTR(ret);
 
 duplicate_name:
+	if (retref && !IS_ERR(cell))
+		afs_get_cell(cell);
+
 	read_unlock(&afs_cells_lock);
 	up_write(&afs_cells_sem);
+
+	if (retref) {
+		_leave(" = %p", cell);
+		return cell;
+	}
+
+	_leave(" = -EEXIST");
 	return ERR_PTR(-EEXIST);
 }
 
@@ -233,7 +245,7 @@ int afs_cell_init(char *rootcell)
 		*cp++ = 0;
 
 	/* allocate a cell record for the root cell */
-	new_root = afs_cell_create(rootcell, cp);
+	new_root = afs_cell_create(rootcell, strlen(rootcell), cp, false);
 	if (IS_ERR(new_root)) {
 		_leave(" = %ld", PTR_ERR(new_root));
 		return PTR_ERR(new_root);
@@ -253,11 +265,12 @@ int afs_cell_init(char *rootcell)
 /*
  * lookup a cell record
  */
-struct afs_cell *afs_cell_lookup(const char *name, unsigned namesz)
+struct afs_cell *afs_cell_lookup(const char *name, unsigned namesz,
+				 bool dns_cell)
 {
 	struct afs_cell *cell;
 
-	_enter("\"%*.*s\",", namesz, namesz, name ? name : "");
+	_enter("\"%*.*s\",", namesz, namesz, name ?: "");
 
 	down_read(&afs_cells_sem);
 	read_lock(&afs_cells_lock);
@@ -271,6 +284,8 @@ struct afs_cell *afs_cell_lookup(const char *name, unsigned namesz)
 			}
 		}
 		cell = ERR_PTR(-ENOENT);
+		if (dns_cell)
+			goto create_cell;
 	found:
 		;
 	} else {
@@ -293,6 +308,15 @@ struct afs_cell *afs_cell_lookup(const char *name, unsigned namesz)
 	up_read(&afs_cells_sem);
 	_leave(" = %p", cell);
 	return cell;
+
+create_cell:
+	read_unlock(&afs_cells_lock);
+	up_read(&afs_cells_sem);
+
+	cell = afs_cell_create(name, namesz, NULL, true);
+
+	_leave(" = %p", cell);
+	return cell;
 }
 
 #if 0
diff --git a/fs/afs/dir.c b/fs/afs/dir.c
index b42d5cc..0d38c09 100644
--- a/fs/afs/dir.c
+++ b/fs/afs/dir.c
@@ -477,6 +477,40 @@ static int afs_do_lookup(struct inode *dir, struct dentry *dentry,
 }
 
 /*
+ * Try to auto mount the mountpoint with pseudo directory, if the autocell
+ * operation is setted.
+ */
+static struct inode *afs_try_auto_mntpt(
+	int ret, struct dentry *dentry, struct inode *dir, struct key *key,
+	struct afs_fid *fid)
+{
+	const char *devname = dentry->d_name.name;
+	struct afs_vnode *vnode = AFS_FS_I(dir);
+	struct inode *inode;
+
+	_enter("%d, %p{%s}, {%x:%u}, %p",
+	       ret, dentry, devname, vnode->fid.vid, vnode->fid.vnode, key);
+
+	if (ret != -ENOENT ||
+	    !test_bit(AFS_VNODE_AUTOCELL, &vnode->flags))
+		goto out;
+
+	inode = afs_iget_autocell(dir, devname, strlen(devname), key);
+	if (IS_ERR(inode)) {
+		ret = PTR_ERR(inode);
+		goto out;
+	}
+
+	*fid = AFS_FS_I(inode)->fid;
+	_leave("= %p", inode);
+	return inode;
+
+out:
+	_leave("= %d", ret);
+	return ERR_PTR(ret);
+}
+
+/*
  * look up an entry in a directory
  */
 static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
@@ -520,6 +554,13 @@ static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
 
 	ret = afs_do_lookup(dir, dentry, &fid, key);
 	if (ret < 0) {
+		inode = afs_try_auto_mntpt(ret, dentry, dir, key, &fid);
+		if (!IS_ERR(inode)) {
+			key_put(key);
+			goto success;
+		}
+
+		ret = PTR_ERR(inode);
 		key_put(key);
 		if (ret == -ENOENT) {
 			d_add(dentry, NULL);
@@ -539,6 +580,7 @@ static struct dentry *afs_lookup(struct inode *dir, struct dentry *dentry,
 		return ERR_CAST(inode);
 	}
 
+success:
 	dentry->d_op = &afs_fs_dentry_operations;
 
 	d_add(dentry, inode);
@@ -696,8 +738,9 @@ static int afs_d_delete(struct dentry *dentry)
 		goto zap;
 
 	if (dentry->d_inode &&
-	    test_bit(AFS_VNODE_DELETED, &AFS_FS_I(dentry->d_inode)->flags))
-			goto zap;
+	    (test_bit(AFS_VNODE_DELETED,   &AFS_FS_I(dentry->d_inode)->flags) ||
+	     test_bit(AFS_VNODE_PSEUDODIR, &AFS_FS_I(dentry->d_inode)->flags)))
+		goto zap;
 
 	_leave(" = 0 [keep]");
 	return 0;
diff --git a/fs/afs/inode.c b/fs/afs/inode.c
index 320ffef..0747339 100644
--- a/fs/afs/inode.c
+++ b/fs/afs/inode.c
@@ -19,6 +19,8 @@
 #include <linux/fs.h>
 #include <linux/pagemap.h>
 #include <linux/sched.h>
+#include <linux/mount.h>
+#include <linux/namei.h>
 #include "internal.h"
 
 struct afs_iget_data {
@@ -102,6 +104,16 @@ static int afs_iget5_test(struct inode *inode, void *opaque)
 }
 
 /*
+ * iget5() comparator for inode created by autocell operations
+ *
+ * These pseudo inodes don't match anything.
+ */
+static int afs_iget5_autocell_test(struct inode *inode, void *opaque)
+{
+	return 0;
+}
+
+/*
  * iget5() inode initialiser
  */
 static int afs_iget5_set(struct inode *inode, void *opaque)
@@ -118,6 +130,67 @@ static int afs_iget5_set(struct inode *inode, void *opaque)
 }
 
 /*
+ * inode retrieval for autocell
+ */
+struct inode *afs_iget_autocell(struct inode *dir, const char *dev_name,
+				int namesz, struct key *key)
+{
+	struct afs_iget_data data;
+	struct afs_super_info *as;
+	struct afs_vnode *vnode;
+	struct super_block *sb;
+	struct inode *inode;
+	static atomic_t afs_autocell_ino;
+
+	_enter("{%x:%u},%*.*s,",
+	       AFS_FS_I(dir)->fid.vid, AFS_FS_I(dir)->fid.vnode,
+	       namesz, namesz, dev_name ?: "");
+
+	sb = dir->i_sb;
+	as = sb->s_fs_info;
+	data.volume = as->volume;
+	data.fid.vid = as->volume->vid;
+	data.fid.unique = 0;
+	data.fid.vnode = 0;
+
+	inode = iget5_locked(sb, atomic_inc_return(&afs_autocell_ino),
+			     afs_iget5_autocell_test, afs_iget5_set,
+			     &data);
+	if (!inode) {
+		_leave(" = -ENOMEM");
+		return ERR_PTR(-ENOMEM);
+	}
+
+	_debug("GOT INODE %p { ino=%lu, vl=%x, vn=%x, u=%x }",
+	       inode, inode->i_ino, data.fid.vid, data.fid.vnode,
+	       data.fid.unique);
+
+	vnode = AFS_FS_I(inode);
+
+	/* there shouldn't be an existing inode */
+	BUG_ON(!(inode->i_state & I_NEW));
+
+	inode->i_size		= 0;
+	inode->i_mode		= S_IFDIR | S_IRUGO | S_IXUGO;
+	inode->i_op		= &afs_autocell_inode_operations;
+	inode->i_nlink		= 2;
+	inode->i_uid		= 0;
+	inode->i_gid		= 0;
+	inode->i_ctime.tv_sec	= get_seconds();
+	inode->i_ctime.tv_nsec	= 0;
+	inode->i_atime		= inode->i_mtime = inode->i_ctime;
+	inode->i_blocks		= 0;
+	inode->i_version	= 0;
+	inode->i_generation	= 0;
+
+	set_bit(AFS_VNODE_PSEUDODIR, &vnode->flags);
+	inode->i_flags |= S_NOATIME;
+	unlock_new_inode(inode);
+	_leave(" = %p", inode);
+	return inode;
+}
+
+/*
  * inode retrieval
  */
 struct inode *afs_iget(struct super_block *sb, struct key *key,
@@ -314,6 +387,19 @@ int afs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 }
 
 /*
+ * discard an AFS inode
+ */
+int afs_drop_inode(struct inode *inode)
+{
+	_enter("");
+
+	if (test_bit(AFS_VNODE_PSEUDODIR, &AFS_FS_I(inode)->flags))
+		return generic_delete_inode(inode);
+	else
+		return generic_drop_inode(inode);
+}
+
+/*
  * clear an AFS inode
  */
 void afs_evict_inode(struct inode *inode)
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index 8679089..ce12a2b 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -42,6 +42,7 @@ typedef enum {
 struct afs_mount_params {
 	bool			rwpath;		/* T if the parent should be considered R/W */
 	bool			force;		/* T to force cell type */
+	bool			autocell;	/* T if set auto mount operation */
 	afs_voltype_t		type;		/* type of volume requested */
 	int			volnamesz;	/* size of volume name */
 	const char		*volname;	/* name of volume to mount */
@@ -358,6 +359,8 @@ struct afs_vnode {
 #define AFS_VNODE_READLOCKED	7		/* set if vnode is read-locked on the server */
 #define AFS_VNODE_WRITELOCKED	8		/* set if vnode is write-locked on the server */
 #define AFS_VNODE_UNLOCKING	9		/* set if vnode is being unlocked on the server */
+#define AFS_VNODE_AUTOCELL	10		/* set if Vnode is an auto mount point */
+#define AFS_VNODE_PSEUDODIR	11		/* set if Vnode is a pseudo directory */
 
 	long			acl_order;	/* ACL check count (callback break count) */
 
@@ -468,8 +471,8 @@ extern struct list_head afs_proc_cells;
 
 #define afs_get_cell(C) do { atomic_inc(&(C)->usage); } while(0)
 extern int afs_cell_init(char *);
-extern struct afs_cell *afs_cell_create(const char *, char *);
-extern struct afs_cell *afs_cell_lookup(const char *, unsigned);
+extern struct afs_cell *afs_cell_create(const char *, unsigned, char *, bool);
+extern struct afs_cell *afs_cell_lookup(const char *, unsigned, bool);
 extern struct afs_cell *afs_grab_cell(struct afs_cell *);
 extern void afs_put_cell(struct afs_cell *);
 extern void afs_cell_purge(void);
@@ -558,6 +561,8 @@ extern int afs_fs_release_lock(struct afs_server *, struct key *,
 /*
  * inode.c
  */
+extern struct inode *afs_iget_autocell(struct inode *, const char *, int,
+				       struct key *);
 extern struct inode *afs_iget(struct super_block *, struct key *,
 			      struct afs_fid *, struct afs_file_status *,
 			      struct afs_callback *);
@@ -566,6 +571,7 @@ extern int afs_validate(struct afs_vnode *, struct key *);
 extern int afs_getattr(struct vfsmount *, struct dentry *, struct kstat *);
 extern int afs_setattr(struct dentry *, struct iattr *);
 extern void afs_evict_inode(struct inode *);
+extern int afs_drop_inode(struct inode *);
 
 /*
  * main.c
@@ -581,6 +587,7 @@ extern int afs_abort_to_error(u32);
  * mntpt.c
  */
 extern const struct inode_operations afs_mntpt_inode_operations;
+extern const struct inode_operations afs_autocell_inode_operations;
 extern const struct file_operations afs_mntpt_file_operations;
 
 extern int afs_mntpt_check_symlink(struct afs_vnode *, struct key *);
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index a9e2303..6d55268 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -38,6 +38,11 @@ const struct inode_operations afs_mntpt_inode_operations = {
 	.getattr	= afs_getattr,
 };
 
+const struct inode_operations afs_autocell_inode_operations = {
+	.follow_link	= afs_mntpt_follow_link,
+	.getattr	= afs_getattr,
+};
+
 static LIST_HEAD(afs_vfsmounts);
 static DECLARE_DELAYED_WORK(afs_mntpt_expiry_timer, afs_mntpt_expiry_timed_out);
 
@@ -136,20 +141,16 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 {
 	struct afs_super_info *super;
 	struct vfsmount *mnt;
+	struct afs_vnode *vnode;
 	struct page *page;
-	size_t size;
-	char *buf, *devname, *options;
+	char *devname, *options;
+	bool rwpath = false;
 	int ret;
 
 	_enter("{%s}", mntpt->d_name.name);
 
 	BUG_ON(!mntpt->d_inode);
 
-	ret = -EINVAL;
-	size = mntpt->d_inode->i_size;
-	if (size > PAGE_SIZE - 1)
-		goto error_no_devname;
-
 	ret = -ENOMEM;
 	devname = (char *) get_zeroed_page(GFP_KERNEL);
 	if (!devname)
@@ -159,28 +160,59 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 	if (!options)
 		goto error_no_options;
 
-	/* read the contents of the AFS special symlink */
-	page = read_mapping_page(mntpt->d_inode->i_mapping, 0, NULL);
-	if (IS_ERR(page)) {
-		ret = PTR_ERR(page);
-		goto error_no_page;
+	vnode = AFS_FS_I(mntpt->d_inode);
+	if (test_bit(AFS_VNODE_PSEUDODIR, &vnode->flags)) {
+		/* if the directory is a pseudo directory, use the d_name */
+		static const char afs_root_cell[] = ":root.cell.";
+		unsigned size = mntpt->d_name.len;
+
+		ret = -ENOENT;
+		if (size < 2 || size > AFS_MAXCELLNAME)
+			goto error_no_page;
+
+		if (mntpt->d_name.name[0] == '.') {
+			devname[0] = '#';
+			memcpy(devname + 1, mntpt->d_name.name, size - 1);
+			memcpy(devname + size, afs_root_cell,
+			       sizeof(afs_root_cell));
+			rwpath = true;
+		} else {
+			devname[0] = '%';
+			memcpy(devname + 1, mntpt->d_name.name, size);
+			memcpy(devname + size + 1, afs_root_cell,
+			       sizeof(afs_root_cell));
+		}
+	} else {
+		/* read the contents of the AFS special symlink */
+		loff_t size = i_size_read(mntpt->d_inode);
+		char *buf;
+
+		ret = -EINVAL;
+		if (size > PAGE_SIZE - 1)
+			goto error_no_page;
+
+		page = read_mapping_page(mntpt->d_inode->i_mapping, 0, NULL);
+		if (IS_ERR(page)) {
+			ret = PTR_ERR(page);
+			goto error_no_page;
+		}
+
+		ret = -EIO;
+		if (PageError(page))
+			goto error;
+
+		buf = kmap_atomic(page, KM_USER0);
+		memcpy(devname, buf, size);
+		kunmap_atomic(buf, KM_USER0);
+		page_cache_release(page);
+		page = NULL;
 	}
 
-	ret = -EIO;
-	if (PageError(page))
-		goto error;
-
-	buf = kmap_atomic(page, KM_USER0);
-	memcpy(devname, buf, size);
-	kunmap_atomic(buf, KM_USER0);
-	page_cache_release(page);
-	page = NULL;
-
 	/* work out what options we want */
 	super = AFS_FS_S(mntpt->d_sb);
 	memcpy(options, "cell=", 5);
 	strcpy(options + 5, super->volume->cell->name);
-	if (super->volume->type == AFSVL_RWVOL)
+	if (super->volume->type == AFSVL_RWVOL || rwpath)
 		strcat(options, ",rwpath");
 
 	/* try and do the mount */
diff --git a/fs/afs/proc.c b/fs/afs/proc.c
index 852739d..096b23f 100644
--- a/fs/afs/proc.c
+++ b/fs/afs/proc.c
@@ -294,7 +294,7 @@ static ssize_t afs_proc_cells_write(struct file *file, const char __user *buf,
 	if (strcmp(kbuf, "add") == 0) {
 		struct afs_cell *cell;
 
-		cell = afs_cell_create(name, args);
+		cell = afs_cell_create(name, strlen(name), args, false);
 		if (IS_ERR(cell)) {
 			ret = PTR_ERR(cell);
 			goto done;
diff --git a/fs/afs/super.c b/fs/afs/super.c
index 9cf80f0..77e1e5a 100644
--- a/fs/afs/super.c
+++ b/fs/afs/super.c
@@ -16,6 +16,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
+#include <linux/mount.h>
 #include <linux/init.h>
 #include <linux/slab.h>
 #include <linux/smp_lock.h>
@@ -48,6 +49,7 @@ struct file_system_type afs_fs_type = {
 static const struct super_operations afs_super_ops = {
 	.statfs		= afs_statfs,
 	.alloc_inode	= afs_alloc_inode,
+	.drop_inode	= afs_drop_inode,
 	.destroy_inode	= afs_destroy_inode,
 	.evict_inode	= afs_evict_inode,
 	.put_super	= afs_put_super,
@@ -62,12 +64,14 @@ enum {
 	afs_opt_cell,
 	afs_opt_rwpath,
 	afs_opt_vol,
+	afs_opt_autocell,
 };
 
 static const match_table_t afs_options_list = {
 	{ afs_opt_cell,		"cell=%s"	},
 	{ afs_opt_rwpath,	"rwpath"	},
 	{ afs_opt_vol,		"vol=%s"	},
+	{ afs_opt_autocell,	"autocell"	},
 	{ afs_no_opt,		NULL		},
 };
 
@@ -151,7 +155,8 @@ static int afs_parse_options(struct afs_mount_params *params,
 		switch (token) {
 		case afs_opt_cell:
 			cell = afs_cell_lookup(args[0].from,
-					       args[0].to - args[0].from);
+					       args[0].to - args[0].from,
+					       false);
 			if (IS_ERR(cell))
 				return PTR_ERR(cell);
 			afs_put_cell(params->cell);
@@ -166,6 +171,10 @@ static int afs_parse_options(struct afs_mount_params *params,
 			*devname = args[0].from;
 			break;
 
+		case afs_opt_autocell:
+			params->autocell = 1;
+			break;
+
 		default:
 			printk(KERN_ERR "kAFS:"
 			       " Unknown or invalid mount option: '%s'\n", p);
@@ -252,10 +261,10 @@ static int afs_parse_device_name(struct afs_mount_params *params,
 
 	/* lookup the cell record */
 	if (cellname || !params->cell) {
-		cell = afs_cell_lookup(cellname, cellnamesz);
+		cell = afs_cell_lookup(cellname, cellnamesz, true);
 		if (IS_ERR(cell)) {
-			printk(KERN_ERR "kAFS: unable to lookup cell '%s'\n",
-			       cellname ?: "");
+			printk(KERN_ERR "kAFS: unable to lookup cell '%*.*s'\n",
+			       cellnamesz, cellnamesz, cellname ?: "");
 			return PTR_ERR(cell);
 		}
 		afs_put_cell(params->cell);
@@ -321,6 +330,9 @@ static int afs_fill_super(struct super_block *sb, void *data)
 	if (IS_ERR(inode))
 		goto error_inode;
 
+	if (params->autocell)
+		set_bit(AFS_VNODE_AUTOCELL, &AFS_FS_I(inode)->flags);
+
 	ret = -ENOMEM;
 	root = d_alloc_root(inode);
 	if (!root)


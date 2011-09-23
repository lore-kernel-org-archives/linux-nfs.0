Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59760 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750930Ab1IWQLC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2011 12:11:02 -0400
Received: by fxe4 with SMTP id 4so3963221fxe.19
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2011 09:11:00 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: David Howells <dhowells@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
	<1316747758.3346.89.camel@perseus.themaw.net>
	<20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
	<1316707443.3346.44.camel@perseus.themaw.net>
	<CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
	<1316709935.3346.48.camel@perseus.themaw.net>
	<20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
	<20110922144453.6cf53a25@barsoom.rdu.redhat.com>
	<1316719228.3968.14.camel@lade.trondhjem.org>
	<CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
	<CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
	<21772.1316774025@redhat.com>
	<1316788444.14812.10.camel@lade.trondhjem.org>
	<29743.1316791138@redhat.com>
Date: Fri, 23 Sep 2011 18:10:31 +0200
In-Reply-To: <29743.1316791138@redhat.com> (David Howells's message of "Fri,
	23 Sep 2011 16:18:58 +0100")
Message-ID: <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

David Howells <dhowells@redhat.com> writes:

>> Get a grip, people. Stop over-analyzing things. Stop bothering to
>> mention what Solaris does, when the *MUCH* bigger issue is what
>> *Linux* has done for years and years.
>
> So the word is Linux may not change it's behaviour in this regard from what
> existed prior to the d_automount patch, period?

You can change behavior if it won't cause regressions.  So fix userspace
first, introduce change afterwards.

>> Stop saying "we'll revert Miklos patch" in the same sentence where you
>> then seem to not even understand that the *original* behavior was the
>> one that Miklos patch re-introduced.
>
> Miklos's patch did *NOT* re-introduce the original behaviour.  It introduced a
> third state.  It merely moved the regression and brought about a more serious
> one.

Yes, and there have been lots of proposals on how to fix it.  There just
doesn't seem to be a consensus.

I suggest that we first restore the original behavior for all
filesystems.  And it doesn't mean all the d_automount infrastructure has
to be thrown out.  A really simple fix is to pass the lookup flags (or
some derived automount flags) to d_automount and fix up the very few
instances to reflect the old semantics.  Untested patch attached.

Thanks,
Miklos


diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 6533807..5fe8124 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -19,7 +19,7 @@ prototypes:
 	void (*d_release)(struct dentry *);
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)((struct dentry *dentry, char *buffer, int buflen);
-	struct vfsmount *(*d_automount)(struct path *path);
+	struct vfsmount *(*d_automount)(struct path *path, int);
 	int (*d_manage)(struct dentry *, bool);
 
 locking rules:
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 52d8fb8..15e6a50 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -894,7 +894,7 @@ struct dentry_operations {
 	void (*d_release)(struct dentry *);
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)(struct dentry *, char *, int);
-	struct vfsmount *(*d_automount)(struct path *);
+	struct vfsmount *(*d_automount)(struct path *, int);
 	int (*d_manage)(struct dentry *, bool);
 };
 
diff --git a/fs/afs/internal.h b/fs/afs/internal.h
index d2b0888..e687963 100644
--- a/fs/afs/internal.h
+++ b/fs/afs/internal.h
@@ -592,7 +592,7 @@ extern const struct inode_operations afs_mntpt_inode_operations;
 extern const struct inode_operations afs_autocell_inode_operations;
 extern const struct file_operations afs_mntpt_file_operations;
 
-extern struct vfsmount *afs_d_automount(struct path *);
+extern struct vfsmount *afs_d_automount(struct path *, int);
 extern int afs_mntpt_check_symlink(struct afs_vnode *, struct key *);
 extern void afs_mntpt_kill_timer(void);
 
diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index aa59184..aba1c56 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -238,12 +238,19 @@ error_no_devname:
 /*
  * handle an automount point
  */
-struct vfsmount *afs_d_automount(struct path *path)
+struct vfsmount *afs_d_automount(struct path *path, int lookup_flags)
 {
 	struct vfsmount *newmnt;
 
 	_enter("{%s,%s}", path->mnt->mnt_devname, path->dentry->d_name.name);
 
+	/*
+	 * We don't want to mount if someone's just doing an lstat - unless
+	 * they're stat'ing a directory and appended a '/' to the name.
+	 */
+	if (!(lookup_flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY | LOOKUP_FOLLOW)))
+		return ERR_PTR(-EISDIR);
+
 	newmnt = afs_mntpt_do_automount(path->dentry);
 	if (IS_ERR(newmnt))
 		return newmnt;
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index f55ae23..5335e08 100644
--- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -322,7 +322,7 @@ static struct dentry *autofs4_mountpoint_changed(struct path *path)
 	return path->dentry;
 }
 
-static struct vfsmount *autofs4_d_automount(struct path *path)
+static struct vfsmount *autofs4_d_automount(struct path *path, int lookup_flags)
 {
 	struct dentry *dentry = path->dentry;
 	struct autofs_sb_info *sbi = autofs4_sbi(dentry->d_sb);
@@ -332,6 +332,22 @@ static struct vfsmount *autofs4_d_automount(struct path *path)
 	DPRINTK("dentry=%p %.*s",
 		dentry, dentry->d_name.len, dentry->d_name.name);
 
+	/* We don't want to mount if someone's just doing a stat -
+	 * unless they're stat'ing a directory and appended a '/' to
+	 * the name.
+	 *
+	 * We do, however, want to mount if someone wants to open or
+	 * create a file of any type under the mountpoint, wants to
+	 * traverse through the mountpoint or wants to open the
+	 * mounted directory.  Also, autofs may mark negative dentries
+	 * as being automount points.  These will need the attentions
+	 * of the daemon to instantiate them before they can be used.
+	 */
+	if (!(lookup_flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
+			      LOOKUP_OPEN | LOOKUP_CREATE)) &&
+	    path->dentry->d_inode)
+		return ERR_PTR(-EISDIR);
+
 	/* The daemon never triggers a mount. */
 	if (autofs4_oz_mode(sbi))
 		return NULL;
diff --git a/fs/cifs/cifs_dfs_ref.c b/fs/cifs/cifs_dfs_ref.c
index 6873bb6..2ad1dcb 100644
--- a/fs/cifs/cifs_dfs_ref.c
+++ b/fs/cifs/cifs_dfs_ref.c
@@ -347,12 +347,19 @@ cdda_exit:
 /*
  * Attempt to automount the referral
  */
-struct vfsmount *cifs_dfs_d_automount(struct path *path)
+struct vfsmount *cifs_dfs_d_automount(struct path *path, int lookup_flags)
 {
 	struct vfsmount *newmnt;
 
 	cFYI(1, "in %s", __func__);
 
+	/*
+	 * We don't want to mount if someone's just doing an lstat - unless
+	 * they're stat'ing a directory and appended a '/' to the name.
+	 */
+	if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY | LOOKUP_FOLLOW)))
+		return ERR_PTR(-EISDIR);
+
 	newmnt = cifs_dfs_do_automount(path->dentry);
 	if (IS_ERR(newmnt)) {
 		cFYI(1, "leaving %s [automount failed]" , __func__);
diff --git a/fs/cifs/cifsfs.h b/fs/cifs/cifsfs.h
index 95da802..0cd1286 100644
--- a/fs/cifs/cifsfs.h
+++ b/fs/cifs/cifsfs.h
@@ -101,7 +101,7 @@ extern const struct dentry_operations cifs_dentry_ops;
 extern const struct dentry_operations cifs_ci_dentry_ops;
 
 #ifdef CONFIG_CIFS_DFS_UPCALL
-extern struct vfsmount *cifs_dfs_d_automount(struct path *path);
+extern struct vfsmount *cifs_dfs_d_automount(struct path *path, int lookup_flags);
 #else
 #define cifs_dfs_d_automount NULL
 #endif
diff --git a/fs/namei.c b/fs/namei.c
index f478836..a637893 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -727,27 +727,11 @@ static int follow_automount(struct path *path, unsigned flags,
 	if ((flags & LOOKUP_NO_AUTOMOUNT) && !(flags & LOOKUP_PARENT))
 		return -EISDIR; /* we actually want to stop here */
 
-	/* We don't want to mount if someone's just doing a stat -
-	 * unless they're stat'ing a directory and appended a '/' to
-	 * the name.
-	 *
-	 * We do, however, want to mount if someone wants to open or
-	 * create a file of any type under the mountpoint, wants to
-	 * traverse through the mountpoint or wants to open the
-	 * mounted directory.  Also, autofs may mark negative dentries
-	 * as being automount points.  These will need the attentions
-	 * of the daemon to instantiate them before they can be used.
-	 */
-	if (!(flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY |
-		     LOOKUP_OPEN | LOOKUP_CREATE)) &&
-	    path->dentry->d_inode)
-		return -EISDIR;
-
 	current->total_link_count++;
 	if (current->total_link_count >= 40)
 		return -ELOOP;
 
-	mnt = path->dentry->d_op->d_automount(path);
+	mnt = path->dentry->d_op->d_automount(path, flags);
 	if (IS_ERR(mnt)) {
 		/*
 		 * The filesystem is allowed to return -EISDIR here to indicate
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index ab12913..904779f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -276,7 +276,7 @@ extern void nfs_sb_deactive(struct super_block *sb);
 /* namespace.c */
 extern char *nfs_path(char **p, struct dentry *dentry,
 		      char *buffer, ssize_t buflen);
-extern struct vfsmount *nfs_d_automount(struct path *path);
+extern struct vfsmount *nfs_d_automount(struct path *path, int lookup_flags);
 #ifdef CONFIG_NFS_V4
 rpc_authflavor_t nfs_find_best_sec(struct nfs4_secinfo_flavors *);
 #endif
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 8102391..0c0ef6a 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -223,7 +223,7 @@ static inline int nfs_lookup_with_sec(struct nfs_server *server,
  * situation, and that different filesystems may want to use
  * different security flavours.
  */
-struct vfsmount *nfs_d_automount(struct path *path)
+struct vfsmount *nfs_d_automount(struct path *path, int lookup_flags)
 {
 	struct vfsmount *mnt;
 	struct nfs_server *server = NFS_SERVER(path->dentry->d_inode);
@@ -235,6 +235,14 @@ struct vfsmount *nfs_d_automount(struct path *path)
 
 	dprintk("--> nfs_d_automount()\n");
 
+	/*
+	 * We don't want to mount if someone's just doing an lstat - unless
+	 * they're stat'ing a directory and appended a '/' to the name.
+	 */
+	mnt = ERR_PTR(-EISDIR);
+	if (!(lookup_flags & (LOOKUP_PARENT | LOOKUP_DIRECTORY | LOOKUP_FOLLOW)))
+		goto out_nofree;
+
 	mnt = ERR_PTR(-ESTALE);
 	if (IS_ROOT(path->dentry))
 		goto out_nofree;
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index 62157c0..deeb5b2 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -167,7 +167,7 @@ struct dentry_operations {
 	void (*d_release)(struct dentry *);
 	void (*d_iput)(struct dentry *, struct inode *);
 	char *(*d_dname)(struct dentry *, char *, int);
-	struct vfsmount *(*d_automount)(struct path *);
+	struct vfsmount *(*d_automount)(struct path *, int);
 	int (*d_manage)(struct dentry *, bool);
 } ____cacheline_aligned;
 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34753 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750771AbdAYOwy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2017 09:52:54 -0500
Received: by mail-io0-f173.google.com with SMTP id l66so15219732ioi.1
        for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2017 06:52:54 -0800 (PST)
Date: Wed, 25 Jan 2017 08:52:51 -0600
From: Seth Forshee <seth.forshee@canonical.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "ebiederm@xmission.com" <ebiederm@xmission.com>
Cc: Steve French <sfrench@primarydata.com>,
        "dhowells@redhat.com" <dhowells@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: Use current_real_cred() when looking up rpc
 credentials
Message-ID: <20170125145251.GB51023@ubuntu-hedt>
References: <1481842899.11785.1.camel@primarydata.com>
 <20161216130609.GA124240@ubuntu-hedt>
 <20170110145504.GH52661@ubuntu-hedt>
 <87ziiyfntm.fsf@xmission.com>
 <20170124151745.GA114560@ubuntu-hedt>
 <87efzsdq5b.fsf@xmission.com>
 <87inp4rqaj.fsf@xmission.com>
 <1485301593.36478.2.camel@primarydata.com>
 <87y3y0ko5s.fsf@xmission.com>
 <1485303265.36478.7.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1485303265.36478.7.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2017 at 12:14:26AM +0000, Trond Myklebust wrote:
> Adding David Howells and Steve French as I believe both AFS and CIFS
> have the exact same requirements and NFS here.
> 
> On Wed, 2017-01-25 at 12:56 +1300, Eric W. Biederman wrote:
> > Trond Myklebust <trondmy@primarydata.com> writes:
> > 
> > > On Wed, 2017-01-25 at 12:28 +1300, Eric W. Biederman wrote:
> > > > With respect to nfs and automounts.
> > > > 
> > > > Does NFS have different automount behavior based on the user
> > > > performing the automount?
> > > > 
> > > > If NFS does not have different automount behavior depending on
> > > > the
> > > > user
> > > > we just use the creds of the original mounter of NFS?
> > > > 
> > > > If NFS does have different automount behavior depending on the
> > > > user
> > > > (ouch!) we need to go through the call path and see where it
> > > > makes
> > > > sense to over ride things and where it does not.
> > > 
> > > The reason why the NFS client creates a mountpoint is because on
> > > entering a directory, it detects that there is either a similar
> > > mountpoint on the server, or there is a referral (which acts sort
> > > of
> > > like a symlink, except it points to a path on one or more different
> > > NFS
> > > servers).
> > > Without that mountpoint, most things would work, but the user would
> > > end
> > > up seeing nasty non-posix features like duplicate inode numbers.
> > > 
> > > We do not want to use any creds other than user creds here, because
> > > as
> > > far as the security model is concerned, the process is just
> > > crossing
> > > into an existing directory.
> > 
> > But sget needs different creds.
> > 
> > Because the user who authorizes the mounting of the filesystem is
> > different than the user who is crossing into the new filesystem.
> > 
> > The local system now cares about that distinction even if the nfs
> > server
> > does not.
> 
> Why? The filesystem is already mounted. We're creating a new
> mountpoint, but we could equally well just say 'sod that' and create an
> ordinary directory. The penalty would be aforementioned non-posix
> weirdness.
> 
> > 
> > > > Seth the fundamental problem with your patch was that you were
> > > > patching
> > > > a location that is used for more just mounts.
> > > > 
> > > > I am strongly wishing that we could just change follow_automount
> > > > from:
> > > > 
> > > > 
> > > > 	old_cred = override_creds(&init_cred);
> > > > 	mnt = path->dentry->d_op->d_automount(path);
> > > > 	revert_creds(old_cred);
> > > > 
> > > > to:
> > > > 
> > > > 	old_cred = override_creds(path->mnt->mnt_sb->s_cred);
> > > > 	mnt = path->dentry->d_op->d_automount(path);
> > > > 	revert_creds(old_cred);
> > > > 
> > > > And all will be well with nfs.  That does remain possible.
> > > 
> > > No. That would break permissions checking. See above.
> > 
> > Then we need to look much harder at the permission checking
> > model of d_automount because we need to permission check against
> > both sets of creds.

How about something like this? Essentially, stash the creds used at
mount time in the super block, then create a vfs_kern_automount()
function which overrides the currend creds then calls vfs_kern_mount().

Only compile tested so far, and probably it should be split up into
several patches.

diff --git a/fs/afs/mntpt.c b/fs/afs/mntpt.c
index 81dd075356b9..4455e64610d3 100644
--- a/fs/afs/mntpt.c
+++ b/fs/afs/mntpt.c
@@ -202,7 +202,7 @@ static struct vfsmount *afs_mntpt_do_automount(struct dentry *mntpt)
 
 	/* try and do the mount */
 	_debug("--- attempting mount %s -o %s ---", devname, options);
-	mnt = vfs_kern_mount(&afs_fs_type, 0, devname, options);
+	mnt = vfs_kern_automount(mntpt, &afs_fs_type, 0, devname, options);
 	_debug("--- mount result %p ---", mnt);
 
 	free_page((unsigned long) devname);
diff --git a/fs/cifs/cifs_dfs_ref.c b/fs/cifs/cifs_dfs_ref.c
index ec9dbbcca3b9..d378f88e8630 100644
--- a/fs/cifs/cifs_dfs_ref.c
+++ b/fs/cifs/cifs_dfs_ref.c
@@ -245,9 +245,10 @@ char *cifs_compose_mount_options(const char *sb_mountdata,
  * @fullpath:		full path in UNC format
  * @ref:		server's referral
  */
-static struct vfsmount *cifs_dfs_do_refmount(struct cifs_sb_info *cifs_sb,
+static struct vfsmount *cifs_dfs_do_refmount(struct dentry *mntpt,
 		const char *fullpath, const struct dfs_info3_param *ref)
 {
+	struct cifs_sb_info *cifs_sb = CIFS_SB(mntpt->d_sb);
 	struct vfsmount *mnt;
 	char *mountdata;
 	char *devname = NULL;
@@ -259,7 +260,7 @@ static struct vfsmount *cifs_dfs_do_refmount(struct cifs_sb_info *cifs_sb,
 	if (IS_ERR(mountdata))
 		return (struct vfsmount *)mountdata;
 
-	mnt = vfs_kern_mount(&cifs_fs_type, 0, devname, mountdata);
+	mnt = vfs_kern_automount(mntpt, &cifs_fs_type, 0, devname, mountdata);
 	kfree(mountdata);
 	kfree(devname);
 	return mnt;
@@ -334,7 +335,7 @@ static struct vfsmount *cifs_dfs_do_automount(struct dentry *mntpt)
 			mnt = ERR_PTR(-EINVAL);
 			break;
 		}
-		mnt = cifs_dfs_do_refmount(cifs_sb,
+		mnt = cifs_dfs_do_refmount(mntpt,
 				full_path, referrals + i);
 		cifs_dbg(FYI, "%s: cifs_dfs_do_refmount:%s , mnt:%p\n",
 			 __func__, referrals[i].node_name, mnt);
diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
index f17fcf89e18e..d45f131af869 100644
--- a/fs/debugfs/inode.c
+++ b/fs/debugfs/inode.c
@@ -187,9 +187,9 @@ static const struct super_operations debugfs_super_operations = {
 
 static struct vfsmount *debugfs_automount(struct path *path)
 {
-	struct vfsmount *(*f)(void *);
-	f = (struct vfsmount *(*)(void *))path->dentry->d_fsdata;
-	return f(d_inode(path->dentry)->i_private);
+	struct vfsmount *(*f)(struct dentry *, void *);
+	f = (struct vfsmount *(*)(struct dentry *, void *))path->dentry->d_fsdata;
+	return f(path->dentry, d_inode(path->dentry)->i_private);
 }
 
 static const struct dentry_operations debugfs_dops = {
@@ -504,7 +504,7 @@ EXPORT_SYMBOL_GPL(debugfs_create_dir);
  */
 struct dentry *debugfs_create_automount(const char *name,
 					struct dentry *parent,
-					struct vfsmount *(*f)(void *),
+					struct vfsmount *(*f)(struct dentry *, void *),
 					void *data)
 {
 	struct dentry *dentry = start_creating(name, parent);
diff --git a/fs/namespace.c b/fs/namespace.c
index 487ba30bb5c6..da7e6dfa56cb 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -989,6 +989,21 @@ vfs_kern_mount(struct file_system_type *type, int flags, const char *name, void
 }
 EXPORT_SYMBOL_GPL(vfs_kern_mount);
 
+struct vfsmount *
+vfs_kern_automount(struct dentry *dentry, struct file_system_type *type,
+		   int flags, const char *name, void *data)
+{
+	const struct cred *old_cred;
+	struct vfsmount *mnt;
+
+	old_cred = override_creds(dentry->d_sb->s_cred);
+	mnt = vfs_kern_mount(type, flags, name, data);
+	revert_creds(old_cred);
+
+	return mnt;
+}
+EXPORT_SYMBOL_GPL(vfs_kern_automount);
+
 static struct mount *clone_mnt(struct mount *old, struct dentry *root,
 					int flag)
 {
diff --git a/fs/nfs/namespace.c b/fs/nfs/namespace.c
index 5551e8ef67fd..dce529c50cbd 100644
--- a/fs/nfs/namespace.c
+++ b/fs/nfs/namespace.c
@@ -222,11 +222,11 @@ void nfs_release_automount_timer(void)
 /*
  * Clone a mountpoint of the appropriate type
  */
-static struct vfsmount *nfs_do_clone_mount(struct nfs_server *server,
+static struct vfsmount *nfs_do_clone_mount(struct dentry *dentry,
 					   const char *devname,
 					   struct nfs_clone_mount *mountdata)
 {
-	return vfs_kern_mount(&nfs_xdev_fs_type, 0, devname, mountdata);
+	return vfs_kern_automount(dentry, &nfs_xdev_fs_type, 0, devname, mountdata);
 }
 
 /**
@@ -261,7 +261,7 @@ struct vfsmount *nfs_do_submount(struct dentry *dentry, struct nfs_fh *fh,
 	mnt = (struct vfsmount *)devname;
 	if (IS_ERR(devname))
 		goto free_page;
-	mnt = nfs_do_clone_mount(NFS_SB(dentry->d_sb), devname, &mountdata);
+	mnt = nfs_do_clone_mount(dentry, devname, &mountdata);
 free_page:
 	free_page((unsigned long)page);
 out:
diff --git a/fs/super.c b/fs/super.c
index 1709ed029a2c..b33b7d606aec 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -166,6 +166,7 @@ static void destroy_super(struct super_block *s)
 	list_lru_destroy(&s->s_inode_lru);
 	security_sb_free(s);
 	WARN_ON(!list_empty(&s->s_mounts));
+	put_cred(s->s_cred);
 	put_user_ns(s->s_user_ns);
 	kfree(s->s_subtype);
 	kfree(s->s_options);
@@ -193,6 +194,7 @@ static struct super_block *alloc_super(struct file_system_type *type, int flags,
 
 	INIT_LIST_HEAD(&s->s_mounts);
 	s->s_user_ns = get_user_ns(user_ns);
+	s->s_cred = get_current_cred();
 
 	if (security_sb_alloc(s))
 		goto fail;
diff --git a/include/linux/debugfs.h b/include/linux/debugfs.h
index 014cc564d1c4..67ac9f10e7b7 100644
--- a/include/linux/debugfs.h
+++ b/include/linux/debugfs.h
@@ -99,7 +99,7 @@ struct dentry *debugfs_create_symlink(const char *name, struct dentry *parent,
 
 struct dentry *debugfs_create_automount(const char *name,
 					struct dentry *parent,
-					struct vfsmount *(*f)(void *),
+					struct vfsmount *(*f)(struct dentry *, void *),
 					void *data);
 
 void debugfs_remove(struct dentry *dentry);
@@ -211,7 +211,7 @@ static inline struct dentry *debugfs_create_symlink(const char *name,
 
 static inline struct dentry *debugfs_create_automount(const char *name,
 					struct dentry *parent,
-					struct vfsmount *(*f)(void *),
+					struct vfsmount *(*f)(struct dentry *, void *),
 					void *data)
 {
 	return ERR_PTR(-ENODEV);
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2ba074328894..cae845944d1d 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1374,6 +1374,9 @@ struct super_block {
 	 */
 	struct user_namespace *s_user_ns;
 
+	/* Credentials of the user who mounted the filesystem */
+	const struct cred *s_cred;
+
 	/*
 	 * Keep the lru lists last in the structure so they always sit on their
 	 * own individual cachelines.
diff --git a/include/linux/mount.h b/include/linux/mount.h
index c6f55158d5e5..b9cdca0c6b1a 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -90,6 +90,9 @@ struct file_system_type;
 extern struct vfsmount *vfs_kern_mount(struct file_system_type *type,
 				      int flags, const char *name,
 				      void *data);
+struct vfsmount *vfs_kern_automount(struct dentry *dentry,
+				    struct file_system_type *type,
+				    int flags, const char *name, void *data);
 
 extern void mnt_set_expiry(struct vfsmount *mnt, struct list_head *expiry_list);
 extern void mark_mounts_for_expiry(struct list_head *mounts);
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index d7449783987a..7bb959abd5f1 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -7503,7 +7503,7 @@ init_tracer_tracefs(struct trace_array *tr, struct dentry *d_tracer)
 	ftrace_init_tracefs(tr, d_tracer);
 }
 
-static struct vfsmount *trace_automount(void *ingore)
+static struct vfsmount *trace_automount(struct dentry *dentry, void *ingore)
 {
 	struct vfsmount *mnt;
 	struct file_system_type *type;
@@ -7516,7 +7516,7 @@ static struct vfsmount *trace_automount(void *ingore)
 	type = get_fs_type("tracefs");
 	if (!type)
 		return NULL;
-	mnt = vfs_kern_mount(type, 0, "tracefs", NULL);
+	mnt = vfs_kern_automount(dentry, type, 0, "tracefs", NULL);
 	put_filesystem(type);
 	if (IS_ERR(mnt))
 		return NULL;

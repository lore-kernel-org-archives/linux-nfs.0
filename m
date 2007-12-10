From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression
Date: Mon, 10 Dec 2007 13:03:05 -0800
Message-ID: <20071210130305.d8983fdc.akpm@linux-foundation.org>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com>
	<200712101619.12522.maximlevitsky@gmail.com>
	<20071210143609.GF2138@fieldses.org>
	<200712101705.30428.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: bfields@fieldses.org, neilb@suse.de, rjw@sisk.pl,
	trond.myklebust@fys.uio.no, gnome42@gmail.com,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	den@openvz.org, linux-nfs@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52836 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752688AbXLJVEc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 16:04:32 -0500
In-Reply-To: <200712101705.30428.maximlevitsky@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Dec 2007 17:05:30 +0200
Maxim Levitsky <maximlevitsky@gmail.com> wrote:

> On Monday 10 December 2007 16:36:09 J. Bruce Fields wrote:
> > On Mon, Dec 10, 2007 at 04:19:12PM +0200, Maxim Levitsky wrote:
> > > ...
> > > > It is best not to use nohide - we should probably mark it as
> > > > 'legacy'.
> > > > 
> > > > Simply export the top level mountpoint as 'crossmnt'  and everything
> > > > below there will be exported.
> > > > 
> > > > > Where should I put those options in root file-system export or in submount export?
> > > > 
> > > > crossmnt goes at the top.  nohide goes in the submount.  Both have
> > > > the same general effect though with subtle differences.
> > > > You don't need both (though that doesn't hurt).
> > > > Just use crossmnt at the top,  Then you don't need to mention the
> > > > lower level filesystems at all.
> > > > 
> > > > > 
> > > ...
> > > > > (I decided to switch to NFS4 only due to the lack of ability to see underlying mounts)
> > > > > 
> > > > 
> > > > All of this should work fine with v3.  Once you have the right patch
> > > > for the crossmnt bug applied, if you have further problems post them
> > > > to linux-nfs-u79uwXL29TaiAVqoAR/hOA@public.gmane.org
> > > > 
> > > > NeilBrown
> > > > 
> > > 
> > > Big thanks,
> > > 
> > > Still NFS server just don't want to accept the connection
> > > I noticed that if I first mount with
> > > -tnfs, unmount,  and then mount with -tnfs4, it works
> > 
> > OK, in that case, that's definitely the bug Eric sent out the patch for;
> > you may want to try applying his patch.
> You mean
> "[PATCH 2.6.24-rc4] proc: Remove/Fix proc generic d_revalidate" ?
> 
> I did apply it (on both kernel and server), and it doesn't help.

argh, this is getting bad.

Can you please test the below patch asap? Against 2.6.24-rc4 or latest-linus.


From: Andrew Morton <akpm@linux-foundation.org>

Revert

    commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416
    Author: Eric W. Biederman <ebiederm@xmission.com>
    Date:   Sun Dec 2 00:33:17 2007 +1100

        [NETNS]: Fix /proc/net breakage

It has caused all sorts of procfs mayhem.

Reverting this will reintroduce

    "Currently things work but there are odd details visible to user
     space, even when we have a single network namespace."

Where "details" was never elaborated upon.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Pavel Emelyanov <xemul@openvz.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Denis V. Lunev" <den@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/generic.c       |   12 -----
 fs/proc/proc_net.c      |   86 +++++++++++++++++++++++++++++++++++---
 include/linux/proc_fs.h |    3 -
 3 files changed, 82 insertions(+), 19 deletions(-)

diff -puN fs/proc/generic.c~revert-fix-proc-net-breakage fs/proc/generic.c
--- a/fs/proc/generic.c~revert-fix-proc-net-breakage
+++ a/fs/proc/generic.c
@@ -374,16 +374,9 @@ static int proc_delete_dentry(struct den
 	return 1;
 }
 
-static int proc_revalidate_dentry(struct dentry *dentry, struct nameidata *nd)
-{
-	d_drop(dentry);
-	return 0;
-}
-
 static struct dentry_operations proc_dentry_operations =
 {
 	.d_delete	= proc_delete_dentry,
-	.d_revalidate	= proc_revalidate_dentry,
 };
 
 /*
@@ -404,11 +397,8 @@ struct dentry *proc_lookup(struct inode 
 			if (de->namelen != dentry->d_name.len)
 				continue;
 			if (!memcmp(dentry->d_name.name, de->name, de->namelen)) {
-				unsigned int ino;
+				unsigned int ino = de->low_ino;
 
-				if (de->shadow_proc)
-					de = de->shadow_proc(current, de);
-				ino = de->low_ino;
 				de_get(de);
 				spin_unlock(&proc_subdir_lock);
 				error = -EINVAL;
diff -puN fs/proc/proc_net.c~revert-fix-proc-net-breakage fs/proc/proc_net.c
--- a/fs/proc/proc_net.c~revert-fix-proc-net-breakage
+++ a/fs/proc/proc_net.c
@@ -50,14 +50,89 @@ struct net *get_proc_net(const struct in
 }
 EXPORT_SYMBOL_GPL(get_proc_net);
 
-static struct proc_dir_entry *shadow_pde;
+static struct proc_dir_entry *proc_net_shadow;
 
-static struct proc_dir_entry *proc_net_shadow(struct task_struct *task,
+static struct dentry *proc_net_shadow_dentry(struct dentry *parent,
 						struct proc_dir_entry *de)
 {
-	return task->nsproxy->net_ns->proc_net;
+	struct dentry *shadow = NULL;
+	struct inode *inode;
+	if (!de)
+		goto out;
+	de_get(de);
+	inode = proc_get_inode(parent->d_inode->i_sb, de->low_ino, de);
+	if (!inode)
+		goto out_de_put;
+	shadow = d_alloc_name(parent, de->name);
+	if (!shadow)
+		goto out_iput;
+	shadow->d_op = parent->d_op; /* proc_dentry_operations */
+	d_instantiate(shadow, inode);
+out:
+	return shadow;
+out_iput:
+	iput(inode);
+out_de_put:
+	de_put(de);
+	goto out;
+}
+
+static void *proc_net_follow_link(struct dentry *parent, struct nameidata *nd)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct dentry *shadow;
+	shadow = proc_net_shadow_dentry(parent, net->proc_net);
+	if (!shadow)
+		return ERR_PTR(-ENOENT);
+
+	dput(nd->dentry);
+	/* My dentry count is 1 and that should be enough as the
+	 * shadow dentry is thrown away immediately.
+	 */
+	nd->dentry = shadow;
+	return NULL;
 }
 
+static struct dentry *proc_net_lookup(struct inode *dir, struct dentry *dentry,
+				      struct nameidata *nd)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct dentry *shadow;
+
+	shadow = proc_net_shadow_dentry(nd->dentry, net->proc_net);
+	if (!shadow)
+		return ERR_PTR(-ENOENT);
+
+	dput(nd->dentry);
+	nd->dentry = shadow;
+
+	return shadow->d_inode->i_op->lookup(shadow->d_inode, dentry, nd);
+}
+
+static int proc_net_setattr(struct dentry *dentry, struct iattr *iattr)
+{
+	struct net *net = current->nsproxy->net_ns;
+	struct dentry *shadow;
+	int ret;
+
+	shadow = proc_net_shadow_dentry(dentry->d_parent, net->proc_net);
+	if (!shadow)
+		return -ENOENT;
+	ret = shadow->d_inode->i_op->setattr(shadow, iattr);
+	dput(shadow);
+	return ret;
+}
+
+static const struct file_operations proc_net_dir_operations = {
+	.read			= generic_read_dir,
+};
+
+static struct inode_operations proc_net_dir_inode_operations = {
+	.follow_link	= proc_net_follow_link,
+	.lookup		= proc_net_lookup,
+	.setattr	= proc_net_setattr,
+};
+
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *root, *netd, *net_statd;
@@ -110,8 +185,9 @@ static struct pernet_operations __net_in
 
 int __init proc_net_init(void)
 {
-	shadow_pde = proc_mkdir("net", NULL);
-	shadow_pde->shadow_proc = proc_net_shadow;
+	proc_net_shadow = proc_mkdir("net", NULL);
+	proc_net_shadow->proc_iops = &proc_net_dir_inode_operations;
+	proc_net_shadow->proc_fops = &proc_net_dir_operations;
 
 	return register_pernet_subsys(&proc_net_ns_ops);
 }
diff -puN include/linux/proc_fs.h~revert-fix-proc-net-breakage include/linux/proc_fs.h
--- a/include/linux/proc_fs.h~revert-fix-proc-net-breakage
+++ a/include/linux/proc_fs.h
@@ -48,8 +48,6 @@ typedef	int (read_proc_t)(char *page, ch
 typedef	int (write_proc_t)(struct file *file, const char __user *buffer,
 			   unsigned long count, void *data);
 typedef int (get_info_t)(char *, char **, off_t, int);
-typedef struct proc_dir_entry *(shadow_proc_t)(struct task_struct *task,
-						struct proc_dir_entry *pde);
 
 struct proc_dir_entry {
 	unsigned int low_ino;
@@ -80,7 +78,6 @@ struct proc_dir_entry {
 	int pde_users;	/* number of callers into module in progress */
 	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
 	struct completion *pde_unload_completion;
-	shadow_proc_t *shadow_proc;
 };
 
 struct kcore_list {
_


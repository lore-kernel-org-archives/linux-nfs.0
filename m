From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 026 of 28] nfsd4: initialize recovery directory
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006j1-Tq@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3O-0005x0-QM
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:14 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3L-0002Qx-68
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:14 -0700
To: Andrew Morton <akpm@osdl.org>
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


NFSv4 clients are required to know what state they have on the server so that
they can reclaim it on server reboot.  However, it is possible for pathalogical
combinations of server reboots and network partitions to leave a client in a
state where it cannot know whether it has lost its state on the server.

For this reason, rfc3530 requires that we store some information about clients
to stable storage.

So we maintain a directory /var/lib/nfs/v4recovery with a subdirectory for
each client with active state.  We leave open the possibility of including
files underneath each such subdirectory with information about the client, but
for now the subdirectories are empty.

We create a client subdirectory whenever a client makes its first non-reclaim
open_confirm.

We remove a client subdirectory whenever either
        a) its lease expires, or
	b) the grace period ends without it reclaiming anything.
When handling reclaims, we allow the reclaim if and only if the client doing
the reclaim has a subdirectory.

This patch adds just the code to scan the recovery directory on nfsd startup.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4recover.c      |  166 +++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4state.c        |   18 ++++
 ./include/linux/nfsd/state.h |    4 +
 3 files changed, 186 insertions(+), 2 deletions(-)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-05-31 14:21:02.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-06-01 14:21:39.000000000 +1000
@@ -39,6 +39,9 @@
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
+#include <linux/param.h>
+#include <linux/file.h>
+#include <linux/namei.h>
 #include <asm/uaccess.h>
 #include <asm/scatterlist.h>
 #include <linux/crypto.h>
@@ -46,6 +49,27 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
+/* Globals */
+char recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
+static struct nameidata rec_dir;
+static int rec_dir_init = 0;
+
+static void
+nfs4_save_user(uid_t *saveuid, gid_t *savegid)
+{
+	*saveuid = current->fsuid;
+	*savegid = current->fsgid;
+	current->fsuid = 0;
+	current->fsgid = 0;
+}
+
+static void
+nfs4_reset_user(uid_t saveuid, gid_t savegid)
+{
+	current->fsuid = saveuid;
+	current->fsgid = savegid;
+}
+
 static void
 md5_to_hex(char *out, char *md5)
 {
@@ -95,3 +119,145 @@ out:
 		crypto_free_tfm(tfm);
 	return status;
 }
+
+typedef int (recdir_func)(struct dentry *, struct dentry *);
+
+struct dentry_list {
+	struct dentry *dentry;
+	struct list_head list;
+};
+
+struct dentry_list_arg {
+	struct list_head dentries;
+	struct dentry *parent;
+};
+
+static int
+nfsd4_build_dentrylist(void *arg, const char *name, int namlen,
+		loff_t offset, ino_t ino, unsigned int d_type)
+{
+	struct dentry_list_arg *dla = arg;
+	struct list_head *dentries = &dla->dentries;
+	struct dentry *parent = dla->parent;
+	struct dentry *dentry;
+	struct dentry_list *child;
+
+	if (name && isdotent(name, namlen))
+		return nfs_ok;
+	dentry = lookup_one_len(name, parent, namlen);
+	if (IS_ERR(dentry))
+		return PTR_ERR(dentry);
+	child = kmalloc(sizeof(*child), GFP_KERNEL);
+	if (child == NULL)
+		return -ENOMEM;
+	child->dentry = dentry;
+	list_add(&child->list, dentries);
+	return 0;
+}
+
+static int
+nfsd4_list_rec_dir(struct dentry *dir, recdir_func *f)
+{
+	struct file *filp;
+	struct dentry_list_arg dla = {
+		.parent = dir,
+	};
+	struct list_head *dentries = &dla.dentries;
+	struct dentry_list *child;
+	uid_t uid;
+	gid_t gid;
+	int status;
+
+	if (!rec_dir_init)
+		return 0;
+
+	nfs4_save_user(&uid, &gid);
+
+	filp = dentry_open(dget(dir), mntget(rec_dir.mnt),
+			O_RDWR);
+	status = PTR_ERR(filp);
+	if (IS_ERR(filp))
+		goto out;
+	INIT_LIST_HEAD(dentries);
+	status = vfs_readdir(filp, nfsd4_build_dentrylist, &dla);
+	fput(filp);
+	while (!list_empty(dentries)) {
+		child = list_entry(dentries->next, struct dentry_list, list);
+		status = f(dir, child->dentry);
+		if (status)
+			goto out;
+		list_del(&child->list);
+		dput(child->dentry);
+		kfree(child);
+	}
+out:
+	while (!list_empty(dentries)) {
+		child = list_entry(dentries->next, struct dentry_list, list);
+		list_del(&child->list);
+		dput(child->dentry);
+		kfree(child);
+	}
+	nfs4_reset_user(uid, gid);
+	return status;
+}
+
+static int
+load_recdir(struct dentry *parent, struct dentry *child)
+{
+	if (child->d_name.len != HEXDIR_LEN - 1) {
+		printk("nfsd4: illegal name %s in recovery directory\n",
+				child->d_name.name);
+		/* Keep trying; maybe the others are OK: */
+		return nfs_ok;
+	}
+	nfs4_client_to_reclaim(child->d_name.name);
+	return nfs_ok;
+}
+
+int
+nfsd4_recdir_load(void) {
+	int status;
+
+	status = nfsd4_list_rec_dir(rec_dir.dentry, load_recdir);
+	if (status)
+		printk("nfsd4: failed loading clients from recovery"
+			" directory %s\n", rec_dir.dentry->d_name.name);
+	return status;
+}
+
+/*
+ * Hold reference to the recovery directory.
+ */
+
+void
+nfsd4_init_recdir(char *rec_dirname)
+{
+	uid_t			uid = 0;
+	gid_t			gid = 0;
+	int 			status;
+
+	printk("NFSD: Using %s as the NFSv4 state recovery directory\n",
+			rec_dirname);
+
+	BUG_ON(rec_dir_init);
+
+	nfs4_save_user(&uid, &gid);
+
+	status = path_lookup(rec_dirname, LOOKUP_FOLLOW, &rec_dir);
+	if (status == -ENOENT)
+		printk("NFSD: recovery directory %s doesn't exist\n",
+				rec_dirname);
+
+	if (!status)
+		rec_dir_init = 1;
+	nfs4_reset_user(uid, gid);
+}
+
+void
+nfsd4_shutdown_recdir(void)
+{
+	if (!rec_dir_init)
+		return;
+	rec_dir_init = 0;
+	path_release(&rec_dir);
+}

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:07.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-06-01 14:21:39.000000000 +1000
@@ -71,6 +71,7 @@ static stateid_t onestateid;            
 static struct nfs4_stateid * find_stateid(stateid_t *stid, int flags);
 static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static void release_stateid_lockowners(struct nfs4_stateid *open_stp);
+extern char recovery_dirname[];
 
 /* Locking:
  *
@@ -3091,8 +3092,8 @@ alloc_reclaim(void)
 /*
  * failure => all reset bets are off, nfserr_no_grace...
  */
-static int
-nfs4_client_to_reclaim(char *name)
+int
+nfs4_client_to_reclaim(const char *name)
 {
 	unsigned int strhashval;
 	struct nfs4_client_reclaim *crp = NULL;
@@ -3202,6 +3203,17 @@ nfs4_state_init(void)
 	reclaim_str_hashtbl_size = 0;
 }
 
+static void
+nfsd4_load_reboot_recovery_data(void)
+{
+	int status;
+
+	nfsd4_init_recdir(recovery_dirname);
+	status = nfsd4_recdir_load();
+	if (status)
+		printk("NFSD: Failure reading reboot recovery data\n");
+}
+
 /* initialization to perform when the nfsd service is started: */
 
 static void
@@ -3228,6 +3240,7 @@ nfs4_state_start(void)
 	status = nfsd4_init_slabs();
 	if (status)
 		return status;
+	nfsd4_load_reboot_recovery_data();
 	__nfs4_state_start();
 	nfs4_init = 1;
 	return 0;
@@ -3286,6 +3299,7 @@ __nfs4_state_shutdown(void)
 	cancel_delayed_work(&laundromat_work);
 	flush_workqueue(laundry_wq);
 	destroy_workqueue(laundry_wq);
+	nfsd4_shutdown_recdir();
 	nfs4_init = 0;
 }
 

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-05-31 14:21:07.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-06-01 14:21:39.000000000 +1000
@@ -278,6 +278,10 @@ extern void nfsd4_probe_callback(struct 
 extern void nfsd4_cb_recall(struct nfs4_delegation *dp);
 extern void nfs4_put_delegation(struct nfs4_delegation *dp);
 extern int nfs4_make_rec_clidname(char *clidname, struct xdr_netobj *clname);
+extern void nfsd4_init_recdir(char *recdir_name);
+extern int nfsd4_recdir_load(void);
+extern void nfsd4_shutdown_recdir(void);
+extern int nfs4_client_to_reclaim(const char *name);
 
 static inline void
 nfs4_put_stateowner(struct nfs4_stateowner *so)


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

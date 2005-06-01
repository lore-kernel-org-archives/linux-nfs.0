From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 027 of 28] nfsd4: reboot recovery
Date: Thu, 02 Jun 2005 08:50:57 +1000
Message-ID: <E1Ddc37-0006j4-VR@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3T-0005xl-L4
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:19 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3R-0005OK-Nm
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:19 -0700
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


This patch adds the code to create and remove client subdirectories from the
recovery directory, as described in the previous patch comment.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4recover.c      |  169 +++++++++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfs4state.c        |   16 ++++
 ./include/linux/nfsd/state.h |    5 +
 3 files changed, 190 insertions(+)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2005-06-01 14:24:55.000000000 +1000
+++ ./fs/nfsd/nfs4recover.c	2005-06-01 14:22:11.000000000 +1000
@@ -120,6 +120,70 @@ out:
 	return status;
 }
 
+static int
+nfsd4_rec_fsync(struct dentry *dentry)
+{
+	struct file *filp;
+	int status = nfs_ok;
+
+	dprintk("NFSD: nfs4_fsync_rec_dir\n");
+	filp = dentry_open(dget(dentry), mntget(rec_dir.mnt), O_RDWR);
+	if (IS_ERR(filp)) {
+		status = PTR_ERR(filp);
+		goto out;
+	}
+	if (filp->f_op && filp->f_op->fsync)
+		status = filp->f_op->fsync(filp, filp->f_dentry, 0);
+	fput(filp);
+out:
+	if (status)
+		printk("nfsd4: unable to sync recovery directory\n");
+	return status;
+}
+
+int
+nfsd4_create_clid_dir(struct nfs4_client *clp)
+{
+	char *dname = clp->cl_recdir;
+	struct dentry *dentry;
+	uid_t uid;
+	gid_t gid;
+	int status;
+
+	dprintk("NFSD: nfsd4_create_clid_dir for \"%s\"\n", dname);
+
+	if (!rec_dir_init || clp->cl_firststate)
+		return 0;
+
+	nfs4_save_user(&uid, &gid);
+
+	/* lock the parent */
+	down(&rec_dir.dentry->d_inode->i_sem);
+
+	dentry = lookup_one_len(dname, rec_dir.dentry, HEXDIR_LEN-1);
+	if (IS_ERR(dentry)) {
+		status = PTR_ERR(dentry);
+		goto out_unlock;
+	}
+	status = -EEXIST;
+	if (dentry->d_inode) {
+		dprintk("NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
+		goto out_put;
+	}
+	status = vfs_mkdir(rec_dir.dentry->d_inode, dentry, S_IRWXU);
+out_put:
+	dput(dentry);
+out_unlock:
+	up(&rec_dir.dentry->d_inode->i_sem);
+	if (status == 0) {
+		clp->cl_firststate = 1;
+		status = nfsd4_rec_fsync(rec_dir.dentry);
+	}
+	nfs4_reset_user(uid, gid);
+	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
+	return status;
+}
+
 typedef int (recdir_func)(struct dentry *, struct dentry *);
 
 struct dentry_list {
@@ -202,6 +266,111 @@ out:
 }
 
 static int
+nfsd4_remove_clid_file(struct dentry *dir, struct dentry *dentry)
+{
+	int status;
+
+	if (!S_ISREG(dir->d_inode->i_mode)) {
+		printk("nfsd4: non-file found in client recovery directory\n");
+		return -EINVAL;
+	}
+	down(&dir->d_inode->i_sem);
+	status = vfs_unlink(dir->d_inode, dentry);
+	up(&dir->d_inode->i_sem);
+	return status;
+}
+
+static int
+nfsd4_clear_clid_dir(struct dentry *dir, struct dentry *dentry)
+{
+	int status;
+
+	/* For now this directory should already be empty, but we empty it of
+	 * any regular files anyway, just in case the directory was created by
+	 * a kernel from the future.... */
+	nfsd4_list_rec_dir(dentry, nfsd4_remove_clid_file);
+	down(&dir->d_inode->i_sem);
+	status = vfs_rmdir(dir->d_inode, dentry);
+	up(&dir->d_inode->i_sem);
+	return status;
+}
+
+static int
+nfsd4_unlink_clid_dir(char *name, int namlen)
+{
+	struct dentry *dentry;
+	int status;
+
+	dprintk("NFSD: nfsd4_unlink_clid_dir. name %.*s\n", namlen, name);
+
+	dentry = lookup_one_len(name, rec_dir.dentry, namlen);
+	if (IS_ERR(dentry)) {
+		status = PTR_ERR(dentry);
+		return status;
+	}
+	status = -ENOENT;
+	if (!dentry->d_inode)
+		goto out;
+
+	status = nfsd4_clear_clid_dir(rec_dir.dentry, dentry);
+out:
+	dput(dentry);
+	return status;
+}
+
+void
+nfsd4_remove_clid_dir(struct nfs4_client *clp)
+{
+	uid_t uid;
+	gid_t gid;
+	int status;
+
+	if (!rec_dir_init || !clp->cl_firststate)
+		return;
+
+	nfs4_save_user(&uid, &gid);
+	status = nfsd4_unlink_clid_dir(clp->cl_recdir, HEXDIR_LEN-1);
+	nfs4_reset_user(uid, gid);
+	if (status == 0)
+		status = nfsd4_rec_fsync(rec_dir.dentry);
+	if (status)
+		printk("NFSD: Failed to remove expired client state directory"
+				" %.*s\n", HEXDIR_LEN, clp->cl_recdir);
+	return;
+}
+
+static int
+purge_old(struct dentry *parent, struct dentry *child)
+{
+	int status;
+
+	if (nfs4_has_reclaimed_state(child->d_name.name))
+		return nfs_ok;
+
+	status = nfsd4_clear_clid_dir(parent, child);
+	if (status)
+		printk("failed to remove client recovery directory %s\n",
+				child->d_name.name);
+	/* Keep trying, success or failure: */
+	return nfs_ok;
+}
+
+void
+nfsd4_recdir_purge_old(void) {
+	int status;
+
+	if (!rec_dir_init)
+		return;
+	status = nfsd4_list_rec_dir(rec_dir.dentry, purge_old);
+	if (status == 0)
+		status = nfsd4_rec_fsync(rec_dir.dentry);
+	if (status)
+		printk("nfsd4: failed to purge old clients from recovery"
+			" directory %s\n", rec_dir.dentry->d_name.name);
+	return;
+}
+
+static int
 load_recdir(struct dentry *parent, struct dentry *child)
 {
 	if (child->d_name.len != HEXDIR_LEN - 1) {

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-06-01 14:24:55.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-06-01 14:27:13.000000000 +1000
@@ -905,6 +905,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			conf = find_confirmed_client_by_str(unconf->cl_recdir,
 									hash);
 			if (conf) {
+				nfsd4_remove_clid_dir(conf);
 				expire_client(conf);
 			}
 			move_to_confirmed(unconf);
@@ -1691,6 +1692,7 @@ nfs4_set_claim_prev(struct nfsd4_open *o
 			*status = nfserr_reclaim_bad;
 		else {
 			open->op_stateowner->so_confirmed = 1;
+			open->op_stateowner->so_client->cl_firststate = 1;
 			open->op_stateowner->so_seqid--;
 		}
 	}
@@ -1903,6 +1905,7 @@ static void
 end_grace(void)
 {
 	dprintk("NFSD: end of grace period\n");
+	nfsd4_recdir_purge_old();
 	in_grace = 0;
 }
 
@@ -1932,6 +1935,7 @@ nfs4_laundromat(void)
 		}
 		dprintk("NFSD: purging unused client (clientid %08x)\n",
 			clp->cl_clientid.cl_id);
+		nfsd4_remove_clid_dir(clp);
 		expire_client(clp);
 	}
 	INIT_LIST_HEAD(&reaplist);
@@ -2320,6 +2324,8 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 		         stp->st_stateid.si_stateownerid,
 		         stp->st_stateid.si_fileid,
 		         stp->st_stateid.si_generation);
+
+	nfsd4_create_clid_dir(sop->so_client);
 out:
 	if (oc->oc_stateowner)
 		nfs4_get_stateowner(oc->oc_stateowner);
@@ -3089,6 +3095,16 @@ alloc_reclaim(void)
 	return kmalloc(sizeof(struct nfs4_client_reclaim), GFP_KERNEL);
 }
 
+int
+nfs4_has_reclaimed_state(const char *name)
+{
+	unsigned int strhashval = clientstr_hashval(name);
+	struct nfs4_client *clp;
+
+	clp = find_confirmed_client_by_str(name, strhashval);
+	return clp ? 1 : 0;
+}
+
 /*
  * failure => all reset bets are off, nfserr_no_grace...
  */

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2005-06-01 14:24:55.000000000 +1000
+++ ./include/linux/nfsd/state.h	2005-06-01 14:21:50.000000000 +1000
@@ -131,6 +131,7 @@ struct nfs4_client {
 	nfs4_verifier		cl_confirm;	/* generated by server */
 	struct nfs4_callback	cl_callback;    /* callback info */
 	atomic_t		cl_count;	/* ref count */
+	u32			cl_firststate;	/* recovery dir creation */
 };
 
 /* struct nfs4_client_reset
@@ -282,6 +283,10 @@ extern void nfsd4_init_recdir(char *recd
 extern int nfsd4_recdir_load(void);
 extern void nfsd4_shutdown_recdir(void);
 extern int nfs4_client_to_reclaim(const char *name);
+extern int nfs4_has_reclaimed_state(const char *name);
+extern void nfsd4_recdir_purge_old(void);
+extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
+extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 
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

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 53 of 54] nfsd4: move delegation decisions to lock_manager callbacks
Date: Tue, 08 Mar 2005 17:06:45 +1100
Message-ID: <E1D8Xrh-0001AF-KT@notabene.cse.unsw.edu.au>
References: <20050308165419.3842.patches@notabene>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D8Xrt-00028G-L4
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:57 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D8Xrs-0005Da-La
	for nfs@lists.sourceforge.net; Mon, 07 Mar 2005 22:06:57 -0800
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


Remove nfs4_check_deleg_recall(). Move its checks into __setlease() via two new
lock_manager callbacks, fl_mylease and fl_change, so that all leases (not just
NFSv4 lease as with nfs4_check_deleg_recall) are checked.  Default
implementations of fl_mylease and fl_change are provided for the sake of the
fcntl_setlease interface.  Both callbacks must always be defined.

fl_mylease:  
   for the NFSv4 server, this check is used to see if an existing 
   lease comes from the same client.
   For the fcntl_setlease interface, the existing logic is preserved. the 
   fl_mylease check sees if the existing lease is from the input filp.

fl_change: called if the fl_mylease returns true
   the NFSv4 server does not hand out a delegation to a client that already
   has one. -EAGAIN is returned.  Otherwise lease_modify is used.
   For the fcntl_setlease interface, the exisiting logic is preserved: The 
   callback used in lease_modify().

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/locks.c          |   15 ++++++--
 ./fs/nfsd/nfs4state.c |   93 +++++++++++++++++++++++++++-----------------------
 ./include/linux/fs.h  |    3 +
 3 files changed, 66 insertions(+), 45 deletions(-)

diff ./fs/locks.c~current~ ./fs/locks.c
--- ./fs/locks.c~current~	2005-03-07 15:22:10.000000000 +1100
+++ ./fs/locks.c	2005-03-07 15:18:41.000000000 +1100
@@ -406,9 +406,16 @@ static void lease_release_private_callba
 	fl->fl_file->f_owner.signum = 0;
 }
 
+static int lease_mylease_callback(struct file_lock *fl, struct file_lock *try)
+{
+	return fl->fl_file == try->fl_file;
+}
+
 struct lock_manager_operations lease_manager_ops = {
 	.fl_break = lease_break_callback,
 	.fl_release_private = lease_release_private_callback,
+	.fl_mylease = lease_mylease_callback,
+	.fl_change = lease_modify,
 };
 
 /*
@@ -1058,7 +1065,7 @@ int locks_mandatory_area(int read_write,
 EXPORT_SYMBOL(locks_mandatory_area);
 
 /* We already had a lease on this file; just change its type */
-static int lease_modify(struct file_lock **before, int arg)
+int lease_modify(struct file_lock **before, int arg)
 {
 	struct file_lock *fl = *before;
 	int error = assign_type(fl, arg);
@@ -1071,6 +1078,8 @@ static int lease_modify(struct file_lock
 	return 0;
 }
 
+EXPORT_SYMBOL(lease_modify);
+
 static void time_out_leases(struct inode *inode)
 {
 	struct file_lock **before;
@@ -1315,7 +1324,7 @@ int __setlease(struct file *filp, long a
 	for (before = &inode->i_flock;
 			((fl = *before) != NULL) && IS_LEASE(fl);
 			before = &fl->fl_next) {
-		if (fl->fl_file == filp)
+		if (lease->fl_lmops->fl_mylease(fl, lease))
 			my_before = before;
 		else if (fl->fl_type == (F_INPROGRESS | F_UNLCK))
 			/*
@@ -1333,7 +1342,7 @@ int __setlease(struct file *filp, long a
 		goto out;
 
 	if (my_before != NULL) {
-		error = lease_modify(my_before, arg);
+		error = lease->fl_lmops->fl_change(my_before, arg);
 		goto out;
 	}
 

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-03-07 15:22:10.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2005-03-07 15:12:02.000000000 +1100
@@ -1402,10 +1402,39 @@ void nfsd_copy_lock_deleg_cb(struct file
 	dp->dl_flock = new;
 }
 
+/*
+ * Called from __setlease() with lock_kernel() held
+ */
+static
+int nfsd_same_client_deleg_cb(struct file_lock *onlist, struct file_lock *try)
+{
+	struct nfs4_delegation *onlistd =
+		(struct nfs4_delegation *)onlist->fl_owner;
+	struct nfs4_delegation *tryd =
+		(struct nfs4_delegation *)try->fl_owner;
+
+	if (onlist->fl_lmops != try->fl_lmops)
+		return 0;
+
+	return onlistd->dl_client == tryd->dl_client;
+}
+
+
+static
+int nfsd_change_deleg_cb(struct file_lock **onlist, int arg)
+{
+	if (arg & F_UNLCK)
+		return lease_modify(onlist, arg);
+	else
+		return -EAGAIN;
+}
+
 struct lock_manager_operations nfsd_lease_mng_ops = {
-        .fl_break = nfsd_break_deleg_cb,
-        .fl_release_private = nfsd_release_deleg_cb,
-        .fl_copy_lock = nfsd_copy_lock_deleg_cb,
+	.fl_break = nfsd_break_deleg_cb,
+	.fl_release_private = nfsd_release_deleg_cb,
+	.fl_copy_lock = nfsd_copy_lock_deleg_cb,
+	.fl_mylease = nfsd_same_client_deleg_cb,
+	.fl_change = nfsd_change_deleg_cb,
 };
 
 
@@ -1501,25 +1530,6 @@ out:
 }
 
 static int
-nfs4_check_deleg_recall(struct nfs4_file *fp, struct nfsd4_open *op, int *flag)
-{
-	struct nfs4_delegation *dp;
-	int status = 0;
-
-	list_for_each_entry(dp, &fp->fi_del_perfile, dl_del_perfile) {
-		if (op->op_share_access & NFS4_SHARE_ACCESS_WRITE
-			|| op->op_stateowner->so_client == dp->dl_client) {
-			*flag = NFS4_OPEN_DELEGATE_NONE;
-			goto out;
-		}
-	}
-out:
-	dprintk("NFSD: nfs4_check_deleg_recall returns %d with flag %d\n",
-		status, *flag);
-	return status;
-}
-
-static int
 nfs4_check_open(struct nfs4_file *fp, struct nfs4_stateowner *sop, struct nfsd4_open *open, struct nfs4_stateid **stpp)
 {
 	struct nfs4_stateid *local;
@@ -1623,31 +1633,28 @@ nfs4_set_claim_prev(struct nfsd4_open *o
  * Attempt to hand out a delegation.
  */
 static void
-nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_stateid *stp, int *flag)
+nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open, struct nfs4_stateid *stp)
 {
 	struct nfs4_delegation *dp;
 	struct nfs4_stateowner *sop = stp->st_stateowner;
 	struct nfs4_callback *cb = &sop->so_client->cl_callback;
 	struct file_lock fl, *flp = &fl;
-	int status;
-
-	if (*flag == NFS4_OPEN_DELEGATE_NONE)
-		return;
+	int status, flag = 0;
 
-	*flag = NFS4_OPEN_DELEGATE_NONE;
+	flag = NFS4_OPEN_DELEGATE_NONE;
 	if (open->op_claim_type != NFS4_OPEN_CLAIM_NULL
 	     || !atomic_read(&cb->cb_set) || !sop->so_confirmed)
-		return;
+		goto out;
 
 	if (open->op_share_access & NFS4_SHARE_ACCESS_WRITE)
-		*flag = NFS4_OPEN_DELEGATE_WRITE;
+		flag = NFS4_OPEN_DELEGATE_WRITE;
 	else
-		*flag = NFS4_OPEN_DELEGATE_READ;
+		flag = NFS4_OPEN_DELEGATE_READ;
 
-	dp = alloc_init_deleg(sop->so_client, stp, fh, *flag);
+	dp = alloc_init_deleg(sop->so_client, stp, fh, flag);
 	if (dp == NULL) {
-		*flag = NFS4_OPEN_DELEGATE_NONE;
-		return;
+		flag = NFS4_OPEN_DELEGATE_NONE;
+		goto out;
 	}
 	locks_init_lock(&fl);
 	fl.fl_lmops = &nfsd_lease_mng_ops;
@@ -1657,15 +1664,18 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	fl.fl_file = stp->st_vfs_file;
 	fl.fl_pid = current->tgid;
 
+	/* setlease checks to see if delegation should be handed out.
+	 * the lock_manager callbacks fl_mylease and fl_change are used
+	 */
 	if ((status = setlease(stp->st_vfs_file,
-		*flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK, &flp))) {
+		flag == NFS4_OPEN_DELEGATE_READ? F_RDLCK: F_WRLCK, &flp))) {
 		dprintk("NFSD: setlease failed [%d], no delegation\n", status);
 		list_del(&dp->dl_del_perfile);
 		list_del(&dp->dl_del_perclnt);
 		nfs4_put_delegation(dp);
 		free_delegation++;
-		*flag = NFS4_OPEN_DELEGATE_NONE;
-		return;
+		flag = NFS4_OPEN_DELEGATE_NONE;
+		goto out;
 	}
 
 	memcpy(&open->op_delegate_stateid, &dp->dl_stateid, sizeof(dp->dl_stateid));
@@ -1675,6 +1685,8 @@ nfs4_open_delegation(struct svc_fh *fh, 
 	             dp->dl_stateid.si_stateownerid,
 	             dp->dl_stateid.si_fileid,
 	             dp->dl_stateid.si_generation);
+out:
+	open->op_delegate_type = flag;
 }
 
 /*
@@ -1687,7 +1699,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_stateid *stp = NULL;
-	int status, delegflag = -1;
+	int status;
 
 	status = nfserr_inval;
 	if (!TEST_ACCESS(open->op_share_access) || !TEST_DENY(open->op_share_deny))
@@ -1701,8 +1713,6 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	if (fp) {
 		if ((status = nfs4_check_open(fp, sop, open, &stp)))
 			goto out;
-		if ((status = nfs4_check_deleg_recall(fp, open, &delegflag)))
-			goto out;
 	} else {
 		status = nfserr_resource;
 		fp = alloc_init_file(ino);
@@ -1748,8 +1758,7 @@ nfsd4_process_open2(struct svc_rqst *rqs
 	* Attempt to hand out a delegation. No error return, because the
 	* OPEN succeeds even if we fail.
 	*/
-	nfs4_open_delegation(current_fh, open, stp, &delegflag);
-	open->op_delegate_type = delegflag;
+	nfs4_open_delegation(current_fh, open, stp);
 
 	status = nfs_ok;
 

diff ./include/linux/fs.h~current~ ./include/linux/fs.h
--- ./include/linux/fs.h~current~	2005-03-07 15:22:10.000000000 +1100
+++ ./include/linux/fs.h	2005-03-07 15:19:16.000000000 +1100
@@ -654,6 +654,8 @@ struct lock_manager_operations {
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
 	void (*fl_release_private)(struct file_lock *);
 	void (*fl_break)(struct file_lock *);
+	int (*fl_mylease)(struct file_lock *, struct file_lock *);
+	int (*fl_change)(struct file_lock **, int);
 };
 
 /* that will die - we need it for nfs_lock_info */
@@ -720,6 +722,7 @@ extern int flock_lock_file_wait(struct f
 extern int __break_lease(struct inode *inode, unsigned int flags);
 extern void lease_get_mtime(struct inode *, struct timespec *time);
 extern int setlease(struct file *, long, struct file_lock **);
+extern int lease_modify(struct file_lock **, int);
 extern void remove_lease(struct file_lock *);
 extern int lock_may_read(struct inode *, loff_t start, unsigned long count);
 extern int lock_may_write(struct inode *, loff_t start, unsigned long count);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 15 of 23] Kernel thread for delegation callback
Date: Fri, 17 Dec 2004 16:23:56 +1100
Message-ID: <E1CfAaq-0002eK-Nf@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAc0-0005Ay-Fs
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:08 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbx-0006Am-Jd
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:08 -0800
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


Any task can call break_lease or time_out_leases
on a v4 delegated file which results in a recall callback rpc sent to the
NFSv4 client holding the delegation, and/or the FL_LEASE to be removed.
Spawn a kernel thread to perform the callback.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   96 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 96 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:21.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:36.000000000 +1100
@@ -44,6 +44,7 @@
 #include <linux/mount.h>
 #include <linux/workqueue.h>
 #include <linux/smp_lock.h>
+#include <linux/kthread.h>
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
@@ -1311,6 +1312,101 @@ nfs4_file_downgrade(struct file *filp, u
 	}
 }
 
+/*
+ * Recall a delegation
+ */
+static int
+do_recall(void *__dp)
+{
+	struct nfs4_delegation *dp = __dp;
+
+	daemonize("nfsv4-recall");
+
+	atomic_inc(&dp->dl_count);
+	nfsd4_cb_recall(dp);
+	return 0;
+}
+
+/*
+ * Spawn a thread to perform a recall on the delegation represented
+ * by the lease (file_lock)
+ *
+ * Called from break_lease() with lock_kernel() held,
+ *
+ */
+static
+void nfsd_break_deleg_cb(struct file_lock *fl)
+{
+	struct nfs4_delegation *dp=  (struct nfs4_delegation *)fl->fl_owner;
+	struct task_struct *t;
+
+	dprintk("NFSD nfsd_break_deleg_cb: dp %p fl %p\n",dp,fl);
+	if (!dp)
+		return;
+
+	/* schedule delegation for recall */
+	spin_lock(&recall_lock);
+	atomic_set(&dp->dl_state, NFS4_RECALL_IN_PROGRESS);
+	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);
+	spin_unlock(&recall_lock);
+
+	/* only place dl_time is set. protected by lock_kernel*/
+	dp->dl_time = get_seconds();
+
+	/* XXX need to merge NFSD_LEASE_TIME with fs/locks.c:lease_break_time */
+	fl->fl_break_time = jiffies + NFSD_LEASE_TIME * HZ;
+
+	t = kthread_run(do_recall, dp, "%s", "nfs4_cb_recall");
+	if (IS_ERR(t)) {
+		struct nfs4_client *clp = dp->dl_client;
+
+		printk(KERN_INFO "NFSD: Callback thread failed for "
+			"for client (clientid %08x/%08x)\n",
+			clp->cl_clientid.cl_boot, clp->cl_clientid.cl_id);
+	}
+}
+
+/*
+ * The file_lock is being reapd.
+ *
+ * Called by locks_free_lock() with lock_kernel() held.
+ */
+static
+void nfsd_release_deleg_cb(struct file_lock *fl)
+{
+	struct nfs4_delegation *dp = (struct nfs4_delegation *)fl->fl_owner;
+
+	dprintk("NFSD nfsd_release_deleg_cb: fl %p dp %p dl_count %d, dl_state %d\n", fl,dp, atomic_read(&dp->dl_count), atomic_read(&dp->dl_state));
+
+	if (!(fl->fl_flags & FL_LEASE) || !dp)
+		return;
+	atomic_set(&dp->dl_state,NFS4_RECALL_COMPLETE);
+	dp->dl_flock = NULL;
+}
+
+/*
+ * Set the delegation file_lock back pointer.
+ *
+ * Called from __setlease() with lock_kernel() held.
+ */
+static
+void nfsd_copy_lock_deleg_cb(struct file_lock *new, struct file_lock *fl)
+{
+	struct nfs4_delegation *dp = (struct nfs4_delegation *)new->fl_owner;
+
+	dprintk("NFSD: nfsd_copy_lock_deleg_cb: new fl %p dp %p\n", new, dp);
+	if (!dp)
+		return;
+	dp->dl_flock = new;
+}
+
+struct lock_manager_operations nfsd_lease_mng_ops = {
+        .fl_break = nfsd_break_deleg_cb,
+        .fl_release_private = nfsd_release_deleg_cb,
+        .fl_copy_lock = nfsd_copy_lock_deleg_cb,
+};
+
+
 
 /*
  * nfsd4_process_open1()


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

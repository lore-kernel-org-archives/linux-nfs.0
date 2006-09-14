From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 2/4 Revised] NLM failover - nlm_set_igrace
Date: Thu, 14 Sep 2006 00:48:26 -0400
Message-ID: <4508DF1A.4090907@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030407080200030202010901"
Cc: lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNix8-0006IT-8U
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:35:54 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GNix8-0000kO-8L
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:35:55 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k8E4ZrvF020528
	for <nfs@lists.sourceforge.net>; Thu, 14 Sep 2006 00:35:53 -0400
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------030407080200030202010901
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This change enables per NFS-export entry lockd grace period. The 
implementation is based on a double linked list fo_fsid_list that 
contains entries of fsid info. It is expected this would not be a 
frequent event. The fo_fsid_list is short and the entries expire within 
a maximum of 50 seconds.  The grace period setting follows the existing 
NLM grace period handling logic and is triggered via echoing the NFS 
export filesystem id into nfsd procfs entry as:

shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/svc.c              |    8 +
 fs/lockd/svc4proc.c         |   28 +++++-
 fs/lockd/svcproc.c          |   29 +++++--
 fs/lockd/svcsubs.c          |  180 
++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c            |   32 +++++++
 include/linux/lockd/bind.h  |    3
 include/linux/lockd/lockd.h |   14 +++
 7 files changed, 279 insertions(+), 15 deletions(-)


--------------030407080200030202010901
Content-Type: text/x-patch;
 name="gfs_nlm_igrace.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_nlm_igrace.patch"

--- linux-1/include/linux/lockd/lockd.h	2006-09-03 21:51:41.000000000 -0400
+++ linux-2/include/linux/lockd/lockd.h	2006-09-13 22:48:00.000000000 -0400
@@ -107,6 +107,17 @@ struct nlm_file {
 	int		       	f_hash;		/* hash of f_handle */
 };
 
+#define NLM_FO_MAX_FSID_GP	127
+
+/* Server fsid linked list for NLM lock failover */
+struct fo_fsid {
+	struct list_head	g_list;		/* linked list */
+	unsigned long		g_expire;	/* when this grace period
+						 * will expire */
+	int			g_fsid;		/* exported fsid */
+	int			g_flag;		/* printk flag */
+};
+
 /*
  * This is a server block (i.e. a lock requested by some client which
  * couldn't be granted because of a conflicting lock).
@@ -187,6 +198,8 @@ void		  nlmsvc_traverse_blocks(struct nl
 					int action);
 void	  nlmsvc_grant_reply(struct svc_rqst *, struct nlm_cookie *, u32);
 
+unsigned long set_grace_period(void); /*required by svcsubs.c and svc.c 
+					to support nlm failover */
 /*
  * File handling for the server personality
  */
@@ -197,6 +210,7 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 int 		  nlmsvc_fo_unlock(int *fsid);
+int 		  nlmsvc_fo_check(struct nfs_fh *fh);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- linux-1/fs/lockd/svcsubs.c	2006-09-13 13:48:01.000000000 -0400
+++ linux-2/fs/lockd/svcsubs.c	2006-09-13 22:50:51.000000000 -0400
@@ -32,6 +32,13 @@
 static struct nlm_file *	nlm_files[FILE_NRHASH];
 static DEFINE_MUTEX(nlm_file_mutex);
 
+/* 
+ * Global control structure for lock failover 
+ */
+static spinlock_t nlm_fo_lock=SPIN_LOCK_UNLOCKED;
+static int fo_fsid_cnt=0;
+LIST_HEAD(fo_fsid_list);
+
 #ifdef NFSD_DEBUG
 static inline void nlm_debug_print_fh(char *msg, struct nfs_fh *f)
 {
@@ -403,3 +410,176 @@ nlmsvc_fo_unlock(int *fsid)
 	return (nlm_traverse_files(NULL, fsid, NLM_ACT_FO_UNLOCK)); 
 }
 
+EXPORT_SYMBOL(nlmsvc_fo_setgrace);
+
+/*
+ * Add fsid into global fo_fsid_list (single linked list).
+ *
+ * Note that if this routine is repeatedly called with the very 
+ * same fsid, we could end up with multiple fsid in the global 
+ * fo_fsid_list. Instead of searching thru the list to purge old
+ * entries (to make the code un-necessarily complicated), we 
+ * will just leave the old entries there because the list is
+ * searched in top-down order (newer entry first). As soon as one 
+ * is found, the search stops. This implies the older entries will 
+ * not be used and always expire before new entry.    
+ *
+ * As an admin interface, the list is expected to be short and 
+ * entries are purged (expired) quickly.
+ *
+ * Also, please don't ask why using opencoded list manipulation, 
+ * instead of <linux/list.h>, unless you can point to me where
+ * in that file have existing macro and/or functions that can do
+ * single linked list. 
+ */
+int
+nlmsvc_fo_setgrace(int fsid)
+{
+	struct list_head *p, *tlist;
+	struct fo_fsid *per_fsid, *entry;
+	int done=0;
+
+	/* allocate the entry */
+	per_fsid = kmalloc(sizeof(struct fo_fsid), GFP_KERNEL);
+	if (per_fsid == NULL) {
+		printk("lockd: nlmsvc_fo_setgrace kmalloc fails\n");
+		return(-ENOMEM);
+	}
+
+	/* debug printk */
+	dprintk("lockd: nlmsvc_fo_setgrace fsid=%d jiffies=%lu\n", 
+		fsid, jiffies);
+
+	/* fill in info */
+	per_fsid->g_expire = set_grace_period();
+	per_fsid->g_fsid   = fsid;
+	per_fsid->g_flag   = 0;
+
+	spin_lock(&nlm_fo_lock);
+
+	if (list_empty(&fo_fsid_list)) {
+		list_add(&per_fsid->g_list, &fo_fsid_list);
+		fo_fsid_cnt = 1;
+		done = 1;
+		goto nlmsvc_fo_setgrace_out;
+	} else if (fo_fsid_cnt > NLM_FO_MAX_FSID_GP) {
+                kfree(per_fsid);
+                printk("lockd: fo_setgrace max cnt reached fsid=%d not added\n",                        fsid);
+                goto nlmsvc_fo_setgrace_out;
+        }
+
+	list_for_each_safe(p, tlist, &fo_fsid_list) {
+		entry = list_entry(p, struct fo_fsid, g_list);
+		if (!done) {
+			/* add the new fsid into the list */
+			if (entry->g_expire <= per_fsid->g_expire) {
+				list_add(&per_fsid->g_list, &entry->g_list);
+				fo_fsid_cnt++;
+				done = 1;
+			}
+		}
+		if (done && (entry->g_fsid == fsid)) {
+			/* multiple fsid(s) */
+			BUG_ON(entry->g_expire > per_fsid->g_expire); 
+			list_del(p); 
+			fo_fsid_cnt--;
+			kfree(entry);
+		} else if (time_before(entry->g_expire, jiffies)) {
+			/* garbage collection */
+			printk("nlmsvc fo_fsid = %d expires\n", entry->g_fsid);
+			list_del(p);
+			fo_fsid_cnt--;
+			kfree(entry);
+		} 
+	}
+	
+nlmsvc_fo_setgrace_out:
+
+	spin_unlock(&nlm_fo_lock);
+
+	/* debug */
+	if (done)
+		printk("nlmsvc fo setgrace: fsid=%d, jiffies=%lu, expire=%lu\n",
+			per_fsid->g_fsid, jiffies, per_fsid->g_expire);
+	else
+		printk("nlmsvc_fo_setgrace: adding fsid=%d fails\n", fsid);
+
+	return 0;
+}
+
+/* 
+ * Reset global fo_fsid_list list 
+ */
+void 
+nlmsvc_fo_reset_servs()
+{
+	struct fo_fsid *e_purge;
+	struct list_head *p, *tlist;
+
+	spin_lock(&nlm_fo_lock);
+
+	/* nothing to do */
+	if (list_empty(&fo_fsid_list)) {
+		spin_unlock(&nlm_fo_lock);
+		return;
+	}
+
+	dprintk("lockd: nlmsvc_fo_reset fo_fsid_list\n");
+
+	/* purge the entries */
+	list_for_each_safe(p, tlist, &fo_fsid_list) {
+		e_purge = list_entry(p, struct fo_fsid, g_list);
+		list_del(p);
+		kfree(e_purge);
+	}
+	fo_fsid_cnt = 0;
+
+	spin_unlock(&nlm_fo_lock);
+}
+
+/*
+ * Check whether the fsid is in the failover list: fo_fsid_list.
+ *	return TRUE (1) if fsid in nlm_serv.
+ */
+int
+nlmsvc_fo_check(struct nfs_fh *fh)
+{
+	struct fo_fsid *e_this;
+	struct list_head *p, *tlist;
+	int rc=0, this_fsid;
+
+	/* see if this fh has fsid */
+	if (!nlm_fo_get_fsid(fh, &this_fsid)) {
+		return 0;
+	}
+
+	spin_lock(&nlm_fo_lock);
+
+	/* no failover entry */
+	if (list_empty(&fo_fsid_list))  
+		goto nlmsvc_fo_check_out;
+
+	/* check to see whether this_fsid is in fo_fsid_list list */
+	list_for_each_safe(p, tlist, &fo_fsid_list) {
+		e_this = list_entry(p, struct fo_fsid, g_list);
+		if (time_before(e_this->g_expire, jiffies)) {
+			printk("lockd: fsid=%d grace period expires\n",
+				e_this->g_fsid);
+			list_del(p);
+			fo_fsid_cnt--;
+			kfree(e_this);
+		} else if (e_this->g_fsid == this_fsid) {
+			if (!e_this->g_flag) {
+				e_this->g_flag = 1;
+				printk("lockd: fsid=%d in grace period\n",
+					e_this->g_fsid);
+			}
+			rc = 1;
+		}
+	}
+
+nlmsvc_fo_check_out:
+	spin_unlock(&nlm_fo_lock);
+	return rc;
+}
+
--- linux-1/include/linux/lockd/bind.h	2006-09-03 21:51:41.000000000 -0400
+++ linux-2/include/linux/lockd/bind.h	2006-09-11 16:52:34.000000000 -0400
@@ -37,5 +37,8 @@ extern void	lockd_down(void);
  * NLM failover
  */
 extern int     nlmsvc_fo_unlock(int *fsid);
+extern int     nlmsvc_fo_setgrace(int fsid);
+extern void    nlmsvc_fo_reset_servs(void);
+
 
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-1/fs/nfsd/nfsctl.c	2006-09-03 21:51:40.000000000 -0400
+++ linux-2/fs/nfsd/nfsctl.c	2006-09-11 16:52:25.000000000 -0400
@@ -56,6 +56,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_NlmUnlock,
+	NFSD_NlmIgrace,
 	NFSD_Threads,
 	NFSD_Versions,
 	/*
@@ -93,6 +94,7 @@ static ssize_t write_recoverydir(struct 
 #define NFSDDBG_FACILITY	NFSDDBG_CLUSTER
 
 static ssize_t write_fo_unlock(struct file *file, char *buf, size_t size);
+static ssize_t write_fo_grace(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -104,6 +106,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_NlmUnlock] = write_fo_unlock,
+	[NFSD_NlmIgrace] = write_fo_grace,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Versions] = write_versions,
 #ifdef CONFIG_NFSD_V4
@@ -375,6 +378,34 @@ static ssize_t write_fo_unlock(struct fi
 	return strlen(buf);
 }
 
+static ssize_t write_fo_grace(struct file *file, char *buf, size_t size)
+{
+	char *mesg = buf;
+	int fsid, rc;
+ 
+	if (size <= 0) return -EINVAL;
+ 
+	/* convert string into a valid fsid */
+	rc = get_int(&mesg, &fsid);
+	if (rc) {
+		dprintk("do_nlm_fsid_grace: invalid fsid (%s)\n", buf);
+		return rc;
+	}
+ 
+	/* call nlm to set the grace period */
+	rc = nlmsvc_fo_setgrace(fsid);
+	if (rc) {
+		dprintk("nlmsvc_fo_setgrace return rc=%d\n", rc);
+		return rc;
+	}
+ 
+	dprintk("nlm set fsid=%d grace period\n", fsid);
+ 
+	/* done */
+	sprintf(buf, "nlm set per fsid=%d grace period\n", fsid);
+	return strlen(buf);
+}
+
 extern int nfsd_nrthreads(void);
 
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
@@ -524,6 +555,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_NlmUnlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_NlmIgrace] = {"nlm_set_igrace", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
--- linux-1/fs/lockd/svc4proc.c	2006-09-13 13:49:35.000000000 -0400
+++ linux-2/fs/lockd/svc4proc.c	2006-09-13 14:03:39.000000000 -0400
@@ -18,9 +18,22 @@
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
 
-
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
+extern struct list_head fo_fsid_list;
+
+/* 
+ * Check for per filesystem failover grace period 
+ */
+static inline int
+nlm4svc_fo_grace_period(struct nlm_args *argp) 
+{
+	if (unlikely(!list_empty(&fo_fsid_list)))
+		return(nlmsvc_fo_check(&argp->lock.fh));
+
+	return 0;
+}
+
 /*
  * Obtain client and file from arguments
  */
@@ -89,7 +102,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if ((nlmsvc_grace_period) || (nlm4svc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -119,7 +132,8 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if ((nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp))) 
+			&& !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -162,7 +176,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if ((nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp)))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -195,7 +209,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -330,7 +344,7 @@ nlm4svc_proc_share(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if ((nlmsvc_grace_period ||(nlm4svc_fo_grace_period(argp))) && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -363,7 +377,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rq
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
--- linux-1/fs/lockd/svcproc.c	2006-09-03 21:51:39.000000000 -0400
+++ linux-2/fs/lockd/svcproc.c	2006-09-13 13:51:59.000000000 -0400
@@ -50,6 +50,21 @@ cast_to_nlm(u32 status, u32 vers)
 #endif
 
 /*
+ * Check for per filesystem failover grace period 
+ */
+
+extern struct list_head fo_fsid_list;
+
+int inline
+nlmsvc_fo_grace_period(struct nlm_args *argp)
+{
+	if (unlikely(!list_empty(&fo_fsid_list)))
+		return(nlmsvc_fo_check(&argp->lock.fh));
+
+	return 0;
+}
+
+/*
  * Obtain client and file from arguments
  */
 static u32
@@ -115,7 +130,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || (nlmsvc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -146,7 +161,8 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if ((nlmsvc_grace_period || (nlmsvc_fo_grace_period(argp))) 
+			&& !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -189,7 +205,7 @@ nlmsvc_proc_cancel(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || nlmsvc_fo_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -222,7 +238,7 @@ nlmsvc_proc_unlock(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || nlmsvc_fo_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -359,7 +375,8 @@ nlmsvc_proc_share(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if ((nlmsvc_grace_period || (nlmsvc_fo_grace_period(argp))) 
+			&& !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -392,7 +409,7 @@ nlmsvc_proc_unshare(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || nlmsvc_fo_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
--- linux-1/fs/lockd/svc.c	2006-09-03 21:51:39.000000000 -0400
+++ linux-2/fs/lockd/svc.c	2006-09-11 16:51:58.000000000 -0400
@@ -71,7 +71,7 @@ static const int		nlm_port_min = 0, nlm_
 
 static struct ctl_table_header * nlm_sysctl_table;
 
-static unsigned long set_grace_period(void)
+unsigned long set_grace_period(void)
 {
 	unsigned long grace_period;
 
@@ -81,7 +81,6 @@ static unsigned long set_grace_period(vo
 				/ nlm_timeout) * nlm_timeout * HZ;
 	else
 		grace_period = nlm_timeout * 5 * HZ;
-	nlmsvc_grace_period = 1;
 	return grace_period + jiffies;
 }
 
@@ -129,6 +128,8 @@ lockd(struct svc_rqst *rqstp)
 	nlmsvc_timeout = nlm_timeout * HZ;
 
 	grace_period_expire = set_grace_period();
+	nlmsvc_grace_period = 1;
+	(void) nlmsvc_fo_reset_servs();
 
 	/*
 	 * The main request loop. We don't terminate until the last
@@ -143,6 +144,8 @@ lockd(struct svc_rqst *rqstp)
 			if (nlmsvc_ops) {
 				nlmsvc_invalidate_all();
 				grace_period_expire = set_grace_period();
+				nlmsvc_grace_period = 1;
+				(void) nlmsvc_fo_reset_servs();
 			}
 		}
 
@@ -189,6 +192,7 @@ lockd(struct svc_rqst *rqstp)
 			nlmsvc_invalidate_all();
 		nlm_shutdown_hosts();
 		nlmsvc_pid = 0;
+		(void) nlmsvc_fo_reset_servs();
 	} else
 		printk(KERN_DEBUG
 			"lockd: new process, skipping host shutdown\n");

--------------030407080200030202010901
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------030407080200030202010901
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030407080200030202010901--

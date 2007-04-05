From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 2/4 Revised] NLM - set per fsid grace period
Date: Thu, 05 Apr 2007 17:52:01 -0400
Message-ID: <46156F81.8010808@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090201000903030600020100"
Cc: Lon Hohberger <lhh@redhat.com>
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZaC6-0003k1-IP
	for nfs@lists.sourceforge.net; Thu, 05 Apr 2007 15:12:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZaC6-0004pv-Ln
	for nfs@lists.sourceforge.net; Thu, 05 Apr 2007 15:12:39 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l35MCb7J014498
	for <nfs@lists.sourceforge.net>; Thu, 5 Apr 2007 18:12:37 -0400
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
--------------090201000903030600020100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This change enables per NFS-export entry lockd grace period. The 
implementation is based on a double linked list fo_fsid_list that 
contains entries of fsid info. It is expected this would not be a 
frequent event. The fo_fsid_list is short and the entries expire within 
a maximum of 50 seconds.  The grace period setting follows the existing 
NLM grace period handling logic and is triggered via echoing the NFS 
export filesystem id into nfsd procfs entry as:

shell> echo 1234 > nlm_set_grace_for_fsid

-- Wendy

--------------090201000903030600020100
Content-Type: text/x-patch;
 name="002_nlm_grace_p.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="002_nlm_grace_p.patch"

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/svc.c              |    8 +-
 fs/lockd/svc4proc.c         |   15 ++-
 fs/lockd/svcproc.c          |   12 +--
 fs/lockd/svcsubs.c          |  169 ++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfsctl.c            |   27 +++++++
 include/linux/lockd/bind.h  |    2 
 include/linux/lockd/lockd.h |   30 +++++++
 7 files changed, 248 insertions(+), 15 deletions(-)

--- linux-nlm-1/include/linux/lockd/lockd.h	2007-03-26 10:29:44.000000000 -0400
+++ linux/include/linux/lockd/lockd.h	2007-03-26 17:37:39.000000000 -0400
@@ -114,6 +114,16 @@ struct nlm_file {
 	struct mutex		f_mutex;	/* avoid concurrent access */
 };
 
+#define NLM_FO_MAX_FSID_GP	127
+
+/* Server fsid linked list for NLM lock failover */
+struct fo_fsid {
+	struct list_head	g_list;		/* linked list */
+	unsigned long		g_expire;	/* when this grace period
+						 * will expire */
+	int			g_fsid;		/* exported fsid */
+};
+
 /*
  * This is a server block (i.e. a lock requested by some client which
  * couldn't be granted because of a conflicting lock).
@@ -193,6 +203,8 @@ void		  nlmsvc_traverse_blocks(struct nl
 					nlm_host_match_fn_t match);
 void		  nlmsvc_grant_reply(struct nlm_cookie *, __be32);
 
+unsigned long set_grace_period(void); /*required by svcsubs.c and svc.c 
+					to support nlm failover */
 /*
  * File handling for the server personality
  */
@@ -204,6 +216,7 @@ void		  nlmsvc_free_host_resources(struc
 void		  nlmsvc_invalidate_all(void);
 int		  nlmsvc_same_fsid(struct nlm_host *, struct nlm_host *);
 int		  nlmsvc_fo_unlock(int *fsid);
+int		  nlmsvc_fo_check(struct nfs_fh *fh);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
@@ -234,6 +247,23 @@ nlm_compare_locks(const struct file_lock
 	     &&(fl1->fl_type  == fl2->fl_type || fl2->fl_type == F_UNLCK);
 }
 
+extern struct list_head fo_fsid_list;
+
+/*Check for grace period: return TRUE or FALSE */
+static inline int
+nlmsvc_check_grace_period(struct nlm_args *argp)
+{
+	/* check for system wide grace period */
+	if (nlmsvc_grace_period)
+		return 1;
+
+	/* check for per exported fsid grace period */
+        if (unlikely(!list_empty(&fo_fsid_list)))
+                return(nlmsvc_fo_check(&argp->lock.fh));
+
+        return 0;
+}
+
 extern struct lock_manager_operations nlmsvc_lock_operations;
 
 #endif /* __KERNEL__ */
--- linux-nlm-1/include/linux/lockd/bind.h	2007-03-26 10:29:44.000000000 -0400
+++ linux/include/linux/lockd/bind.h	2007-03-26 11:11:14.000000000 -0400
@@ -38,5 +38,7 @@ extern int	nlmclnt_proc(struct inode *, 
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 extern int	nlmsvc_fo_unlock(int *fsid);
+extern int	nlmsvc_fo_setgrace(int fsid);
+extern void	nlmsvc_fo_reset_servs(void);
 
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-nlm-1/fs/nfsd/nfsctl.c	2007-03-26 10:23:36.000000000 -0400
+++ linux/fs/nfsd/nfsctl.c	2007-03-26 15:40:12.000000000 -0400
@@ -55,6 +55,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_NlmUnlock,
+	NFSD_NlmGrace,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -91,6 +92,8 @@ static ssize_t write_maxblksize(struct f
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
+static ssize_t write_fo_unlock(struct file *file, char *buf, size_t size);
+static ssize_t write_fo_grace(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -102,6 +105,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_NlmUnlock] = write_fo_unlock,
+	[NFSD_NlmGrace] = write_fo_grace,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -372,6 +376,28 @@ static ssize_t write_fo_unlock(struct fi
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
+	if (rc) 
+		return rc;
+ 
+	/* call nlm to set the grace period */
+	rc = nlmsvc_fo_setgrace(fsid);
+	if (rc) 
+		return rc;
+ 
+	/* done */
+	sprintf(buf, "nlm set per fsid=%d grace period\n", fsid);
+	return strlen(buf);
+}
+
 extern int nfsd_nrthreads(void);
 
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
@@ -676,6 +702,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_NlmUnlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_NlmGrace] = {"nlm_set_grace_for_fsid", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
--- linux-nlm-1/fs/lockd/svcsubs.c	2007-03-26 10:23:22.000000000 -0400
+++ linux/fs/lockd/svcsubs.c	2007-03-26 16:01:54.000000000 -0400
@@ -31,6 +31,13 @@
 static struct hlist_head	nlm_files[FILE_NRHASH];
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
@@ -430,3 +437,165 @@ nlmsvc_fo_unlock(int *fsid)
 }
 
 
+EXPORT_SYMBOL(nlmsvc_fo_setgrace);
+
+/*
+ * Add fsid into global fo_fsid_list.
+ *
+ * If this routine is repeatedly called with the same fsid, instead 
+ * of searching thru the list to purge old entries (to make the code 
+ * un-necessarily complicated), we will keep the old entries. Since
+ * the list is later searched in top-down order (newer entry first), 
+ * as soon as one is found, the search stops. This implies the older 
+ * entries will not be used and always expire before new entry.    
+ *
+ * As an admin interface, the list is expected to be short and 
+ * entries are purged (expired) quickly.
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
+			dprintk("nlmsvc fo_fsid = %d expires\n", entry->g_fsid);
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
+		dprintk("nlmsvc fo setgrace: fsid=%d, jiffies=%lu, expire=%lu\n",
+			per_fsid->g_fsid, jiffies, per_fsid->g_expire);
+	else
+		dprintk("nlmsvc_fo_setgrace: adding fsid=%d fails\n", fsid);
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
+	if (!get_fsid(fh, &this_fsid)) {
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
+			printk("lockd: fsid=%d in grace period\n",
+				e_this->g_fsid);
+			rc = 1;
+		}
+	}
+
+nlmsvc_fo_check_out:
+	spin_unlock(&nlm_fo_lock);
+	return rc;
+}
+
--- linux-nlm-1/fs/lockd/svc4proc.c	2007-03-26 10:23:22.000000000 -0400
+++ linux/fs/lockd/svc4proc.c	2007-03-26 17:34:27.000000000 -0400
@@ -18,9 +18,10 @@
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
 
-
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
+extern struct list_head fo_fsid_list;
+
 /*
  * Obtain client and file from arguments
  */
@@ -89,7 +90,7 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -119,7 +120,7 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (nlmsvc_check_grace_period(argp) && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -162,7 +163,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -195,7 +196,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -332,7 +333,7 @@ nlm4svc_proc_share(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (nlmsvc_check_grace_period(argp) && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -365,7 +366,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rq
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
--- linux-nlm-1/fs/lockd/svcproc.c	2007-03-26 10:23:23.000000000 -0400
+++ linux/fs/lockd/svcproc.c	2007-03-26 17:37:30.000000000 -0400
@@ -117,7 +117,7 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -148,7 +148,7 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (nlmsvc_check_grace_period(argp) && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -191,7 +191,7 @@ nlmsvc_proc_cancel(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -224,7 +224,7 @@ nlmsvc_proc_unlock(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -363,7 +363,7 @@ nlmsvc_proc_share(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if (nlmsvc_check_grace_period(argp) && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -396,7 +396,7 @@ nlmsvc_proc_unshare(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_check_grace_period(argp)) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
--- linux-nlm-1/fs/lockd/svc.c	2007-03-26 10:23:22.000000000 -0400
+++ linux/fs/lockd/svc.c	2007-03-26 11:16:27.000000000 -0400
@@ -75,7 +75,7 @@ static const int		nlm_port_min = 0, nlm_
 
 static struct ctl_table_header * nlm_sysctl_table;
 
-static unsigned long set_grace_period(void)
+unsigned long set_grace_period(void)
 {
 	unsigned long grace_period;
 
@@ -85,7 +85,6 @@ static unsigned long set_grace_period(vo
 				/ nlm_timeout) * nlm_timeout * HZ;
 	else
 		grace_period = nlm_timeout * 5 * HZ;
-	nlmsvc_grace_period = 1;
 	return grace_period + jiffies;
 }
 
@@ -133,6 +132,8 @@ lockd(struct svc_rqst *rqstp)
 	nlmsvc_timeout = nlm_timeout * HZ;
 
 	grace_period_expire = set_grace_period();
+	nlmsvc_grace_period = 1;
+	(void) nlmsvc_fo_reset_servs();
 
 	/*
 	 * The main request loop. We don't terminate until the last
@@ -148,6 +149,8 @@ lockd(struct svc_rqst *rqstp)
 			if (nlmsvc_ops) {
 				nlmsvc_invalidate_all();
 				grace_period_expire = set_grace_period();
+				nlmsvc_grace_period = 1;
+				(void) nlmsvc_fo_reset_servs();
 			}
 		}
 
@@ -194,6 +197,7 @@ lockd(struct svc_rqst *rqstp)
 		nlm_shutdown_hosts();
 		nlmsvc_pid = 0;
 		nlmsvc_serv = NULL;
+		(void) nlmsvc_fo_reset_servs();
 	} else
 		printk(KERN_DEBUG
 			"lockd: new process, skipping host shutdown\n");



--------------090201000903030600020100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------090201000903030600020100
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090201000903030600020100--

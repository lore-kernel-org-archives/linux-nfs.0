From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 2/5] NLM failover - per fs grace period
Date: Mon, 14 Aug 2006 02:00:21 -0400
Message-ID: <1155535221.3416.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-OBZdBKobHtIWTMDWkOvO"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCVJR-0006GO-O5
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 22:48:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCVJR-0007zs-Jp
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 22:48:34 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k7E5mWAU021246
	for <nfs@lists.sourceforge.net>; Mon, 14 Aug 2006 01:48:32 -0400
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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


--=-OBZdBKobHtIWTMDWkOvO
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This change enables per NFS-export entry lockd grace period. The
implementation is based on a global single linked list nlm_servs that
contains entries of fsid info. It is expected this would not be a
frequent event. The nlm_servs list should be short and the entries
expire within a maximum of 50 seconds.  The grace period setting follows
the existing NLM grace period handling logic and is triggered via
echoing the NFS export filesystem id into /proc/fs/nfsd/nlm_set_igrace
file as:

shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/svc.c              |    8 +-
 fs/lockd/svc4proc.c         |   31 +++++++---
 fs/lockd/svcproc.c          |   29 +++++++--
 fs/lockd/svcsubs.c          |  133 ++++++++++++++++++++++++++++++++++++
++++++++ 
 fs/nfsd/nfsctl.c            |   32 ++++++++++
 include/linux/lockd/bind.h  |    3
 include/linux/lockd/lockd.h |   10 +++
 7 files changed, 230 insertions(+), 16 deletions(-)



--=-OBZdBKobHtIWTMDWkOvO
Content-Disposition: attachment; filename=gfs_nlm_igrace.patch
Content-Type: text/x-patch; name=gfs_nlm_igrace.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-1/include/linux/lockd/lockd.h	2006-08-11 10:12:29.000000000 -0400
+++ linux-2/include/linux/lockd/lockd.h	2006-08-12 02:02:42.000000000 -0400
@@ -107,6 +107,13 @@ struct nlm_file {
 	int		       	f_hash;		/* hash of f_handle */
 };
 
+/* Server fsid linked list for NLM lock failover */
+struct nlm_serv {
+	struct nlm_serv*	s_next;		/* linked list */
+	unsigned long		s_grace_period;	/* per fsid grace period */
+	int			s_fsid;		/* export fsid */
+};
+
 /*
  * This is a server block (i.e. a lock requested by some client which
  * couldn't be granted because of a conflicting lock).
@@ -188,6 +195,8 @@ void		  nlmsvc_traverse_blocks(struct nl
 					int action);
 void	  nlmsvc_grant_reply(struct svc_rqst *, struct nlm_cookie *, u32);
 
+unsigned long set_grace_period(void); /*required by svcsubs.c and svc.c 
+					to support nlm failover */
 /*
  * File handling for the server personality
  */
@@ -198,6 +207,7 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 int 		  nlmsvc_fo_unlock(int *fsid);
+int 		  nlmsvc_fo_check(struct nfs_fh *fh);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- linux-1/fs/lockd/svcsubs.c	2006-08-11 10:12:29.000000000 -0400
+++ linux-2/fs/lockd/svcsubs.c	2006-08-11 12:09:03.000000000 -0400
@@ -62,6 +62,10 @@ static inline void nlm_debug_print_file(
 }
 #endif
 
+/* Global control structure for lock failover */
+static spinlock_t nlm_fo_lock=SPIN_LOCK_UNLOCKED;
+struct nlm_serv *nlm_servs=NULL;
+
 static inline unsigned int file_hash(struct nfs_fh *f)
 {
 	unsigned int tmp=0;
@@ -400,3 +404,132 @@ nlmsvc_fo_unlock(int *fsid)
 	return (nlm_traverse_files(NULL, fsid, NLM_ACT_FO_UNLOCK)); 
 }
 
+EXPORT_SYMBOL(nlmsvc_fo_setgrace);
+
+/*
+ * Add fsid into global nlm_servs list.
+ */
+int
+nlmsvc_fo_setgrace(int fsid)
+{
+	struct nlm_serv *per_fsid, *entry;
+
+	/* allocate the entry */
+	per_fsid = kmalloc(sizeof(struct nlm_serv), GFP_KERNEL);
+	if (per_fsid == NULL) {
+		printk("lockd: nlmsvc_fo_setgrace kmalloc fails\n");
+		return(-ENOMEM);
+	}
+
+	dprintk("lockd: nlmsvc_fo_setgrace fsid=%d jiffies=%lu\n", 
+		fsid, jiffies);
+
+	/* fill in info */
+	per_fsid->s_grace_period = set_grace_period();
+	per_fsid->s_fsid = fsid;
+
+	/* link into the global list */
+	spin_lock(&nlm_fo_lock);
+	
+	entry = nlm_servs;
+	per_fsid->s_next = entry;
+	nlm_servs = per_fsid;
+
+	/* done */
+	spin_unlock(&nlm_fo_lock);
+	return 0;
+}
+
+/* nlm_servs gargabe collection 
+ *  - caller should hold nlm_ip_mutex
+ */
+static inline void
+__nlm_servs_gc(struct nlm_serv *e_purge)
+{
+	struct nlm_serv *e_next;
+
+	while (e_purge) {
+		e_next = e_purge->s_next;
+		dprintk("lockd: purge fsid=%d grace period at jiffies=%lu\n",
+			e_purge->s_fsid, jiffies);
+		kfree(e_purge);
+		e_purge = e_next;
+	}
+}
+
+/* 
+ * Reset global nlm_servs list 
+ */
+void 
+nlmsvc_fo_reset_servs()
+{
+	struct nlm_serv *e_purge;
+
+	spin_lock(&nlm_fo_lock);
+
+	/* nothing to do */
+	if (!nlm_servs) {
+		spin_unlock(&nlm_fo_lock);
+		return;
+	}
+
+	dprintk("lockd: nlmsvc_fo_reset nlm_servs\n");
+
+	/* purge the entries */
+	e_purge   = nlm_servs;
+	nlm_servs = NULL;
+	__nlm_servs_gc(e_purge);
+
+	spin_unlock(&nlm_fo_lock);
+	return;
+}
+
+/*
+ * Check whether the fsid is in the failover list: nlm_servs.
+ *	return TRUE (1) if fsid in nlm_serv.
+ */
+int
+nlmsvc_fo_check(struct nfs_fh *fh)
+{
+	struct nlm_serv **e_top, *e_this, *e_purge=NULL;
+	int rc=0, this_fsid, not_found;
+
+	spin_lock(&nlm_fo_lock);
+
+	/* no failover entry */
+	if (!(e_this = nlm_servs))  
+		goto nlmsvc_fo_check_out;
+
+	/* see if this fh has fsid */
+	not_found = nlm_fo_get_fsid(fh, &this_fsid);
+	if (not_found) 
+		goto nlmsvc_fo_check_out;
+
+	/* check to see whether this_fsid is in nlm_servs list */
+	e_top = &nlm_servs;
+	while (e_this) {
+		if (time_before(e_this->s_grace_period, jiffies)) {
+			dprintk("lockd: fsid=%d grace period expires\n",
+				e_this->s_fsid);
+			e_purge = e_this;
+			break;
+		} else if (e_this->s_fsid == this_fsid) {
+			dprintk("lockd: fsid=%d in grace period\n",
+				e_this->s_fsid);
+			rc = 1;
+		}
+		e_top = &(e_this->s_next);
+		e_this = e_this->s_next;
+	}
+
+	/* piggy back nlm_servs garbage collection */
+	if (e_purge) {
+		*e_top = NULL;
+		__nlm_servs_gc(e_purge);
+	}
+
+nlmsvc_fo_check_out:
+	spin_unlock(&nlm_fo_lock);
+	return rc;
+}
+
--- linux-1/include/linux/lockd/bind.h	2006-08-11 10:12:29.000000000 -0400
+++ linux-2/include/linux/lockd/bind.h	2006-08-11 10:17:04.000000000 -0400
@@ -37,5 +37,8 @@ extern void	lockd_down(void);
  * NLM failover
  */
 extern int     nlmsvc_fo_unlock(int *fsid);
+extern int     nlmsvc_fo_setgrace(int fsid);
+extern void    nlmsvc_fo_reset_servs(void);
+
 
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-1/fs/nfsd/nfsctl.c	2006-08-11 10:12:29.000000000 -0400
+++ linux-2/fs/nfsd/nfsctl.c	2006-08-11 10:17:04.000000000 -0400
@@ -56,6 +56,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_Nlm_unlock,
+	NFSD_Nlm_igrace,
 	NFSD_Threads,
 	NFSD_Versions,
 	/*
@@ -93,6 +94,7 @@ static ssize_t write_recoverydir(struct 
 #define NFSDDBG_FACILITY	NFSDDBG_CLUSTER
 
 static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size);
+static ssize_t do_nlm_fs_grace(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -104,6 +106,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Nlm_unlock] = do_nlm_fo_unlock,
+	[NFSD_Nlm_igrace] = do_nlm_fs_grace,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Versions] = write_versions,
 #ifdef CONFIG_NFSD_V4
@@ -348,6 +351,34 @@ static ssize_t write_filehandle(struct f
 	return mesg - buf;	
 }
 
+static ssize_t do_nlm_fs_grace(struct file *file, char *buf, size_t size)
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
 static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
@@ -523,6 +554,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Nlm_unlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Nlm_igrace] = {"nlm_set_igrace", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
--- linux-1/fs/lockd/svc4proc.c	2006-08-11 10:11:30.000000000 -0400
+++ linux-2/fs/lockd/svc4proc.c	2006-08-12 02:03:55.000000000 -0400
@@ -21,6 +21,20 @@
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
+extern struct nlm_serv *nlm_servs;
+
+/* 
+ * Check for per filesystem failover grace period 
+ */
+static inline int
+nlm4svc_fo_grace_period(struct nlm_args *argp) 
+{
+	if (unlikely(nlm_servs))
+		return(nlmsvc_fo_check(&argp->lock.fh));
+
+	return 0;
+}
+
 /*
  * Obtain client and file from arguments
  */
@@ -89,13 +103,13 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept test requests during grace period */
-	if (nlmsvc_grace_period) {
+	if ((nlmsvc_grace_period) || (nlm4svc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if (resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file))
 		return rpc_success;
 
 	/* Now check for conflicting locks */
@@ -119,13 +133,14 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if ((nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp))) 
+			&& !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if (resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file))
 		return rpc_success;
 
 #if 0
@@ -162,7 +177,7 @@ nlm4svc_proc_cancel(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if ((nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp)))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -195,7 +210,7 @@ nlm4svc_proc_unlock(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -330,7 +345,7 @@ nlm4svc_proc_share(struct svc_rqst *rqst
 	resp->cookie = argp->cookie;
 
 	/* Don't accept new lock requests during grace period */
-	if (nlmsvc_grace_period && !argp->reclaim) {
+	if ((nlmsvc_grace_period ||(nlm4svc_fo_grace_period(argp))) && !argp->reclaim) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
@@ -363,7 +378,7 @@ nlm4svc_proc_unshare(struct svc_rqst *rq
 	resp->cookie = argp->cookie;
 
 	/* Don't accept requests during grace period */
-	if (nlmsvc_grace_period) {
+	if (nlmsvc_grace_period || (nlm4svc_fo_grace_period(argp))) {
 		resp->status = nlm_lck_denied_grace_period;
 		return rpc_success;
 	}
--- linux-1/fs/lockd/svcproc.c	2006-08-11 10:11:30.000000000 -0400
+++ linux-2/fs/lockd/svcproc.c	2006-08-12 01:57:38.000000000 -0400
@@ -50,6 +50,21 @@ cast_to_nlm(u32 status, u32 vers)
 #endif
 
 /*
+ * Check for per filesystem failover grace period 
+ */
+
+extern struct nlm_serv *nlm_servs;
+
+static inline int
+nlmsvc_fo_grace_period(struct nlm_args *argp)
+{
+	if (unlikely(nlm_servs))
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
--- linux-1/fs/lockd/svc.c	2006-08-11 10:11:30.000000000 -0400
+++ linux-2/fs/lockd/svc.c	2006-08-11 10:17:04.000000000 -0400
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

--=-OBZdBKobHtIWTMDWkOvO
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-OBZdBKobHtIWTMDWkOvO
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-OBZdBKobHtIWTMDWkOvO--

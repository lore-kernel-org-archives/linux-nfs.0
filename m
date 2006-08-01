From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 2/3] NLM lock failover
Date: Mon, 31 Jul 2006 22:16:17 -0400
Message-ID: <1154398577.3378.33.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FJUQYwbI7eNAZi8wglXQ"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7jco-0007ot-BK
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 19:04:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7jco-0000b7-21
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 19:04:50 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k7124iar001558
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 22:04:44 -0400
To: nfs@lists.sourceforge.net
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


--=-FJUQYwbI7eNAZi8wglXQ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This change enables per ip NLM lock grace period. The implementation is
based on a global single linked list nlm_servs that contains entries of
per server ip info. It is expected this would not be a frequent event.
The nlm_servs list would be short and the entries expire within a
maximum of 50 seconds. The grace period setting follows the existing NLM
grace period handling logic and is triggered via echoing the ipv4 dot
address into /proc/fs/nfsd/nlm_set_ip_grace file.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger <lhh@redhat.com>

fs/lockd/svc.c              |    8 +-
fs/lockd/svc4proc.c         |   41 ++++++++++---
fs/lockd/svcproc.c          |   43 +++++++++++---
fs/lockd/svcsubs.c          |  133 +++++++++++++++++++++++++++++++++++++
++++++ 
fs/nfsd/nfsctl.c            |   36 +++++++++++
include/linux/lockd/bind.h  |    3
include/linux/lockd/lockd.h |   15 ++++
7 files changed, 261 insertions(+), 18 deletions(-)




--=-FJUQYwbI7eNAZi8wglXQ
Content-Disposition: attachment; filename=gfs_nlm_ip_grace.patch
Content-Type: text/x-patch; name=gfs_nlm_ip_grace.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-1/include/linux/lockd/lockd.h	2006-07-28 15:47:27.000000000 -0400
+++ linux-2/include/linux/lockd/lockd.h	2006-07-28 15:51:49.000000000 -0400
@@ -108,6 +108,13 @@ struct nlm_file {
 	__u32			f_iaddr;	/* server ip for failover */
 };
 
+/* Server ip linked list for NLM lock failover */
+struct nlm_serv {
+	struct nlm_serv *	s_next;		/* linked list */
+	unsigned long		s_grace_period;	/* per ip grace period */
+	struct in_addr		s_ip;		/* server ip */
+};
+
 /*
  * This is a server block (i.e. a lock requested by some client which
  * couldn't be granted because of a conflicting lock).
@@ -137,6 +144,13 @@ struct nlm_block {
 #define NLM_ACT_FO_UNLOCK	3		/* failover release locks */
 
 /*
+ * Floating ip failover grace period check
+ */
+#define NLMSVC_FO_PASSTHRU	0
+#define NLMSVC_FO_RECLAIM	1
+#define NLMSVC_FO_BLOCK_ANY	2
+
+/*
  * Global variables
  */
 extern struct rpc_program	nlm_program;
@@ -199,6 +213,7 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 int 		  nlmsvc_fo_unlock(struct in_addr *);
+int 		  nlmsvc_fo_check(__u32);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- linux-1/fs/lockd/svcsubs.c	2006-07-28 15:47:28.000000000 -0400
+++ linux-2/fs/lockd/svcsubs.c	2006-07-31 17:29:24.000000000 -0400
@@ -62,6 +62,10 @@ static inline void nlm_debug_print_file(
 }
 #endif
 
+/* Global control structure for lock failover */
+static DEFINE_MUTEX(nlm_ip_mutex);
+struct nlm_serv *nlm_servs=NULL;
+
 static inline unsigned int file_hash(struct nfs_fh *f)
 {
 	unsigned int tmp=0;
@@ -379,3 +383,132 @@ nlmsvc_fo_unlock(struct in_addr *serv_ip
 	return (nlm_traverse_files(NULL, serv_ip, NLM_ACT_FO_UNLOCK)); 
 }
 
+extern unsigned long set_grace_period(void); /* see fs/lockd/svc.c */
+
+EXPORT_SYMBOL(nlmsvc_fo_setgrace);
+
+/*
+ * Add serv_ip into global nlm_servs list.
+ */
+int
+nlmsvc_fo_setgrace(struct in_addr *serv_ip)
+{
+	struct nlm_serv *per_ip, *entry;
+
+	/* allocate the entry */
+	per_ip = kmalloc(sizeof(struct nlm_serv), GFP_KERNEL);
+	if (per_ip == NULL) {
+		printk("lockd: nlmsvc_fo_setgrace kmalloc fails\n");
+		return(-ENOMEM);
+	}
+
+	dprintk("lockd: nlmsvc_fo_setgrace ip=%u.%u.%u.%u jiffies=%lu\n",
+		NIPQUAD(serv_ip->s_addr), jiffies);
+
+	/* fill in info */
+	per_ip->s_grace_period = set_grace_period();
+	per_ip->s_ip = *serv_ip;
+
+	/* link into the global list */
+	mutex_lock(&nlm_ip_mutex);
+
+	entry = nlm_servs;
+	per_ip->s_next = entry;
+	nlm_servs = per_ip;
+
+	/* done */
+	mutex_unlock(&nlm_ip_mutex);
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
+		dprintk("lockd: nlm purge per ip (%u.%u.%u.%u) grace period at jiffies=%lu\n",
+			NIPQUAD(e_purge->s_ip.s_addr), jiffies);
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
+	mutex_lock(&nlm_ip_mutex);
+
+	/* nothing to do */
+	if (!nlm_servs) {
+		mutex_unlock(&nlm_ip_mutex);
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
+	mutex_unlock(&nlm_ip_mutex);
+	return;
+}
+
+/*
+ * Check whether the ip is in the failover list: nlm_servs.
+ */
+int
+nlmsvc_fo_check(__u32 this_ip)
+{
+	struct nlm_serv **e_top, *e_this, *e_purge=NULL;
+	int rc=0;
+
+	dprintk("lockd: nlmsvc_fo_check (%u.%u.%u.%u)\n", NIPQUAD(this_ip));
+
+	mutex_lock(&nlm_ip_mutex);
+
+	/* no failover floating ip */
+	if (!(e_this = nlm_servs))  {
+		mutex_unlock(&nlm_ip_mutex);
+		return 0;
+	}
+
+	/* check to see whether this_ip is in nlm_servs list */
+	e_top = &nlm_servs;
+	while (e_this) {
+		if (time_before(e_this->s_grace_period, jiffies)) {
+			dprintk("lockd: nlmsvc %u.%u.%u.%u grace period expires\n",
+				NIPQUAD(e_this->s_ip.s_addr));
+			e_purge = e_this;
+			break;
+		} else if (e_this->s_ip.s_addr == this_ip) {
+			dprintk("lockd: nlmsvc %u.%u.%u.%u in grace period\n",
+				NIPQUAD(e_this->s_ip.s_addr));
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
+	/* done */
+	mutex_unlock(&nlm_ip_mutex);
+	return rc;
+}
+
--- linux-1/include/linux/lockd/bind.h	2006-07-28 15:47:28.000000000 -0400
+++ linux-2/include/linux/lockd/bind.h	2006-07-28 15:51:49.000000000 -0400
@@ -37,5 +37,8 @@ extern void	lockd_down(void);
  * NLM failover
  */
 extern int     nlmsvc_fo_unlock(struct in_addr *);
+extern int     nlmsvc_fo_setgrace(struct in_addr *);
+extern void    nlmsvc_fo_reset_servs(void);
+
 
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-1/fs/nfsd/nfsctl.c	2006-07-31 18:04:49.000000000 -0400
+++ linux-2/fs/nfsd/nfsctl.c	2006-07-31 18:04:01.000000000 -0400
@@ -56,6 +56,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_Nlm_unlock,
+	NFSD_Nlm_ipgrace,
 	NFSD_Threads,
 	NFSD_Versions,
 	/*
@@ -93,6 +94,7 @@ static ssize_t write_recoverydir(struct 
 #define NFSDDBG_FACILITY	NFSDDBG_CLUSTER
 
 static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size);
+static ssize_t do_nlm_ip_grace(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -104,6 +106,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Nlm_unlock] = do_nlm_fo_unlock,
+	[NFSD_Nlm_ipgrace] = do_nlm_ip_grace,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Versions] = write_versions,
 #ifdef CONFIG_NFSD_V4
@@ -362,9 +365,38 @@ int __get_nlm_host(char *buf, size_t siz
 	host_addr->s_addr = in_aton(buf);
 	dprintk("nfsd: __get_nlm_host (%u.%u.%u.%u)\n",
 		NIPQUAD(host_addr->s_addr));
+
 	return 0;
 }
 
+static ssize_t do_nlm_ip_grace(struct file *file, char *buf, size_t size)
+{
+	struct in_addr serv_addr;
+	int rc;
+
+	/* convert string into valid ip address */
+	rc = __get_nlm_host(buf, size, &serv_addr);
+	if (rc) {
+		dprintk("do_nlm_ip_grace: invalid ip (%s)\n", buf);
+		return rc;
+	}
+
+	/* call nlm to set the grace period */
+	rc = nlmsvc_fo_setgrace(&serv_addr);
+	if (rc) {
+		dprintk("nlmsvc_fo_setgrace return rc=%d\n", rc);
+		return rc;
+	}
+
+	dprintk("nlm set per ip grace period for %u.%u.%u.%u\n",
+		NIPQUAD(serv_addr.s_addr));
+
+	/* done */
+	sprintf(buf, "nlm set per ip grace period for %u.%u.%u.%u\n",
+		NIPQUAD(serv_addr.s_addr));
+	return strlen(buf);
+}
+
 static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size)
 {
 	struct in_addr serv_addr;
@@ -384,6 +416,9 @@ static ssize_t do_nlm_fo_unlock(struct f
 		return rc;
 	}
 
+	dprintk("nlm ip unlock released for %u.%u.%u.%u\n",
+		NIPQUAD(serv_addr.s_addr));
+
 	/* done */
 	sprintf(buf, "nlm ip unlock released for %u.%u.%u.%u\n",
 		NIPQUAD(serv_addr.s_addr));
@@ -539,6 +574,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Nlm_unlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Nlm_ipgrace] = {"nlm_set_ip_grace", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
--- linux-1/fs/lockd/svc4proc.c	2006-07-28 15:46:04.000000000 -0400
+++ linux-2/fs/lockd/svc4proc.c	2006-07-28 15:51:49.000000000 -0400
@@ -21,12 +21,15 @@
 
 #define NLMDBG_FACILITY		NLMDBG_CLIENT
 
+extern struct nlm_serv *nlm_servs;
+
 /*
  * Obtain client and file from arguments
  */
 static u32
 nlm4svc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
-			struct nlm_host **hostp, struct nlm_file **filp)
+			struct nlm_host **hostp, struct nlm_file **filp,
+			int passthru_check)
 {
 	struct nlm_host		*host = NULL;
 	struct nlm_file		*file = NULL;
@@ -37,6 +40,22 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 	if (!nlmsvc_ops)
 		return nlm_lck_denied_nolocks;
 
+	/* Floating ip failover grace period */
+	if (unlikely(nlm_servs)) {
+		if (nlmsvc_fo_check(rqstp->rq_daddr)) {
+			dprintk("lockd: nlm v4 fo passthru_check= %d\n", 
+				passthru_check);
+			switch (passthru_check) {
+				case NLMSVC_FO_PASSTHRU:
+					break;
+				case NLMSVC_FO_RECLAIM:
+					if (argp->reclaim) break;
+				default:
+					return nlm_lck_denied_grace_period;
+			}
+		}
+	}
+
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
 	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
@@ -95,7 +114,8 @@ nlm4svc_proc_test(struct svc_rqst *rqstp
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Now check for conflicting locks */
@@ -125,7 +145,8 @@ nlm4svc_proc_lock(struct svc_rqst *rqstp
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file,
+		NLMSVC_FO_RECLAIM)))
 		return rpc_success;
 
 #if 0
@@ -168,7 +189,8 @@ nlm4svc_proc_cancel(struct svc_rqst *rqs
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Try to cancel request. */
@@ -201,7 +223,8 @@ nlm4svc_proc_unlock(struct svc_rqst *rqs
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Now try to remove the lock */
@@ -336,7 +359,8 @@ nlm4svc_proc_share(struct svc_rqst *rqst
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_RECLAIM)))
 		return rpc_success;
 
 	/* Now try to create the share */
@@ -369,7 +393,8 @@ nlm4svc_proc_unshare(struct svc_rqst *rq
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlm4svc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Now try to lock the file */
@@ -404,7 +429,7 @@ nlm4svc_proc_free_all(struct svc_rqst *r
 	struct nlm_host	*host;
 
 	/* Obtain client */
-	if (nlm4svc_retrieve_args(rqstp, argp, &host, NULL))
+	if (nlm4svc_retrieve_args(rqstp, argp, &host, NULL, NLMSVC_FO_PASSTHRU))
 		return rpc_success;
 
 	nlmsvc_free_host_resources(host);
--- linux-1/fs/lockd/svcproc.c	2006-07-28 15:46:04.000000000 -0400
+++ linux-2/fs/lockd/svcproc.c	2006-07-28 15:51:49.000000000 -0400
@@ -49,12 +49,15 @@ cast_to_nlm(u32 status, u32 vers)
 #define cast_status(status) (status)
 #endif
 
+extern struct nlm_serv *nlm_servs;
+
 /*
  * Obtain client and file from arguments
  */
 static u32
 nlmsvc_retrieve_args(struct svc_rqst *rqstp, struct nlm_args *argp,
-			struct nlm_host **hostp, struct nlm_file **filp)
+			struct nlm_host **hostp, struct nlm_file **filp,
+			int passthru_check)
 {
 	struct nlm_host		*host = NULL;
 	struct nlm_file		*file = NULL;
@@ -65,6 +68,24 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 	if (!nlmsvc_ops)
 		return nlm_lck_denied_nolocks;
 
+	/* Floating ip failover grace period */
+	if (unlikely(nlm_servs)) {
+		if (nlmsvc_fo_check(rqstp->rq_daddr)) {
+
+			dprintk("lockd: nlm fo passthru_check = %d\n", 
+				passthru_check);
+
+			switch (passthru_check) {
+				case NLMSVC_FO_PASSTHRU:
+					break;
+				case NLMSVC_FO_RECLAIM:
+					if (argp->reclaim) break;
+				default:
+					return nlm_lck_denied_grace_period;
+			}
+		}
+	}
+
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
 	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
@@ -121,7 +142,8 @@ nlmsvc_proc_test(struct svc_rqst *rqstp,
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Now check for conflicting locks */
@@ -152,7 +174,8 @@ nlmsvc_proc_lock(struct svc_rqst *rqstp,
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_RECLAIM)))
 		return rpc_success;
 
 #if 0
@@ -195,7 +218,8 @@ nlmsvc_proc_cancel(struct svc_rqst *rqst
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Try to cancel request. */
@@ -228,7 +252,8 @@ nlmsvc_proc_unlock(struct svc_rqst *rqst
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Now try to remove the lock */
@@ -365,7 +390,8 @@ nlmsvc_proc_share(struct svc_rqst *rqstp
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_RECLAIM)))
 		return rpc_success;
 
 	/* Now try to create the share */
@@ -398,7 +424,8 @@ nlmsvc_proc_unshare(struct svc_rqst *rqs
 	}
 
 	/* Obtain client and file */
-	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file)))
+	if ((resp->status = nlmsvc_retrieve_args(rqstp, argp, &host, &file,
+			NLMSVC_FO_BLOCK_ANY)))
 		return rpc_success;
 
 	/* Now try to unshare the file */
@@ -433,7 +460,7 @@ nlmsvc_proc_free_all(struct svc_rqst *rq
 	struct nlm_host	*host;
 
 	/* Obtain client */
-	if (nlmsvc_retrieve_args(rqstp, argp, &host, NULL))
+	if (nlmsvc_retrieve_args(rqstp, argp, &host, NULL, NLMSVC_FO_PASSTHRU))
 		return rpc_success;
 
 	nlmsvc_free_host_resources(host);
--- linux-1/fs/lockd/svc.c	2006-07-28 15:46:04.000000000 -0400
+++ linux-2/fs/lockd/svc.c	2006-07-28 15:51:49.000000000 -0400
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

--=-FJUQYwbI7eNAZi8wglXQ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-FJUQYwbI7eNAZi8wglXQ
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-FJUQYwbI7eNAZi8wglXQ--

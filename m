From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 2/3] NLM per-ip grace period - core
Date: Fri, 25 Jan 2008 00:17:30 -0500
Message-ID: <479970EA.2060900@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010106040807010001010605"
To: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
Return-path: <cluster-devel-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010106040807010001010605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The logic is implemented on top of linux nfsd procfs with core functions 
residing in lockd kernel module. Entry function is nlmsvc_resume_ip() 
where it stores the requested ip interface into a linked-list 
nlm_failover_list. The list entry count is nlm_failover_cnt and access 
protection is done by nlm_failover_mutex. Entry in nlm_failover_ip_list 
is a "nlm_failover_struct", defined in: include/linux/lockd/lockd.h.

The list is kept in descending order (newer entry first) based on 
g_expire jiffies. For per ip grace period checking, the search goes thru 
the list. As soon as one match ip is found, the search stops. This 
implies older entries will not be used and always expire before new 
entry. This is to allow multiple entries (for the same ip) to be added 
into the list. The maximum size of the list entries is NLM_FO_MAX_GP_CNT 
(1024).

-- Wendy

--------------010106040807010001010605
Content-Type: text/x-patch;
 name="resume_002.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="resume_002.patch"

The logic is implemented on top of linux nfsd procfs with core functions
residing in lockd kernel module. Entry function is nlmsvc_resume_ip() where
it stores the requested ip interface into a linked-list nlm_failover_list.
The list entry count is nlm_failover_cnt and access protection is done by
nlm_failover_mutex. Entry in nlm_failover_ip_list is a "nlm_failover_struct", 
defined in: include/linux/lockd/lockd.h.

The list is kept in descending order (newer entry first) based on g_expire
jiffies. For per ip grace period checking, the search goes thru the list.
As soon as one match ip is found, the search stops. This implies older
entries will not be used and always expire before new entry. This is to allow 
multiple entries (for the same ip) to be added into the list. The maximum size 
of the list entries is NLM_FO_MAX_GP_CNT (1024).

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/svc.c              |    4 +
 fs/lockd/svcsubs.c          |  159 +++++++++++++++++++++++++++++++++++++++++++-
 include/linux/lockd/lockd.h |   14 +++
 3 files changed, 174 insertions(+), 3 deletions(-)

--- linux-2/include/linux/lockd/lockd.h	2008-01-24 17:07:21.000000000 -0500
+++ linux-3/include/linux/lockd/lockd.h	2008-01-24 17:09:26.000000000 -0500
@@ -221,6 +221,20 @@ void		  nlmsvc_invalidate_all(void);
 int           nlmsvc_failover_path(struct nameidata *nd);
 int           nlmsvc_failover_ip(__be32 server_addr);
 int           nlmsvc_failover_setgrace(void *server_ip, int ip_size);
+void          nlmsvc_failover_reset(void);
+
+#define NLM_FO_MAX_GP_CNT	1024
+
+struct nlm_failover_struct {
+	struct list_head	g_list;		/* linked list */
+	unsigned long		g_expire;	/* grace period expire */
+	int			g_size;		/* g_key type: ipv4 or ipv6 */
+	union {
+		__be32		ipv4;		/* ip v4 address */
+		__be32		ipv6[4];	/* ip v6 address */
+	} g_key;
+#define g_ip			g_key.ipv6
+};
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- linux-2/fs/lockd/svc.c	2008-01-22 11:44:48.000000000 -0500
+++ linux-3/fs/lockd/svc.c	2008-01-24 17:30:55.000000000 -0500
@@ -145,6 +145,7 @@ lockd(struct svc_rqst *rqstp)
 	nlmsvc_timeout = nlm_timeout * HZ;
 
 	grace_period_expire = set_grace_period();
+	nlmsvc_failover_reset();
 
 	/*
 	 * The main request loop. We don't terminate until the last
@@ -160,6 +161,7 @@ lockd(struct svc_rqst *rqstp)
 			if (nlmsvc_ops) {
 				nlmsvc_invalidate_all();
 				grace_period_expire = set_grace_period();
+				nlmsvc_failover_reset();
 			}
 		}
 
@@ -209,6 +211,8 @@ lockd(struct svc_rqst *rqstp)
 	} else
 		printk(KERN_DEBUG
 			"lockd: new process, skipping host shutdown\n");
+
+	nlmsvc_failover_reset();
 	wake_up(&lockd_exit);
 
 	/* Exit the RPC thread */
--- linux-2/fs/lockd/svcsubs.c	2008-01-22 11:45:44.000000000 -0500
+++ linux-3/fs/lockd/svcsubs.c	2008-01-24 17:35:30.000000000 -0500
@@ -23,7 +23,6 @@
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
-
 /*
  * Global file hash table
  */
@@ -423,11 +422,165 @@ nlmsvc_failover_ip(__be32 server_addr)
 }
 EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
 
+static DEFINE_MUTEX(nlm_failover_mutex);
+int nlm_failover_cnt;
+LIST_HEAD(nlm_failover_list);
+
+/* garbage collection */
+static inline
+int __fo_check_expire(struct nlm_failover_struct *e_this, struct list_head *p)
+{
+	if (time_before(e_this->g_expire, jiffies)) {
+		dprintk("lockd: ip=%u.%u.%u.%u grace period expires\n",
+			NIPQUAD(*e_this->g_ip));
+		list_del(p);
+		nlm_failover_cnt--;
+		kfree(e_this);
+		return 1;
+	}
+	return 0;
+}
+
+/*
+ * Add grace period setting into global nlm_failover_struct_list where it
+ * stores the server ip interfaces that should be in grace period.
+ *
+ * It is different from (but not conflict with) system-wide lockd grace
+ * period when lockd is first initialized (see nlmsvc_check_grace_period
+ * for details).
+ *
+ * The list is searched with top-down order (newer entry first). As soon
+ * as one is found, the search stops. This implies older entries will not
+ * be used and always expire before new entry.
+ *
+ * As an admin interface, the list is expected to be short and entries are
+ * purged (expired) quickly.
+ */
+
 int
 nlmsvc_failover_setgrace(void *server_ip, int ip_size)
 {
-	/* implemented by resume_002.patch */
-	return ENOSYS;
+	struct list_head *p, *tlist;
+	struct nlm_failover_struct *per_ip, *entry;
+	int done = 0;
+	ulong time_expire;
+
+	/* allocate the entry */
+	per_ip = kzalloc(sizeof(struct nlm_failover_struct), GFP_KERNEL);
+	if (per_ip == NULL) {
+		dprintk("lockd: nlmsvc_fo_setgrace kmalloc fails\n");
+		return(-ENOMEM);
+	}
+
+	/* fill in info */
+	per_ip->g_size = ip_size;
+	memcpy((void *) per_ip->g_ip, (void *) server_ip, ip_size);
+	time_expire = get_nfs_grace_period();
+	per_ip->g_expire = time_expire + jiffies;
+	dprintk("lockd: fo_setgrace ip=%u.%u.%u.%u, ip_size=%d, expire=%lu\n",
+		   NIPQUAD(per_ip->g_ip[0]), ip_size, per_ip->g_expire);
+
+	/* add to the nlm_failover_list*/
+	mutex_lock(&nlm_failover_mutex);
+
+	/* handle special case */
+	if (list_empty(&nlm_failover_list)) {
+		list_add(&per_ip->g_list, &nlm_failover_list);
+		nlm_failover_cnt = 1;
+		done = 1;
+		goto nlmsvc_fo_setgrace_out;
+	}
+
+	/* add to list */
+	list_for_each_safe(p, tlist, &nlm_failover_list) {
+		entry = list_entry(p, struct nlm_failover_struct, g_list);
+		if (!done) {
+			/* add the new ip into the list */
+			if (entry->g_expire <= per_ip->g_expire) {
+				list_add(&per_ip->g_list, &entry->g_list);
+				nlm_failover_cnt++;
+				done = 1;
+			}
+		} else {
+			/* garbage collection:
+			 * we really don't care about duplicate keys
+			 * since the list is inserted in descending order */
+			if (!__fo_check_expire(entry, p))
+				goto nlmsvc_fo_setgrace_out;
+		}
+	}
+
+	/* unlikely event but check for the limit */
+	if (nlm_failover_cnt > NLM_FO_MAX_GP_CNT) {
+		list_del(&per_ip->g_list);
+		nlm_failover_cnt--;
+		kfree(per_ip);
+		done = 0;
+		dprintk("lockd: error fo_setgrace max cnt reached\n");
+	}
+
+nlmsvc_fo_setgrace_out:
+	mutex_unlock(&nlm_failover_mutex);
+	if (done)
+		dprintk("lockd: nlmsvc_failover_list=%p\n", &nlm_failover_list);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(nlmsvc_failover_setgrace);
 
+/*
+ * Reset global nlm_failover_struct list
+ */
+void
+nlmsvc_failover_reset(void)
+{
+	struct nlm_failover_struct *e_purge;
+	struct list_head *p, *tlist;
+
+	mutex_lock(&nlm_failover_mutex);
+
+	/* nothing to do */
+	if (list_empty(&nlm_failover_list)) {
+		mutex_unlock(&nlm_failover_mutex);
+		return;
+	}
+
+	/* purge the entries */
+	list_for_each_safe(p, tlist, &nlm_failover_list) {
+		e_purge = list_entry(p, struct nlm_failover_struct, g_list);
+		list_del(p);
+		kfree(e_purge);
+	}
+	nlm_failover_cnt = 0;
+
+	mutex_unlock(&nlm_failover_mutex);
+}
+
+/*
+ * Check whether the ip is in the failover list: nlm_failover_list.
+ *	- nlm_failover_mutex taken
+ *	- return TRUE (1) if ip in grace period.
+ */
+int
+nlmsvc_failover_check(struct svc_rqst *rqstp)
+{
+	struct nlm_failover_struct *e_this;
+	struct list_head *p, *tlist;
+	int rc = 0, done = 0;
+	struct in6_addr *addr_u = &rqstp->rq_daddr.addr6;
+
+	mutex_lock(&nlm_failover_mutex);
+
+	/* assume rq_daddr structure is zeroed out upon creation */
+	list_for_each_safe(p, tlist, &nlm_failover_list) {
+		e_this = list_entry(p, struct nlm_failover_struct, g_list);
+		if (!__fo_check_expire(e_this, p)) {
+			if (!done &&
+			    !memcmp((void *) e_this->g_ip, (void *) addr_u,
+					e_this->g_size))
+			    done = rc = 1;
+		}
+	}
+
+	mutex_unlock(&nlm_failover_mutex);
+	return rc;
+}

--------------010106040807010001010605--

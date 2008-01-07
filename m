From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 1/2] NLM failover unlock commands
Date: Mon, 07 Jan 2008 00:39:25 -0500
Message-ID: <4781BB0D.90706@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090403090801090601040402"
Cc: cluster-devel@redhat.com
To: NFS list <linux-nfs@vger.kernel.org>
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
--------------090403090801090601040402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

We've implemented two new NFSD procfs files:

o /proc/fs/nfsd/unlock_ip
o /proc/fs/nfsd/unlock_filesystem

They are intended to allow admin or user mode script to release NLM 
locks based on either a path name or a server in-bound ip address (ipv4 
for now)
as;

shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem

The expected usage is for High Availability (HA) environment where nfs 
servers are clustered together to provide either load balancing or take 
over upon server failure. The task is normally started by transferring a 
floating IP address from serverA to serverB with the following sequences:

ServerA:
1. Tear down the IP address
2. Unexport the path
3. Write IP to /proc/fs/nfsd/unlock_ip to unlock files
4. If unmount required,
      write path name to /proc/fs/nfsd/unlock_filesystem, then unmount.
5. Signal peer to begin take-over.

For details, check out:
http://people.redhat.com/wcheng/Patches/NFS/NLM/004.txt

Acknowledgment goes to Neil Brown who has been offered support and 
guidance during our prototype efforts.

-- Wendy


--------------090403090801090601040402
Content-Type: text/x-patch;
 name="unlock_001.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="unlock_001.patch"

Two new NFSD procfs files are added:
  /proc/fs/nfsd/unlock_ip
  /proc/fs/nfsd/unlock_filesystem

They are intended to allow admin or user mode script to release NLM locks
based on either a path name or a server in-bound ip address (ipv4 for now)
as;

shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/svcsubs.c          |  117 +++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/export.c            |   20 +++++++
 fs/nfsd/nfsctl.c            |   60 ++++++++++++++++++++++
 include/linux/lockd/bind.h  |    2 
 include/linux/lockd/lockd.h |   14 ++++-
 include/linux/nfsd/export.h |   12 ++++
 6 files changed, 221 insertions(+), 4 deletions(-)

--- linux-o/include/linux/nfsd/export.h	2008-01-04 10:01:08.000000000 -0500
+++ linux/include/linux/nfsd/export.h	2008-01-06 15:33:13.000000000 -0500
@@ -138,6 +138,18 @@ int			exp_rootfh(struct auth_domain *, 
 __be32			exp_pseudoroot(struct svc_rqst *, struct svc_fh *);
 __be32			nfserrno(int errno);
 
+/* cluster failover support */
+
+#define NFSD_FO_VIP     0
+#define NFSD_FO_PATH    1
+
+#define DEBUG 0
+#define fo_printk(x...) ((void)(DEBUG && printk(x)))
+
+int nfsd_fo_cmd(int cmd, char *datap, int grace_time);
+
+/* end of failover addition */
+
 extern struct cache_detail svc_export_cache;
 
 static inline void exp_put(struct svc_export *exp)
--- linux-o/fs/nfsd/nfsctl.c	2008-01-04 10:01:08.000000000 -0500
+++ linux/fs/nfsd/nfsctl.c	2008-01-06 15:27:34.000000000 -0500
@@ -52,6 +52,8 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_FO_UnlockIP,
+	NFSD_FO_UnlockFS,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -88,6 +90,9 @@ static ssize_t write_leasetime(struct fi
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
+
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -97,6 +102,8 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_FO_UnlockIP] = failover_unlock_ip,
+	[NFSD_FO_UnlockFS] = failover_unlock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -288,6 +295,56 @@ static ssize_t write_getfd(struct file *
 	return err;
 }
 
+extern __u32 in_aton(const char *str);
+
+static
+ssize_t failover_parse(int where, struct file *file, char *buf, size_t size)
+{
+	char *fo_path, *mesg;
+	__be32 server_ip[4];
+
+	/* sanity check */
+	if (size <= 0) {
+		fo_printk("nfsd fo buf size not correct\n");
+		return -EINVAL;
+	}
+	if (buf[size-1] == '\n') 
+		buf[size-1] = 0;
+
+	/* get the string */
+	fo_printk("nfsd fo buf = %s\n", buf);
+
+	fo_path = mesg = buf;
+	if (qword_get(&mesg, fo_path, size) < 0)
+		return EINVAL;
+
+	fo_printk("fo_dev=%s\n", fo_path);
+
+	switch (where) {
+		case NFSD_FO_PATH:
+			break;
+		case NFSD_FO_VIP:
+			server_ip[0] = in_aton(fo_path);
+			fo_path = (char *) server_ip;
+			break;
+		default:
+			fo_printk("nfsd unknown fo cmd (%d)\n", where);
+			return -EINVAL;
+	}
+
+	return (nfsd_fo_cmd(where, fo_path, 0));
+}
+
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
+{
+	return (failover_parse(NFSD_FO_VIP, file, buf, size));
+}
+
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
+{
+	return (failover_parse(NFSD_FO_PATH, file, buf, size));
+}
+
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 {
 	/* request is:
@@ -646,6 +703,8 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
+		[NFSD_FO_UnlockIP] = {"unlock_ip", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_FO_UnlockFS] = {"unlock_filesystem", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
@@ -717,7 +776,6 @@ static void __exit exit_nfsd(void)
 	nfsd4_free_slabs();
 	unregister_filesystem(&nfsd_fs_type);
 }
-
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
 module_init(init_nfsd)
--- linux-o/fs/nfsd/export.c	2008-01-04 10:01:08.000000000 -0500
+++ linux/fs/nfsd/export.c	2008-01-06 15:14:55.000000000 -0500
@@ -1679,3 +1679,23 @@ nfsd_export_shutdown(void)
 	exp_writeunlock();
 	dprintk("nfsd: export shutdown complete.\n");
 }
+
+int
+nfsd_fo_cmd(int cmd, char *datap, int grace_period)
+{
+	struct nameidata nd;
+	void *objp = (void *)datap;
+	int rc=0;
+
+	if (cmd == NFSD_FO_PATH) { 
+		rc = path_lookup((const char *)datap, 0, &nd);
+		if (rc) {
+			fo_printk("nfsd: nfsd_fo path (%s) not found\n", datap);
+			return rc;
+		}
+		fo_printk("nfsd: nfsd_fo lookup path = (0x%p,0x%p)\n", 
+			nd.mnt, nd.dentry);
+		objp = (void *) &nd;
+	} 
+	return (nlmsvc_fo_cmd(cmd, objp, grace_period));
+}
--- linux-o/fs/lockd/svcsubs.c	2008-01-04 10:01:08.000000000 -0500
+++ linux/fs/lockd/svcsubs.c	2008-01-06 16:20:37.000000000 -0500
@@ -18,10 +18,11 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
+#include <linux/module.h>
+#include <linux/mount.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
-
 /*
  * Global file hash table
  */
@@ -87,7 +88,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	unsigned int	hash;
 	__be32		nfserr;
 
-	nlm_debug_print_fh("nlm_file_lookup", f);
+	nlm_debug_print_fh("nlm_lookup_file", f);
 
 	hash = file_hash(f);
 
@@ -123,6 +124,11 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 
 	hlist_add_head(&file->f_list, &nlm_files[hash]);
 
+	/* fill in f_iaddr for nlm lock failover */
+	file->f_iaddr = rqstp->rq_daddr;
+	fo_printk("lockd: file->f_iaddr = %u.%u.%u.%u\n", 
+			NIPQUAD(file->f_iaddr.addr.s_addr));
+
 found:
 	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
 	*result = file;
@@ -194,12 +200,88 @@ again:
 	return 0;
 }
 
+static inline int
+nlmsvc_fo_unlock_match(void *datap, struct nlm_file *file)
+{
+	nlm_fo_cmd *fo_cmd = (nlm_fo_cmd *) datap;
+	int cmd = fo_cmd->cmd;
+	struct path *f_path;
+
+	fo_printk("nlm_fo_unlock_match cmd=%d\n", cmd);
+
+	if (cmd == NFSD_FO_VIP) {
+		if (file->f_iaddr.addr.s_addr == 
+			((struct in_addr *)fo_cmd->datap)->s_addr) {
+				fo_printk("lockd: fo ip matches %u.%u.%u.%u\n",
+					NIPQUAD(file->f_iaddr.addr.s_addr));
+				goto nlmsvc_fo_unlock_match_found;
+		} else {
+			fo_printk("lockd: fo ip no match %u.%u.%u.%u\n",
+				NIPQUAD(((struct in_addr *)fo_cmd->datap)->s_addr));
+			return 0;
+		}
+	}
+
+	/* looking for match using file's vfsmount */
+	f_path = &(file->f_file->f_path);
+
+	if (cmd == NFSD_FO_PATH) {
+		struct path fo_path;
+		/* 
+		 * The dentry is not really used but stays here for
+		 * debugging purpose.
+		 */
+		fo_path.mnt = ((struct nameidata *) fo_cmd->datap)->mnt;
+		fo_path.dentry = ((struct nameidata *) fo_cmd->datap)->dentry;
+		fo_printk("f_path->mnt (0x%p) f_path->dentry (0x%p)\n",
+			f_path->mnt, f_path->dentry);
+		fo_printk("fo_path (0x%p) fo_path->dentry (0x%p)\n",
+			fo_path.mnt, fo_path.dentry);
+		/* check vfsmount */
+		if (fo_path.mnt == f_path->mnt)
+			goto nlmsvc_fo_unlock_match_found;
+		return 0; /* not found */
+	} 
+
+	fo_printk("nlmsvc_fo_unlock_match - unknown cmd\n");
+	return 0; /* should never reach here */
+
+nlmsvc_fo_unlock_match_found:
+	fo_printk("nlmsvc_fo_unlock_match found file=0x%p\n", file);
+	fo_cmd->stat++;	
+	return 1;
+}
+
+/* To fit the logic into current lockd code structure, we add a
+ * little wrapper function here. The real matching task should be
+ * carried out by nlm_fo_check_fsid().
+ */
+int nlmsvc_fo_match(struct nlm_host *dummy1, struct nlm_host *dummy2)
+{
+        return 1;
+}
+
 /*
  * Inspect a single file
  */
 static inline int
 nlm_inspect_file(struct nlm_host *host, struct nlm_file *file, nlm_host_match_fn_t match)
 {
+	/* Cluster failover has timing constraints. There is a slight
+	 * performance hit if nlm_fo_unlock_match() is implemented as 
+	 * a match fn (since it will be invoked for each block, share,
+	 * and lock later when the lists are traversed). Instead, we 
+	 * add path-matching logic into the following unlikely clause. 
+	 * If matches, the dummy nlmsvc_fo_match will always return 
+	 * true. 
+	 */
+	dprintk("nlm_inspect_files: file=%p\n", file);
+	if (unlikely(match == nlmsvc_fo_match)) {
+		if (!nlmsvc_fo_unlock_match((void *)host, file))
+			return 0;
+		fo_printk("nlm_fo find lock file entry (0x%p)\n", file);
+	}
+
 	nlmsvc_traverse_blocks(host, file, match);
 	nlmsvc_traverse_shares(host, file, match);
 	return nlm_traverse_locks(host, file, match);
@@ -370,3 +452,34 @@ nlmsvc_invalidate_all(void)
 	 */
 	nlm_traverse_files(NULL, nlmsvc_is_client);
 }
+
+/*
+ * Release locks associated with an export fsid upon failover
+ *      invoked via nfsd nfsctl call (write_fo_unlock).
+ */
+int
+nlmsvc_fo_cmd(int cmd, void *datap, int grace_time)
+{
+	nlm_fo_cmd fo_cmd;
+	int rc=-EINVAL;
+
+	fo_printk("lockd: nlmsvc_fo_cmd enter, cmd=%d, datap=0x%p, gp=%d\n",
+		cmd, datap, grace_time);
+
+	fo_cmd.cmd   = cmd;
+	fo_cmd.stat  = 0;
+	fo_cmd.gp    = 0;
+	fo_cmd.datap = datap;
+
+	/* "if" place holder for NFSD_FO_RESUME */
+	{
+		/* fo_start */
+		rc = nlm_traverse_files((struct nlm_host*) &fo_cmd, 
+					nlmsvc_fo_match);
+		fo_printk("nlmsvc_fo_cmd rc=%d, stat=%d\n", rc, fo_cmd.stat);
+	} 
+
+	return rc;
+}
+
+EXPORT_SYMBOL(nlmsvc_fo_cmd);
--- linux-o/include/linux/lockd/bind.h	2008-01-04 10:01:08.000000000 -0500
+++ linux/include/linux/lockd/bind.h	2008-01-06 15:14:55.000000000 -0500
@@ -47,4 +47,6 @@ unsigned long get_nfs4_grace_period(void
 static inline unsigned long get_nfs4_grace_period(void) {return 0;}
 #endif
 
+extern int      nlmsvc_fo_cmd(int cmd, void *datap, int grace_time);
+
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-o/include/linux/lockd/lockd.h	2008-01-04 10:01:08.000000000 -0500
+++ linux/include/linux/lockd/lockd.h	2008-01-06 15:14:55.000000000 -0500
@@ -39,7 +39,7 @@
 struct nlm_host {
 	struct hlist_node	h_hash;		/* doubly linked list */
 	struct sockaddr_in	h_addr;		/* peer address */
-	struct sockaddr_in	h_saddr;	/* our address (optional) */
+	struct sockaddr_in      h_saddr;        /* our address (optional) */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char *			h_name;		/* remote hostname */
 	u32			h_version;	/* interface version */
@@ -113,6 +113,7 @@ struct nlm_file {
 	unsigned int		f_locks;	/* guesstimate # of locks */
 	unsigned int		f_count;	/* reference count */
 	struct mutex		f_mutex;	/* avoid concurrent access */
+	union svc_addr_u	f_iaddr;	/* server ip for failover */
 };
 
 /*
@@ -214,6 +215,17 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 
+/* cluster failover support */
+
+typedef struct {
+	int     cmd;
+	int     stat;
+	int     gp;
+	void    *datap;
+} nlm_fo_cmd;
+
+int           nlmsvc_fo_cmd(int cmd, void *datap, int grace_time);
+
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
 {

--------------090403090801090601040402--

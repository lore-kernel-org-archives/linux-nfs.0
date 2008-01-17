From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 11:10:12 -0500
Message-ID: <478F7DE4.30404@redhat.com>
References: <20080108170220.GA21401@infradead.org>
	<20080108174958.GA25025@infradead.org>
	<4783E3C9.3040803@redhat.com>
	<20080109180214.GA31071@infradead.org>
	<20080110075959.GA9623@infradead.org> <4788665B.4020405@redhat.com>
	<18315.62909.330258.83038@notabene.brown>
	<478D14C5.1000804@redhat.com>
	<18317.7319.443532.62244@notabene.brown>
	<478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org>
	<478F78E8.40601@redhat.com> <478F7D96.1060602@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020208040400020404080008"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <478F7D96.1060602@redhat.com>
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
--------------020208040400020404080008
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Wendy Cheng wrote:
> Add a more detailed description into the top of the patch itself. I'm 
> working on the resume patch now - it will include an overall write-up 
> in the Documentation directory.

Sorry, forgot to attach the patch. Here it is ... Wendy


--------------020208040400020404080008
Content-Type: text/x-patch;
 name="unlock_v4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="unlock_v4.patch"

Two new NFSD procfs files are added:
  /proc/fs/nfsd/unlock_ip
  /proc/fs/nfsd/unlock_filesystem

They are intended to allow admin or user mode script to release NLM locks
based on either a path name or a server in-bound ip address (ipv4 for now)
as:

shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip
shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem

The expected sequence of events can be:
1. Tear down the IP address
2. Unexport the path
3. Write IP to /proc/fs/nfsd/unlock_ip to unlock files
4. If unmount required, write path name to 
   /proc/fs/nfsd/unlock_filesystem, then unmount.
5. Signal peer to begin take-over. 

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>
Signed-off-by: Christoph Hellwig <hch@lst.de>

 fs/lockd/svcsubs.c          |   66 +++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfsctl.c            |   65 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    7 ++++
 3 files changed, 131 insertions(+), 7 deletions(-)

--- linux-o/fs/nfsd/nfsctl.c	2008-01-04 10:01:08.000000000 -0500
+++ linux/fs/nfsd/nfsctl.c	2008-01-15 11:30:19.000000000 -0500
@@ -22,6 +22,7 @@
 #include <linux/seq_file.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
+#include <linux/inet.h>
 #include <linux/string.h>
 #include <linux/smp_lock.h>
 #include <linux/ctype.h>
@@ -35,6 +36,7 @@
 #include <linux/nfsd/cache.h>
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
+#include <linux/lockd/lockd.h>
 
 #include <asm/uaccess.h>
 
@@ -52,6 +54,8 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_FO_UnlockIP,
+	NFSD_FO_UnlockFS,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -88,6 +92,9 @@ static ssize_t write_leasetime(struct fi
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
+
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -97,6 +104,8 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_FO_UnlockIP] = failover_unlock_ip,
+	[NFSD_FO_UnlockFS] = failover_unlock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -288,6 +297,58 @@ static ssize_t write_getfd(struct file *
 	return err;
 }
 
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
+{
+	__be32 server_ip;
+	char *fo_path, c;
+	int b1, b2, b3, b4;
+
+	/* sanity check */
+	if (size == 0)
+		return -EINVAL;
+
+	if (buf[size-1] != '\n')
+		return -EINVAL;
+
+	fo_path = buf;
+	if (qword_get(&buf, fo_path, size) < 0)
+		return -EINVAL;
+
+	/* get ipv4 address */
+	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
+		return -EINVAL;
+	server_ip = htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
+
+	return nlmsvc_failover_ip(server_ip);
+}
+
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
+{
+	struct nameidata nd;
+	char *fo_path;
+	int error;
+
+	/* sanity check */
+	if (size == 0)
+		return -EINVAL;
+
+	if (buf[size-1] != '\n')
+		return -EINVAL;
+
+	fo_path = buf;
+	if (qword_get(&buf, fo_path, size) < 0)
+		return -EINVAL;
+
+	error = path_lookup(fo_path, 0, &nd);
+	if (error)
+		return error;
+
+	error = nlmsvc_failover_path(&nd);
+
+	path_release(&nd);
+	return error;
+}
+
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 {
 	/* request is:
@@ -646,6 +707,10 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
+		[NFSD_FO_UnlockIP] = {"unlock_ip",
+					&transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_FO_UnlockFS] = {"unlock_filesystem",
+					&transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
--- linux-o/fs/lockd/svcsubs.c	2008-01-04 10:01:08.000000000 -0500
+++ linux/fs/lockd/svcsubs.c	2008-01-15 11:16:48.000000000 -0500
@@ -18,6 +18,8 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
+#include <linux/module.h>
+#include <linux/mount.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
@@ -87,7 +89,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	unsigned int	hash;
 	__be32		nfserr;
 
-	nlm_debug_print_fh("nlm_file_lookup", f);
+	nlm_debug_print_fh("nlm_lookup_file", f);
 
 	hash = file_hash(f);
 
@@ -123,6 +125,9 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 
 	hlist_add_head(&file->f_list, &nlm_files[hash]);
 
+	/* fill in f_iaddr for nlm lock failover */
+	file->f_iaddr = rqstp->rq_daddr;
+
 found:
 	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
 	*result = file;
@@ -194,6 +199,12 @@ again:
 	return 0;
 }
 
+static int
+nlmsvc_always_match(struct nlm_host *dummy1, struct nlm_host *dummy2)
+{
+	return 1;
+}
+
 /*
  * Inspect a single file
  */
@@ -230,7 +241,8 @@ nlm_file_inuse(struct nlm_file *file)
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
+nlm_traverse_files(void *data, nlm_host_match_fn_t match,
+		int (*is_failover_file)(void *data, struct nlm_file *file))
 {
 	struct hlist_node *pos, *next;
 	struct nlm_file	*file;
@@ -244,8 +256,17 @@ nlm_traverse_files(struct nlm_host *host
 
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
-			if (nlm_inspect_file(host, file, match))
-				ret = 1;
+
+			if (likely(is_failover_file == NULL) ||
+				is_failover_file(data, file)) {
+				/*
+				 *  Note that nlm_inspect_file updates f_locks
+				 *  and ret is the number of files that can't
+				 *  be unlocked.
+				 */
+				ret += nlm_inspect_file(data, file, match);
+			} else
+				file->f_locks = nlm_file_inuse(file);
 
 			mutex_lock(&nlm_file_mutex);
 			file->f_count--;
@@ -337,7 +358,7 @@ void
 nlmsvc_mark_resources(void)
 {
 	dprintk("lockd: nlmsvc_mark_resources\n");
-	nlm_traverse_files(NULL, nlmsvc_mark_host);
+	nlm_traverse_files(NULL, nlmsvc_mark_host, NULL);
 }
 
 /*
@@ -348,7 +369,7 @@ nlmsvc_free_host_resources(struct nlm_ho
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, nlmsvc_same_host)) {
+	if (nlm_traverse_files(host, nlmsvc_same_host, NULL)) {
 		printk(KERN_WARNING
 			"lockd: couldn't remove all locks held by %s\n",
 			host->h_name);
@@ -368,5 +389,36 @@ nlmsvc_invalidate_all(void)
 	 * turn, which is about as inefficient as it gets.
 	 * Now we just do it once in nlm_traverse_files.
 	 */
-	nlm_traverse_files(NULL, nlmsvc_is_client);
+	nlm_traverse_files(NULL, nlmsvc_is_client, NULL);
+}
+
+static int
+nlmsvc_failover_file_ok_path(void *datap, struct nlm_file *file)
+{
+	struct nameidata *nd = datap;
+	return nd->mnt == file->f_file->f_path.mnt;
+}
+
+int
+nlmsvc_failover_path(struct nameidata *nd)
+{
+	return nlm_traverse_files(nd, nlmsvc_always_match,
+			nlmsvc_failover_file_ok_path);
+}
+EXPORT_SYMBOL_GPL(nlmsvc_failover_path);
+
+static int
+nlmsvc_failover_file_ok_ip(void *datap, struct nlm_file *file)
+{
+	__be32 *server_addr = datap;
+
+	return file->f_iaddr.addr.s_addr == *server_addr;
+}
+
+int
+nlmsvc_failover_ip(__be32 server_addr)
+{
+	return nlm_traverse_files(&server_addr, nlmsvc_always_match,
+			nlmsvc_failover_file_ok_ip);
 }
+EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
--- linux-o/include/linux/lockd/lockd.h	2008-01-04 10:01:08.000000000 -0500
+++ linux/include/linux/lockd/lockd.h	2008-01-15 11:13:04.000000000 -0500
@@ -113,6 +113,7 @@ struct nlm_file {
 	unsigned int		f_locks;	/* guesstimate # of locks */
 	unsigned int		f_count;	/* reference count */
 	struct mutex		f_mutex;	/* avoid concurrent access */
+	union svc_addr_u	f_iaddr;	/* server ip for failover */
 };
 
 /*
@@ -214,6 +215,12 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 
+/*
+ * Cluster failover support
+ */
+int           nlmsvc_failover_path(struct nameidata *nd);
+int           nlmsvc_failover_ip(__be32 server_addr);
+
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
 {

--------------020208040400020404080008--

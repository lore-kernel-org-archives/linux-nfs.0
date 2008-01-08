From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Tue, 8 Jan 2008 17:49:58 +0000
Message-ID: <20080108174958.GA25025@infradead.org>
References: <4781BB0D.90706@redhat.com> <20080108170220.GA21401@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:58744 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbYAHRuA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 12:50:00 -0500
In-Reply-To: <20080108170220.GA21401@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, I played around with this and cleaned up the ip/path codepathes to
be entirely setup which helped the code quite a bit.  Also a few other
cleanups and two bugfixes (postive error code returned and missing
path_release) fell out of it.  I still don't like what's going on in
fs/lockd/svcsubs.c, it would be much better if the cluster unlock code
simply didn't use nlm_traverse_files but did it's own loop over
the nlm hosts.  That should also absolete the second patch.


Index: linux-2.6/fs/nfsd/nfsctl.c
===================================================================
--- linux-2.6.orig/fs/nfsd/nfsctl.c	2008-01-08 18:36:37.000000000 +0100
+++ linux-2.6/fs/nfsd/nfsctl.c	2008-01-08 18:45:55.000000000 +0100
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
@@ -288,6 +297,55 @@ static ssize_t write_getfd(struct file *
 	return err;
 }
 
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
+{
+	__be32 server_ip;
+	char *fo_path;
+	char *mesg;
+
+	/* sanity check */
+	if (size <= 0)
+		return -EINVAL;
+
+	if (buf[size-1] == '\n')
+		buf[size-1] = 0;
+
+	fo_path = mesg = buf;
+	if (qword_get(&mesg, fo_path, size) < 0)
+		return -EINVAL;
+
+	server_ip = in_aton(fo_path);
+	return nlmsvc_failover_ip(server_ip[0]);
+}
+
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
+{
+	struct nameidata nd;
+	char *fo_path;
+	char *mesg;
+	int error;
+
+	/* sanity check */
+	if (size <= 0)
+		return -EINVAL;
+
+	if (buf[size-1] == '\n')
+		buf[size-1] = 0;
+
+	fo_path = mesg = buf;
+	if (qword_get(&mesg, fo_path, size) < 0)
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
@@ -646,6 +704,8 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
+		[NFSD_FO_UnlockIP] = {"unlock_ip", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_FO_UnlockFS] = {"unlock_filesystem", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
Index: linux-2.6/fs/lockd/svcsubs.c
===================================================================
--- linux-2.6.orig/fs/lockd/svcsubs.c	2008-01-08 18:36:37.000000000 +0100
+++ linux-2.6/fs/lockd/svcsubs.c	2008-01-08 18:44:11.000000000 +0100
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
@@ -194,12 +199,63 @@ again:
 	return 0;
 }
 
+static int
+nlmsvc_fo_unlock_match_path(void *datap, struct nlm_file *file)
+{
+	struct nameidata *nd = datap;
+	return nd->mnt == file->f_file->f_path.mnt;
+}
+
+static int
+nlmsvc_fo_unlock_match_ip(void *datap, struct nlm_file *file)
+{
+	struct in_addr *in = datap;
+
+	return file->f_iaddr.addr.s_addr == in->s_addr;
+}
+
+/*
+ * To fit the logic into current lockd code structure, we add a
+ * little wrapper function here. The real matching task should be
+ * carried out by nlm_fo_check_fsid().
+ */
+
+static int nlmsvc_fo_match_path(struct nlm_host *dummy1,
+		struct nlm_host *dummy2)
+{
+        return 1;
+}
+
+static int nlmsvc_fo_match_ip(struct nlm_host *dummy1, struct nlm_host *dummy2)
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
+	/*
+	 * Cluster failover has timing constraints. There is a slight
+	 * performance hit if nlm_fo_unlock_match() is implemented as
+	 * a match fn (since it will be invoked for each block, share,
+	 * and lock later when the lists are traversed). Instead, we
+	 * add path-matching logic into the following unlikely clause.
+	 * If matches, the dummy nlmsvc_fo_match will always return
+	 * true.
+	 */
+	dprintk("nlm_inspect_files: file=%p\n", file);
+	if (unlikely(match == nlmsvc_fo_match_path)) {
+		if (!nlmsvc_fo_unlock_match_path(host, file))
+			return 0;
+	}
+	if (unlikely(match == nlmsvc_fo_match_ip)) {
+		if (!nlmsvc_fo_unlock_match_ip(host, file))
+			return 0;
+	}
+
 	nlmsvc_traverse_blocks(host, file, match);
 	nlmsvc_traverse_shares(host, file, match);
 	return nlm_traverse_locks(host, file, match);
@@ -370,3 +426,22 @@ nlmsvc_invalidate_all(void)
 	 */
 	nlm_traverse_files(NULL, nlmsvc_is_client);
 }
+
+/*
+ * Release locks associated with an export fsid upon failover
+ *      invoked via nfsd nfsctl call (write_fo_unlock).
+ */
+int
+nlmsvc_failover_path(struct nameidata *nd)
+{
+	return nlm_traverse_files((struct nlm_host*)nd, nlmsvc_fo_match_path);
+}
+EXPORT_SYMBOL_GPL(nlmsvc_failover_path);
+
+int
+nlmsvc_failover_ip(__be32 server_addr)
+{
+	return nlm_traverse_files((struct nlm_host *)&server_addr,
+				nlmsvc_fo_match_ip);
+}
+EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
Index: linux-2.6/include/linux/lockd/lockd.h
===================================================================
--- linux-2.6.orig/include/linux/lockd/lockd.h	2008-01-08 18:36:37.000000000 +0100
+++ linux-2.6/include/linux/lockd/lockd.h	2008-01-08 18:44:44.000000000 +0100
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

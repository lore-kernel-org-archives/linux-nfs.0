From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [NFS] [PATCH] lockd: unlock lockd locks associated with a given
	server ip
Date: Tue, 22 Apr 2008 19:17:29 -0400
Message-ID: <20080422231729.GJ21770@fieldses.org>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
	<4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org>
	<20080422231520.GI21770@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>, nfs@lists.sourceforge.net,
	Christoph Hellwig <hch@lst.de>,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34055 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbYDVXRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Apr 2008 19:17:47 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JoRk9-0005bb-NW
	for linux-nfs@vger.kernel.org; Wed, 23 Apr 2008 09:17:45 +1000
In-Reply-To: <20080422231520.GI21770@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Wendy Cheng <wcheng@redhat.com>

For high-availability NFS service, we generally need to be able to drop
file locks held on the exported filesystem before moving clients to a
new server.  Currently the only way to do that is by shutting down lockd
entirely, which is often undesireable (for example, if you want to
continue exporting other filesystems).

This patch allows the administrator to release all locks held by clients
accessing the client through a given server ip address, by echoing that
address to a new file, /proc/fs/nfsd/unlock_ip, as in:

shell> echo 10.1.1.2 > /proc/fs/nfsd/unlock_ip

The expected sequence of events can be:
1. Tear down the IP address
2. Unexport the path
3. Write IP to /proc/fs/nfsd/unlock_ip to unlock files
4. Signal peer to begin take-over.

For now we only support IPv4 addresses and NFSv2/v3 (NFSv4 locks are not
affected).

Also, if unmounting the filesystem is required, we assume at step 3 that
clients using the given server ip are the only clients holding locks on
the given filesystem; otherwise, an additional patch is required to
allow revoking all locks held by lockd on a given filesystem.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Cc: Lon Hohberger  <lhh@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

 fs/lockd/svcsubs.c          |   66 +++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/nfsctl.c            |   65 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    7 ++++
 3 files changed, 131 insertions(+), 7 deletions(-)
---
 fs/lockd/svcsubs.c          |   36 +++++++++++++++++++++++++++++++-----
 fs/nfsd/nfsctl.c            |   33 +++++++++++++++++++++++++++++++++
 include/linux/lockd/lockd.h |    7 ++++++-
 3 files changed, 70 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index dbbefbc..e12daba 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -18,6 +18,8 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
+#include <linux/module.h>
+#include <linux/mount.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
@@ -230,7 +232,7 @@ nlm_file_inuse(struct nlm_file *file)
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
+nlm_traverse_files(void *data, nlm_host_match_fn_t match)
 {
 	struct hlist_node *pos, *next;
 	struct nlm_file	*file;
@@ -244,7 +246,7 @@ nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
 
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
-			if (nlm_inspect_file(host, file, match))
+			if (nlm_inspect_file(data, file, match))
 				ret = 1;
 
 			mutex_lock(&nlm_file_mutex);
@@ -303,21 +305,27 @@ nlm_release_file(struct nlm_file *file)
  *	Used by nlmsvc_invalidate_all
  */
 static int
-nlmsvc_mark_host(struct nlm_host *host, struct nlm_host *dummy)
+nlmsvc_mark_host(void *data, struct nlm_host *dummy)
 {
+	struct nlm_host *host = data;
+
 	host->h_inuse = 1;
 	return 0;
 }
 
 static int
-nlmsvc_same_host(struct nlm_host *host, struct nlm_host *other)
+nlmsvc_same_host(void *data, struct nlm_host *other)
 {
+	struct nlm_host *host = data;
+
 	return host == other;
 }
 
 static int
-nlmsvc_is_client(struct nlm_host *host, struct nlm_host *dummy)
+nlmsvc_is_client(void *data, struct nlm_host *dummy)
 {
+	struct nlm_host *host = data;
+
 	if (host->h_server) {
 		/* we are destroying locks even though the client
 		 * hasn't asked us too, so don't unmonitor the
@@ -370,3 +378,21 @@ nlmsvc_invalidate_all(void)
 	 */
 	nlm_traverse_files(NULL, nlmsvc_is_client);
 }
+
+static int
+nlmsvc_failover_file_ok_ip(void *datap, struct nlm_host *host)
+{
+	__be32 *server_addr = datap;
+
+	return host->h_saddr.sin_addr.s_addr == *server_addr;
+}
+
+int
+nlmsvc_failover_ip(__be32 server_addr)
+{
+	int ret;
+	ret = nlm_traverse_files(&server_addr, nlmsvc_failover_file_ok_ip);
+	return ret ? -EIO : 0;
+
+}
+EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 8516137..02c3949 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
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
 
@@ -52,6 +54,7 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_FO_UnlockIP,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -88,6 +91,8 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
+
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -97,6 +102,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_FO_UnlockIP] = failover_unlock_ip,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -288,6 +294,31 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
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
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 {
 	/* request is:
@@ -696,6 +727,8 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_Getfd] = {".getfd", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
+		[NFSD_FO_UnlockIP] = {"unlock_ip",
+					&transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 4babb2a..f06d2db 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -191,7 +191,7 @@ void		  nsm_release(struct nsm_handle *);
  * This is used in garbage collection and resource reclaim
  * A return value != 0 means destroy the lock/block/share
  */
-typedef int	  (*nlm_host_match_fn_t)(struct nlm_host *cur, struct nlm_host *ref);
+typedef int	  (*nlm_host_match_fn_t)(void *cur, struct nlm_host *ref);
 
 /*
  * Server-side lock handling
@@ -217,6 +217,11 @@ void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 
+/*
+ * Cluster failover support
+ */
+int           nlmsvc_failover_ip(__be32 server_addr);
+
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
 {
-- 
1.5.5.rc1


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs


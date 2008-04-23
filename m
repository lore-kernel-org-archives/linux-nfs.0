From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] lockd: unlock lockd locks held for a certain
	filesystem
Date: Wed, 23 Apr 2008 13:12:40 -0400
Message-ID: <20080423171240.GG31576@fieldses.org>
References: <48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com> <20080417215222.GK9912@fieldses.org>
	<4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org>
	<20080422231520.GI21770@fieldses.org>
	<20080422231729.GJ21770@fieldses.org>
	<20080422231855.GK21770@fieldses.org>
	<20080423074422.GA23518@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>,
	Wendy Cheng <s.wendy.cheng@gmail.com>,
	nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60076 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751174AbYDWSNy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2008 14:13:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JojTc-0008NF-LR
	for linux-nfs@vger.kernel.org; Thu, 24 Apr 2008 04:13:52 +1000
In-Reply-To: <20080423074422.GA23518@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 23, 2008 at 09:44:22AM +0200, Christoph Hellwig wrote:
> Please don't pass down the nameidata, but just the super_block.  That's
> all we need in the lower layer functions.

Yep, I agree that's nicer; here's the result.

--b.

commit 26a816586b71877d8a84fbb436373099384e328b
Author: Wendy Cheng <wcheng@redhat.com>
Date:   Thu Jan 17 11:10:12 2008 -0500

    lockd: unlock lockd locks held for a certain filesystem
    
    Add /proc/fs/nfsd/unlock_filesystem, which allows e.g.:
    
    shell> echo /mnt/sfs1 > /proc/fs/nfsd/unlock_filesystem
    
    so that a filesystem can be unmounted before allowing a peer nfsd to
    take over nfs service for the filesystem.
    
    Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
    Cc: Lon Hohberger  <lhh@redhat.com>
    Cc: Christoph Hellwig <hch@lst.de>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    
     fs/lockd/svcsubs.c          |   66 +++++++++++++++++++++++++++++++++++++++-----
     fs/nfsd/nfsctl.c            |   65 +++++++++++++++++++++++++++++++++++++++++++
     include/linux/lockd/lockd.h |    7 ++++
     3 files changed, 131 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index e12daba..dcdcff6 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -196,6 +196,12 @@ again:
 	return 0;
 }
 
+static int
+nlmsvc_always_match(void *dummy1, struct nlm_host *dummy2)
+{
+	return 1;
+}
+
 /*
  * Inspect a single file
  */
@@ -232,7 +238,8 @@ nlm_file_inuse(struct nlm_file *file)
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(void *data, nlm_host_match_fn_t match)
+nlm_traverse_files(void *data, nlm_host_match_fn_t match,
+		int (*is_failover_file)(void *data, struct nlm_file *file))
 {
 	struct hlist_node *pos, *next;
 	struct nlm_file	*file;
@@ -241,6 +248,8 @@ nlm_traverse_files(void *data, nlm_host_match_fn_t match)
 	mutex_lock(&nlm_file_mutex);
 	for (i = 0; i < FILE_NRHASH; i++) {
 		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
+			if (is_failover_file && !is_failover_file(data, file))
+				continue;
 			file->f_count++;
 			mutex_unlock(&nlm_file_mutex);
 
@@ -345,7 +354,7 @@ void
 nlmsvc_mark_resources(void)
 {
 	dprintk("lockd: nlmsvc_mark_resources\n");
-	nlm_traverse_files(NULL, nlmsvc_mark_host);
+	nlm_traverse_files(NULL, nlmsvc_mark_host, NULL);
 }
 
 /*
@@ -356,7 +365,7 @@ nlmsvc_free_host_resources(struct nlm_host *host)
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, nlmsvc_same_host)) {
+	if (nlm_traverse_files(host, nlmsvc_same_host, NULL)) {
 		printk(KERN_WARNING
 			"lockd: couldn't remove all locks held by %s\n",
 			host->h_name);
@@ -376,8 +385,27 @@ nlmsvc_invalidate_all(void)
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
+	struct super_block *sb = datap;
+
+	return sb == file->f_file->f_path.mnt->mnt_sb;
+}
+
+int
+nlmsvc_failover_path(struct super_block *sb)
+{
+	int ret;
+
+	ret = nlm_traverse_files(sb, nlmsvc_always_match,
+				 nlmsvc_failover_file_ok_path);
+	return ret ? -EIO : 0;
 }
+EXPORT_SYMBOL_GPL(nlmsvc_failover_path);
 
 static int
 nlmsvc_failover_file_ok_ip(void *datap, struct nlm_host *host)
@@ -391,7 +419,8 @@ int
 nlmsvc_failover_ip(__be32 server_addr)
 {
 	int ret;
-	ret = nlm_traverse_files(&server_addr, nlmsvc_failover_file_ok_ip);
+	ret = nlm_traverse_files(&server_addr, nlmsvc_failover_file_ok_ip,
+						NULL);
 	return ret ? -EIO : 0;
 
 }
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 02c3949..b4ca5c9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -55,6 +55,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_FO_UnlockIP,
+	NFSD_FO_UnlockFS,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -92,6 +93,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
 static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -103,6 +105,7 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_FO_UnlockIP] = failover_unlock_ip,
+	[NFSD_FO_UnlockFS] = failover_unlock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -319,6 +322,33 @@ static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size)
 	return nlmsvc_failover_ip(server_ip);
 }
 
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
+	error = nlmsvc_failover_path(nd.path.mnt->mnt_sb);
+
+	path_put(&nd.path);
+	return error;
+}
+
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 {
 	/* request is:
@@ -729,6 +759,8 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_FO_UnlockIP] = {"unlock_ip",
 					&transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_FO_UnlockFS] = {"unlock_filesystem",
+					&transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index f06d2db..7cd9c8e 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -220,6 +220,7 @@ void		  nlmsvc_invalidate_all(void);
 /*
  * Cluster failover support
  */
+int           nlmsvc_failover_path(struct super_block *sb);
 int           nlmsvc_failover_ip(__be32 server_addr);
 
 static __inline__ struct inode *

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


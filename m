From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] Forcefully resetting a lock
Date: Thu, 17 Apr 2008 17:52:22 -0400
Message-ID: <20080417215222.GK9912@fieldses.org>
References: <200804161117.24734.hensema@hostingxs.nl>
	<48061807.9030808@gmail.com> <20080416184233.GF22743@fieldses.org>
	<480655E7.30800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Erik Hensema / HostingXS Internet Services
	<hensema-yolSOB3tinz/D1n+0JDH9g@public.gmane.org>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37173 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753711AbYDQVz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Apr 2008 17:55:27 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jmc4i-0000kv-3w
	for linux-nfs@vger.kernel.org; Fri, 18 Apr 2008 07:55:24 +1000
In-Reply-To: <480655E7.30800@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2008 at 02:39:19PM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> On Wed, Apr 16, 2008 at 10:15:19AM -0500, Wendy Cheng wrote:
>>   
>>> Erik Hensema / HostingXS Internet Services wrote:
>>>     
>>>> Hi all,
>>>>
>>>> Sometimes a file lock gets stuck. Is there any way on either server 
>>>> or  client to obtain a list of locks? Or a list of 
>>>> processes/clients  locking a particular file?
>>>> And the million dollar question: is it possible to forcefully 
>>>> remove a  lock?
>>>>
>>>> I'm using NFSv4 on Linux 2.6.18 (server and client).
>>>>
>>>>         
>>> *Cough* !
>>>
>>> Bruce, so what happens to my lock dropping patch that was said "will 
>>> get  pulled into 2.6.26 kernel" ?
>>>     
>>
>> Gulp.
>>
>> I started an alternative implementation, and got it to the point where
>> it was basically working (but I didn't completely trust it).  And I did
>> a small fix or two on your patches, but I seem to recall there were one
>> or more todo's there too.
>>
>> Then I dropped both for a couple weeks.
>>   
>
> Be carefully. .. "a couple weeks" can turn into "a couple years" .. It  
> has been more than 2 years since my first patch submission. Regardless  
> the patch has been repeatedly requested and had gone thru thorough  
> testings, it just sits there idling while Linux nfs server keeps  
> suffering the very same issue.

Yes, apologies for not getting this done on time.

> Don't get too ambitious. Cluster issues are not trivial - please take  
> one step at a time. The patch is very usable *and* solves an immediate  
> issue *and* has a clean boundary with existing main-line logic. I really  
> don't see the reason to delay it.

My current version of your patch follows.

I've rebased it a couple times (the only change I recall being required
was a trivial fix to take into account reorganization of struct
nameidata.).  I also made two other changes; any objections to either?:

	- I believe the addition of f_iaddr to store the server-side ip
	  address was not quite correct, since the struct nlm_file may
	  be shared by multiple clients accessing the filesystem through
	  multiple server ip's--possibly not an issue for your use case,
	  but easily fixable, since there's already a host->h_saddr
	  filled in for server-side nlm_host structs, which saves us the
	  trouble of inventing a new field.

	- I made the unlock-by-path match filesystems on superblock, not
	  vfs_mount: my understanding is that its purpose is to release
	  all of the locks held by nfs which would prevent completely
	  unmounting the given filesystem.  So we should be matching on
	  all locks for a given superblock, not just those for a single
	  vfsmount of that superblock.

Still to fix:

	- The write methods appear to return the number of failed unlock
	  requests.  But positive return values have a special meaning
	  to nfsctl_transaction_write().  This looks like a bug.

	- The nlm_traverse_files() changes are hairy.

Also still to do, though not necessarily blocks to submitting them:

	- Figure out how to drop locks held by nfsv4 clients as well.

	- Fix the ip address type.

--b.

commit 5f4e32d8544564c477c04009393db914145d6d5b
Author: Wendy Cheng <wcheng@redhat.com>
Date:   Thu Jan 17 11:10:12 2008 -0500

    NLM failover unlock commands
    
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

diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index dbbefbc..a82019e 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -18,6 +18,8 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
+#include <linux/module.h>
+#include <linux/mount.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
@@ -194,6 +196,12 @@ again:
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
@@ -230,7 +238,8 @@ nlm_file_inuse(struct nlm_file *file)
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
+nlm_traverse_files(void *data, nlm_host_match_fn_t match,
+		int (*is_failover_file)(void *data, struct nlm_file *file))
 {
 	struct hlist_node *pos, *next;
 	struct nlm_file	*file;
@@ -244,8 +253,17 @@ nlm_traverse_files(struct nlm_host *host, nlm_host_match_fn_t match)
 
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
@@ -303,21 +321,27 @@ nlm_release_file(struct nlm_file *file)
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
@@ -337,7 +361,7 @@ void
 nlmsvc_mark_resources(void)
 {
 	dprintk("lockd: nlmsvc_mark_resources\n");
-	nlm_traverse_files(NULL, nlmsvc_mark_host);
+	nlm_traverse_files(NULL, nlmsvc_mark_host, NULL);
 }
 
 /*
@@ -348,7 +372,7 @@ nlmsvc_free_host_resources(struct nlm_host *host)
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, nlmsvc_same_host)) {
+	if (nlm_traverse_files(host, nlmsvc_same_host, NULL)) {
 		printk(KERN_WARNING
 			"lockd: couldn't remove all locks held by %s\n",
 			host->h_name);
@@ -368,5 +392,36 @@ nlmsvc_invalidate_all(void)
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
+	return nd->path.mnt->mnt_sb == file->f_file->f_path.mnt->mnt_sb;
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
+	return nlm_traverse_files(&server_addr, nlmsvc_failover_file_ok_ip,
+						NULL);
 }
+EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 8516137..05a59cc 100644
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
 
@@ -52,6 +54,8 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_FO_UnlockIP,
+	NFSD_FO_UnlockFS,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -88,6 +92,9 @@ static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
+static ssize_t failover_unlock_ip(struct file *file, char *buf, size_t size);
+static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size);
+
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -97,6 +104,8 @@ static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_FO_UnlockIP] = failover_unlock_ip,
+	[NFSD_FO_UnlockFS] = failover_unlock_fs,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -288,6 +297,58 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
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
+	path_put(&nd.path);
+	return error;
+}
+
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size)
 {
 	/* request is:
@@ -696,6 +757,10 @@ static int nfsd_fill_super(struct super_block * sb, void * data, int silent)
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
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 4babb2a..cde8605 100644
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
@@ -217,6 +217,12 @@ void		  nlmsvc_mark_resources(void);
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


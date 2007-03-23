From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH 1/4 Revised] NLM failover - nlm_unlock
Date: Fri, 23 Mar 2007 18:55:17 -0400
Message-ID: <46045AD5.9010702@redhat.com>
References: <4508DE13.6030705@redhat.com>
	<17688.30411.484871.224188@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070002050005050902040704"
Cc: cluster-devel@redhat.com, lhh@redhat.com,
	nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUsy1-0005fg-EZ
	for nfs@lists.sourceforge.net; Fri, 23 Mar 2007 16:14:41 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUsy3-0001O5-1k
	for nfs@lists.sourceforge.net; Fri, 23 Mar 2007 16:14:43 -0700
In-Reply-To: <17688.30411.484871.224188@cse.unsw.edu.au>
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
--------------070002050005050902040704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Neil Brown wrote:
> On Thursday September 14, wcheng@redhat.com wrote:
>   
>> By writing exported filesytem id into /proc/fs/nfsd/nlm_unlock, this 
>> patch walks thru lockd's global nlm_files list to release all the locks 
>> associated with the particular id. It is used to enable NFS lock 
>> failover with active-active clustered servers.
>>
>> Relevant steps:
>> 1) Exports filesystem with "fsid" option as:
>>    /etc/exports entry> /mnt/ext3/exports *(fsid=1234,sync,rw)
>> 2) Drops locks based on fsid by:
>>    shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
>>     
>
> I actually felt a bit more comfortable with the server-ip based
> approach, how I cannot really fault the fsid based approach, and it
> does seem to have some advantages, so I guess we go with it.
>   
Neil,

I replaced the checking inside nlm_traverse_files with nlm_file_inuse() 
as we discussed in:
http://sourceforge.net/mailarchive/forum.php?thread_id=31885384&forum_id=4930

If a separate patch is a better idea, feel free to yank it out. The code 
is based on 2.6.21.rc4 kernel and can be used independently (without 
other NLM failover patches). We submit it earlier (others still being 
worked on) to avoid the tedious rebase efforts. There are also  customer 
requests from our distribution to ask for this function in a single 
server (no cluster) environment.

-- Wendy


--------------070002050005050902040704
Content-Type: text/x-patch;
 name="nlm_unlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nlm_unlock.patch"

 Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
 Signed-off-by: Lon Hohberger  <lhh@redhat.com>
 
 fs/lockd/svcsubs.c          |   64 ++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfsctl.c            |   28 +++++++++++++++++++
 include/linux/lockd/bind.h  |    1
 include/linux/lockd/lockd.h |    4 ++
 include/linux/nfsd/nfsfh.h  |   29 +++++++++++++++++++
 5 files changed, 124 insertions(+), 2 deletions(-)

--- gfs2-nmw/include/linux/nfsd/nfsfh.h	2007-03-19 14:18:53.000000000 -0400
+++ linux/include/linux/nfsd/nfsfh.h	2007-03-20 15:45:29.000000000 -0400
@@ -254,6 +254,35 @@ static inline int key_len(int type)
 	}
 }
 
+/* 
+ * Used by lockd to get FSID_NUM fsid from nfs_fh, logic based on fh_verify
+ *      return 0 if not found
+ *             1 if *fsid contain a valid fsid
+ */	
+static inline int get_fsid(struct nfs_fh *fh, unsigned int *fsid)
+{
+	struct nfs_fhbase_new *fh_base = (struct nfs_fhbase_new *) fh->data;
+	int data_left = fh->size/4;
+
+	/* From fb_version to fb_auth - at least two u32 */
+	if (data_left < 2)		
+		return 0;
+
+	/* For various types, check out 
+	 * inlcude/linux/nfsd/nfsfsh.h
+	 */
+	if ((fh_base->fb_version != 1) ||  
+		(fh_base->fb_auth_type != 0) ||
+		(fh_base->fb_fsid_type != FSID_NUM))
+		return 0;
+ 
+	/* The fb_auth is 0 bytes long - imply fb_auth[0] has
+	 * fsid value.
+	 */
+	*fsid = (int) fh_base->fb_auth[0];
+	return 1;
+}
+
 /*
  * Shorthand for dprintk()'s
  */
--- gfs2-nmw/include/linux/lockd/lockd.h	2007-03-19 14:18:42.000000000 -0400
+++ linux/include/linux/lockd/lockd.h	2007-03-21 15:01:57.000000000 -0400
@@ -202,6 +202,8 @@ void		  nlm_release_file(struct nlm_file
 void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
+int		  nlmsvc_same_fsid(struct nlm_host *, struct nlm_host *);
+int		  nlmsvc_fo_unlock(int *fsid);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- gfs2-nmw/fs/lockd/svcsubs.c	2007-03-19 14:17:52.000000000 -0400
+++ linux/fs/lockd/svcsubs.c	2007-03-23 17:46:10.000000000 -0400
@@ -18,6 +18,7 @@
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
+#include <linux/module.h>	/* EXPORT_SYMBOL */
 
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
@@ -179,6 +180,7 @@ again:
 		if (match(lockhost, host)) {
 			struct file_lock lock = *fl;
 
+			dprintk("nlm_traverse_locks: match-delete the lock\n");
 			lock.fl_type  = F_UNLCK;
 			lock.fl_start = 0;
 			lock.fl_end   = OFFSET_MAX;
@@ -194,12 +196,41 @@ again:
 	return 0;
 }
 
+static inline int
+nlm_fo_fsid_match(struct nlm_host *host, struct nlm_file *file)
+{
+	struct nfs_fh *fh = &file->f_handle;
+	unsigned int fsid_found, fsid_passed = *((unsigned int *)host);
+ 
+	nlm_debug_print_fh("nlm_fo_check_fsid", fh);
+
+	/* yank fsid out of file handle */
+	if (get_fsid(fh, &fsid_found) && (fsid_found == fsid_passed))
+		return 1;
+
+	/* no match */
+	return 0;
+}
+
 /*
  * Inspect a single file
  */
 static inline int
 nlm_inspect_file(struct nlm_host *host, struct nlm_file *file, nlm_host_match_fn_t match)
 {
+	/* Cluster failover has timing constraints. There is a slight
+	 * performance hit if nlm_fo_check_fsid()is implemented as a match 
+	 * fn (since it will be invoked multiple times later). Instead, we
+	 * we add fsid-matching logic into the following clause.
+	 * If fsid matches, nlmsvc_same_fsid will always return true.
+	 */
+	dprintk("nlm_inspect_files: file=%p\n", file);
+	if (unlikely(match == nlmsvc_same_fsid)) {
+		if (!nlm_fo_fsid_match(host, file))
+			return 0;
+		dprintk("nlm_fo fsid matches\n");
+	}
+
 	nlmsvc_traverse_blocks(host, file, match);
 	nlmsvc_traverse_shares(host, file, match);
 	return nlm_traverse_locks(host, file, match);
@@ -250,8 +281,7 @@ nlm_traverse_files(struct nlm_host *host
 			mutex_lock(&nlm_file_mutex);
 			file->f_count--;
 			/* No more references to this file. Let go of it. */
-			if (list_empty(&file->f_blocks) && !file->f_locks
-			 && !file->f_shares && !file->f_count) {
+			if (!nlm_file_inuse(file)) {
 				hlist_del(&file->f_list);
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);
@@ -301,7 +331,14 @@ nlm_release_file(struct nlm_file *file)
  * nlmsvc_is_client:
  *	returns 1 iff the host is a client.
  *	Used by nlmsvc_invalidate_all
+ *
+ * nlmsvc_same_fsid:
+ *	always returns 1 if invoked. The real job is done by
+ *	nlm_fo_check_fsid(). It should release all resources 
+ *	bound to a specific nfs export, identified by exported 
+ *	fsid.
  */
+
 static int
 nlmsvc_mark_host(struct nlm_host *host, struct nlm_host *dummy)
 {
@@ -330,6 +367,15 @@ nlmsvc_is_client(struct nlm_host *host, 
 		return 0;
 }
 
+/* To fit the logic into current lockd code structure, we add a 
+ * little wrapper function here. The real matching task should be
+ * carried out by nlm_fo_check_fsid().
+ */
+int nlmsvc_same_fsid(struct nlm_host *dummy1, struct nlm_host *dummy2)
+{
+	return 1;
+}
+
 /*
  * Mark all hosts that still hold resources
  */
@@ -370,3 +416,17 @@ nlmsvc_invalidate_all(void)
 	 */
 	nlm_traverse_files(NULL, nlmsvc_is_client);
 }
+
+EXPORT_SYMBOL(nlmsvc_fo_unlock);
+
+/*
+ * Release locks associated with an export fsid upon failover
+ * 	invoked via nfsd nfsctl call (write_fo_unlock).
+ */
+int
+nlmsvc_fo_unlock(int *fsid)
+{
+	return (nlm_traverse_files((struct nlm_host*)fsid, nlmsvc_same_fsid));
+}
+
+
--- gfs2-nmw/fs/nfsd/nfsctl.c	2007-03-19 14:18:04.000000000 -0400
+++ linux/fs/nfsd/nfsctl.c	2007-03-23 18:24:47.000000000 -0400
@@ -36,6 +36,7 @@
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/nfsd/interface.h>
+#include <linux/lockd/bind.h>
 
 #include <asm/uaccess.h>
 
@@ -53,6 +54,7 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_NlmUnlock,
 	NFSD_Threads,
 	NFSD_Pool_Threads,
 	NFSD_Versions,
@@ -79,6 +81,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
+static ssize_t write_fo_unlock(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_pool_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_versions(struct file *file, char *buf, size_t size);
@@ -98,6 +101,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_NlmUnlock] = write_fo_unlock,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Pool_Threads] = write_pool_threads,
 	[NFSD_Versions] = write_versions,
@@ -345,6 +349,29 @@ static ssize_t write_filehandle(struct f
 	return mesg - buf;	
 }
 
+static ssize_t write_fo_unlock(struct file *file, char *buf, size_t size)
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
+	/* call nlm to release the locks - fsid is passed by reference 
+	 * to allow other routine uses NULL pointer. */
+	rc = nlmsvc_fo_unlock(&fsid);
+	if (rc) 
+		return rc;
+
+	/* done */
+	sprintf(buf, "nlm_fo fsid=%d released locks\n", fsid);
+	return strlen(buf);
+}
+
 extern int nfsd_nrthreads(void);
 
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
@@ -648,6 +675,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_NlmUnlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
--- gfs2-nmw/include/linux/lockd/bind.h	2007-03-19 14:18:42.000000000 -0400
+++ linux/include/linux/lockd/bind.h	2007-03-21 14:54:07.000000000 -0400
@@ -37,5 +37,6 @@ extern struct nlmsvc_binding *	nlmsvc_op
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
+extern int	nlmsvc_fo_unlock(int *fsid);
 
 #endif /* LINUX_LOCKD_BIND_H */
--- gfs2-nmw/include/linux/lockd/lockd.h	2007-03-19 14:18:42.000000000 -0400
+++ linux/include/linux/lockd/lockd.h	2007-03-21 15:01:57.000000000 -0400
@@ -202,6 +202,8 @@ void		  nlm_release_file(struct nlm_file
 void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
+int		  nlmsvc_same_fsid(struct nlm_host *, struct nlm_host *);
+int		  nlmsvc_fo_unlock(int *fsid);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)

--------------070002050005050902040704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--------------070002050005050902040704
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070002050005050902040704--

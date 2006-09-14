From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 1/4 Revised] NLM failover - nlm_unlock
Date: Thu, 14 Sep 2006 00:44:03 -0400
Message-ID: <4508DE13.6030705@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------040402020403010306030501"
Cc: lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNisx-0005xZ-MC
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:31:35 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GNisx-0003bW-T1
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:31:36 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k8E4VTlV019314
	for <nfs@lists.sourceforge.net>; Thu, 14 Sep 2006 00:31:29 -0400
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
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
--------------040402020403010306030501
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

By writing exported filesytem id into /proc/fs/nfsd/nlm_unlock, this 
patch walks thru lockd's global nlm_files list to release all the locks 
associated with the particular id. It is used to enable NFS lock 
failover with active-active clustered servers.

Relevant steps:
1) Exports filesystem with "fsid" option as:
   /etc/exports entry> /mnt/ext3/exports *(fsid=1234,sync,rw)
2) Drops locks based on fsid by:
   shell> echo 1234 > /proc/fs/nfsd/nlm_unlock

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger  <lhh@redhat.com>

 fs/lockd/svcsubs.c          |   79 
+++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/nfsctl.c            |   42 +++++++++++++++++++++++
 include/linux/lockd/bind.h  |    5 ++
 include/linux/lockd/lockd.h |    2 +
 include/linux/nfsd/debug.h  |    1
 5 files changed, 124 insertions(+), 5 deletions(-)


--------------040402020403010306030501
Content-Type: text/x-patch;
 name="gfs_nlm_unlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gfs_nlm_unlock.patch"

--- linux-0/include/linux/lockd/lockd.h	2006-09-03 21:06:18.000000000 -0400
+++ linux-1/include/linux/lockd/lockd.h	2006-09-03 21:51:41.000000000 -0400
@@ -132,6 +132,7 @@ struct nlm_block {
 #define NLM_ACT_CHECK		0		/* check for locks */
 #define NLM_ACT_MARK		1		/* mark & sweep */
 #define NLM_ACT_UNLOCK		2		/* release all locks */
+#define NLM_ACT_FO_UNLOCK	3		/* failover release locks */
 
 /*
  * Global variables
@@ -195,6 +196,7 @@ void		  nlm_release_file(struct nlm_file
 void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
+int 		  nlmsvc_fo_unlock(int *fsid);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- linux-0/fs/lockd/svcsubs.c	2006-09-03 21:06:17.000000000 -0400
+++ linux-1/fs/lockd/svcsubs.c	2006-09-13 13:48:01.000000000 -0400
@@ -19,6 +19,8 @@
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
 
+#include <linux/module.h>
+
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
 
@@ -214,6 +216,37 @@ again:
 }
 
 /*
+ * Get fsid from nfs_fh:
+ * return 1 if *fsid contains a valid value.
+ */
+static inline int
+nlm_fo_get_fsid(struct nfs_fh *fh, int *fsid)
+{
+	struct nfs_fhbase_new *fh_base = (struct nfs_fhbase_new *) fh->data;
+ 	int data_left = fh->size/4;
+ 
+ 	nlm_debug_print_fh("nlm_fo_find_fsid", fh);
+ 
+ 	/* From fb_version to fb_auth - at least two u32 */
+ 	if (data_left < 2)		
+ 		return 0;
+  
+ 	/* For various types, check out 
+ 	 * inlcude/linux/nfsd/nfsfsh.h
+ 	 */
+ 	if ((fh_base->fb_version != 1) ||  
+ 		(fh_base->fb_auth_type != 0) ||
+ 		(fh_base->fb_fsid_type != 1))
+ 		return 0;
+ 
+ 	/* The fb_auth is 0 bytes long - imply fb_auth[0] has
+ 	 * fsid value.
+ 	 */
+ 	*fsid = (int) fh_base->fb_auth[0];
+ 	return 1;
+}
+
+/*
  * Operate on a single file
  */
 static inline int
@@ -234,21 +267,42 @@ nlm_inspect_file(struct nlm_host *host, 
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(struct nlm_host *host, int action)
+nlm_traverse_files(struct nlm_host *host, int *fsidp, int action)
 {
 	struct nlm_file	*file, **fp;
-	int i, ret = 0;
+	int i, ret = 0, found, fsid_in=0, fsid, act=action;
 
 	mutex_lock(&nlm_file_mutex);
+	if (unlikely(action == NLM_ACT_FO_UNLOCK)) {
+		BUG_ON(fsidp == NULL);
+		fsid_in = *fsidp;
+	}
 	for (i = 0; i < FILE_NRHASH; i++) {
 		fp = nlm_files + i;
 		while ((file = *fp) != NULL) {
 			file->f_count++;
 			mutex_unlock(&nlm_file_mutex);
 
+			/*
+ 		 	 * NLM lock failover:
+ 		 	 *      Upon NLM_ACT_FO_UNLOCK, obtain fsid from
+ 		 	 *      f_handle. If match is found, the lock will 
+ 			 *	be released via NLM_ACT_UNLOCK.
+ 		 	 */
+ 			if (unlikely(action == NLM_ACT_FO_UNLOCK)) {
+ 				found = nlm_fo_get_fsid(&file->f_handle, &fsid);
+ 				if (!found || (fsid != fsid_in)) {
+ 					fp = &file->f_next;
+ 					continue;
+ 				}
+ 				dprintk("lockd: drop lock file=%p fsid=%d\n", 
+ 					 file, fsid);
+ 				act  = NLM_ACT_UNLOCK;
+ 			}
+
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
-			if (nlm_inspect_file(host, file, action))
+			if (nlm_inspect_file(host, file, act))
 				ret = 1;
 
 			mutex_lock(&nlm_file_mutex);
@@ -256,6 +310,8 @@ nlm_traverse_files(struct nlm_host *host
 			/* No more references to this file. Let go of it. */
 			if (!file->f_blocks && !file->f_locks
 			 && !file->f_shares && !file->f_count) {
+				dprintk("lockd: fo_unlock close file=%p\n", 
+					 file);
 				*fp = file->f_next;
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);
@@ -303,7 +359,7 @@ nlmsvc_mark_resources(void)
 {
 	dprintk("lockd: nlmsvc_mark_resources\n");
 
-	nlm_traverse_files(NULL, NLM_ACT_MARK);
+	nlm_traverse_files(NULL, NULL, NLM_ACT_MARK);
 }
 
 /*
@@ -314,7 +370,7 @@ nlmsvc_free_host_resources(struct nlm_ho
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, NLM_ACT_UNLOCK))
+	if (nlm_traverse_files(host, NULL, NLM_ACT_UNLOCK))
 		printk(KERN_WARNING
 			"lockd: couldn't remove all locks held by %s",
 			host->h_name);
@@ -334,3 +390,16 @@ nlmsvc_invalidate_all(void)
 		nlm_release_host(host);
 	}
 }
+
+EXPORT_SYMBOL(nlmsvc_fo_unlock);
+
+/*
+ * release locks associated with an export fsid upon failover
+ */
+int
+nlmsvc_fo_unlock(int *fsid)
+{
+	/* drop the locks */
+	return (nlm_traverse_files(NULL, fsid, NLM_ACT_FO_UNLOCK)); 
+}
+
--- linux-0/include/linux/lockd/bind.h	2006-09-03 21:06:18.000000000 -0400
+++ linux-1/include/linux/lockd/bind.h	2006-09-03 21:51:41.000000000 -0400
@@ -33,4 +33,9 @@ extern int	nlmclnt_proc(struct inode *, 
 extern int	lockd_up(void);
 extern void	lockd_down(void);
 
+/*
+ * NLM failover
+ */
+extern int     nlmsvc_fo_unlock(int *fsid);
+
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-0/fs/nfsd/nfsctl.c	2006-09-03 21:06:17.000000000 -0400
+++ linux-1/fs/nfsd/nfsctl.c	2006-09-03 21:51:40.000000000 -0400
@@ -33,6 +33,10 @@
 #include <linux/nfsd/syscall.h>
 #include <linux/nfsd/interface.h>
 
+/* nlm failover */
+#include <linux/in.h>
+#include <linux/lockd/bind.h>
+
 #include <asm/uaccess.h>
 
 unsigned int nfsd_versbits = ~0;
@@ -51,6 +55,7 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
+	NFSD_NlmUnlock,
 	NFSD_Threads,
 	NFSD_Versions,
 	/*
@@ -81,6 +86,14 @@ static ssize_t write_leasetime(struct fi
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 #endif
 
+/*
+ * NLM lock failover
+ */
+
+#define NFSDDBG_FACILITY	NFSDDBG_CLUSTER
+
+static ssize_t write_fo_unlock(struct file *file, char *buf, size_t size);
+
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -90,6 +103,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_NlmUnlock] = write_fo_unlock,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Versions] = write_versions,
 #ifdef CONFIG_NFSD_V4
@@ -334,6 +348,33 @@ static ssize_t write_filehandle(struct f
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
+	if (rc) {
+		dprintk("nfsd: write_fo_unlock invalid fsid(%s)\n", buf);
+		return rc;
+	}
+
+	/* call nlm to release the locks - fsid is passed by reference 
+	 * to allow other routine uses NULL pointer. */
+	rc = nlmsvc_fo_unlock(&fsid);
+	if (rc) {
+		dprintk("nfsd: nlmsvc_fo_unlock return rc=%d\n", rc);
+		return rc;
+	}
+
+	/* done */
+	sprintf(buf, "nlm_fo fsid=%d released locks\n", fsid);
+	return strlen(buf);
+}
+
 extern int nfsd_nrthreads(void);
 
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
@@ -482,6 +523,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_NlmUnlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
--- linux-0/include/linux/nfsd/debug.h	2006-09-03 21:06:18.000000000 -0400
+++ linux-1/include/linux/nfsd/debug.h	2006-09-03 21:51:41.000000000 -0400
@@ -32,6 +32,7 @@
 #define NFSDDBG_REPCACHE	0x0080
 #define NFSDDBG_XDR		0x0100
 #define NFSDDBG_LOCKD		0x0200
+#define NFSDDBG_CLUSTER 	0x0400
 #define NFSDDBG_ALL		0x7FFF
 #define NFSDDBG_NOCHANGE	0xFFFF
 

--------------040402020403010306030501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------040402020403010306030501
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------040402020403010306030501--

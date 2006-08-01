From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 1/3] NLM lock failover
Date: Mon, 31 Jul 2006 22:01:32 -0400
Message-ID: <1154397693.3378.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-CG4jx4Pwx+G+TNeVDbkI"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7jOU-0006aA-BB
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 18:50:02 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7jOS-0003pm-5t
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 18:50:02 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k711nxOs029072
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 21:49:59 -0400
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


--=-CG4jx4Pwx+G+TNeVDbkI
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The patch piggy-backs the logic into "rq_daddr" field of struct svc_rqst
where NFS server ip address is stored. Upon writing IPv4 address in
standard dot notation into /proc/fs/nfsd/nlm_unlock, the logic examines
NLM's global nlm_files list and subsequently unlock the associated file
if server ip address matches.

Signed-off-by: S. Wendy Cheng <wcheng@redhat.com>
Signed-off-by: Lon Hohberger <lhh@redhat.com>

fs/lockd/svcsubs.c          |   58 +++++++++++++++++++++++++++++++++++++
+++---- 
fs/nfsd/nfsctl.c            |   57 +++++++++++++++++++++++++++++++++++++
+++++
include/linux/lockd/bind.h  |    5 +++
include/linux/lockd/lockd.h |    3 ++
include/linux/nfsd/debug.h  |    1
net/sunrpc/svcsock.c        |    5 +++
6 files changed, 124 insertions(+), 5 deletions(-)




--=-CG4jx4Pwx+G+TNeVDbkI
Content-Disposition: attachment; filename=gfs_nlm_unlock.patch
Content-Type: text/x-patch; name=gfs_nlm_unlock.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-0/include/linux/lockd/lockd.h	2006-07-14 14:32:29.000000000 -0400
+++ linux-1/include/linux/lockd/lockd.h	2006-07-28 15:47:27.000000000 -0400
@@ -105,6 +105,7 @@ struct nlm_file {
 	unsigned int		f_count;	/* reference count */
 	struct semaphore	f_sema;		/* avoid concurrent access */
 	int		       	f_hash;		/* hash of f_handle */
+	__u32			f_iaddr;	/* server ip for failover */
 };
 
 /*
@@ -133,6 +134,7 @@ struct nlm_block {
 #define NLM_ACT_CHECK		0		/* check for locks */
 #define NLM_ACT_MARK		1		/* mark & sweep */
 #define NLM_ACT_UNLOCK		2		/* release all locks */
+#define NLM_ACT_FO_UNLOCK	3		/* failover release locks */
 
 /*
  * Global variables
@@ -196,6 +198,7 @@ void		  nlm_release_file(struct nlm_file
 void		  nlmsvc_mark_resources(void);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
+int 		  nlmsvc_fo_unlock(struct in_addr *);
 
 static __inline__ struct inode *
 nlmsvc_file_inode(struct nlm_file *file)
--- linux-0/net/sunrpc/svcsock.c	2006-07-14 14:32:25.000000000 -0400
+++ linux-1/net/sunrpc/svcsock.c	2006-07-28 15:47:28.000000000 -0400
@@ -454,6 +454,7 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	struct msghdr	msg;
 	struct socket	*sock;
 	int		len, alen;
+	struct sockaddr_in   daddr;
 
 	rqstp->rq_addrlen = sizeof(rqstp->rq_addr);
 	sock = rqstp->rq_sock->sk_sock;
@@ -474,6 +475,10 @@ svc_recvfrom(struct svc_rqst *rqstp, str
 	alen = sizeof(rqstp->rq_addr);
 	sock->ops->getname(sock, (struct sockaddr *)&rqstp->rq_addr, &alen, 1);
 
+	/* add server ip for nlm lock failover */
+	sock->ops->getname(sock, (struct sockaddr *)&daddr, &alen, 0);
+	rqstp->rq_daddr = daddr.sin_addr.s_addr;
+
 	dprintk("svc: socket %p recvfrom(%p, %Zu) = %d\n",
 		rqstp->rq_sock, iov[0].iov_base, iov[0].iov_len, len);
 
--- linux-0/fs/lockd/svcsubs.c	2006-07-14 14:32:27.000000000 -0400
+++ linux-1/fs/lockd/svcsubs.c	2006-07-28 15:47:28.000000000 -0400
@@ -19,6 +19,8 @@
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
 
+#include <linux/module.h>
+
 #define NLMDBG_FACILITY		NLMDBG_SVCSUBS
 
 
@@ -123,6 +125,10 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	file->f_next = nlm_files[hash];
 	nlm_files[hash] = file;
 
+	/* fill in f_iaddr for nlm lock failover */
+	file->f_iaddr = rqstp->rq_daddr;
+	dprintk("lockd: file->f_iaddr = %u.%u.%u.%u\n", NIPQUAD(file->f_iaddr));
+
 found:
 	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
 	*result = file;
@@ -234,18 +240,38 @@ nlm_inspect_file(struct nlm_host *host, 
  * Loop over all files in the file table.
  */
 static int
-nlm_traverse_files(struct nlm_host *host, int action)
+nlm_traverse_files(struct nlm_host *host, struct in_addr *serv, int action)
 {
 	struct nlm_file	*file, **fp;
-	int		i;
+	int		i, act=action;
 
 	mutex_lock(&nlm_file_mutex);
 	for (i = 0; i < FILE_NRHASH; i++) {
 		fp = nlm_files + i;
 		while ((file = *fp) != NULL) {
+
+			/*
+		 	 * NLM lock failover:
+		 	 *      Upon NLM_ACT_FO_UNLOCK, compare the
+		 	 *      server in_addr (f_iaddr) with requested
+		 	 *      serv. If match is found, the lock will 
+			 *	be released via NLM_ACT_UNLOCK.
+		 	 */
+			if (unlikely(action == NLM_ACT_FO_UNLOCK)) {
+				dprintk("lockd: fo file check %u.%u.%u.%u\n",
+					NIPQUAD(serv->s_addr));
+				if (serv->s_addr != file->f_iaddr) {
+					fp = &file->f_next;
+					continue;
+				}
+				dprintk("lockd: fo found match file 0x%x\n",
+					(int) file);
+				act  = NLM_ACT_UNLOCK;
+			}
+
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
-			if (nlm_inspect_file(host, file, action)) {
+			if (nlm_inspect_file(host, file, act)) {
 				mutex_unlock(&nlm_file_mutex);
 				return 1;
 			}
@@ -253,6 +279,8 @@ nlm_traverse_files(struct nlm_host *host
 			/* No more references to this file. Let go of it. */
 			if (!file->f_blocks && !file->f_locks
 			 && !file->f_shares && !file->f_count) {
+				dprintk("lockd: fo_unlock close file=0x%x\n", 
+					(int) file);
 				*fp = file->f_next;
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);
@@ -300,7 +328,7 @@ nlmsvc_mark_resources(void)
 {
 	dprintk("lockd: nlmsvc_mark_resources\n");
 
-	nlm_traverse_files(NULL, NLM_ACT_MARK);
+	nlm_traverse_files(NULL, NULL, NLM_ACT_MARK);
 }
 
 /*
@@ -311,7 +339,7 @@ nlmsvc_free_host_resources(struct nlm_ho
 {
 	dprintk("lockd: nlmsvc_free_host_resources\n");
 
-	if (nlm_traverse_files(host, NLM_ACT_UNLOCK))
+	if (nlm_traverse_files(host, NULL, NLM_ACT_UNLOCK))
 		printk(KERN_WARNING
 			"lockd: couldn't remove all locks held by %s",
 			host->h_name);
@@ -331,3 +359,23 @@ nlmsvc_invalidate_all(void)
 		nlm_release_host(host);
 	}
 }
+
+EXPORT_SYMBOL(nlmsvc_fo_unlock);
+
+/*
+ * release locks associated with an IP upon failover
+ */
+int
+nlmsvc_fo_unlock(struct in_addr *serv_ip)
+{
+	struct nlm_host clnt;
+
+	/* To do:
+	 * prepare nlm_host for nfs V4 client 
+	 */
+	memset(&clnt, 0, sizeof(struct nlm_host));
+
+	/* drop the locks */
+	return (nlm_traverse_files(NULL, serv_ip, NLM_ACT_FO_UNLOCK)); 
+}
+
--- linux-0/include/linux/lockd/bind.h	2006-07-14 14:32:29.000000000 -0400
+++ linux-1/include/linux/lockd/bind.h	2006-07-28 15:47:28.000000000 -0400
@@ -33,4 +33,9 @@ extern int	nlmclnt_proc(struct inode *, 
 extern int	lockd_up(void);
 extern void	lockd_down(void);
 
+/*
+ * NLM failover
+ */
+extern int     nlmsvc_fo_unlock(struct in_addr *);
+
 #endif /* LINUX_LOCKD_BIND_H */
--- linux-0/fs/nfsd/nfsctl.c	2006-07-14 14:32:28.000000000 -0400
+++ linux-1/fs/nfsd/nfsctl.c	2006-07-31 18:04:49.000000000 -0400
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
+	NFSD_Nlm_unlock,
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
+static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size);
+
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
 	[NFSD_Add] = write_add,
@@ -90,6 +103,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
+	[NFSD_Nlm_unlock] = do_nlm_fo_unlock,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Versions] = write_versions,
 #ifdef CONFIG_NFSD_V4
@@ -334,6 +348,48 @@ static ssize_t write_filehandle(struct f
 	return mesg - buf;	
 }
 
+extern __u32 in_aton(const char *str);
+
+int __get_nlm_host(char *buf, size_t size, struct in_addr *host_addr)
+{
+	/* sanity check */
+	if (size <= 0) return -EINVAL;
+
+	/* The ip is passed from nfsctl_transaction_write() 
+	 * where simple_transaction_get() "copy_from_user()"
+	 * into buf. Convert the string into a valid ip addr.
+	 */
+	host_addr->s_addr = in_aton(buf);
+	dprintk("nfsd: __get_nlm_host (%u.%u.%u.%u)\n",
+		NIPQUAD(host_addr->s_addr));
+	return 0;
+}
+
+static ssize_t do_nlm_fo_unlock(struct file *file, char *buf, size_t size)
+{
+	struct in_addr serv_addr;
+	int rc;
+
+	/* convert string into a valid ip */
+	rc = __get_nlm_host(buf, size, &serv_addr);
+	if (rc) {
+		dprintk("nfsd: do_nlm_ip_unlock invalid ip(%s)\n", buf);
+		return rc;
+	}
+
+	/* call nlm to release the locks */
+	rc = nlmsvc_fo_unlock(&serv_addr);
+	if (rc) {
+		dprintk("nfsd: nlmsvc_fo_unlock return rc=%d\n", rc);
+		return rc;
+	}
+
+	/* done */
+	sprintf(buf, "nlm ip unlock released for %u.%u.%u.%u\n",
+		NIPQUAD(serv_addr.s_addr));
+	return strlen(buf);
+}
+
 extern int nfsd_nrthreads(void);
 
 static ssize_t write_threads(struct file *file, char *buf, size_t size)
@@ -482,6 +538,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Nlm_unlock] = {"nlm_unlock", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
--- linux-0/include/linux/nfsd/debug.h	2006-07-14 14:32:29.000000000 -0400
+++ linux-1/include/linux/nfsd/debug.h	2006-07-31 18:18:46.000000000 -0400
@@ -32,6 +32,7 @@
 #define NFSDDBG_REPCACHE	0x0080
 #define NFSDDBG_XDR		0x0100
 #define NFSDDBG_LOCKD		0x0200
+#define NFSDDBG_CLUSTER 	0x0400
 #define NFSDDBG_ALL		0x7FFF
 #define NFSDDBG_NOCHANGE	0xFFFF
 

--=-CG4jx4Pwx+G+TNeVDbkI
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--=-CG4jx4Pwx+G+TNeVDbkI
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-CG4jx4Pwx+G+TNeVDbkI--

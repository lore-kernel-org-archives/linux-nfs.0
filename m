From: Bruce Allan <bwa@us.ibm.com>
Subject: [PATCH 2/5] initial changes for NFS-over-IPv6
 (linux-2.5.66-NFS_IPv6-nfsd.dif)
Date: 11 Apr 2003 16:35:21 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1050104122.1413.274.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bwa@us.ibm.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e4.ny.us.ibm.com ([32.97.182.104])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19483O-0006Vy-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 16:35:31 -0700
Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e4.ny.us.ibm.com (8.12.9/8.12.2) with ESMTP id h3BNZNsZ163674
	for <nfs@lists.sourceforge.net>; Fri, 11 Apr 2003 19:35:23 -0400
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This patch against 2.5.66 provides for IPv6 support for the NFS server.

diff -Naurp linux-2.5.66/fs/nfsd/nfsctl.c linux-2.5.66-NFS_IPV6/fs/nfsd/nfsctl.c
--- linux-2.5.66/fs/nfsd/nfsctl.c	2003-03-24 14:00:08.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/nfsd/nfsctl.c	2003-04-07 17:50:29.000000000 -0700
@@ -276,7 +276,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfs(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fsparm *data;
-	struct sockaddr_in *sin;
+	struct sockaddr *ap;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh *res;
@@ -285,16 +285,21 @@ static ssize_t write_getfs(struct file *
 		return -EINVAL;
 	data = (struct nfsctl_fsparm*)buf;
 	err = -EPROTONOSUPPORT;
+#ifdef CONFIG_NFS_IPV6
+	if (data->gd_addr.ss_family != AF_INET &&
+	    data->gd_addr.ss_family != AF_INET6)
+#else
 	if (data->gd_addr.sa_family != AF_INET)
+#endif
 		goto out;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	ap = (struct sockaddr *)&data->gd_addr;
 	if (data->gd_maxlen > NFS3_FHSIZE)
 		data->gd_maxlen = NFS3_FHSIZE;
 
 	res = (struct knfsd_fh*)buf;
 
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+	if (!(clp = auth_unix_lookup(ap)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, res, data->gd_maxlen);
@@ -310,7 +315,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_getfd(struct file *file, char *buf, size_t size)
 {
 	struct nfsctl_fdparm *data;
-	struct sockaddr_in *sin;
+	struct sockaddr *ap;
 	struct auth_domain *clp;
 	int err = 0;
 	struct knfsd_fh fh;
@@ -320,16 +325,21 @@ static ssize_t write_getfd(struct file *
 		return -EINVAL;
 	data = (struct nfsctl_fdparm*)buf;
 	err = -EPROTONOSUPPORT;
+#ifdef CONFIG_NFS_IPV6
+	if (data->gd_addr.ss_family != AF_INET && 
+	    data->gd_addr.ss_family != AF_INET6)
+#else
 	if (data->gd_addr.sa_family != AF_INET)
+#endif
 		goto out;
 	err = -EINVAL;
 	if (data->gd_version < 2 || data->gd_version > NFSSVC_MAXVERS)
 		goto out;
 
 	res = buf;
-	sin = (struct sockaddr_in *)&data->gd_addr;
+	ap = (struct sockaddr *)&data->gd_addr;
 	exp_readlock();
-	if (!(clp = auth_unix_lookup(sin->sin_addr)))
+	if (!(clp = auth_unix_lookup(ap)))
 		err = -EPERM;
 	else {
 		err = exp_rootfh(clp, data->gd_path, &fh, NFS_FHSIZE);
diff -Naurp linux-2.5.66/fs/nfsd/nfsfh.c linux-2.5.66-NFS_IPV6/fs/nfsd/nfsfh.c
--- linux-2.5.66/fs/nfsd/nfsfh.c	2003-03-24 14:00:17.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/nfsd/nfsfh.c	2003-04-07 17:38:23.000000000 -0700
@@ -22,6 +22,8 @@
 
 #include <linux/sunrpc/svc.h>
 #include <linux/nfsd/nfsd.h>
+#include <linux/in.h>
+#include <linux/in6.h>
 
 #define NFSDDBG_FACILITY		NFSDDBG_FH
 #define NFSD_PARANOIA 1
@@ -91,6 +93,8 @@ fh_verify(struct svc_rqst *rqstp, struct
 	struct dentry	*dentry;
 	struct inode	*inode;
 	u32		error = 0;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 
 	dprintk("nfsd: fh_verify(%s)\n", SVCFH_fmt(fhp));
 
@@ -156,10 +160,38 @@ fh_verify(struct svc_rqst *rqstp, struct
 		/* Check if the request originated from a secure port. */
 		error = nfserr_perm;
 		if (!rqstp->rq_secure && EX_SECURE(exp)) {
-			printk(KERN_WARNING
-			       "nfsd: request from insecure port (%08x:%d)!\n",
-			       ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			       ntohs(rqstp->rq_addr.sin_port));
+			switch ( rqstp->rq_addr.ss_family ) {
+			case AF_INET:
+				sin = (struct sockaddr_in *)&(rqstp->rq_addr);
+				printk(KERN_WARNING
+				       "nfsd: request from insecure port "
+				       "(%08x:%d)!\n",
+				       ntohl(sin->sin_addr.s_addr),
+				       ntohs(sin->sin_port));
+				break;
+
+			case AF_INET6:
+				sin6 = (struct sockaddr_in6 *)&(rqstp->rq_addr);
+				printk(KERN_WARNING
+				       "nfsd: request from insecure port "
+					"(%x:%x:%x:%x:%x:%x:%x:%x port %d)!\n",
+				       ntohs(sin6->sin6_addr.s6_addr16[0]),
+				       ntohs(sin6->sin6_addr.s6_addr16[1]),
+				       ntohs(sin6->sin6_addr.s6_addr16[2]),
+				       ntohs(sin6->sin6_addr.s6_addr16[3]),
+				       ntohs(sin6->sin6_addr.s6_addr16[4]),
+				       ntohs(sin6->sin6_addr.s6_addr16[5]),
+				       ntohs(sin6->sin6_addr.s6_addr16[6]),
+				       ntohs(sin6->sin6_addr.s6_addr16[7]),
+				       ntohs(sin6->sin6_port));
+				break;
+
+			default:
+				printk("nfsd: %s unknown address family %d\n",
+					__FUNCTION__,
+					rqstp->rq_addr.ss_family);
+				break;
+			}
 			goto out;
 		}
 
diff -Naurp linux-2.5.66/fs/nfsd/nfsproc.c linux-2.5.66-NFS_IPV6/fs/nfsd/nfsproc.c
--- linux-2.5.66/fs/nfsd/nfsproc.c	2003-03-24 14:00:15.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/fs/nfsd/nfsproc.c	2003-04-07 17:38:52.000000000 -0700
@@ -15,6 +15,7 @@
 #include <linux/fcntl.h>
 #include <linux/net.h>
 #include <linux/in.h>
+#include <linux/in6.h>
 #include <linux/namei.h>
 #include <linux/unistd.h>
 #include <linux/slab.h>
@@ -117,6 +118,8 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 				       struct nfsd_readres  *resp)
 {
 	int	nfserr;
+	struct sockaddr_in  *sin  = NULL;
+	struct sockaddr_in6 *sin6 = NULL;
 
 	dprintk("nfsd: READ    %s %d bytes at %d\n",
 		SVCFH_fmt(&argp->fh),
@@ -127,11 +130,39 @@ nfsd_proc_read(struct svc_rqst *rqstp, s
 	 */
 
 	if (NFSSVC_MAXBLKSIZE < argp->count) {
-		printk(KERN_NOTICE
-			"oversized read request from %08x:%d (%d bytes)\n",
-				ntohl(rqstp->rq_addr.sin_addr.s_addr),
-				ntohs(rqstp->rq_addr.sin_port),
+		switch ( rqstp->rq_addr.ss_family ) {
+		case AF_INET:
+			sin = (struct sockaddr_in *)&(rqstp->rq_addr);
+			printk(KERN_NOTICE
+			     "oversized read request from %08x:%d (%d bytes)\n",
+				ntohl(sin->sin_addr.s_addr),
+				ntohs(sin->sin_port),
 				argp->count);
+			break;
+
+		case AF_INET6:
+			sin6 = (struct sockaddr_in6 *)&(rqstp->rq_addr);
+			printk(KERN_NOTICE
+				"oversized read request from "
+				"%x:%x:%x:%x:%x:%x:%x:%x port %d (%d bytes)\n",
+				ntohs(sin6->sin6_addr.s6_addr16[0]),
+				ntohs(sin6->sin6_addr.s6_addr16[1]),
+				ntohs(sin6->sin6_addr.s6_addr16[2]),
+				ntohs(sin6->sin6_addr.s6_addr16[3]),
+				ntohs(sin6->sin6_addr.s6_addr16[4]),
+				ntohs(sin6->sin6_addr.s6_addr16[5]),
+				ntohs(sin6->sin6_addr.s6_addr16[6]),
+				ntohs(sin6->sin6_addr.s6_addr16[7]),
+				ntohs(sin6->sin6_port),
+				argp->count);
+			break;
+
+		default:
+			printk("nfsd: %s unknown address family %d\n",
+				__FUNCTION__,
+				rqstp->rq_addr.ss_family);
+			break;
+		}
 		argp->count = NFSSVC_MAXBLKSIZE;
 	}
 	svc_reserve(rqstp, (19<<2) + argp->count + 4);
diff -Naurp linux-2.5.66/include/linux/nfsd/cache.h linux-2.5.66-NFS_IPV6/include/linux/nfsd/cache.h
--- linux-2.5.66/include/linux/nfsd/cache.h	2003-03-24 13:59:55.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/nfsd/cache.h	2003-04-07 17:40:41.000000000 -0700
@@ -26,7 +26,7 @@ struct svc_cacherep {
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
-	struct sockaddr_in	c_addr;
+	struct sockaddr_storage	c_addr;
 	u32			c_xid;
 	u32			c_prot;
 	u32			c_proc;
diff -Naurp linux-2.5.66/include/linux/nfsd/syscall.h linux-2.5.66-NFS_IPV6/include/linux/nfsd/syscall.h
--- linux-2.5.66/include/linux/nfsd/syscall.h	2003-03-24 14:01:48.000000000 -0800
+++ linux-2.5.66-NFS_IPV6/include/linux/nfsd/syscall.h	2003-04-10 16:35:40.000000000 -0700
@@ -49,7 +49,11 @@ struct nfsctl_svc {
 struct nfsctl_client {
 	char			cl_ident[NFSCLNT_IDMAX+1];
 	int			cl_naddr;
+#ifdef CONFIG_NFS_IPV6
+	struct nfs_addr		cl_addrlist[NFSCLNT_ADDRMAX];
+#else
 	struct in_addr		cl_addrlist[NFSCLNT_ADDRMAX];
+#endif
 	int			cl_fhkeytype;
 	int			cl_fhkeylen;
 	unsigned char		cl_fhkey[NFSCLNT_KEYMAX];
@@ -68,14 +72,22 @@ struct nfsctl_export {
 
 /* GETFD */
 struct nfsctl_fdparm {
+#ifdef CONFIG_NFS_IPV6
+	struct sockaddr_storage	gd_addr;
+#else
 	struct sockaddr		gd_addr;
+#endif
 	char			gd_path[NFS_MAXPATHLEN+1];
 	int			gd_version;
 };
 
 /* GETFS - GET Filehandle with Size */
 struct nfsctl_fsparm {
+#ifdef CONFIG_NFS_IPV6
+	struct sockaddr_storage	gd_addr;
+#else
 	struct sockaddr		gd_addr;
+#endif
 	char			gd_path[NFS_MAXPATHLEN+1];
 	int			gd_maxlen;
 };

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR



-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 003 of 4] Allow run-time selection of NFS versions to export
Date: Fri, 14 Oct 2005 12:23:08 +1000
Message-ID: <1051014022308.11566@cse.unsw.edu.au>
References: <20051014122041.11376.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EQFE5-0006Ra-C5
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:17 -0700
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EQFE4-0006Js-En
	for nfs@lists.sourceforge.net; Thu, 13 Oct 2005 19:23:17 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Provide a file in the NFSD filesystem that allows setting
and querying of which version of NFS are being exported.
Changes are only allowed while no server is running.

Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfsctl.c             |   70 ++++++++++++++++++++++++++++++++++++
 ./fs/nfsd/nfssvc.c             |   79 ++++++++++++++++++++++++++---------------
 ./include/linux/nfsd/nfsd.h    |    2 -
 ./include/linux/nfsd/syscall.h |   17 ++++++++
 4 files changed, 139 insertions(+), 29 deletions(-)

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2005-10-14 12:02:35.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2005-10-14 12:02:52.000000000 +1000
@@ -23,6 +23,7 @@
 #include <linux/seq_file.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
+#include <linux/string.h>
 
 #include <linux/nfs.h>
 #include <linux/nfsd_idmap.h>
@@ -35,6 +36,8 @@
 
 #include <asm/uaccess.h>
 
+unsigned int nfsd_versbits = ~0;
+
 /*
  *	We have a single directory with 9 nodes in it.
  */
@@ -51,6 +54,7 @@ enum {
 	NFSD_Fh,
 	NFSD_Threads,
 	NFSD_Leasetime,
+	NFSD_Versions,
 	NFSD_RecoveryDir,
 };
 
@@ -67,6 +71,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
+static ssize_t write_versions(struct file *file, char *buf, size_t size);
 static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
@@ -80,6 +85,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Leasetime] = write_leasetime,
+	[NFSD_Versions] = write_versions,
 	[NFSD_RecoveryDir] = write_recoverydir,
 };
 
@@ -343,6 +349,69 @@ static ssize_t write_threads(struct file
 	return strlen(buf);
 }
 
+static ssize_t write_versions(struct file *file, char *buf, size_t size)
+{
+	/*
+	 * Format:
+	 *   [-/+]vers [-/+]vers ...
+	 */
+	char *mesg = buf;
+	char *vers, sign;
+	int len, num;
+	ssize_t tlen = 0;
+	char *sep;
+
+	if (size>0) {
+		if (nfsd_serv)
+			return -EBUSY;
+		if (buf[size-1] != '\n')
+			return -EINVAL;
+		buf[size-1] = 0;
+
+		vers = mesg;
+		len = qword_get(&mesg, vers, size);
+		if (len <= 0) return -EINVAL;
+		do {
+			sign = *vers;
+			if (sign == '+' || sign == '-')
+				num = simple_strtol((vers+1), NULL, 0);
+			else
+				num = simple_strtol(vers, NULL, 0);
+			switch(num) {
+			case 2:
+			case 3:
+			case 4:
+				if (sign != '-')
+					NFSCTL_VERSET(nfsd_versbits, num);
+				else
+					NFSCTL_VERUNSET(nfsd_versbits, num);
+				break;
+			default:
+				return -EINVAL;
+			}
+			vers += len + 1;
+			tlen += len;
+		} while ((len = qword_get(&mesg, vers, size)) > 0);
+		/* If all get turned off, turn them back on, as
+		 * having no versions is BAD
+		 */
+		if ((nfsd_versbits & NFSCTL_VERALL)==0)
+			nfsd_versbits = NFSCTL_VERALL;
+	}
+	/* Now write current state into reply buffer */
+	len = 0;
+	sep = "";
+	for (num=2 ; num <= 4 ; num++)
+		if (NFSCTL_VERISSET(NFSCTL_VERALL, num)) {
+			len += sprintf(buf+len, "%s%c%d", sep,
+				       NFSCTL_VERISSET(nfsd_versbits, num)?'+':'-',
+				       num);
+			sep = " ";
+		}
+	len += sprintf(buf+len, "\n");
+	return len;
+}
+
 extern time_t nfs4_leasetime(void);
 
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
@@ -407,6 +476,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_RecoveryDir] = {"nfsv4recoverydir", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
+		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		/* last one */ {""}
 	};
 	return simple_fill_super(sb, 0x6e667364, nfsd_files);

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2005-10-14 12:02:52.000000000 +1000
@@ -30,6 +30,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
+#include <linux/nfsd/syscall.h>
 #include <linux/lockd/bind.h>
 #include <linux/nfsacl.h>
 
@@ -52,7 +53,7 @@
 extern struct svc_program	nfsd_program;
 static void			nfsd(struct svc_rqst *rqstp);
 struct timeval			nfssvc_boot;
-static struct svc_serv 		*nfsd_serv;
+       struct svc_serv 		*nfsd_serv;
 static atomic_t			nfsd_busy;
 static unsigned long		nfsd_last_call;
 static DEFINE_SPINLOCK(nfsd_call_lock);
@@ -63,6 +64,31 @@ struct nfsd_list {
 };
 static struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
 
+static struct svc_version *	nfsd_version[] = {
+	[2] = &nfsd_version2,
+#if defined(CONFIG_NFSD_V3)
+	[3] = &nfsd_version3,
+#endif
+#if defined(CONFIG_NFSD_V4)
+	[4] = &nfsd_version4,
+#endif
+};
+
+#define NFSD_MINVERS    	2
+#define NFSD_NRVERS		(sizeof(nfsd_version)/sizeof(nfsd_version[0]))
+static struct svc_version *nfsd_versions[NFSD_NRVERS];
+
+struct svc_program		nfsd_program = {
+	.pg_prog		= NFS_PROGRAM,		/* program number */
+	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
+	.pg_vers		= nfsd_versions,	/* version table */
+	.pg_name		= "nfsd",		/* program name */
+	.pg_class		= "nfsd",		/* authentication class */
+	.pg_stats		= &nfsd_svcstats,	/* version table */
+	.pg_authenticate	= &svc_set_client,	/* export authentication */
+
+};
+
 /*
  * Maximum number of nfsd processes
  */
@@ -80,11 +106,12 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	int	none_left;	
+	int	none_left, found_one, i;
 	struct list_head *victim;
 	
 	lock_kernel();
-	dprintk("nfsd: creating service\n");
+	dprintk("nfsd: creating service: vers 0x%x\n",
+		nfsd_versbits);
 	error = -EINVAL;
 	if (nrservs <= 0)
 		nrservs = 0;
@@ -99,6 +126,27 @@ nfsd_svc(unsigned short port, int nrserv
 	if (error<0)
 		goto out;
 	if (!nfsd_serv) {
+		/*
+		 * Use the nfsd_ctlbits to define which
+		 * versions that will be advertised.
+		 * If nfsd_ctlbits doesn't list any version,
+		 * export them all.
+		 */
+		found_one = 0;
+
+		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++) {
+			if (NFSCTL_VERISSET(nfsd_versbits, i)) {
+				nfsd_program.pg_vers[i] = nfsd_version[i];
+				found_one = 1;
+			} else
+				nfsd_program.pg_vers[i] = NULL;
+		}
+
+		if (!found_one) {
+			for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++)
+				nfsd_program.pg_vers[i] = nfsd_version[i];
+		}
+
 		atomic_set(&nfsd_busy, 0);
 		error = -ENOMEM;
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
@@ -389,28 +437,3 @@ static struct svc_stat	nfsd_acl_svcstats
 #else
 #define nfsd_acl_program_p	NULL
 #endif /* defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL) */
-
-extern struct svc_version nfsd_version2, nfsd_version3, nfsd_version4;
-
-static struct svc_version *	nfsd_version[] = {
-	[2] = &nfsd_version2,
-#if defined(CONFIG_NFSD_V3)
-	[3] = &nfsd_version3,
-#endif
-#if defined(CONFIG_NFSD_V4)
-	[4] = &nfsd_version4,
-#endif
-};
-
-#define NFSD_NRVERS		(sizeof(nfsd_version)/sizeof(nfsd_version[0]))
-struct svc_program		nfsd_program = {
-	.pg_next		= nfsd_acl_program_p,
-	.pg_prog		= NFS_PROGRAM,		/* program number */
-	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
-	.pg_vers		= nfsd_version,		/* version table */
-	.pg_name		= "nfsd",		/* program name */
-	.pg_class		= "nfsd",		/* authentication class */
-	.pg_stats		= &nfsd_svcstats,	/* version table */
-	.pg_authenticate	= &svc_set_client,	/* export authentication */
-
-};

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2005-10-14 12:02:52.000000000 +1000
@@ -60,7 +60,7 @@ typedef int (*nfsd_dirop_t)(struct inode
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
-
+extern struct svc_serv		*nfsd_serv;
 /*
  * Function prototypes.
  */

diff ./include/linux/nfsd/syscall.h~current~ ./include/linux/nfsd/syscall.h
--- ./include/linux/nfsd/syscall.h~current~	2005-10-14 12:01:38.000000000 +1000
+++ ./include/linux/nfsd/syscall.h	2005-10-14 12:02:52.000000000 +1000
@@ -39,6 +39,21 @@
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define	NFSCTL_GETFS		8	/* get an fh by path with max FH len */
 
+/*
+ * Macros used to set version
+ */
+#define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |=  (1 << (_v)))
+#define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << (_v)))
+#define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << (_v)))
+
+#if defined(CONFIG_NFSD_V4)
+#define	NFSCTL_VERALL	(0x1c /* 0b011100 */)
+#elif defined(CONFIG_NFSD_V3)
+#define	NFSCTL_VERALL	(0x0c /* 0b001100 */)
+#else
+#define	NFSCTL_VERALL	(0x04 /* 0b000100 */)
+#endif
+
 /* SVC */
 struct nfsctl_svc {
 	unsigned short		svc_port;
@@ -120,6 +135,8 @@ extern int		exp_delclient(struct nfsctl_
 extern int		exp_export(struct nfsctl_export *nxp);
 extern int		exp_unexport(struct nfsctl_export *nxp);
 
+extern unsigned int nfsd_versbits;
+
 #endif /* __KERNEL__ */
 
 #endif /* NFSD_SYSCALL_H */


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

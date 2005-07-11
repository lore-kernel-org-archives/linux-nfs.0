From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] kNFSD: fixed '-p port' arg to rpc.nfsd and enables the defining
 proto versions and transpots
Date: Mon, 11 Jul 2005 14:41:53 -0400
Message-ID: <42D2BD71.30101@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020104000501010107090706"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds3EP-00005r-GB
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 11:42:17 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds3EO-0004CY-IO
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 11:42:17 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

This is a multi-part message in MIME format.
--------------020104000501010107090706
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is an other attempt to make the '-p port' command line
argument to rpc.nfsd work plus define which network transports
should be advertised as well as define the protocol versions
that should be advertised.

The difference between these patches and the prior ones is
I've broken up the setting of the versions and ports/transports
into two different files.

To set the port and transport you write a string in the
format of "family transport address port" to the
/proc/fs/nfsd/ports file. An example would be
echo "ipv4 tcp 192.168.0.1 2049" > /proc/fs/nfsd/ports.
Currently only the transport and port are looked at.

To set the protocol version you write a string in the
format of "[+/-]vers [+/-]vers" to the proc/fs/nfsd/versions
file. An example would be echo "+2 +3 -4" > /proc/fs/nfsd/versions
which would turn off version 4.

These patches also added the command line arguments to rpc.nfsd:

     -N  or  --no-nfs-version vers
         This option can be used to request that rpc.nfsd does not  offer
         certain  versions of NFS. The current version of rpc.nfsd can
         support both NFS version 2,3 and the newer version 4.

     -T  or  --no-tcp
         Disable rpc.nfsd from accepting TCP connections from clients.

     -U  or  --no-udp
         Disable rpc.nfsd from accepting UDP connections from clients.

I've been getting a lot of requests for this type of functionality both
on the Fedora Core and RHEL fronts, so I'm hopeful this these patches
will be consider for inclusion in a upstream kernel and nfs-utils
package.

steved.


--------------020104000501010107090706
Content-Type: text/x-patch;
 name="linux-2.6.12-nfsd-ctlbits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.12-nfsd-ctlbits.patch"

This kernel patch allows the setting of the port and network transport
on which kNFSD will listen on and which protocol version will
be advertised. 

Signed-off: Steve Dickson <steved@redhat.com>
-------------------------------
--- linux-2.6.12/fs/nfsd/nfs4state.c.orig	2005-06-17 15:48:29.000000000 -0400
+++ linux-2.6.12/fs/nfsd/nfs4state.c	2005-07-11 07:57:11.000000000 -0400
@@ -3256,6 +3256,9 @@ __nfs4_state_shutdown(void)
 void
 nfs4_state_shutdown(void)
 {
+	if (!nfs4_init)
+		return;
+
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
--- linux-2.6.12/fs/nfsd/nfsctl.c.orig	2005-06-17 15:48:29.000000000 -0400
+++ linux-2.6.12/fs/nfsd/nfsctl.c	2005-07-11 13:59:46.000000000 -0400
@@ -23,6 +23,7 @@
 #include <linux/seq_file.h>
 #include <linux/pagemap.h>
 #include <linux/init.h>
+#include <linux/string.h>
 
 #include <linux/nfs.h>
 #include <linux/nfsd_idmap.h>
@@ -35,6 +36,10 @@
 
 #include <asm/uaccess.h>
 
+int nfsd_port = 2049;
+unsigned int nfsd_portbits = 0;
+unsigned int nfsd_versbits = 0;
+
 /*
  *	We have a single directory with 9 nodes in it.
  */
@@ -51,6 +56,8 @@ enum {
 	NFSD_Fh,
 	NFSD_Threads,
 	NFSD_Leasetime,
+	NFSD_Ports,
+	NFSD_Versions,
 };
 
 /*
@@ -66,6 +73,8 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
+static ssize_t write_ports(struct file *file, char *buf, size_t size);
+static ssize_t write_versions(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -78,6 +87,8 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Threads] = write_threads,
 	[NFSD_Leasetime] = write_leasetime,
+	[NFSD_Ports] = write_ports,
+	[NFSD_Versions] = write_versions,
 };
 
 static ssize_t nfsctl_transaction_write(struct file *file, const char __user *buf, size_t size, loff_t *pos)
@@ -85,14 +96,12 @@ static ssize_t nfsctl_transaction_write(
 	ino_t ino =  file->f_dentry->d_inode->i_ino;
 	char *data;
 	ssize_t rv;
-
 	if (ino >= sizeof(write_op)/sizeof(write_op[0]) || !write_op[ino])
 		return -EINVAL;
 
 	data = simple_transaction_get(file, buf, size);
 	if (IS_ERR(data))
 		return PTR_ERR(data);
-
 	rv =  write_op[ino](file, data, size);
 	if (rv>0) {
 		simple_transaction_set(file, rv);
@@ -256,7 +265,7 @@ static ssize_t write_filehandle(struct f
 	 * qword quoting is used, so filehandle will be \x....
 	 */
 	char *dname, *path;
-	int maxsize;
+	int maxsize = 0;
 	char *mesg = buf;
 	int len;
 	struct auth_domain *dom;
@@ -325,6 +334,92 @@ static ssize_t write_threads(struct file
 	sprintf(buf, "%d\n", nfsd_nrthreads());
 	return strlen(buf);
 }
+static ssize_t write_ports(struct file *file, char *buf, size_t size)
+{
+	/*
+	 * Format:
+	 *   family proto address port
+	 */
+	char *mesg = buf;
+	char *family, *proto, *addr; 
+	int len, port = 0;
+	ssize_t tlen = 0;
+
+	if (buf[size-1] != '\n')
+		return -EINVAL;
+	buf[size-1] = 0;
+
+	family = mesg;
+	len = qword_get(&mesg, family, size);
+	if (len <= 0) return -EINVAL;
+
+	tlen += len;
+	proto = family+len+1;
+	len = qword_get(&mesg, proto, size);
+	if (len <= 0) return -EINVAL;
+
+	tlen += len;
+	addr = proto+len+1;
+	len = qword_get(&mesg, addr, size);
+	if (len <= 0) return -EINVAL;
+
+	len = get_int(&mesg, &port);
+	if (len)
+		return len;
+
+	tlen += sizeof(port);
+	if (port)
+		nfsd_port = port;
+
+	if (strcmp(proto, "tcp") == 0 || strcmp(proto, "TCP") == 0)
+		NFSCTL_TCPSET(nfsd_portbits);
+	if (strcmp(proto, "udp") == 0 || strcmp(proto, "UDP") == 0)
+		NFSCTL_UDPSET(nfsd_portbits);
+
+	return tlen;
+}
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
+
+	if (buf[size-1] != '\n')
+		return -EINVAL;
+	buf[size-1] = 0;
+
+	vers = mesg;
+	len = qword_get(&mesg, vers, size);
+	if (len <= 0) return -EINVAL;
+	do {
+		sign = *vers;
+		if (sign == '+' || sign == '-')
+			num = simple_strtol((vers+1), NULL, 0);
+		else
+			num = simple_strtol(vers, NULL, 0);
+		switch(num) {
+		case 2:
+		case 3:
+		case 4:
+			if (sign != '-')
+				NFSCTL_VERSET(nfsd_versbits, num);
+			else
+				NFSCTL_VERUNSET(nfsd_versbits, num);
+			break;
+		default:
+			return -EINVAL;
+		}
+		vers += len + 1;
+		tlen += len;
+	} while ((len = qword_get(&mesg, vers, size)) > 0);
+
+	return tlen;
+}
 
 extern time_t nfs4_leasetime(void);
 
@@ -370,6 +465,8 @@ static int nfsd_fill_super(struct super_
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
+		[NFSD_Ports] = {"ports", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Versions] = {"versions", &transaction_ops, S_IWUSR|S_IRUSR},
 		/* last one */ {""}
 	};
 	return simple_fill_super(sb, 0x6e667364, nfsd_files);
--- linux-2.6.12/fs/nfsd/nfssvc.c.orig	2005-06-17 15:48:29.000000000 -0400
+++ linux-2.6.12/fs/nfsd/nfssvc.c	2005-07-11 11:36:04.000000000 -0400
@@ -30,6 +30,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
+#include <linux/nfsd/syscall.h>
 #include <linux/lockd/bind.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
@@ -51,10 +52,7 @@
 extern struct svc_program	nfsd_program;
 static void			nfsd(struct svc_rqst *rqstp);
 struct timeval			nfssvc_boot;
-static struct svc_serv 		*nfsd_serv;
-static atomic_t			nfsd_busy;
-static unsigned long		nfsd_last_call;
-static DEFINE_SPINLOCK(nfsd_call_lock);
+static struct svc_serv 		*nfsd_serv; static atomic_t			nfsd_busy; static unsigned long		nfsd_last_call; static DEFINE_SPINLOCK(nfsd_call_lock);
 
 struct nfsd_list {
 	struct list_head 	list;
@@ -62,6 +60,31 @@ struct nfsd_list {
 };
 static struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
 
+extern struct svc_version nfsd_version2, nfsd_version3, nfsd_version4;
+
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
+struct svc_program		nfsd_program = {
+	.pg_prog		= NFS_PROGRAM,		/* program number */
+	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
+	.pg_vers		= nfsd_version,		/* version table */
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
@@ -79,17 +102,37 @@ int
 nfsd_svc(unsigned short port, int nrservs)
 {
 	int	error;
-	int	none_left;	
+	int	none_left, found_one, i;
 	struct list_head *victim;
 	
 	lock_kernel();
-	dprintk("nfsd: creating service\n");
+	dprintk("nfsd: creating service: port %d vers 0x%x proto 0x%x\n",
+		nfsd_port, nfsd_versbits, nfsd_portbits);
 	error = -EINVAL;
 	if (nrservs <= 0)
 		nrservs = 0;
 	if (nrservs > NFSD_MAXSERVS)
 		nrservs = NFSD_MAXSERVS;
 	
+	/*
+	 * If set, use the nfsd_ctlbits to define which
+	 * versions that will be advertised
+	 */
+	found_one = 0;
+	if (nfsd_versbits) {
+		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++) {
+			if (NFSCTL_VERISSET(nfsd_versbits, i)) {
+				nfsd_program.pg_vers[i] = nfsd_version[i];
+				found_one = 1;
+			} else
+				nfsd_program.pg_vers[i] = NULL;
+		}
+	}
+	if (!found_one) {
+		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++)
+			nfsd_program.pg_vers[i] = nfsd_version[i];
+	}
+
 	/* Readahead param cache - will no-op if it already exists */
 	error =	nfsd_racache_init(2*nrservs);
 	if (error<0)
@@ -97,20 +140,24 @@ nfsd_svc(unsigned short port, int nrserv
 	error = nfs4_state_init();
 	if (error<0)
 		goto out;
+
 	if (!nfsd_serv) {
 		atomic_set(&nfsd_busy, 0);
 		error = -ENOMEM;
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
 		if (nfsd_serv == NULL)
 			goto out;
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
-		if (error < 0)
-			goto failure;
-
+		if (!nfsd_portbits || NFSCTL_UDPISSET(nfsd_portbits)) {
+			error = svc_makesock(nfsd_serv, IPPROTO_UDP, nfsd_port);
+			if (error < 0)
+				goto failure;
+		}
 #ifdef CONFIG_NFSD_TCP
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
-		if (error < 0)
-			goto failure;
+		if (!nfsd_portbits || NFSCTL_TCPISSET(nfsd_portbits)) {
+		    error = svc_makesock(nfsd_serv, IPPROTO_TCP, nfsd_port);
+		    if (error < 0)
+			    goto failure;
+		}
 #endif
 		do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	} else
@@ -362,26 +409,3 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
 	return 1;
 }
 
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
-	.pg_prog		= NFS_PROGRAM,		/* program number */
-	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
-	.pg_vers		= nfsd_version,		/* version table */
-	.pg_name		= "nfsd",		/* program name */
-	.pg_class		= "nfsd",		/* authentication class */
-	.pg_stats		= &nfsd_svcstats,	/* version table */
-	.pg_authenticate	= &svc_set_client,	/* export authentication */
-
-};
--- linux-2.6.12/include/linux/nfsd/syscall.h.orig	2005-06-17 15:48:29.000000000 -0400
+++ linux-2.6.12/include/linux/nfsd/syscall.h	2005-07-11 11:31:21.000000000 -0400
@@ -39,6 +39,22 @@
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define	NFSCTL_GETFS		8	/* get an fh by path with max FH len */
 
+/*
+ * Macros used to set version and protocol
+ */
+#define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |=  (1 << ((_v) - 1)))
+#define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1)))
+#define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1)))
+
+#define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |=  (1 << (17 - 1)))
+#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1)))
+#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & (1 << (17 - 1)))
+
+#define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |=  (1 << (18 - 1)))
+#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1)))
+#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & (1 << (18 - 1)))
+
+
 /* SVC */
 struct nfsctl_svc {
 	unsigned short		svc_port;
@@ -120,6 +136,9 @@ extern int		exp_delclient(struct nfsctl_
 extern int		exp_export(struct nfsctl_export *nxp);
 extern int		exp_unexport(struct nfsctl_export *nxp);
 
+extern int nfsd_port;
+extern unsigned int nfsd_versbits, nfsd_portbits;
+
 #endif /* __KERNEL__ */
 
 #endif /* NFSD_SYSCALL_H */

--------------020104000501010107090706
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-nfsd-ctlbits3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-nfsd-ctlbits3.patch"

This patch added the following aruments to rpc.nfsd:

    -N  or  --no-nfs-version vers
        This option can be used to request that rpc.nfsd does not  offer
        certain  versions of NFS. The current version of rpc.nfsd can
        support both NFS version 2,3 and the newer version 4.

    -T  or  --no-tcp
        Disable rpc.nfsd from accepting TCP connections from clients.

    -U  or  --no-udp
        Disable rpc.nfsd from accepting UDP connections from clients.


Signed-off: Steve Dickson <steved@redhat.com>
-------------------------------
--- nfs-utils-1.0.7/support/include/nfs/nfs.h.orig	2003-07-02 22:09:31.000000000 -0400
+++ nfs-utils-1.0.7/support/include/nfs/nfs.h	2005-07-11 12:14:29.000000000 -0400
@@ -10,6 +10,9 @@
 #define	NFS3_FHSIZE	64
 #define	NFS_FHSIZE	32
 
+#define NFSD_MINVERS 2
+#define NFSD_MAXVERS 4
+
 struct nfs_fh_len {
 	int		fh_size;
 	u_int8_t	fh_handle[NFS3_FHSIZE];
@@ -40,7 +43,15 @@ struct nfs_fh_old {
 #define NFSCTL_LOCKD		0x10000
 #define LOCKDCTL_SVC		NFSCTL_LOCKD
 
+#define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
+#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1))) 
+#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1))) 
+
+#define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
+#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & (1 << (17 - 1))) 
+#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & (1 << (18 - 1))) 
 
+#define NFSCTL_ALLBITS (~0)
 
 /* SVC */
 struct nfsctl_svc {
--- nfs-utils-1.0.7/support/include/nfslib.h.orig	2004-09-14 21:58:40.000000000 -0400
+++ nfs-utils-1.0.7/support/include/nfslib.h	2005-07-11 12:29:25.000000000 -0400
@@ -118,7 +118,7 @@ int			wildmat(char *text, char *pattern)
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs);
+int			nfssvc(int port, int nrservs, unsigned int versbits, unsigned int portbits);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
--- nfs-utils-1.0.7/support/nfs/nfssvc.c.orig	2003-08-04 00:26:06.000000000 -0400
+++ nfs-utils-1.0.7/support/nfs/nfssvc.c	2005-07-11 14:04:39.000000000 -0400
@@ -10,22 +10,85 @@
 
 #include <unistd.h>
 #include <fcntl.h>
+#include <syslog.h>
+#include <errno.h>
 
 #include "nfslib.h"
 
+static void
+nfssvc_portbits(int port, unsigned int ctlbits)
+{
+	int fd, n;
+	char buf[BUFSIZ];
+
+	fd = open("/proc/fs/nfsd/ports", O_WRONLY);
+	if (fd < 0)
+		return;
+
+	if (NFSCTL_UDPISSET(ctlbits)) {
+		snprintf(buf, BUFSIZ,"ipv4 udp * %d\n", port); 
+		n = write(fd, buf, strlen(buf));
+		if (n != strlen(buf)) {
+			syslog(LOG_ERR,"nfssvc:udp write failed: errno %d (%s)",
+			errno, strerror(errno));
+		}
+	}
+	if (NFSCTL_TCPISSET(ctlbits)) {
+		snprintf(buf, BUFSIZ,"ipv4 tcp * %d\n", port); 
+		n = write(fd, buf, strlen(buf));
+		if (n != strlen(buf)) {
+			syslog(LOG_ERR,"nfssvc:tcp write failed: errno %d (%s)",
+			errno, strerror(errno));
+		}
+	}
+	close(fd);
+
+	return;
+}
+static void
+nfssvc_versbits(unsigned int ctlbits)
+{
+	int fd, n, off;
+	char buf[BUFSIZ], *ptr;
+
+	ptr = buf;
+	off = 0;
+	fd = open("/proc/fs/nfsd/versions", O_WRONLY);
+	if (fd < 0)
+		return;
+	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
+		if (NFSCTL_VERISSET(ctlbits, n))
+		    off += snprintf(ptr+off, BUFSIZ - off, "+%d ", n);
+		else
+		    off += snprintf(ptr+off, BUFSIZ - off, "-%d ", n);
+	}
+	if (off) {
+	    off += snprintf(ptr+off, BUFSIZ - off, "\n");
+	    if (write(fd, buf, strlen(buf)) != strlen(buf)) {
+			syslog(LOG_ERR, 
+			"nfssvc: versions write failed: errno %d (%s)",
+			errno, strerror(errno));
+		}
+	}
+	close(fd);
+}
 int
-nfssvc(int port, int nrservs)
+nfssvc(int port, int nrservs, unsigned int versbits, unsigned portbits)
 {
 	struct nfsctl_arg	arg;
 	int fd;
 
+	if (portbits != NFSCTL_ALLBITS)
+		nfssvc_portbits(port, portbits);
+	if (versbits != NFSCTL_ALLBITS)
+		nfssvc_versbits(versbits);
+
 	fd = open("/proc/fs/nfsd/threads", O_WRONLY);
 	if (fd < 0)
 		fd = open("/proc/fs/nfs/threads", O_WRONLY);
 	if (fd >= 0) {
 		/* 2.5+ kernel with nfsd filesystem mounted.
 		 * Just write the number in.
-		 * Cannot handle port number yet, but does anyone care?
 		 */
 		char buf[20];
 		int n;
--- nfs-utils-1.0.7/utils/nfsd/nfsd.c.orig	2005-07-11 11:42:00.000000000 -0400
+++ nfs-utils-1.0.7/utils/nfsd/nfsd.c	2005-07-11 13:11:48.000000000 -0400
@@ -23,10 +23,23 @@
 
 static void	usage(const char *);
 
+static struct option longopts[] =
+{
+	{ "help", 0, 0, 'h' },
+	{ "no-nfs-version", 1, 0, 'N' },
+	{ "no-tcp", 0, 0, 'T' },
+	{ "no-udp", 0, 0, 'U' },
+	{ "port", 1, 0, 'P' },
+	{ "port", 1, 0, 'p' },
+	{ NULL, 0, 0, 0 }
+};
+unsigned int portbits = NFSCTL_ALLBITS;
+unsigned int versbits = NFSCTL_ALLBITS;
+
 int
 main(int argc, char **argv)
 {
-	int	count = 1, c, error, port, fd;
+	int	count = 1, c, error, port, fd, found_one;
 	struct servent *ent;
 	DIR *dir;
 
@@ -36,7 +49,7 @@ main(int argc, char **argv)
 	else
 		port = 2049;
 
-	while ((c = getopt(argc, argv, "hp:P:")) != EOF) {
+	while ((c = getopt_long(argc, argv, "hN:p:P:TU", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
@@ -47,12 +60,50 @@ main(int argc, char **argv)
 				usage(argv [0]);
 			}
 			break;
+		case 'N':
+			switch((c = atoi(optarg))) {
+			case 2:
+			case 3:
+			case 4:
+				NFSCTL_VERUNSET(versbits, c);
+				break;
+			default:
+				fprintf(stderr, "%c: Unsupported version\n", c);
+				exit(1);
+			}
 			break;
-		case 'h':
+		case 'T':
+				NFSCTL_TCPUNSET(portbits);
+				break;
+		case 'U':
+				NFSCTL_UDPUNSET(portbits);
+				break;
 		default:
+			fprintf(stderr, "Invalid argument: '%c'\n", c);
+		case 'h':
 			usage(argv[0]);
 		}
 	}
+	/*
+	 * Do some sanity checking, if the ctlbits are set
+	 */
+	if (!NFSCTL_UDPISSET(portbits) && !NFSCTL_TCPISSET(portbits)) {
+		fprintf(stderr, "invalid protocol specified\n");
+		exit(1);
+	}
+	found_one = 0;
+	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
+		if (NFSCTL_VERISSET(versbits, c))
+			found_one = 1;
+	}
+	if (!found_one) {
+		fprintf(stderr, "no version specified\n");
+		exit(1);
+	}			
+	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(versbits)) {
+		fprintf(stderr, "version 4 requires the TCP protocol\n");
+		exit(1);
+	}
 
 	if (chdir(NFS_STATEDIR)) {
 		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
@@ -69,7 +120,6 @@ main(int argc, char **argv)
 			count = 1;
 		}
 	}
-
 	/* KLUDGE ALERT:
 	   Some kernels let nfsd kernel threads inherit open files
 	   from the program that spawns them (i.e. us).  So close
@@ -98,10 +148,10 @@ main(int argc, char **argv)
 		while (--fd > 2)
 			(void) close(fd);
 	}
+	openlog("nfsd", LOG_PID, LOG_DAEMON);
 
-	if ((error = nfssvc(port, count)) < 0) {
+	if ((error = nfssvc(port, count, versbits, portbits)) < 0) {
 		int e = errno;
-		openlog("nfsd", LOG_PID, LOG_DAEMON);
 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
 		closelog();
 	}
@@ -112,7 +162,8 @@ main(int argc, char **argv)
 static void
 usage(const char *prog)
 {
-	fprintf(stderr, "usage:\n"
-			"%s nrservs\n", prog);
+	fprintf(stderr, "Usage:\n"
+		"%s [-p|-P|--port] [-N|no-nfs-version] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
+		prog);
 	exit(2);
 }
--- nfs-utils-1.0.7/utils/nfsd/nfsd.man.orig	2002-08-26 12:57:59.000000000 -0400
+++ nfs-utils-1.0.7/utils/nfsd/nfsd.man	2005-07-11 11:46:46.000000000 -0400
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.nfsd \- NFS server process
 .SH SYNOPSIS
-.BI "/usr/sbin/rpc.nfsd [-p " port "] " nproc
+.BI "/usr/sbin/rpc.nfsd [" options "]" " "nproc
 .SH DESCRIPTION
 The
 .B rpc.nfsd
@@ -22,11 +22,28 @@ server provides an ancillary service nee
 by NFS clients.
 .SH OPTIONS
 .TP
-.BI \-p " port"
+.B \-p " or " \-\-port  port
 specify a diferent port to listen on for NFS requests. By default,
 .B rpc.nfsd
 will listen on port 2049.
 .TP
+.B \-N " or " \-\-no-nfs-version vers
+This option can be used to request that 
+.B rpc.nfsd
+does not offer certain versions of NFS. The current version of
+.B rpc.nfsd
+can support both NFS version 2,3 and the newer version 4.
+.TP
+.B \-T " or " \-\-no-tcp
+Disable 
+.B rpc.nfsd 
+from accepting TCP connections from clients.
+.TP
+.B \-U " or " \-\-no-udp
+Disable
+.B rpc.nfsd
+from accepting UDP connections from clients.
+.TP
 .I nproc
 specify the number of NFS server threads. By default, just one
 thread is started. However, for optimum performance several threads

--------------020104000501010107090706--


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus more.
Date: Tue, 22 Mar 2005 10:01:30 -0500
Message-ID: <4240334A.9010007@RedHat.com>
References: <423EDD43.8000209@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080706010005090302090306"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDkkv-00069c-Gc
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 06:53:17 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDkkf-0001v9-3h
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 06:53:17 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j2MEr0JJ024049
	for <nfs@lists.sourceforge.net>; Tue, 22 Mar 2005 09:53:00 -0500
Received: from [192.168.62.4] (vpn83-128.boston.redhat.com [172.16.83.128])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j2MEqxO19161
	for <nfs@lists.sourceforge.net>; Tue, 22 Mar 2005 09:52:59 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <423EDD43.8000209@RedHat.com>
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
--------------080706010005090302090306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:
> The following patches fix the '-p port' command line
> argument to rpc.nfsd as well as adds following
> flags that control the NFS versions and transports that
> rpc.nfsd will use.
Just for the sake of completion on this proposal, I've updated
the patches to introduce the -V flag and changed the name of the file
rpc.nfsd uses from threads, to config (i.e. /proc/fs/nfsd/config),
which does more accurately describes what is happening....

steved.

--------------080706010005090302090306
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-nfsd-ctlbits2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-nfsd-ctlbits2.patch"

--- nfs-utils-1.0.7/support/include/nfs/nfs.h.orig	2003-07-02 22:09:31.000000000 -0400
+++ nfs-utils-1.0.7/support/include/nfs/nfs.h	2005-03-22 08:48:55.055423216 -0500
@@ -40,7 +40,14 @@ struct nfs_fh_old {
 #define NFSCTL_LOCKD		0x10000
 #define LOCKDCTL_SVC		NFSCTL_LOCKD
 
-
+#define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1)))
+#define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
+#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1))) 
+#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1))) 
+
+#define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
+#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & (1 << (17 - 1))) 
+#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & (1 << (18 - 1))) 
 
 /* SVC */
 struct nfsctl_svc {
--- nfs-utils-1.0.7/support/include/nfslib.h.orig	2004-09-14 21:58:40.000000000 -0400
+++ nfs-utils-1.0.7/support/include/nfslib.h	2005-03-17 09:02:15.000000000 -0500
@@ -118,7 +118,7 @@ int			wildmat(char *text, char *pattern)
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs);
+int			nfssvc(int port, int nrservs, unsigned int ctlbits);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
--- nfs-utils-1.0.7/support/nfs/nfssvc.c.orig	2005-03-17 09:44:28.000000000 -0500
+++ nfs-utils-1.0.7/support/nfs/nfssvc.c	2005-03-22 09:29:34.956501872 -0500
@@ -14,27 +14,32 @@
 #include "nfslib.h"
 
 int
-nfssvc(int port, int nrservs)
+nfssvc(int port, int nrservs, unsigned ctlbits)
 {
 	struct nfsctl_arg	arg;
 	int fd;
 
-	fd = open("/proc/fs/nfsd/threads", O_WRONLY);
+	fd = open("/proc/fs/nfsd/config", O_WRONLY);
 	if (fd < 0)
 		fd = open("/proc/fs/nfs/threads", O_WRONLY);
 	if (fd >= 0) {
 		/* 2.5+ kernel with nfsd filesystem mounted.
 		 * Just write the number in.
-		 * Cannot handle port number yet, but does anyone care?
 		 */
-		char buf[20];
+		char buf[40];
 		int n;
-		snprintf(buf, 20,"%d\n", nrservs);
+		snprintf(buf, 40,"%d %d %d\n", nrservs, port, ctlbits);
 		n = write(fd, buf, strlen(buf));
 		close(fd);
-		if (n != strlen(buf))
-			return -1;
-		else
+		if (n != strlen(buf)) {
+			/*
+			 * See if this an older kernel that does not
+			 * have the ctlbits support
+			 */
+			snprintf(buf, 40, "%d\n", nrservs);
+			if (n != strlen(buf))
+				return -1;
+		} else
 			return 0;
 	}
 
--- nfs-utils-1.0.7/utils/mountd/mountd.c.orig	2005-03-17 07:30:36.000000000 -0500
+++ nfs-utils-1.0.7/utils/mountd/mountd.c	2005-03-19 11:57:38.000000000 -0500
@@ -255,6 +255,9 @@ mount_mnt_3_svc(struct svc_req *rqstp, d
 			= sizeof(flavors)/sizeof(flavors[0]);
 		ok->auth_flavors.auth_flavors_val = flavors;
 	}
+	if (fh == NULL || res->fhs_status)
+		xlog(D_CALL, "MNT3(%s) failed: status %d\n", res->fhs_status);
+
 	return 1;
 }
 
--- nfs-utils-1.0.7/utils/nfsd/nfsd.c.orig	2005-03-17 07:30:36.000000000 -0500
+++ nfs-utils-1.0.7/utils/nfsd/nfsd.c	2005-03-22 09:22:43.600037560 -0500
@@ -23,12 +23,25 @@
 
 static void	usage(const char *);
 
+static struct option longopts[] =
+{
+	{ "help", 0, 0, 'h' },
+	{ "nfs-version", 1, 0, 'V' },
+	{ "no-nfs-version", 1, 0, 'N' },
+	{ "no-tcp", 0, 0, 'T' },
+	{ "no-udp", 0, 0, 'U' },
+	{ "port", 1, 0, 'P' },
+	{ "port", 1, 0, 'p' },
+	{ NULL, 0, 0, 0 }
+};
+
 int
 main(int argc, char **argv)
 {
-	int	count = 1, c, error, port, fd;
+	int	count = 1, c, error, port, fd, found_one;
 	struct servent *ent;
 	DIR *dir;
+	unsigned int ctlbits = ~0;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -36,7 +49,7 @@ main(int argc, char **argv)
 	else
 		port = 2049;
 
-	while ((c = getopt(argc, argv, "hp:P:")) != EOF) {
+	while ((c = getopt_long(argc, argv, "hN:p:P:TUV:", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
@@ -47,12 +60,70 @@ main(int argc, char **argv)
 				usage(argv [0]);
 			}
 			break;
+		case 'N':
+			switch((c = atoi(optarg))) {
+			case 2:
+			case 3:
+			case 4:
+				NFSCTL_VERUNSET(ctlbits, c);
+				break;
+			default:
+				fprintf(stderr, "%c: Unsupported version\n", c);
+				exit(1);
+			}
+			break;
+		case 'T':
+			NFSCTL_TCPUNSET(ctlbits);
+			break;
+		case 'U':
+			NFSCTL_UDPUNSET(ctlbits);
+			break;
+		case 'V':
+			switch((c = atoi(optarg))) {
+			case 2:
+				NFSCTL_VERUNSET(ctlbits, 3);
+				NFSCTL_VERUNSET(ctlbits, 4);
+				break;
+			case 3:
+				NFSCTL_VERUNSET(ctlbits, 2);
+				NFSCTL_VERUNSET(ctlbits, 4);
+				break;
+			case 4:
+				NFSCTL_VERUNSET(ctlbits, 2);
+				NFSCTL_VERUNSET(ctlbits, 3);
+				break;
+			default:
+				fprintf(stderr, "%c: Unsupported version\n", c);
+				exit(1);
+			}
+			NFSCTL_VERSET(ctlbits, c);
 			break;
-		case 'h':
 		default:
+			fprintf(stderr, "Invalid argument: '%c'\n", c);
+		case 'h':
 			usage(argv[0]);
 		}
 	}
+	/*
+	 * Do some sanity checking, if the ctlbits are set
+	 */
+	if (!NFSCTL_UDPISSET(ctlbits) && !NFSCTL_TCPISSET(ctlbits)) {
+		fprintf(stderr, "invalid protocol specified\n");
+		exit(1);
+	}
+	found_one = 0;
+	for (c = 2; c <= 4; c++) {
+		if (NFSCTL_VERISSET(ctlbits, c))
+			found_one = 1;
+	}
+	if (!found_one) {
+		fprintf(stderr, "no version specified\n");
+		exit(1);
+	}			
+	if (NFSCTL_VERISSET(ctlbits, 4) && !NFSCTL_TCPISSET(ctlbits)) {
+		fprintf(stderr, "version 4 requires the TCP protocol\n");
+		exit(1);
+	}
 
 	if (chdir(NFS_STATEDIR)) {
 		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
@@ -99,7 +170,7 @@ main(int argc, char **argv)
 			(void) close(fd);
 	}
 
-	if ((error = nfssvc(port, count)) < 0) {
+	if ((error = nfssvc(port, count, ctlbits)) < 0) {
 		int e = errno;
 		openlog("nfsd", LOG_PID, LOG_DAEMON);
 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
@@ -112,7 +183,8 @@ main(int argc, char **argv)
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
+++ nfs-utils-1.0.7/utils/nfsd/nfsd.man	2005-03-22 09:37:24.414133464 -0500
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.nfsd \- NFS server process
 .SH SYNOPSIS
-.BI "/usr/sbin/rpc.nfsd [-p " port "] " nproc
+.BI "/usr/sbin/rpc.nfsd [" options "]" " "nproc
 .SH DESCRIPTION
 The
 .B rpc.nfsd
@@ -22,11 +22,35 @@ server provides an ancillary service nee
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
+do not offer certain versions of NFS. The current version of
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
+.B \-V " or " \-\-nfs-version
+This option can be used to request that
+.B rpc.nfsd
+offer certain versions of NFS. The current version of
+.B rpc.nfsd
+can support NFS version 2,3 and the newer version 4.
+.TP
 .I nproc
 specify the number of NFS server threads. By default, just one
 thread is started. However, for optimum performance several threads

--------------080706010005090302090306
Content-Type: text/x-patch;
 name="linux-2.6.11-nfsd-ctlbits2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.11-nfsd-ctlbits2.patch"

--- linux-2.6.11/fs/nfsd/nfs4state.c.orig	2005-03-02 02:38:13.000000000 -0500
+++ linux-2.6.11/fs/nfsd/nfs4state.c	2005-03-18 06:59:15.000000000 -0500
@@ -3250,6 +3250,8 @@ __nfs4_state_shutdown(void)
 void
 nfs4_state_shutdown(void)
 {
+	if (!nfs4_init)
+		return;
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
--- linux-2.6.11/fs/nfsd/nfssvc.c.orig	2005-03-02 02:38:10.000000000 -0500
+++ linux-2.6.11/fs/nfsd/nfssvc.c	2005-03-18 08:39:53.000000000 -0500
@@ -30,6 +30,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/stats.h>
 #include <linux/nfsd/cache.h>
+#include <linux/nfsd/syscall.h>
 #include <linux/lockd/bind.h>
 
 #define NFSDDBG_FACILITY	NFSDDBG_SVC
@@ -62,6 +63,29 @@ struct nfsd_list {
 };
 struct list_head nfsd_list = LIST_HEAD_INIT(nfsd_list);
 
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
+#define NFSD_MINVERS    2
+#define NFSD_NRVERS		(sizeof(nfsd_version)/sizeof(nfsd_version[0]))
+struct svc_program		nfsd_program = {
+	.pg_prog		= NFS_PROGRAM,		/* program number */
+	.pg_nvers		= NFSD_NRVERS,		/* nr of entries in nfsd_version */
+	.pg_vers		= nfsd_version,	/* version table */
+	.pg_name		= "nfsd",		/* program name */
+	.pg_class		= "nfsd",		/* authentication class */
+	.pg_stats		= &nfsd_svcstats,	/* version table */
+};
+
 /*
  * Maximum number of nfsd processes
  */
@@ -76,23 +100,47 @@ int nfsd_nrthreads(void)
 }
 
 int
-nfsd_svc(unsigned short port, int nrservs)
+nfsd_svc(unsigned short port, int nrservs, unsigned int ctlbits)
 {
 	int	error;
-	int	none_left;	
+	int	none_left, found_one, i;
 	struct list_head *victim;
 	
+	dprintk("nfsd: creating service (port %d nserver %d ctlbits 0x%x)\n",
+		port, nrservs, ctlbits);
+
 	lock_kernel();
-	dprintk("nfsd: creating service\n");
 	error = -EINVAL;
 	if (nrservs <= 0)
 		nrservs = 0;
 	if (nrservs > NFSD_MAXSERVS)
 		nrservs = NFSD_MAXSERVS;
-	
+	/*
+	 * If set, use the ctlbits to define the
+	 * services that will be advertised
+	 */
+	if (ctlbits) {
+		found_one = 0;
+		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++) {
+			if (NFSCTL_VERISSET(ctlbits, i)) {
+				nfsd_program.pg_vers[i] = nfsd_version[i]; 
+				found_one = 1;
+			} else
+				nfsd_program.pg_vers[i] = NULL;
+		}
+		if (!found_one) {
+			printk(KERN_ERR "nfsd: no version set (cltbits 0x%x)\n", ctlbits);
+			goto out;
+		}			
+	} else { /* otherwise, turn everthing on */
+		ctlbits = ~0;
+		nfsd_program.pg_vers = nfsd_version;
+	}
+
 	/* Readahead param cache - will no-op if it already exists */
 	error =	nfsd_racache_init(2*nrservs);
-	nfs4_state_init();
+	if (NFSCTL_VERISSET(ctlbits, 4))
+		nfs4_state_init();
 	if (error<0)
 		goto out;
 	if (!nfsd_serv) {
@@ -101,14 +149,17 @@ nfsd_svc(unsigned short port, int nrserv
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE);
 		if (nfsd_serv == NULL)
 			goto out;
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
-		if (error < 0)
-			goto failure;
-
+		if (NFSCTL_UDPISSET(ctlbits)) {
+			error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
+			if (error < 0)
+				goto failure;
+		}
 #ifdef CONFIG_NFSD_TCP
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
-		if (error < 0)
-			goto failure;
+		if (NFSCTL_TCPISSET(ctlbits)) {
+			error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
+			if (error < 0)
+				goto failure;
+		}
 #endif
 		do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	} else
@@ -358,24 +409,3 @@ nfsd_dispatch(struct svc_rqst *rqstp, u3
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
-};
--- linux-2.6.11/fs/nfsd/nfsctl.c.orig	2005-03-18 07:21:19.000000000 -0500
+++ linux-2.6.11/fs/nfsd/nfsctl.c	2005-03-22 07:41:34.000000000 -0500
@@ -49,7 +49,7 @@ enum {
 	NFSD_Getfs,
 	NFSD_List,
 	NFSD_Fh,
-	NFSD_Threads,
+	NFSD_Config,
 	NFSD_Leasetime,
 };
 
@@ -64,7 +64,7 @@ static ssize_t write_unexport(struct fil
 static ssize_t write_getfd(struct file *file, char *buf, size_t size);
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
-static ssize_t write_threads(struct file *file, char *buf, size_t size);
+static ssize_t write_config(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
@@ -76,7 +76,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfd] = write_getfd,
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
-	[NFSD_Threads] = write_threads,
+	[NFSD_Config] = write_config,
 	[NFSD_Leasetime] = write_leasetime,
 };
 
@@ -133,7 +133,7 @@ static ssize_t write_svc(struct file *fi
 	if (size < sizeof(*data))
 		return -EINVAL;
 	data = (struct nfsctl_svc*) buf;
-	return nfsd_svc(data->svc_port, data->svc_nthreads);
+	return nfsd_svc(data->svc_port, data->svc_nthreads, 0);
 }
 
 static ssize_t write_add(struct file *file, char *buf, size_t size)
@@ -304,13 +304,16 @@ static ssize_t write_filehandle(struct f
 
 extern int nfsd_nrthreads(void);
 
-static ssize_t write_threads(struct file *file, char *buf, size_t size)
+static ssize_t write_config(struct file *file, char *buf, size_t size)
 {
 	/* if size > 0, look for a number of threads and call nfsd_svc
 	 * then write out number of threads as reply
 	 */
 	char *mesg = buf;
 	int rv;
+	unsigned int ctlbits = 0;
+	unsigned int port = 0;
+
 	if (size > 0) {
 		int newthreads;
 		rv = get_int(&mesg, &newthreads);
@@ -318,11 +321,30 @@ static ssize_t write_threads(struct file
 			return rv;
 		if (newthreads <0)
 			return -EINVAL;
-		rv = nfsd_svc(2049, newthreads);
+		rv = get_int(&mesg, &port);
+		if (rv) {
+			/*
+			 * its possible the rpc.nfsd does not 
+			 * have the ctlbits support, so just 
+			 * fill in with default values 
+			 */
+			port = 2049;
+			ctlbits = ~0;
+			sprintf(buf, "%d\n", newthreads);
+		} else {
+			rv = get_int(&mesg, &ctlbits);
+			if (rv) {
+				ctlbits = ~0;
+				sprintf(buf, "%d %d\n", nfsd_nrthreads(), port);
+			} else
+				sprintf(buf, "%d %d %d\n", nfsd_nrthreads(), port, ctlbits);
+		}
+		rv = nfsd_svc((unsigned short)port, newthreads, ctlbits);
 		if (rv)
 			return rv;
-	}
-	sprintf(buf, "%d\n", nfsd_nrthreads());
+	} else 
+		sprintf(buf, "%d\n", nfsd_nrthreads());
+
 	return strlen(buf);
 }
 
@@ -366,7 +388,7 @@ static int nfsd_fill_super(struct super_
 		[NFSD_Getfs] = {".getfs", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
-		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
+		[NFSD_Config] = {"config", &transaction_ops, S_IWUSR|S_IRUSR},
 #ifdef CONFIG_NFSD_V4
 		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
 #endif
--- linux-2.6.11/include/linux/nfsd/syscall.h.orig	2005-03-02 02:38:38.000000000 -0500
+++ linux-2.6.11/include/linux/nfsd/syscall.h	2005-03-18 07:30:26.000000000 -0500
@@ -39,6 +39,14 @@
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define	NFSCTL_GETFS		8	/* get an fh by path with max FH len */
 
+#define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1)))
+#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1)))
+#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1)))
+
+#define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1)))
+#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & (1 << (17 - 1)))
+#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & (1 << (18 - 1)))
+
 /* SVC */
 struct nfsctl_svc {
 	unsigned short		svc_port;
--- linux-2.6.11/include/linux/nfsd/nfsd.h.orig	2005-03-02 02:38:32.000000000 -0500
+++ linux-2.6.11/include/linux/nfsd/nfsd.h	2005-03-18 05:08:55.000000000 -0500
@@ -63,7 +63,7 @@ extern struct svc_version	nfsd_version2,
 /*
  * Function prototypes.
  */
-int		nfsd_svc(unsigned short port, int nrservs);
+int		nfsd_svc(unsigned short port, int nrservs, unsigned int ctlbits);
 int		nfsd_dispatch(struct svc_rqst *rqstp, u32 *statp);
 
 /* nfsd/vfs.c */

--------------080706010005090302090306--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

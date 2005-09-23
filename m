From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils 8 of 10 - added the command line arguments to rpc.nfsd
Date: Fri, 23 Sep 2005 10:49:14 -0400
Message-ID: <433415EA.3020108@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020107050708030406080606"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EIorW-00064p-7F
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:49:18 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EIorV-0007ZP-OS
	for nfs@lists.sourceforge.net; Fri, 23 Sep 2005 07:49:18 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j8NEnGkJ015624
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:49:16 -0400
Received: from [172.16.50.33] (vpn50-33.rdu.redhat.com [172.16.50.33])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j8NEnFV14341
	for <nfs@lists.sourceforge.net>; Fri, 23 Sep 2005 10:49:15 -0400
To: nfs@lists.sourceforge.net
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
--------------020107050708030406080606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


--------------020107050708030406080606
Content-Type: text/x-patch;
 name="nfs-utils-1.0.7-nfsd-ctlbits.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.7-nfsd-ctlbits.patch"

These patches also added the command line arguments to rpc.nfsd:

    -N  or  --no-nfs-version vers
        This option can be used to request that rpc.nfsd does not  offer
        certain  versions of NFS. The current version of rpc.nfsd can
        support both NFS version 2,3 and the newer version 4.

    -T  or  --no-tcp
        Disable rpc.nfsd from accepting TCP connections from clients.

    -U  or  --no-udp
        Disable rpc.nfsd from accepting UDP connections from clients.


Signed-off-by: Steve Dickson <steved@redhat.com>
---------
--- nfs-utils-1.0.6/support/include/nfs/nfs.h.ctlbits	2003-07-02 22:07:25.000000000 -0400
+++ nfs-utils-1.0.6/support/include/nfs/nfs.h	2005-07-25 10:48:42.000000000 -0400
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
--- nfs-utils-1.0.6/support/include/nfslib.h.ctlbits	2005-07-25 10:48:41.000000000 -0400
+++ nfs-utils-1.0.6/support/include/nfslib.h	2005-07-25 10:48:42.000000000 -0400
@@ -118,7 +118,7 @@ int			wildmat(char *text, char *pattern)
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs);
+int			nfssvc(int port, int nrservs, unsigned int versbits, unsigned int portbits);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
--- nfs-utils-1.0.6/support/nfs/nfssvc.c.ctlbits	2003-08-04 00:12:48.000000000 -0400
+++ nfs-utils-1.0.6/support/nfs/nfssvc.c	2005-07-25 12:18:30.000000000 -0400
@@ -10,15 +10,72 @@
 
 #include <unistd.h>
 #include <fcntl.h>
+#include <errno.h>
+#include <syslog.h>
 
 #include "nfslib.h"
 
+static void
+nfssvc_portbits(int port, unsigned int ctlbits)
+{
+	int fd, n;
+	char buf[BUFSIZ], *udp, *tcp;
+
+	fd = open("/proc/fs/nfsd/ports", O_WRONLY);
+	if (fd < 0)
+		return;
+
+	udp = NFSCTL_UDPISSET(ctlbits) ? "udp" : "noudp" ;
+	tcp = NFSCTL_TCPISSET(ctlbits) ? "tcp" : "notcp" ;
+
+	snprintf(buf, BUFSIZ,"ipv4 %s %s * %d\n", udp, tcp, port); 
+	if (write(fd, buf, strlen(buf)) != strlen(buf)) {
+	    syslog(LOG_ERR, 
+		"nfssvc: Setting UDP protocol failed: errno %d (%s)", 
+		errno, strerror(errno));
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
+
+	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
+		if (NFSCTL_VERISSET(ctlbits, n))
+		    off += snprintf(ptr+off, BUFSIZ - off, "+%d ", n);
+		else
+		    off += snprintf(ptr+off, BUFSIZ - off, "-%d ", n);
+	}
+	snprintf(ptr+off, BUFSIZ - off, "\n");
+syslog(LOG_ERR, "nfssvc_versbits: %s\n", buf);
+	if (write(fd, buf, strlen(buf)) != strlen(buf)) {
+		syslog(LOG_ERR, "nfssvc: Setting version failed: errno %d (%s)", 
+			errno, strerror(errno));
+	}
+	close(fd);
+
+	return;
+}
 int
-nfssvc(int port, int nrservs)
+nfssvc(int port, int nrservs, unsigned int versbits, unsigned portbits)
 {
 	struct nfsctl_arg	arg;
 	int fd;
 
+	nfssvc_portbits(port, portbits);
+
+	nfssvc_versbits(versbits);
+
 	fd = open("/proc/fs/nfsd/threads", O_WRONLY);
 	if (fd < 0)
 		fd = open("/proc/fs/nfs/threads", O_WRONLY);
--- nfs-utils-1.0.6/utils/nfsd/nfsd.c.ctlbits	2005-07-25 10:48:42.000000000 -0400
+++ nfs-utils-1.0.6/utils/nfsd/nfsd.c	2005-07-25 11:10:59.000000000 -0400
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
--- nfs-utils-1.0.6/utils/nfsd/nfsd.man.ctlbits	2002-08-26 12:57:59.000000000 -0400
+++ nfs-utils-1.0.6/utils/nfsd/nfsd.man	2005-07-25 10:48:42.000000000 -0400
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

--------------020107050708030406080606--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

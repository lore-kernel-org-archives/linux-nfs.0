From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 904217 (2/2): allow enabling TCP without recompile
Date: Mon, 15 Dec 2003 19:14:48 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FDD6D78.A8FE3262@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVnt4-00028a-Ek
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 00:15:30 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AVnt4-0002mm-2l
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 00:15:30 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

G'day,

These two patches Linux systems to be shipped with CONFIG_NFSD_TCP=y
but TCP support disabled at runtime until the sysadmin edits the
/etc/sysconfig/nfs file and restarts NFS.  The idea is that TCP
support is still disabled by default, but can be enabled with less
pain than currently is the case (we have customers who want to try
it).

The second patch is for nfs-utils and adds a -t option to nfsd which
uses the new nfsctl (added in the first patch) to enable specific
transports, and the infrastructure to allow the sysadmin to specify
it easily.  Default is to enable UDP only for compatibility.

A word about the syntax of the -t option: yes it's verbose specifying
the transport names in full, but the idea is to allow it to grow to
handle NFS over IPv6 in the distant future.


diff -Naur --exclude-from=nfs-utils.exclude nfs-utils-1.0.6.orig/etc/redhat/nfs
nfs-utils-1.0.6.work/etc/redhat/nfs
--- nfs-utils-1.0.6.orig/etc/redhat/nfs	Tue Apr  9 09:48:25 2002
+++ nfs-utils-1.0.6.work/etc/redhat/nfs	Mon Dec 15 18:37:20 2003
@@ -23,6 +23,11 @@
 # might be needed to handle heavy client traffic)
 # NFSDCOUNT=8
 
+# Enable UDP and TCP transports for NFS.  Uncomment if you
+# want to enable TCP (as UDP is enabled by default).  Note
+# that TCP support is still considered EXPERIMENTAL.
+# NFSD_TRANSPORTS="udp,tcp"
+
 # Increase the memory limits on the socket input queues for
 # the nfs processes .. NFS  benchmark SPECsfs demonstrate a
 # need for a larger than default size (64kb) .. setting
diff -Naur --exclude-from=nfs-utils.exclude nfs-utils-1.0.6.orig/etc/redhat/nfs.init
nfs-utils-1.0.6.work/etc/redhat/nfs.init
--- nfs-utils-1.0.6.orig/etc/redhat/nfs.init	Mon Jun 16 11:14:10 2003
+++ nfs-utils-1.0.6.work/etc/redhat/nfs.init	Mon Dec 15 18:37:32 2003
@@ -38,6 +38,10 @@
 # Number of servers to be started by default
 [ -z "$NFSDCOUNT" ] && NFSDCOUNT=8
 
+# NFS transports to be enabled
+TRANSP=
+[ -n "$NFSD_TRANSPORTS" ] && TRANSP="-t $NFSD_TRANSPORTS"
+
 # Remote quota server
 [ -z "$RQUOTAD" ] && RQUOTAD=`type -path rpc.rquotad`
 
@@ -66,7 +70,7 @@
 	    echo
 	fi
 	echo -n "Starting NFS daemon: "
-	daemon rpc.nfsd $NFSDCOUNT
+	daemon rpc.nfsd $TRANSP $NFSDCOUNT
 	echo
 
 	[ -n "$MOUNTD_PORT" ] \
diff -Naur --exclude-from=nfs-utils.exclude
nfs-utils-1.0.6.orig/support/include/nfs/nfs.h
nfs-utils-1.0.6.work/support/include/nfs/nfs.h
--- nfs-utils-1.0.6.orig/support/include/nfs/nfs.h	Thu Jul  3 12:07:25 2003
+++ nfs-utils-1.0.6.work/support/include/nfs/nfs.h	Mon Dec 15 18:37:45 2003
@@ -35,6 +35,7 @@
 #define NFSCTL_GETFH		6	/* get an fh (used by mountd) */
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define NFSCTL_GETFS		8	/* get an fh by path with max size (used by mountd) */
+#define NFSCTL_TRANSPORT	9	/* {en,dis}able transport(s) */
 
 /* Above this is for lockd. */
 #define NFSCTL_LOCKD		0x10000
@@ -113,6 +114,12 @@
 	int			gd_maxlen;
 };
 
+/* TRANSPORT - enable or disable one or all transports */
+struct nfsctl_transport {
+	int			tr_enable;	/* 1=enable 0=disable */
+	char			tr_name[32];	/* name or "" for all transports */
+};
+
 /*
  * This is the argument union.
  */
@@ -126,6 +133,7 @@
 		struct nfsctl_fhparm	u_getfh;
 		struct nfsctl_fdparm	u_getfd;
 		struct nfsctl_fsparm	u_getfs;
+		struct nfsctl_transport u_transport;
 	} u;
 #define ca_svc		u.u_svc
 #define ca_client	u.u_client
@@ -135,6 +143,7 @@
 #define ca_getfd	u.u_getfd
 #define ca_getfs	u.u_getfs
 #define ca_authd	u.u_authd
+#define ca_transport	u.u_transport
 };
 
 union nfsctl_res {
diff -Naur --exclude-from=nfs-utils.exclude
nfs-utils-1.0.6.orig/support/include/nfslib.h
nfs-utils-1.0.6.work/support/include/nfslib.h
--- nfs-utils-1.0.6.orig/support/include/nfslib.h	Mon Aug  4 14:11:18 2003
+++ nfs-utils-1.0.6.work/support/include/nfslib.h	Mon Dec 15 18:37:54 2003
@@ -123,6 +123,7 @@
 struct nfs_fh_len *	getfh_old(struct sockaddr *addr, dev_t dev, ino_t ino);
 struct nfs_fh_len *	getfh(struct sockaddr *addr, const char *);
 struct nfs_fh_len *	getfh_size(struct sockaddr *addr, const char *, int size);
+int			nfstransport(const char *name, int enable);
 
 void qword_print(FILE *f, char *str);
 void qword_printhex(FILE *f, char *str, int slen);
diff -Naur --exclude-from=nfs-utils.exclude nfs-utils-1.0.6.orig/support/nfs/Makefile
nfs-utils-1.0.6.work/support/nfs/Makefile
--- nfs-utils-1.0.6.orig/support/nfs/Makefile	Wed Mar 26 11:29:08 2003
+++ nfs-utils-1.0.6.work/support/nfs/Makefile	Mon Dec 15 18:38:15 2003
@@ -6,7 +6,7 @@
 OBJS	= exports.o rmtab.o xio.o \
 	  rpcmisc.o rpcdispatch.o xlog.o xmalloc.o wildmat.o \
 	  nfssvc.o nfsclient.o nfsexport.o getfh.o nfsctl.o \
-	  lockdsvc.o svc_socket.o cacheio.o
+	  lockdsvc.o svc_socket.o cacheio.o nfstransport.o
 
 include $(TOP)rules.mk
 
diff -Naur --exclude-from=nfs-utils.exclude
nfs-utils-1.0.6.orig/support/nfs/nfstransport.c
nfs-utils-1.0.6.work/support/nfs/nfstransport.c
--- nfs-utils-1.0.6.orig/support/nfs/nfstransport.c	Thu Jan  1 10:00:00 1970
+++ nfs-utils-1.0.6.work/support/nfs/nfstransport.c	Mon Dec 15 18:44:27 2003
@@ -0,0 +1,33 @@
+/*
+ * support/nfs/nfstransport.c
+ *
+ * Enable or disable one or all RPC transports.
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2003 Silicon Graphics Inc. All rights reserved.
+ *
+ * Derived from nfssvc.c which bore the message:
+ * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
+ */
+
+#include "config.h"
+
+#include "nfslib.h"
+
+int
+nfstransport(const char *name, int enable)
+{
+	struct nfsctl_arg	arg;
+
+    	memset(&arg, 0, sizeof(arg));
+	arg.ca_version = NFSCTL_VERSION;
+	arg.ca_transport.tr_enable = enable;
+	if (name != NULL)
+		strncpy(arg.ca_transport.tr_name, name,
+			sizeof(arg.ca_transport.tr_name));
+	return nfsctl(NFSCTL_TRANSPORT, &arg, NULL);
+}
+
diff -Naur --exclude-from=nfs-utils.exclude nfs-utils-1.0.6.orig/utils/nfsd/nfsd.c
nfs-utils-1.0.6.work/utils/nfsd/nfsd.c
--- nfs-utils-1.0.6.orig/utils/nfsd/nfsd.c	Fri Sep 13 07:08:42 2002
+++ nfs-utils-1.0.6.work/utils/nfsd/nfsd.c	Mon Dec 15 18:42:22 2003
@@ -22,11 +22,43 @@
 
 static void	usage(const char *);
 
+/*
+ * Parse the argument to the -t option as a comma-separated
+ * list of transport names.  Multiple -t flags accumulate.
+ * Exactly the transports listed in all the -t options are
+ * enabled in the kernel.  Returns number of transports
+ * successfully enabled or -1 on error.
+ */
+static int
+enable_transports(const char *argv0, const char *opt)
+{
+	char *buf = strdup(opt), *p, *name;
+	static const char sep[] = ",";
+	int n = 0;
+
+	for (p = strtok(buf, sep); p ; p = strtok(NULL, sep)) {
+		name = (!strcmp(p, "all") ? NULL : p);
+		if (nfstransport(name, 1/*enable*/) < 0) {
+			fprintf(stderr, "%s: %s: %s\n",
+				argv0, p, strerror(errno));
+			free(buf);
+			return -1;
+		}
+		n++;
+	}
+	
+	free(buf);
+	return n;
+}
+
+
 int
 main(int argc, char **argv)
 {
 	int	count = 1, c, error, port, fd;
 	struct servent *ent;
+	int	do_transports = 1;
+	int	ntransports = 0;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -34,7 +66,15 @@
 	else
 		port = 2049;
 
-	while ((c = getopt(argc, argv, "hp:P:")) != EOF) {
+	/*
+	 * Try disabling all transports.  If this fails the kernel
+	 * presumably doesn't support the nfstransport() call so complain
+	 * if the user tries to specify -t
+	 */
+	if (nfstransport(NULL, 0) < 0 && errno == EINVAL)
+		do_transports = 0;
+
+	while ((c = getopt(argc, argv, "hp:P:t:")) != EOF) {
 		switch(c) {
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
@@ -45,12 +85,25 @@
 				usage(argv [0]);
 			}
 			break;
+		case 't':
+			if (!do_transports) {
+				fprintf(stderr, "%s: this kernel does not "
+						"support the -t option\n",
+					argv[0]);
+				usage(argv [0]);
+			}
+			if ((error = enable_transports(argv [0], optarg)) <= 0)
+				usage(argv [0]);
+			ntransports += error;
 			break;
 		case 'h':
 		default:
 			usage(argv[0]);
 		}
 	}
+	
+	if (!ntransports && do_transports)
+		nfstransport("udp", 1/*enable*/); /* default is just UDP */
 
 	if (chdir(NFS_STATEDIR)) {
 		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
@@ -98,6 +151,6 @@
 usage(const char *prog)
 {
 	fprintf(stderr, "usage:\n"
-			"%s nrservs\n", prog);
+			"%s [-t transport...] [-p port] nrservs\n", prog);
 	exit(2);
 }
diff -Naur --exclude-from=nfs-utils.exclude nfs-utils-1.0.6.orig/utils/nfsd/nfsd.man
nfs-utils-1.0.6.work/utils/nfsd/nfsd.man
--- nfs-utils-1.0.6.orig/utils/nfsd/nfsd.man	Tue Aug 27 02:57:59 2002
+++ nfs-utils-1.0.6.work/utils/nfsd/nfsd.man	Mon Dec 15 18:43:50 2003
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.nfsd \- NFS server process
 .SH SYNOPSIS
-.BI "/usr/sbin/rpc.nfsd [-p " port "] " nproc
+.BI "/usr/sbin/rpc.nfsd [-p " port "] [-t " transport "] " nproc
 .SH DESCRIPTION
 The
 .B rpc.nfsd
@@ -27,6 +27,16 @@
 .B rpc.nfsd
 will listen on port 2049.
 .TP
+.BI \-t " transport"
+specify a comma-separated list of transports to listen on for NFS
+requests.  Possible transport names are
+.B udp
+and
+.B tcp
+(if the kernel is configured to support NFS over TCP).  By default,
+.B rpc.nfsd
+will listen on UDP only.
+.TP
 .I nproc
 specify the number of NFS server threads. By default, just one
 thread is started. However, for optimum performance several threads


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

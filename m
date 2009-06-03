From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 07/10] nfs-utils: break up the nfssvc interface
Date: Wed,  3 Jun 2009 15:52:40 -0400
Message-ID: <1244058763-10352-8-git-send-email-jlayton@redhat.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51454 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754585AbZFCTwu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 15:52:50 -0400
In-Reply-To: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the only public interface to the routines in nfssvc.c is
nfssvc(). This means that we do an awful lot of work after closing
stderr that could be done while it's still available.

Add prototypes to the header so that more functions in nfssvc.c can be
called individually, and change the nfsd program to call those routines
individually.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfslib.h |    7 +++-
 support/nfs/nfssvc.c     |   30 ++++++++---------
 utils/nfsd/nfsd.c        |   77 ++++++++++++++++++++++++++++++++++------------
 3 files changed, 77 insertions(+), 37 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index ae98650..14b8ba9 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -130,7 +130,12 @@ int			wildmat(char *text, char *pattern);
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4, unsigned int portbits, char *haddr);
+int			nfssvc_inuse(void);
+int			nfssvc_set_sockets(const int family,
+					const unsigned int protobits,
+					const char *host, const char *port);
+void			nfssvc_setvers(unsigned int ctlbits, int minorvers4);
+int			nfssvc_threads(unsigned short port, int nrservs);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 168414c..89fb5be 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -179,7 +179,7 @@ error:
 	return rc;
 }
 
-static int
+int
 nfssvc_set_sockets(const int family, const unsigned int protobits,
 		   const char *host, const char *port)
 {
@@ -197,8 +197,8 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
 	return nfssvc_setfds(&hints, host, port);
 }
 
-static void
-nfssvc_versbits(unsigned int ctlbits, int minorvers4)
+void
+nfssvc_setvers(unsigned int ctlbits, int minorvers4)
 {
 	int fd, n, off;
 	char buf[BUFSIZ], *ptr;
@@ -228,23 +228,13 @@ nfssvc_versbits(unsigned int ctlbits, int minorvers4)
 
 	return;
 }
+
 int
-nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
-	unsigned protobits, char *haddr)
+nfssvc_threads(unsigned short port, const int nrservs)
 {
 	struct nfsctl_arg	arg;
+	struct servent *ent;
 	int fd;
-	char portstr[BUFSIZ];
-
-	/* Note: must set versions before fds so that
-	 * the ports get registered with portmap against correct
-	 * versions
-	 */
-	if (!nfssvc_inuse()) {
-		nfssvc_versbits(versbits, minorvers4);
-		snprintf(portstr, BUFSIZ, "%d", port);
-		nfssvc_set_sockets(AF_INET, protobits, haddr, portstr);
-	}
 
 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
 	if (fd < 0)
@@ -265,6 +255,14 @@ nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
 			return 0;
 	}
 
+	if (!port) {
+		ent = getservbyname("nfs", "udp");
+		if (ent != NULL)
+			port = ntohs(ent->s_port);
+		else
+			port = NFS_PORT;
+	}
+
 	arg.ca_version = NFSCTL_VERSION;
 	arg.ca_svc.svc_nthreads = nrservs;
 	arg.ca_svc.svc_port = port;
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index e9d0bf9..012847b 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -43,21 +43,14 @@ static struct option longopts[] =
 unsigned int protobits = NFSCTL_ALLBITS;
 unsigned int versbits = NFSCTL_ALLBITS;
 int minorvers4 = NFSD_MAXMINORVERS4;		/* nfsv4 minor version */
-char *haddr = NULL;
 
 int
 main(int argc, char **argv)
 {
-	int	count = 1, c, error, port, fd, found_one;
-	struct servent *ent;
-	struct hostent *hp;
-	char *p, *progname;
-
-	ent = getservbyname ("nfs", "udp");
-	if (ent != NULL)
-		port = ntohs (ent->s_port);
-	else
-		port = 2049;
+	int	count = 1, c, error, portnum = 0, fd, found_one;
+	char *p, *progname, *port;
+	char *haddr = NULL;
+	int	socket_up = 0;
 
 	progname = strdup(basename(argv[0]));
 	if (!progname) {
@@ -65,6 +58,12 @@ main(int argc, char **argv)
 		exit(1);
 	}
 
+	port = strdup("nfs");
+	if (!port) {
+		fprintf(stderr, "%s: unable to allocate memory.\n", progname);
+		exit(1);
+	}
+
 	xlog_syslog(1);
 	xlog_stderr(0);
 
@@ -90,12 +89,20 @@ main(int argc, char **argv)
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
-			port = atoi(optarg);
-			if (port <= 0 || port > 65535) {
+			/* only the last -p option has any effect */
+			portnum = atoi(optarg);
+			if (portnum <= 0 || portnum > 65535) {
 				fprintf(stderr, "%s: bad port number: %s\n",
 					progname, optarg);
 				usage(progname);
 			}
+			free(port);
+			port = strdup(optarg);
+			if (!port) {
+				fprintf(stderr, "%s: unable to allocate "
+						"memory.\n", progname);
+				exit(1);
+			}
 			break;
 		case 'N':
 			switch((c = strtol(optarg, &p, 0))) {
@@ -167,10 +174,38 @@ main(int argc, char **argv)
 			count = 1;
 		}
 	}
-	/* KLUDGE ALERT:
-	   Some kernels let nfsd kernel threads inherit open files
-	   from the program that spawns them (i.e. us).  So close
-	   everything before spawning kernel threads.  --Chip */
+
+	/* can only change number of threads if nfsd is already up */
+	if (nfssvc_inuse()) {
+		socket_up = 1;
+		goto set_threads;
+	}
+
+	/*
+	 * must set versions before the fd's so that the right versions get
+	 * registered with rpcbind. Note that on older kernels w/o the right
+	 * interfaces, these are a no-op.
+	 */
+	nfssvc_setvers(versbits, minorvers4);
+
+	error = nfssvc_set_sockets(AF_INET, protobits, haddr, port);
+	if (!error)
+		socket_up = 1;
+
+set_threads:
+	/* don't start any threads if unable to hand off any sockets */
+	if (!socket_up) {
+		xlog(L_ERROR, "unable to set any sockets for nfsd");
+		goto out;
+	}
+	error = 0;
+
+	/*
+	 * KLUDGE ALERT:
+	 * Some kernels let nfsd kernel threads inherit open files
+	 * from the program that spawns them (i.e. us).  So close
+	 * everything before spawning kernel threads.  --Chip
+	 */
 	fd = open("/dev/null", O_RDWR);
 	if (fd == -1)
 		xlog(L_ERROR, "Unable to open /dev/null: %m");
@@ -183,9 +218,11 @@ main(int argc, char **argv)
 	xlog_stderr(0);
 	closeall(3);
 
-	if ((error = nfssvc(port, count, versbits, minorvers4, protobits, haddr)) < 0)
-		xlog(L_ERROR, "nfssvc (%m)");
-
+	if ((error = nfssvc_threads(portnum, count)) < 0)
+		xlog(L_ERROR, "error starting threads: %s", strerror(error));
+out:
+	free(port);
+	free(haddr);
 	free(progname);
 	return (error != 0);
 }
-- 
1.6.2.2


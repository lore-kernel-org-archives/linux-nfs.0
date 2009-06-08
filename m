From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 03/11] nfs-utils: convert rpc.nfsd to use xlog()
Date: Mon,  8 Jun 2009 14:00:36 -0400
Message-ID: <1244484044-21355-4-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48189 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108AbZFHSBE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:01:04 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and add --debug and --syslog options.

With the switch to xlog(), it becomes trivial to add debug messages, so
add an option to turn them on when requested.

Also, rpc.nfsd isn't a proper daemon per-se, so it makes more sense to
log errors to stderr where possible. Usually init scripts take care of
redirecting stderr output to syslog anyway.

For those that don't, add a --syslog option that forces all output to go
to syslog instead. Note that even with this option, errors encountered
during option processing will still go to stderr.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsd/nfsd.c   |   67 ++++++++++++++++++++++++++++++++------------------
 utils/nfsd/nfssvc.c |   47 +++++++++++++++++------------------
 2 files changed, 66 insertions(+), 48 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 183681b..1589a9f 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -18,7 +18,6 @@
 #include <string.h>
 #include <errno.h>
 #include <getopt.h>
-#include <syslog.h>
 #include <netdb.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -26,6 +25,7 @@
 
 #include "nfslib.h"
 #include "nfssvc.h"
+#include "xlog.h"
 
 static void	usage(const char *);
 
@@ -38,6 +38,8 @@ static struct option longopts[] =
 	{ "no-udp", 0, 0, 'U' },
 	{ "port", 1, 0, 'P' },
 	{ "port", 1, 0, 'p' },
+	{ "debug", 0, 0, 'd' },
+	{ "syslog", 0, 0, 's' },
 	{ NULL, 0, 0, 0 }
 };
 unsigned int protobits = NFSCTL_ALLBITS;
@@ -51,7 +53,7 @@ main(int argc, char **argv)
 	int	count = 1, c, error, port, fd, found_one;
 	struct servent *ent;
 	struct hostent *hp;
-	char *p;
+	char *p, *progname;
 
 	ent = getservbyname ("nfs", "udp");
 	if (ent != NULL)
@@ -59,8 +61,20 @@ main(int argc, char **argv)
 	else
 		port = 2049;
 
-	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU", longopts, NULL)) != EOF) {
+	progname = strdup(basename(argv[0]));
+	if (!progname) {
+		fprintf(stderr, "%s: unable to allocate memory.\n", argv[0]);
+		exit(1);
+	}
+
+	xlog_syslog(0);
+	xlog_stderr(1);
+
+	while ((c = getopt_long(argc, argv, "dH:hN:p:P:sTU", longopts, NULL)) != EOF) {
 		switch(c) {
+		case 'd':
+			xlog_config(D_ALL, 1);
+			break;
 		case 'H':
 			if (inet_addr(optarg) != INADDR_NONE) {
 				haddr = strdup(optarg);
@@ -68,8 +82,8 @@ main(int argc, char **argv)
 				haddr = inet_ntoa((*(struct in_addr*)(hp->h_addr_list[0])));
 			} else {
 				fprintf(stderr, "%s: Unknown hostname: %s\n",
-					argv[0], optarg);
-				usage(argv [0]);
+					progname, optarg);
+				usage(progname);
 			}
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
@@ -77,8 +91,8 @@ main(int argc, char **argv)
 			port = atoi(optarg);
 			if (port <= 0 || port > 65535) {
 				fprintf(stderr, "%s: bad port number: %s\n",
-					argv[0], optarg);
-				usage(argv [0]);
+					progname, optarg);
+				usage(progname);
 			}
 			break;
 		case 'N':
@@ -97,6 +111,10 @@ main(int argc, char **argv)
 				exit(1);
 			}
 			break;
+		case 's':
+			xlog_syslog(1);
+			xlog_stderr(0);
+			break;
 		case 'T':
 			NFSCTL_TCPUNSET(protobits);
 			break;
@@ -106,14 +124,17 @@ main(int argc, char **argv)
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
 		case 'h':
-			usage(argv[0]);
+			usage(progname);
 		}
 	}
+
+	xlog_open(progname);
+
 	/*
 	 * Do some sanity checking, if the ctlbits are set
 	 */
 	if (!NFSCTL_UDPISSET(protobits) && !NFSCTL_TCPISSET(protobits)) {
-		fprintf(stderr, "invalid protocol specified\n");
+		xlog(L_ERROR, "invalid protocol specified");
 		exit(1);
 	}
 	found_one = 0;
@@ -122,12 +143,12 @@ main(int argc, char **argv)
 			found_one = 1;
 	}
 	if (!found_one) {
-		fprintf(stderr, "no version specified\n");
+		xlog(L_ERROR, "no version specified");
 		exit(1);
 	}			
 
 	if (NFSCTL_VERISSET(versbits, 4) && !NFSCTL_TCPISSET(protobits)) {
-		fprintf(stderr, "version 4 requires the TCP protocol\n");
+		xlog(L_ERROR, "version 4 requires the TCP protocol");
 		exit(1);
 	}
 	if (haddr == NULL) {
@@ -136,17 +157,15 @@ main(int argc, char **argv)
 	}
 
 	if (chdir(NFS_STATEDIR)) {
-		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
-			argv [0], NFS_STATEDIR, strerror(errno));
+		xlog(L_ERROR, "chdir(%s) failed: %m", NFS_STATEDIR);
 		exit(1);
 	}
 
 	if (optind < argc) {
 		if ((count = atoi(argv[optind])) < 0) {
 			/* insane # of servers */
-			fprintf(stderr,
-				"%s: invalid server count (%d), using 1\n",
-				argv[0], count);
+			xlog(L_ERROR, "invalid server count (%d), using 1",
+				      count);
 			count = 1;
 		}
 	}
@@ -156,21 +175,21 @@ main(int argc, char **argv)
 	   everything before spawning kernel threads.  --Chip */
 	fd = open("/dev/null", O_RDWR);
 	if (fd == -1)
-		perror("/dev/null");
+		xlog(L_ERROR, "Unable to open /dev/null: %m");
 	else {
+		/* switch xlog output to syslog since stderr is being closed */
+		xlog_syslog(1);
+		xlog_stderr(0);
 		(void) dup2(fd, 0);
 		(void) dup2(fd, 1);
 		(void) dup2(fd, 2);
 	}
 	closeall(3);
 
-	openlog("nfsd", LOG_PID, LOG_DAEMON);
-	if ((error = nfssvc(port, count, versbits, minorvers4, protobits, haddr)) < 0) {
-		int e = errno;
-		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
-		closelog();
-	}
+	if ((error = nfssvc(port, count, versbits, minorvers4, protobits, haddr)) < 0)
+		xlog(L_ERROR, "nfssvc: errno %d (%m)", errno);
 
+	free(progname);
 	return (error != 0);
 }
 
@@ -178,7 +197,7 @@ static void
 usage(const char *prog)
 {
 	fprintf(stderr, "Usage:\n"
-		"%s [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
+		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
 		prog);
 	exit(2);
 }
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 6c5289a..0a7546a 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -16,10 +16,9 @@
 #include <unistd.h>
 #include <fcntl.h>
 #include <errno.h>
-#include <syslog.h>
-
 
 #include "nfslib.h"
+#include "xlog.h"
 
 #define NFSD_PORTS_FILE     "/proc/fs/nfsd/portlist"
 #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
@@ -57,13 +56,13 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 	if (NFSCTL_UDPISSET(ctlbits)) {
 		udpfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
 		if (udpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to create UPD socket: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			xlog(L_ERROR, "unable to create UDP socket: "
+				"errno %d (%m)", errno);
 			exit(1);
 		}
 		if (bind(udpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
-			syslog(LOG_ERR, "nfssvc: unable to bind UPD socket: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			xlog(L_ERROR, "unable to bind UDP socket: "
+				"errno %d (%m)", errno);
 			exit(1);
 		}
 	}
@@ -71,32 +70,32 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 	if (NFSCTL_TCPISSET(ctlbits)) {
 		tcpfd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
 		if (tcpfd < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to createt tcp socket: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			xlog(L_ERROR, "unable to create TCP socket: "
+				"errno %d (%m)", errno);
 			exit(1);
 		}
 		if (setsockopt(tcpfd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0) {
-			syslog(LOG_ERR, "nfssvc: unable to set SO_REUSEADDR: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			xlog(L_ERROR, "unable to set SO_REUSEADDR: "
+				"errno %d (%m)", errno);
 			exit(1);
 		}
 		if (bind(tcpfd, (struct  sockaddr  *)&sin, sizeof(sin)) < 0){
-			syslog(LOG_ERR, "nfssvc: unable to bind TCP socket: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			xlog(L_ERROR, "unable to bind TCP socket: "
+				"errno %d (%m)", errno);
 			exit(1);
 		}
 		if (listen(tcpfd, 64) < 0){
-			syslog(LOG_ERR, "nfssvc: unable to create listening socket: "
-				"errno %d (%s)\n", errno, strerror(errno));
+			xlog(L_ERROR, "unable to create listening socket: "
+				"errno %d (%m)", errno);
 			exit(1);
 		}
 	}
 	if (udpfd >= 0) {
 		snprintf(buf, BUFSIZ,"%d\n", udpfd); 
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-			syslog(LOG_ERR, 
-			       "nfssvc: writing fds to kernel failed: errno %d (%s)", 
-			       errno, strerror(errno));
+			xlog(L_ERROR, 
+			       "writing fds to kernel failed: errno %d (%m)", 
+			       errno);
 		}
 		close(fd);
 		fd = -1;
@@ -106,9 +105,9 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 			fd = open(NFSD_PORTS_FILE, O_WRONLY);
 		snprintf(buf, BUFSIZ,"%d\n", tcpfd); 
 		if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-			syslog(LOG_ERR, 
-			       "nfssvc: writing fds to kernel failed: errno %d (%s)", 
-			       errno, strerror(errno));
+			xlog(L_ERROR, 
+			       "writing fds to kernel failed: errno %d (%m)", 
+			       errno);
 		}
 	}
 	close(fd);
@@ -138,11 +137,11 @@ nfssvc_versbits(unsigned int ctlbits, int minorvers4)
 		    off += snprintf(ptr+off, BUFSIZ - off, "%c4.%d",
 				    minorvers4 > 0 ? '+' : '-',
 				    n);
+	xlog(D_GENERAL, "Writing version string to kernel: %s", buf);
 	snprintf(ptr+off, BUFSIZ - off, "\n");
-	if (write(fd, buf, strlen(buf)) != strlen(buf)) {
-		syslog(LOG_ERR, "nfssvc: Setting version failed: errno %d (%s)", 
-			errno, strerror(errno));
-	}
+	if (write(fd, buf, strlen(buf)) != strlen(buf))
+		xlog(L_ERROR, "Setting version failed: errno %d (%m)", errno);
+
 	close(fd);
 
 	return;
-- 
1.6.0.6


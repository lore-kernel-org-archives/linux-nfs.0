Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42754 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbaBTGip (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:38:45 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:36:48 +1100
Subject: [PATCH 1/4] nfsd: add -r and --rdma options to request rdma service.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220063648.6548.10041.stgit@notabene.brown>
In-Reply-To: <20140220063616.6548.42556.stgit@notabene.brown>
References: <20140220063616.6548.42556.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As nfsd establishes UDP and TCP ports, it should establish RDMA too.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/nfsd/nfsd.c   |   22 +++++++++++++++++++---
 utils/nfsd/nfsd.man |    9 +++++++++
 utils/nfsd/nfssvc.c |   34 ++++++++++++++++++++++++++++++++++
 utils/nfsd/nfssvc.h |    1 +
 4 files changed, 63 insertions(+), 3 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index a9d77ab5c586..d67d1c3ee050 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -45,6 +45,7 @@ static struct option longopts[] =
 	{ "port", 1, 0, 'p' },
 	{ "debug", 0, 0, 'd' },
 	{ "syslog", 0, 0, 's' },
+	{ "rdma", 2, 0, 'R' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -96,7 +97,7 @@ int
 main(int argc, char **argv)
 {
 	int	count = NFSD_NPROC, c, error = 0, portnum = 0, fd, found_one;
-	char *p, *progname, *port;
+	char *p, *progname, *port, *rdma_port = NULL;
 	char *haddr = NULL;
 	int	socket_up = 0;
 	int minorvers[NFS4_MAXMINOR + 1] = {0};
@@ -120,7 +121,7 @@ main(int argc, char **argv)
 	xlog_syslog(0);
 	xlog_stderr(1);
 
-	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTU", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUr", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'd':
 			xlog_config(D_ALL, 1);
@@ -155,6 +156,16 @@ main(int argc, char **argv)
 				exit(1);
 			}
 			break;
+		case 'r':
+			rdma_port = "nfsrdma";
+			break;
+		case 'R': /* --rdma */
+			if (optarg)
+				rdma_port = optarg;
+			else
+				rdma_port = "nfsrdma";
+			break;
+
 		case 'N':
 			switch((c = strtol(optarg, &p, 0))) {
 			case 4:
@@ -294,6 +305,11 @@ main(int argc, char **argv)
 		socket_up = 1;
 #endif /* IPV6_SUPPORTED */
 
+	if (rdma_port) {
+		error = nfssvc_set_rdmaport(rdma_port);
+		if (!error)
+			socket_up = 1;
+	}
 set_threads:
 	/* don't start any threads if unable to hand off any sockets */
 	if (!socket_up) {
@@ -334,7 +350,7 @@ static void
 usage(const char *prog)
 {
 	fprintf(stderr, "Usage:\n"
-		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version] [-V|--nfs-version version] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
+		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version] [-V|--nfs-version version] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=] nrservs\n", 
 		prog);
 	exit(2);
 }
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 7de0867e39e8..aedf1409dc53 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -42,6 +42,15 @@ specify a different port to listen on for NFS requests. By default,
 .B rpc.nfsd
 will listen on port 2049.
 .TP
+.B \-r " or " \-\-rdma
+specify that NFS requests on the standard RDMA port ("nfsrdma", port
+20049) should be honored.
+.TP
+.BI \-\-rdma= port
+Listen for RDMA requests on an alternate port - may be a number or a
+name listed in
+.BR /etc/services .
+.TP
 .B \-N " or " \-\-no-nfs-version vers
 This option can be used to request that 
 .B rpc.nfsd
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 1b50abaf9ca8..7eaeef3fb476 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -268,6 +268,40 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
 	return nfssvc_setfds(&hints, host, port);
 }
 
+int
+nfssvc_set_rdmaport(const char *port)
+{
+	struct servent *sv = getservbyname(port, "tcp");
+	int nport;
+	char buf[20];
+	int ret;
+	int fd;
+
+	if (sv)
+		nport = sv->s_port;
+	else {
+		char *ep;
+		nport = strtol(port, &ep, 10);
+		if (!*port || *ep) {
+			xlog(L_ERROR, "unable to interpret port name %s",
+			     port);
+			return 1;
+		}
+	}
+
+	fd = open(NFSD_PORTS_FILE, O_WRONLY);
+	if (fd < 0)
+		return 1;
+	snprintf(buf, sizeof(buf), "rdma %d", nport);
+	ret = 0;
+	if (write(fd, buf, strlen(buf)) != (ssize_t)strlen(buf)) {
+		ret= errno;
+		xlog(L_ERROR, "Unable to request RDMA services: %m");
+	}
+	close(fd);
+	return ret;
+}
+
 void
 nfssvc_setvers(unsigned int ctlbits, int minorvers[])
 {
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 2bbd3d30f92a..bb7fccee7c19 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -24,5 +24,6 @@ void	nfssvc_mount_nfsdfs(char *progname);
 int	nfssvc_inuse(void);
 int	nfssvc_set_sockets(const int family, const unsigned int protobits,
 			   const char *host, const char *port);
+int	nfssvc_set_rdmaport(const char *port);
 void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
 int	nfssvc_threads(unsigned short port, int nrservs);



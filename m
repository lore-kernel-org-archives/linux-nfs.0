Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42755 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbaBTGiy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:38:54 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:36:48 +1100
Subject: [PATCH 2/4] nfsd: alloc nfsv4leasetime and nfsv4gracetime to be set.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220063648.6548.79745.stgit@notabene.brown>
In-Reply-To: <20140220063616.6548.42556.stgit@notabene.brown>
References: <20140220063616.6548.42556.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

New arguments --gracetime (-G) and --leasetime (-L)

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/nfsd/nfsd.c   |   34 ++++++++++++++++++++++++++++++----
 utils/nfsd/nfsd.man |   11 ++++++++++-
 utils/nfsd/nfssvc.c |   17 +++++++++++++++++
 utils/nfsd/nfssvc.h |    1 +
 4 files changed, 58 insertions(+), 5 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index d67d1c3ee050..dbd0d98a8e68 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -46,6 +46,8 @@ static struct option longopts[] =
 	{ "debug", 0, 0, 'd' },
 	{ "syslog", 0, 0, 's' },
 	{ "rdma", 2, 0, 'R' },
+	{ "grace-time", 1, 0, 'G'},
+	{ "lease-time", 1, 0, 'L'},
 	{ NULL, 0, 0, 0 }
 };
 
@@ -105,6 +107,8 @@ main(int argc, char **argv)
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
 	unsigned int proto6 = 0;
+	int grace = -1;
+	int lease = -1;
 
 	progname = strdup(basename(argv[0]));
 	if (!progname) {
@@ -121,7 +125,7 @@ main(int argc, char **argv)
 	xlog_syslog(0);
 	xlog_stderr(1);
 
-	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUr", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'd':
 			xlog_config(D_ALL, 1);
@@ -218,6 +222,20 @@ main(int argc, char **argv)
 		case 'U':
 			NFSCTL_UDPUNSET(protobits);
 			break;
+		case 'G':
+			grace = strtol(optarg, &p, 0);
+			if (*p || grace <= 0) {
+				fprintf(stderr, "%s: Unrecognized grace time.\n", optarg);
+				exit(1);
+			}
+			break;
+		case 'L':
+			lease = strtol(optarg, &p, 0);
+			if (*p || grace <= 0) {
+				fprintf(stderr, "%s: Unrecognized lease time.\n", optarg);
+				exit(1);
+			}
+			break;
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
 		case 'h':
@@ -265,7 +283,7 @@ main(int argc, char **argv)
 	if (!found_one) {
 		xlog(L_ERROR, "no version specified");
 		exit(1);
-	}			
+	}
 
 	if (NFSCTL_VERISSET(versbits, 4) &&
 	    !NFSCTL_TCPISSET(proto4) &&
@@ -294,7 +312,7 @@ main(int argc, char **argv)
 	 * interfaces, these are a no-op.
 	 */
 	nfssvc_setvers(versbits, minorvers);
- 
+
 	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
 		socket_up = 1;
@@ -310,6 +328,11 @@ main(int argc, char **argv)
 		if (!error)
 			socket_up = 1;
 	}
+	if (grace > 0)
+		nfssvc_set_time("grace", grace);
+	if (lease  > 0)
+		nfssvc_set_time("lease", lease);
+
 set_threads:
 	/* don't start any threads if unable to hand off any sockets */
 	if (!socket_up) {
@@ -350,7 +373,10 @@ static void
 usage(const char *prog)
 {
 	fprintf(stderr, "Usage:\n"
-		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version] [-V|--nfs-version version] [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=] nrservs\n", 
+		"%s [-d|--debug] [-H hostname] [-p|-P|--port port]\n"
+		"     [-N|--no-nfs-version version] [-V|--nfs-version version]\n"
+		"     [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=]\n"
+		"     [-G|--gracetime secs] [-L|--leasetime secs] nrservs\n",
 		prog);
 	exit(2);
 }
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index aedf1409dc53..58b53cbff009 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -2,7 +2,7 @@
 .\" nfsd(8)
 .\"
 .\" Copyright (C) 1999 Olaf Kirch <okir@monad.swb.de>
-.TH rpc.nfsd 8 "7 Aug 2006"
+.TH rpc.nfsd 8 "20 Feb 2014"
 .SH NAME
 rpc.nfsd \- NFS server process
 .SH SYNOPSIS
@@ -83,6 +83,15 @@ offer certain versions of NFS. The current version of
 .B rpc.nfsd
 can support NFS versions 2,3,4 and the newer version 4.1.
 .TP
+.B \-L " or " \-\-lease-time seconds
+Set the lease-time used for NFSv4.  This corresponds to how often
+clients need to confirm their state with the server. Valid range is
+from 10 to 3600 seconds.
+.TP
+.B \-G " or " \-\-grace-time seconds
+Set the grace-time used for NFSv4.  New file open requests will not be
+allowed until after this time has passed to allow clients to recover state.
+.TP
 .I nproc
 specify the number of NFS server threads. By default, just one
 thread is started. However, for optimum performance several threads
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 7eaeef3fb476..337ab169c194 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -303,6 +303,23 @@ nfssvc_set_rdmaport(const char *port)
 }
 
 void
+nfssvc_set_time(const char *type, const int seconds)
+{
+	char pathbuf[40];
+	char nbuf[10];
+	int fd;
+
+	snprintf(pathbuf, sizeof(pathbuf), NFSD_FS_DIR "/nfsv4%stime", type);
+	snprintf(nbuf, sizeof(nbuf), "%d", seconds);
+	fd = open(pathbuf, O_WRONLY);
+	if (fd >= 0) {
+		if (write(fd, nbuf, strlen(nbuf)) != (ssize_t)strlen(nbuf))
+			xlog(L_ERROR, "Unable to set nfsv4%stime: %m", type);
+		close(fd);
+	}
+}
+
+void
 nfssvc_setvers(unsigned int ctlbits, int minorvers[])
 {
 	int fd, n, off;
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index bb7fccee7c19..aa946a48a71e 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -24,6 +24,7 @@ void	nfssvc_mount_nfsdfs(char *progname);
 int	nfssvc_inuse(void);
 int	nfssvc_set_sockets(const int family, const unsigned int protobits,
 			   const char *host, const char *port);
+void	nfssvc_set_time(const char *type, const int seconds);
 int	nfssvc_set_rdmaport(const char *port);
 void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
 int	nfssvc_threads(unsigned short port, int nrservs);



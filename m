From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/3] nfs-utils: Adding the --insecure flag to mountd and statd
Date: Fri, 23 Jan 2009 13:13:30 -0500
Message-ID: <497A08CA.6010905@RedHat.com>
References: <497A056E.1030606@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46365 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbZAWSPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2009 13:15:55 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0NIFtbB002248
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:15:55 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0NIFtdG009915
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:15:55 -0500
Received: from xenhat.boston.devel.redhat.com (vpn-10-54.bos.redhat.com [10.16.10.54])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0NIFtXh003781
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:15:55 -0500
In-Reply-To: <497A056E.1030606-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit d83be6a170844d7bef37f0bf48ebfb2ef384b57a
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 23 10:04:14 2009 -0500

    Added a --insecure (-i) command line argument, to both mountd and statd,
    that will disable the host access check provide by the tcp wrapper library.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/mount_dispatch.c
index f00c0c5..c59410a 100644
--- a/utils/mountd/mount_dispatch.c
+++ b/utils/mountd/mount_dispatch.c
@@ -70,10 +70,11 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT *transp)
 {
 	union mountd_arguments 	argument;
 	union mountd_results	result;
-
 #ifdef HAVE_TCP_WRAPPER
+	extern int insecure;
+
 	/* remote host authorization check */
-	if (!check_default("mountd", svc_getcaller(transp),
+	if (!insecure && !check_default("mountd", svc_getcaller(transp),
 			   rqstp->rq_proc, MOUNTPROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 6adb68f..12cca81 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -72,8 +72,14 @@ static struct option longopts[] =
 	{ "num-threads", 1, 0, 't' },
 	{ "reverse-lookup", 0, 0, 'r' },
 	{ "manage-gids", 0, 0, 'g' },
+#ifdef HAVE_TCP_WRAPPER 
+	{ "insecure", 0, 0, 'i' },
+#endif
 	{ NULL, 0, 0, 0 }
 };
+#ifdef HAVE_TCP_WRAPPER 
+int insecure=0;
+#endif
 
 static int nfs_version = -1;
 
@@ -599,7 +605,7 @@ main(int argc, char **argv)
 
 	/* Parse the command line options and arguments. */
 	opterr = 0;
-	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
+	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hiH:N:V:vrs:t:g", longopts, NULL)) != EOF)
 		switch (c) {
 		case 'g':
 			manage_gids = 1;
@@ -627,6 +633,11 @@ main(int argc, char **argv)
 		case 'h':
 			usage(argv [0], 0);
 			break;
+#ifdef HAVE_TCP_WRAPPER 
+		case 'i':
+			insecure=1;
+			break;
+#endif
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
 			port = atoi(optarg);
@@ -778,7 +789,12 @@ usage(const char *prog, int n)
 	fprintf(stderr,
 "Usage: %s [-F|--foreground] [-h|--help] [-v|--version] [-d kind|--debug kind]\n"
 "	[-o num|--descriptors num] [-f exports-file|--exports-file=file]\n"
-"	[-p|--port port] [-V version|--nfs-version version]\n"
+#ifdef HAVE_TCP_WRAPPER 
+"	[-i|--insecure] [-p|--port port]"
+#else
+"	[-p|--port port]"
+#endif
+" [-V version|--nfs-version version]\n"
 "	[-N version|--no-nfs-version version] [-n|--no-tcp]\n"
 "	[-H ha-callout-prog] [-s|--state-directory-path path]\n"
 "	[-g|--manage-gids] [-t num|--num-threads=num]\n", prog);
diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
index 2f42d00..1a78bda 100644
--- a/utils/mountd/mountd.man
+++ b/utils/mountd/mountd.man
@@ -72,6 +72,7 @@ By default, export information is read from
 .B \-h " or " \-\-help
 Display usage message.
 .TP
+.TP
 .B \-o num " or " \-\-descriptors num
 Set the limit of the number of open file descriptors to num. The
 default is to leave the limit unchanged.
@@ -165,6 +166,11 @@ the server. Note that the 'primary' group id is not affected so a
 .I newgroup
 command on the client will still be effective.  This function requires
 a Linux Kernel with version at least 2.6.21.
+.TP
+.B \-i " or " \-\-insecure
+Disables the hosts access protection provided by the
+.B tcp_wrapper
+library
 
 .SH TCP_WRAPPERS SUPPORT
 This
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 321f7a9..72919db 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -71,6 +71,9 @@ static struct option longopts[] =
 	{ "notify-mode", 0, 0, 'N' },
 	{ "ha-callout", 1, 0, 'H' },
 	{ "no-notify", 0, 0, 'L' },
+#ifdef HAVE_TCP_WRAPPER 
+	{ "insecure", 0, 0, 'i' },
+#endif
 	{ NULL, 0, 0, 0 }
 };
 
@@ -84,12 +87,13 @@ extern void simulator (int, char **);
 
 #ifdef HAVE_TCP_WRAPPER 
 #include "tcpwrapper.h"
+int insecure=0;
 
 static void 
 sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 {
 	/* remote host authorization check */
-	if (!check_default("statd", svc_getcaller(transp),
+	if (!insecure && !check_default("statd", svc_getcaller(transp),
 				 rqstp->rq_proc, SM_PROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
@@ -153,6 +157,9 @@ usage(void)
 	fprintf(stderr,"      -h, -?, --help       Print this help screen.\n");
 	fprintf(stderr,"      -F, --foreground     Foreground (no-daemon mode)\n");
 	fprintf(stderr,"      -d, --no-syslog      Verbose logging to stderr.  Foreground mode only.\n");
+#ifdef HAVE_TCP_WRAPPER 
+	fprintf(stderr,"      -i, --insecure       Don't do host access checks\n");
+#endif
 	fprintf(stderr,"      -p, --port           Port to listen on\n");
 	fprintf(stderr,"      -o, --outgoing-port  Port for outgoing connections\n");
 	fprintf(stderr,"      -V, -v, --version    Display version information and exit.\n");
@@ -274,7 +281,7 @@ int main (int argc, char **argv)
 	MY_NAME = NULL;
 
 	/* Process command line switches */
-	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:L", longopts, NULL)) != EOF) {
+	while ((arg = getopt_long(argc, argv, "h?vVFNH:din:p:o:P:L", longopts, NULL)) != EOF) {
 		switch (arg) {
 		case 'V':	/* Version */
 		case 'v':
@@ -292,6 +299,11 @@ int main (int argc, char **argv)
 		case 'd':	/* No daemon only - log to stderr */
 			run_mode |= MODE_LOG_STDERR;
 			break;
+#ifdef HAVE_TCP_WRAPPER 
+		case 'i':
+			insecure = 1;
+			break;
+#endif
 		case 'o':
 			out_port = atoi(optarg);
 			if (out_port < 1 || out_port > 65535) {
diff --git a/utils/statd/statd.man b/utils/statd/statd.man
index e8be9f3..11842ad 100644
--- a/utils/statd/statd.man
+++ b/utils/statd/statd.man
@@ -141,6 +141,11 @@ to print out command-line help and exit.
 Causes
 .B rpc.statd
 to print out version information and exit.
+.TP
+.B \-i, " " \-\-insecure
+Disables the hosts access protection provided by the
+.B tcp_wrapper
+library
 
 
 

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:34373 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756779Ab0ITQdH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 12:33:07 -0400
Received: by gwj17 with SMTP id 17so1357564gwj.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 09:33:07 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/7] mountd: Fix up version and usage messages
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 20 Sep 2010 12:33:04 -0400
Message-ID: <20100920163304.3170.42195.stgit@ellison.1015granger.net>
In-Reply-To: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
References: <20100920162616.3170.24625.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: rpc.mountd is no longer known as kmountd.  Use the program's
basename rather than the full pathname for the usage message.  Display
a version message at start up similar to statd's.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |   38 ++++++++++++++++++++++----------------
 1 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 9c7caf9..1a14a85 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -692,6 +692,7 @@ main(int argc, char **argv)
 {
 	char	*export_file = _PATH_EXPORTS;
 	char    *state_dir = NFS_STATEDIR;
+	char	*progname;
 	unsigned int listeners = 0;
 	int	foreground = 0;
 	int	port = 0;
@@ -701,6 +702,12 @@ main(int argc, char **argv)
 	struct sigaction sa;
 	struct rlimit rlim;
 
+	/* Set the basename */
+	if ((progname = strrchr(argv[0], '/')) != NULL)
+		progname++;
+	else
+		progname = argv[0];
+
 	/* Parse the command line options and arguments. */
 	opterr = 0;
 	while ((c = getopt_long(argc, argv, "o:nFd:f:p:P:hH:N:V:vrs:t:g", longopts, NULL)) != EOF)
@@ -712,8 +719,8 @@ main(int argc, char **argv)
 			descriptors = atoi(optarg);
 			if (descriptors <= 0) {
 				fprintf(stderr, "%s: bad descriptors: %s\n",
-					argv [0], optarg);
-				usage(argv [0], 1);
+					progname, optarg);
+				usage(progname, 1);
 			}
 			break;
 		case 'F':
@@ -729,15 +736,15 @@ main(int argc, char **argv)
 			ha_callout_prog = optarg;
 			break;
 		case 'h':
-			usage(argv [0], 0);
+			usage(progname, 0);
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
 			port = atoi(optarg);
 			if (port <= 0 || port > 65535) {
 				fprintf(stderr, "%s: bad port number: %s\n",
-					argv [0], optarg);
-				usage(argv [0], 1);
+					progname, optarg);
+				usage(progname, 1);
 			}
 			break;
 		case 'N':
@@ -758,7 +765,7 @@ main(int argc, char **argv)
 		case 's':
 			if ((state_dir = xstrdup(optarg)) == NULL) {
 				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
-					argv[0], optarg);
+					progname, optarg);
 				exit(1);
 			}
 			break;
@@ -775,30 +782,28 @@ main(int argc, char **argv)
 			nfs_version |= NFSVERSBIT(vers);
 			break;
 		case 'v':
-			printf("kmountd %s\n", VERSION);
+			printf("%s version " VERSION "\n", progname);
 			exit(0);
 		case 0:
 			break;
 		case '?':
 		default:
-			usage(argv [0], 1);
+			usage(progname, 1);
 		}
 
-	/* No more arguments allowed.
-	 * Require at least one valid version (2, 3, or 4)
-	 */
+	/* No more arguments allowed. */
 	if (optind != argc || !version_any())
-		usage(argv [0], 1);
+		usage(progname, 1);
 
 	if (chdir(state_dir)) {
 		fprintf(stderr, "%s: chdir(%s) failed: %s\n",
-			argv [0], state_dir, strerror(errno));
+			progname, state_dir, strerror(errno));
 		exit(1);
 	}
 
 	if (getrlimit (RLIMIT_NOFILE, &rlim) != 0)
 		fprintf(stderr, "%s: getrlimit (RLIMIT_NOFILE) failed: %s\n",
-				argv [0], strerror(errno));
+				progname, strerror(errno));
 	else {
 		/* glibc sunrpc code dies if getdtablesize > FD_SETSIZE */
 		if ((descriptors == 0 && rlim.rlim_cur > FD_SETSIZE) ||
@@ -808,14 +813,14 @@ main(int argc, char **argv)
 			rlim.rlim_cur = descriptors;
 			if (setrlimit (RLIMIT_NOFILE, &rlim) != 0) {
 				fprintf(stderr, "%s: setrlimit (RLIMIT_NOFILE) failed: %s\n",
-					argv [0], strerror(errno));
+					progname, strerror(errno));
 				exit(1);
 			}
 		}
 	}
 	/* Initialize logging. */
 	if (!foreground) xlog_stderr(0);
-	xlog_open("mountd");
+	xlog_open(progname);
 
 	sa.sa_handler = SIG_IGN;
 	sa.sa_flags = 0;
@@ -886,6 +891,7 @@ main(int argc, char **argv)
 	if (num_threads > 1)
 		fork_workers();
 
+	xlog(L_NOTICE, "Version " VERSION " starting");
 	my_svc_run();
 
 	xlog(L_ERROR, "RPC service loop terminated unexpectedly. Exiting...\n");


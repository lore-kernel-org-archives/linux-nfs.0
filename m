Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45402 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758116AbcLBBKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Dec 2016 20:10:31 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 02 Dec 2016 12:09:44 +1100
Subject: [PATCH 4/4] Remove error messages on xstrdup failure.
Cc: linux-nfs@vger.kernel.org
Message-ID: <148064098431.9179.10389198547881177509.stgit@noble>
In-Reply-To: <148064084082.9179.6570593128436337540.stgit@noble>
References: <148064084082.9179.6570593128436337540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xstrdup() prints a messages and exits, except in statd where is prints
a message and fails.
So there is no point printing an extra message when xstrdup() fails,
and except in statd, no point calling exit() as well.

So remove some pointless code.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mountd/mountd.c     |    6 +-----
 utils/nfsd/nfsd.c         |   34 +++++-----------------------------
 utils/nfsidmap/nfsidmap.c |    6 +-----
 utils/statd/statd.c       |    5 +----
 4 files changed, 8 insertions(+), 43 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index a0ab2935136a..d6cebbbd3920 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -721,11 +721,7 @@ main(int argc, char **argv)
 			reverse_resolve = 1;
 			break;
 		case 's':
-			if ((state_dir = xstrdup(optarg)) == NULL) {
-				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
-					progname, optarg);
-				exit(1);
-			}
+			state_dir = xstrdup(optarg);
 			break;
 		case 't':
 			num_threads = atoi (optarg);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 7b5e67a09bd2..21622887d2f1 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -67,23 +67,9 @@ main(int argc, char **argv)
 	int grace = -1;
 	int lease = -1;
 
-	progname = strdup(basename(argv[0]));
-	if (!progname) {
-		fprintf(stderr, "%s: unable to allocate memory.\n", argv[0]);
-		exit(1);
-	}
-
-	port = strdup("nfs");
-	if (!port) {
-		fprintf(stderr, "%s: unable to allocate memory.\n", progname);
-		exit(1);
-	}
-
-	haddr = malloc(sizeof(char *));
-	if (!haddr) {
-		fprintf(stderr, "%s: unable to allocate memory.\n", progname);
-		exit(1);
-	}
+	progname = xstrdup(basename(argv[0]));
+	port = xstrdup("nfs");
+	haddr = xmalloc(sizeof(char *));
 	haddr[0] = NULL;
 
 	xlog_syslog(0);
@@ -103,12 +89,7 @@ main(int argc, char **argv)
 					exit(1);
 				}
 			}
-			haddr[hcounter] = strdup(optarg);
-			if (!haddr[hcounter]) {
-				fprintf(stderr, "%s: unable to allocate "
-					"memory.\n", progname);
-				exit(1);
-			}
+			haddr[hcounter] = xstrdup(optarg);
 			hcounter++;
 			break;
 		case 'P':	/* XXX for nfs-server compatibility */
@@ -121,12 +102,7 @@ main(int argc, char **argv)
 				usage(progname);
 			}
 			free(port);
-			port = strdup(optarg);
-			if (!port) {
-				fprintf(stderr, "%s: unable to allocate "
-						"memory.\n", progname);
-				exit(1);
-			}
+			port = xstrdup(optarg);
 			break;
 		case 'r':
 			rdma_port = "nfsrdma";
diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 63545fc09143..a027343a078d 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -441,11 +441,7 @@ int main(int argc, char **argv)
 
 	key = strtol(argv[optind++], NULL, 10);
 
-	arg = strdup(argv[optind]);
-	if (arg == NULL) {
-		xlog_err("strdup failed: %m");
-		return EXIT_FAILURE;
-	}
+	arg = xstrdup(argv[optind]);
 	type = strtok(arg, ":");
 	value = strtok(NULL, ":");
 	if (value == NULL) {
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index e5b4c980a86b..15f2b18d104d 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -332,11 +332,8 @@ int main (int argc, char **argv)
 				exit(1);
 			break;
 		case 'H': /* PRC: specify the ha-callout program */
-			if ((ha_callout_prog = xstrdup(optarg)) == NULL) {
-				fprintf(stderr, "%s: xstrdup(%s) failed!\n",
-					argv[0], optarg);
+			if ((ha_callout_prog = xstrdup(optarg)) == NULL)
 				exit(1);
-			}
 			break;
 		case '?':	/* heeeeeelllllllpppp? heh */
 		case 'h':



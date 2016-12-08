Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43930 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751091AbcLHE1w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:27:52 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:24 +1100
Subject: [PATCH 01/10] nfsd: move and improve test on valid port
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117124448.31271.15941445957552185502.stgit@noble>
In-Reply-To: <148117122602.31271.13586847542442809540.stgit@noble>
References: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfssvc_set_sockets() access textual port numbers (by lookup in
/etc/services).  This uses getaddrinfo which reports errors, except
for out-of-range numbers.

So change the test on a valid port to only complain if the port given
is purely numeric, but is out-of-range.

Also move it so that any default value gets tested the same as any
argument value.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/nfsd/nfsd.c |   17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 62b2876948c3..89179be76113 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -59,7 +59,7 @@ static struct option longopts[] =
 int
 main(int argc, char **argv)
 {
-	int	count = NFSD_NPROC, c, i, error = 0, portnum = 0, fd, found_one;
+	int	count = NFSD_NPROC, c, i, error = 0, portnum, fd, found_one;
 	char *p, *progname, *port, *rdma_port = NULL;
 	char **haddr = NULL;
 	int hcounter = 0;
@@ -132,12 +132,6 @@ main(int argc, char **argv)
 		case 'P':	/* XXX for nfs-server compatibility */
 		case 'p':
 			/* only the last -p option has any effect */
-			portnum = atoi(optarg);
-			if (portnum <= 0 || portnum > 65535) {
-				fprintf(stderr, "%s: bad port number: %s\n",
-					progname, optarg);
-				usage(progname);
-			}
 			free(port);
 			port = xstrdup(optarg);
 			break;
@@ -245,6 +239,15 @@ main(int argc, char **argv)
 
 	xlog_open(progname);
 
+	portnum = strtol(port, &p, 0);
+	if (!*p && (portnum <= 0 || portnum > 65535)) {
+		/* getaddrinfo will catch other errors, but not
+		 * out-of-range numbers.
+		 */
+		xlog(L_ERROR, "invalid port number: %s", port);
+		exit(1);
+	}
+
 	/* make sure that at least one version is enabled */
 	found_one = 0;
 	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {



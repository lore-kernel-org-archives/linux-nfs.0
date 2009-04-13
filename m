From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 3/4] utils/nfsd: add -n --nfs-version option
Date: Mon, 13 Apr 2009 11:29:28 +0300
Message-ID: <1239611368-21667-1-git-send-email-bhalevy@panasas.com>
References: <49E2F6E4.2080501@panasas.com>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:4245 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754887AbZDMI3n (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 04:29:43 -0400
In-Reply-To: <49E2F6E4.2080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add the -n --nfs-version option to enable versions, in contrast
to -N --no-nfs-version.  This will be useful for enabling nfsv4
minor versions.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 support/include/nfs/nfs.h |    2 ++
 utils/nfsd/nfsd.c         |   17 +++++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 00b0028..2220305 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -42,6 +42,8 @@ struct nfs_fh_old {
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define NFSCTL_GETFS		8	/* get an fh by path with max size (used by mountd) */
 
+#define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |=  (1 << ((_v) - 1)))
+
 #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
 #define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1))) 
 #define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1))) 
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index ac264da..3d88b72 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -32,6 +32,7 @@ static struct option longopts[] =
 {
 	{ "host", 1, 0, 'H' },
 	{ "help", 0, 0, 'h' },
+	{ "nfs-version", 1, 0, 'n' },
 	{ "no-nfs-version", 1, 0, 'N' },
 	{ "no-tcp", 0, 0, 'T' },
 	{ "no-udp", 0, 0, 'U' },
@@ -57,7 +58,7 @@ main(int argc, char **argv)
 	else
 		port = 2049;
 
-	while ((c = getopt_long(argc, argv, "H:hN:p:P:TU", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "H:hn:N:p:P:TU", longopts, NULL)) != EOF) {
 		switch(c) {
 		case 'H':
 			if (inet_addr(optarg) != INADDR_NONE) {
@@ -79,6 +80,18 @@ main(int argc, char **argv)
 				usage(argv [0]);
 			}
 			break;
+		case 'n':
+			switch((c = atoi(optarg))) {
+			case 4:
+			case 3:
+			case 2:
+				NFSCTL_VERSET(versbits, c);
+				break;
+			default:
+				fprintf(stderr, "%s: Unsupported version\n", optarg);
+				exit(1);
+			}
+			break;
 		case 'N':
 			switch((c = atoi(optarg))) {
 			case 2:
@@ -172,7 +185,7 @@ static void
 usage(const char *prog)
 {
 	fprintf(stderr, "Usage:\n"
-		"%s [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version version ] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
+		"%s [-H hostname] [-p|-P|--port port] [-n|--nfs-version version] [-N|--no-nfs-version version] [-T|--no-tcp] [-U|--no-udp] nrservs\n", 
 		prog);
 	exit(2);
 }
-- 
1.6.2.1


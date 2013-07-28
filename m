Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39437 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751745Ab3G1Sgm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 28 Jul 2013 14:36:42 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r6SIafec024443
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sun, 28 Jul 2013 14:36:42 -0400
Received: from smallhat.bos.devel.redhat.com (vpn-60-122.rdu2.redhat.com [10.10.60.122])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r6SIaeKg022771
	for <linux-nfs@vger.kernel.org>; Sun, 28 Jul 2013 14:36:41 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] rpc.nfsd: Allow v4.2 server support with the -V option
Date: Sun, 28 Jul 2013 14:36:38 -0400
Message-Id: <1375036598-31090-2-git-send-email-steved@redhat.com>
In-Reply-To: <1375036598-31090-1-git-send-email-steved@redhat.com>
References: <1375036598-31090-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/include/nfs/nfs.h |  4 ++++
 utils/nfsd/nfsd.c         | 12 ++++++------
 utils/nfsd/nfssvc.c       | 11 +++++++----
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 5fd86f6..38db5b5 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -15,6 +15,10 @@
 #define NFSD_MINVERS 2
 #define NFSD_MAXVERS 4
 
+#define NFS4_MINMINOR 1
+#define NFS4_MAXMINOR 2
+#define NFS4_VERDEFAULT  0x1  /* minor verion 1 */
+
 struct nfs_fh_len {
 	int		fh_size;
 	u_int8_t	fh_handle[NFS3_FHSIZE];
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index df48392..6db92f0 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -99,7 +99,7 @@ main(int argc, char **argv)
 	char *p, *progname, *port;
 	char *haddr = NULL;
 	int	socket_up = 0;
-	int minorvers41 = 0;	/* nfsv4 minor version */
+	int minorvers = NFS4_VERDEFAULT;	/* nfsv4 minor version */
 	unsigned int versbits = NFSCTL_VERDEFAULT;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
@@ -160,11 +160,11 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i != 1) {
+					if (i > 2) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					minorvers41 = -1;
+					NFSCTL_VERUNSET(minorvers, i);
 					break;
 				}
 			case 3:
@@ -181,11 +181,11 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i != 1) {
+					if (i > 2) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					minorvers41 = 1;
+					NFSCTL_VERSET(minorvers, i);
 					break;
 				}
 			case 3:
@@ -282,7 +282,7 @@ main(int argc, char **argv)
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
 	 */
-	nfssvc_setvers(versbits, minorvers41);
+	nfssvc_setvers(versbits, minorvers);
  
 	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 683008e..8b85846 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -269,7 +269,7 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
 }
 
 void
-nfssvc_setvers(unsigned int ctlbits, int minorvers41)
+nfssvc_setvers(unsigned int ctlbits, int minorvers)
 {
 	int fd, n, off;
 	char *ptr;
@@ -280,9 +280,12 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers41)
 	if (fd < 0)
 		return;
 
-	if (minorvers41)
-		off += snprintf(ptr+off, sizeof(buf) - off, "%c4.1",
-				minorvers41 > 0 ? '+' : '-');
+	for (n = NFS4_MINMINOR; n <= NFS4_MAXMINOR; n++) {
+		if (NFSCTL_VERISSET(minorvers, n)) 
+			off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
+		else			
+			off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
+	}
 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
 		if (NFSCTL_VERISSET(ctlbits, n))
 		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
-- 
1.8.1.4


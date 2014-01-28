Return-Path: linux-nfs-owner@vger.kernel.org
Received: from demumfd002.nsn-inter.net ([93.183.12.31]:12571 "EHLO
	demumfd002.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaA1HMr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jan 2014 02:12:47 -0500
Date: Tue, 28 Jan 2014 08:11:24 +0100
From: Robert Schiele <rschiele@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] support NFS4_MAXMINOR up to the number an unsigned int can
 keep
Message-ID: <20140128071124.GA23439@ulegcprs1.emea.nsn-net.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This implementation allows specifying NFS4 minor version numbers up
to the number of bits available in int data type (typically 32 on
Linux)

This is based on an idea mentioned by
J. Bruce Fields <bfields@fieldses.org> mentioned on the linux-nfs
mailing list.

I changed the data type back from an array to two bit fields, one for
storing whether the minor version was specified on the command line
and the second one for storing whether it was set or unset.  This
change was done to prevent blowing up the allocated stack space in an
unnecessary fashion.

Signed-off-by: Robert Schiele <rschiele@gmail.com>
---

Bruce, I assume that this was approximately what you had in mind.

Robert

 support/include/nfs/nfs.h |  3 ++-
 utils/nfsd/nfsd.c         | 15 +++++++++------
 utils/nfsd/nfssvc.c       | 12 +++++++-----
 utils/nfsd/nfssvc.h       |  2 +-
 4 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index df4ad76..27054e5 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -8,6 +8,7 @@
 #include <netinet/in.h>
 #include <rpcsvc/nfs_prot.h>
 #include <nfs/export.h>
+#include <limits.h>
 
 #define	NFS3_FHSIZE	64
 #define	NFS_FHSIZE	32
@@ -16,7 +17,7 @@
 #define NFSD_MAXVERS 4
 
 #define NFS4_MINMINOR 1
-#define NFS4_MAXMINOR 2
+#define NFS4_MAXMINOR WORD_BIT
 
 struct nfs_fh_len {
 	int		fh_size;
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index a9d77ab..edeb621 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -99,7 +99,8 @@ main(int argc, char **argv)
 	char *p, *progname, *port;
 	char *haddr = NULL;
 	int	socket_up = 0;
-	int minorvers[NFS4_MAXMINOR + 1] = {0};
+	unsigned int minorvers = 0;
+	unsigned int minorversset = 0;
 	unsigned int versbits = NFSCTL_VERDEFAULT;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
@@ -160,11 +161,12 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i > 2) {
+					if (i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					minorvers[i] = -1;
+					NFSCTL_VERSET(minorversset, i);
+					NFSCTL_VERUNSET(minorvers, i);
 					break;
 				}
 			case 3:
@@ -181,11 +183,12 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i > 2) {
+					if (i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					minorvers[i] = 1;
+					NFSCTL_VERSET(minorversset, i);
+					NFSCTL_VERSET(minorvers, i);
 					break;
 				}
 			case 3:
@@ -282,7 +285,7 @@ main(int argc, char **argv)
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
 	 */
-	nfssvc_setvers(versbits, minorvers);
+	nfssvc_setvers(versbits, minorvers, minorversset);
  
 	error = nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 1b50aba..1a52cca 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -269,7 +269,7 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
 }
 
 void
-nfssvc_setvers(unsigned int ctlbits, int minorvers[])
+nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int minorversset)
 {
 	int fd, n, off;
 	char *ptr;
@@ -281,10 +281,12 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers[])
 		return;
 
 	for (n = NFS4_MINMINOR; n <= NFS4_MAXMINOR; n++) {
-		if (minorvers[n] == 1)
-			off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
-		else if (minorvers[n] == -1)
-			off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
+		if (NFSCTL_VERISSET(minorversset, n)) {
+			if (NFSCTL_VERISSET(minorvers, n))
+				off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
+			else
+				off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
+		}
 	}
 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
 		if (NFSCTL_VERISSET(ctlbits, n))
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 2bbd3d3..4418ac8 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -24,5 +24,5 @@ void	nfssvc_mount_nfsdfs(char *progname);
 int	nfssvc_inuse(void);
 int	nfssvc_set_sockets(const int family, const unsigned int protobits,
 			   const char *host, const char *port);
-void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
+void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigned int minorvers4set);
 int	nfssvc_threads(unsigned short port, int nrservs);
-- 
1.8.4

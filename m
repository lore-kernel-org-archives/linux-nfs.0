From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 2/4] utils/nfsd: add support for minorvers4
Date: Mon, 13 Apr 2009 11:29:22 +0300
Message-ID: <1239611362-21636-1-git-send-email-bhalevy@panasas.com>
References: <49E2F6E4.2080501@panasas.com>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:10290 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753784AbZDMI30 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 04:29:26 -0400
In-Reply-To: <49E2F6E4.2080501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

minorvers4 can be used to either enable or disable nfsv4.x.

If minorvers4 is a positive integer n, in the allowed range (only
minorversion 1 is supported for now), the string "+4.n" is appended
to the versions string written onto /proc/fs/nfsd/versions.

Correspondingly, if minorver4 is a negative integer -n, the string
"-4.n" is written.

With the default value, minorvers4==0, the minor version
setting is not changed.

Note that unlike the protocol versions 2, 3, or 4.  The minor version
setting controls the *maximum* minor version nfsd supports.  Particular
minor version cannot be controlled on their own.  With only minor version
1 supported at the moment the difference doesn't matter, but for future
minor versions greater than 1, enabling minor version X will enable support
for all minor versions 1 through X. Disabling minor version X will disable
support for minor versions X and up, enabling 1 through X-1.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 support/include/nfs/nfs.h |    3 +++
 support/include/nfslib.h  |    2 +-
 support/nfs/nfssvc.c      |   13 +++++++++----
 utils/nfsd/nfsd.c         |    3 ++-
 4 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index fc26f4e..00b0028 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -13,6 +13,9 @@
 #define NFSD_MINVERS 2
 #define NFSD_MAXVERS 4
 
+#define NFSD_MINMINORVERS4 1
+#define NFSD_MAXMINORVERS4 1
+
 struct nfs_fh_len {
 	int		fh_size;
 	u_int8_t	fh_handle[NFS3_FHSIZE];
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 9d0d39d..ae98650 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -130,7 +130,7 @@ int			wildmat(char *text, char *pattern);
  * nfsd library functions.
  */
 int			nfsctl(int, struct nfsctl_arg *, union nfsctl_res *);
-int			nfssvc(int port, int nrservs, unsigned int versbits, unsigned int portbits, char *haddr);
+int			nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4, unsigned int portbits, char *haddr);
 int			nfsaddclient(struct nfsctl_client *clp);
 int			nfsdelclient(struct nfsctl_client *clp);
 int			nfsexport(struct nfsctl_export *exp);
diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
index 9bbc9a5..33c15a7 100644
--- a/support/nfs/nfssvc.c
+++ b/support/nfs/nfssvc.c
@@ -116,7 +116,7 @@ nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
 	return;
 }
 static void
-nfssvc_versbits(unsigned int ctlbits)
+nfssvc_versbits(unsigned int ctlbits, int minorvers4)
 {
 	int fd, n, off;
 	char buf[BUFSIZ], *ptr;
@@ -133,6 +133,11 @@ nfssvc_versbits(unsigned int ctlbits)
 		else
 		    off += snprintf(ptr+off, BUFSIZ - off, "-%d ", n);
 	}
+	n = minorvers4 >= 0 ? minorvers4 : -minorvers4;
+	if (n >= NFSD_MINMINORVERS4 && n <= NFSD_MAXMINORVERS4)
+		    off += snprintf(ptr+off, BUFSIZ - off, "%c4.%d",
+				    minorvers4 > 0 ? '+' : '-',
+				    n);
 	snprintf(ptr+off, BUFSIZ - off, "\n");
 	if (write(fd, buf, strlen(buf)) != strlen(buf)) {
 		syslog(LOG_ERR, "nfssvc: Setting version failed: errno %d (%s)", 
@@ -143,8 +148,8 @@ nfssvc_versbits(unsigned int ctlbits)
 	return;
 }
 int
-nfssvc(int port, int nrservs, unsigned int versbits, unsigned protobits,
-	char *haddr)
+nfssvc(int port, int nrservs, unsigned int versbits, int minorvers4,
+	unsigned protobits, char *haddr)
 {
 	struct nfsctl_arg	arg;
 	int fd;
@@ -153,7 +158,7 @@ nfssvc(int port, int nrservs, unsigned int versbits, unsigned protobits,
 	 * the ports get registered with portmap against correct
 	 * versions
 	 */
-	nfssvc_versbits(versbits);
+	nfssvc_versbits(versbits, minorvers4);
 	nfssvc_setfds(port, protobits, haddr);
 
 	fd = open(NFSD_THREAD_FILE, O_WRONLY);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index c97c81f..ac264da 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -41,6 +41,7 @@ static struct option longopts[] =
 };
 unsigned int protobits = NFSCTL_ALLBITS;
 unsigned int versbits = NFSCTL_ALLBITS;
+int minorvers4;				/* nfsv4 minor version */
 char *haddr = NULL;
 
 int
@@ -158,7 +159,7 @@ main(int argc, char **argv)
 	closeall(3);
 
 	openlog("nfsd", LOG_PID, LOG_DAEMON);
-	if ((error = nfssvc(port, count, versbits, protobits, haddr)) < 0) {
+	if ((error = nfssvc(port, count, versbits, minorvers4, protobits, haddr)) < 0) {
 		int e = errno;
 		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
 		closelog();
-- 
1.6.2.1


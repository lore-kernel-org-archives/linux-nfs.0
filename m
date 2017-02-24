Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33922 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751584AbdBXAeM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Feb 2017 19:34:12 -0500
Received: by mail-it0-f65.google.com with SMTP id r141so818303ita.1
        for <linux-nfs@vger.kernel.org>; Thu, 23 Feb 2017 16:33:55 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, neilb@suse.com
Subject: [PATCH 1/2] nfsd: Allow the caller to turn off NFSv4.0 without turning off NFSv4.x
Date: Thu, 23 Feb 2017 19:33:43 -0500
Message-Id: <20170224003344.113724-2-trond.myklebust@primarydata.com>
In-Reply-To: <20170224003344.113724-1-trond.myklebust@primarydata.com>
References: <20170224003344.113724-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new semantic is that '-N4' turns off all NFSv4 minor versions, while
'-V4' turns them all on. In order to turn off just minor version x (x >= 0),
use -N4.x, and to turn it back on. '-V4.x'.

Note that on older kernels, attempting to use -N4.0 and -V4.0 is
equivalent to specifying -N4 or -V4.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 support/include/nfs/nfs.h |  7 +++--
 utils/nfsd/nfsd.c         | 39 +++++++++++++++---------
 utils/nfsd/nfsd.man       |  4 +--
 utils/nfsd/nfssvc.c       | 76 ++++++++++++++++++++++++++++++++++++-----------
 utils/nfsd/nfssvc.h       |  1 +
 5 files changed, 92 insertions(+), 35 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 15ecc6bfc485..5860343f78b7 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -16,8 +16,8 @@
 #define NFSD_MINVERS 2
 #define NFSD_MAXVERS 4
 
-#define NFS4_MINMINOR 1
-#define NFS4_MAXMINOR WORD_BIT
+#define NFS4_MINMINOR 0
+#define NFS4_MAXMINOR (WORD_BIT-1)
 
 struct nfs_fh_len {
 	int		fh_size;
@@ -29,15 +29,18 @@ struct nfs_fh_len {
 #define NFSCTL_TCPBIT		      (1 << (18 - 1))
 
 #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
+#define NFSCTL_MINORUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << (_v)))
 #define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_UDPBIT) 
 #define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_TCPBIT) 
 
 #define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
+#define NFSCTL_MINORISSET(_cltbits, _v) ((_cltbits) & (1 << (_v)))
 #define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
 #define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
 
 #define NFSCTL_VERDEFAULT (0xc)       /* versions 3 and 4 */
 #define NFSCTL_VERSET(_cltbits, _v)   ((_cltbits) |= (1 << ((_v) - 1))) 
+#define NFSCTL_MINORSET(_cltbits, _v)   ((_cltbits) |= (1 << (_v)))
 #define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
 #define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
 
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 20f4b7952203..1708521ab286 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -67,6 +67,7 @@ main(int argc, char **argv)
 	int	socket_up = 0;
 	unsigned int minorvers = 0;
 	unsigned int minorversset = 0;
+	unsigned int minormask = 0;
 	unsigned int versbits = NFSCTL_VERDEFAULT;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	int grace = -1;
@@ -104,10 +105,16 @@ main(int argc, char **argv)
 		else
 			NFSCTL_VERUNSET(versbits, i);
 	}
+
+	nfssvc_get_minormask(&minormask);
 	/* We assume the kernel will default all minor versions to 'on',
 	 * and allow the config file to disable some.
 	 */
-	for (i = NFS4_MINMINOR; i <= NFS4_MAXMINOR; i++) {
+	if (NFSCTL_VERISSET(versbits, 4)) {
+		NFSCTL_MINORSET(minorversset, 0);
+		NFSCTL_MINORSET(minorvers, 0);
+	}
+	for (i = 1; i <= NFS4_MAXMINOR; i++) {
 		char tag[20];
 		sprintf(tag, "vers4.%d", i);
 		/* The default for minor version support is to let the
@@ -119,12 +126,12 @@ main(int argc, char **argv)
 		 * (i.e. don't set the bit in minorversset).
 		 */
 		if (!conf_get_bool("nfsd", tag, 1)) {
-			NFSCTL_VERSET(minorversset, i);
-			NFSCTL_VERUNSET(minorvers, i);
+			NFSCTL_MINORSET(minorversset, i);
+			NFSCTL_MINORUNSET(minorvers, i);
 		}
 		if (conf_get_bool("nfsd", tag, 0)) {
-			NFSCTL_VERSET(minorversset, i);
-			NFSCTL_VERSET(minorvers, i);
+			NFSCTL_MINORSET(minorversset, i);
+			NFSCTL_MINORSET(minorvers, i);
 		}
 	}
 
@@ -179,13 +186,17 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i < NFS4_MINMINOR || i > NFS4_MAXMINOR) {
+					if (i < 0 || i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					NFSCTL_VERSET(minorversset, i);
-					NFSCTL_VERUNSET(minorvers, i);
-					break;
+					NFSCTL_MINORSET(minorversset, i);
+					NFSCTL_MINORUNSET(minorvers, i);
+					if (minorvers != 0)
+						break;
+				} else {
+					minorvers = 0;
+					minorversset = minormask;
 				}
 			case 3:
 			case 2:
@@ -201,14 +212,14 @@ main(int argc, char **argv)
 			case 4:
 				if (*p == '.') {
 					int i = atoi(p+1);
-					if (i < NFS4_MINMINOR || i > NFS4_MAXMINOR) {
+					if (i < 0 || i > NFS4_MAXMINOR) {
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					NFSCTL_VERSET(minorversset, i);
-					NFSCTL_VERSET(minorvers, i);
-					break;
-				}
+					NFSCTL_MINORSET(minorversset, i);
+					NFSCTL_MINORSET(minorvers, i);
+				} else
+					minorvers = minorversset = minormask;
 			case 3:
 			case 2:
 				NFSCTL_VERSET(versbits, c);
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index 8901fb6c6872..0d797fd2ec8d 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -57,7 +57,7 @@ This option can be used to request that
 .B rpc.nfsd
 does not offer certain versions of NFS. The current version of
 .B rpc.nfsd
-can support major NFS versions 2,3,4 and the minor versions 4.1 and 4.2.
+can support major NFS versions 2,3,4 and the minor versions 4.0, 4.1 and 4.2.
 .TP
 .B \-s " or " \-\-syslog
 By default,
@@ -82,7 +82,7 @@ This option can be used to request that
 .B rpc.nfsd
 offer certain versions of NFS. The current version of
 .B rpc.nfsd
-can support major NFS versions 2,3,4 and the minor versions 4.1 and 4.2.
+can support major NFS versions 2,3,4 and the minor versions 4.0, 4.1 and 4.2.
 .TP
 .B \-L " or " \-\-lease-time seconds
 Set the lease-time used for NFSv4.  This corresponds to how often
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 07f6ff1204d1..e8609c15b8e5 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -330,36 +330,78 @@ nfssvc_set_time(const char *type, const int seconds)
 }
 
 void
+nfssvc_get_minormask(unsigned int *mask)
+{
+	int fd;
+	char *ptr = buf;
+	ssize_t size;
+
+	fd = open(NFSD_VERS_FILE, O_RDONLY);
+	if (fd < 0)
+		return;
+
+	size = read(fd, buf, sizeof(buf));
+	if (size < 0) {
+		xlog(L_ERROR, "Getting versions failed: errno %d (%m)", errno);
+		goto out;
+	}
+	ptr[size] = '\0';
+	for (;;) {
+		unsigned vers, minor = 0;
+		char *token = strtok(ptr, " ");
+
+		if (!token)
+			break;
+		ptr = NULL;
+		if (*token != '+' && *token != '-')
+			continue;
+		if (sscanf(++token, "%u.%u", &vers, &minor) > 0 &&
+		    vers == 4 && minor <= NFS4_MAXMINOR)
+			NFSCTL_MINORSET(*mask, minor);
+	}
+out:
+	close(fd);
+	return;
+}
+
+static int
+nfssvc_print_vers(char *ptr, unsigned size, unsigned vers, unsigned minorvers,
+		int isset)
+{
+	char sign = isset ? '+' : '-';
+	if (minorvers == 0)
+		return snprintf(ptr, size, "%c%u ", sign, vers);
+	return snprintf(ptr, size, "%c%u.%u ", sign, vers, minorvers);
+}
+
+void
 nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int minorversset)
 {
 	int fd, n, off;
-	char *ptr;
 
-	ptr = buf;
 	off = 0;
 	fd = open(NFSD_VERS_FILE, O_WRONLY);
 	if (fd < 0)
 		return;
 
-	for (n = NFS4_MINMINOR; n <= NFS4_MAXMINOR; n++) {
-		if (NFSCTL_VERISSET(minorversset, n)) {
-			if (NFSCTL_VERISSET(minorvers, n))
-				off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
-			else
-				off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
-		}
-	}
-	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
-		if (NFSCTL_VERISSET(ctlbits, n))
-		    off += snprintf(ptr+off, sizeof(buf) - off, "+%d ", n);
-		else
-		    off += snprintf(ptr+off, sizeof(buf) - off, "-%d ", n);
+	for (n = NFSD_MINVERS; n <= ((NFSD_MAXVERS < 3) ? NFSD_MAXVERS : 3); n++)
+		off += nfssvc_print_vers(&buf[off], sizeof(buf) - off,
+				n, 0, NFSCTL_VERISSET(ctlbits, n));
+
+	for (n = 0; n <= NFS4_MAXMINOR; n++) {
+		if (!NFSCTL_MINORISSET(minorversset, n))
+			continue;
+		off += nfssvc_print_vers(&buf[off], sizeof(buf) - off,
+				4, n, NFSCTL_MINORISSET(minorvers, n));
 	}
+	if (!off--)
+		goto out;
+	buf[off] = '\0';
 	xlog(D_GENERAL, "Writing version string to kernel: %s", buf);
-	snprintf(ptr+off, sizeof(buf) - off, "\n");
+	snprintf(&buf[off], sizeof(buf) - off, "\n");
 	if (write(fd, buf, strlen(buf)) != (ssize_t)strlen(buf))
 		xlog(L_ERROR, "Setting version failed: errno %d (%m)", errno);
-
+out:
 	close(fd);
 
 	return;
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index cd5a7e84dc7e..39ebf37a90fe 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -28,3 +28,4 @@ void	nfssvc_set_time(const char *type, const int seconds);
 int	nfssvc_set_rdmaport(const char *port);
 void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigned int minorvers4set);
 int	nfssvc_threads(int nrservs);
+void	nfssvc_get_minormask(unsigned int *mask);
-- 
2.9.3


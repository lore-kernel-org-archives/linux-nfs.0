From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] NFSD: Support IPv6 addresses in write_failover_ip()
Date: Wed, 15 Jul 2009 17:38:00 -0400
Message-ID: <20090715213800.7582.38061.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38879
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754114AbZGOViD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:38:03 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In write_failover_ip(), replace the sscanf() with a call to the common
sunrpc.ko presentation address parser.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 6d08475..7e906c5 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -37,6 +37,7 @@
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
+#include <linux/sunrpc/clnt.h>
 
 #include <asm/uaccess.h>
 #include <net/ipv6.h>
@@ -490,22 +491,18 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
  *
  * Input:
  *			buf:	'\n'-terminated C string containing a
- *				presentation format IPv4 address
+ *				presentation format IP address
  *			size:	length of C string in @buf
  * Output:
  *	On success:	returns zero if all specified locks were released;
  *			returns one if one or more locks were not released
  *	On error:	return code is negative errno value
- *
- * Note: Only AF_INET client addresses are passed in
  */
 static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 {
-	struct sockaddr_in sin = {
-		.sin_family	= AF_INET,
-	};
-	int b1, b2, b3, b4;
-	char c;
+	struct sockaddr_storage address;
+	struct sockaddr *sap = (struct sockaddr *)&address;
+	size_t salen = sizeof(address);
 	char *fo_path;
 
 	/* sanity check */
@@ -519,14 +516,10 @@ static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 	if (qword_get(&buf, fo_path, size) < 0)
 		return -EINVAL;
 
-	/* get ipv4 address */
-	if (sscanf(fo_path, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) != 4)
-		return -EINVAL;
-	if (b1 > 255 || b2 > 255 || b3 > 255 || b4 > 255)
+	if (rpc_pton(fo_path, size, sap, salen) == 0)
 		return -EINVAL;
-	sin.sin_addr.s_addr = htonl((b1 << 24) | (b2 << 16) | (b3 << 8) | b4);
 
-	return nlmsvc_unlock_all_by_ip((struct sockaddr *)&sin);
+	return nlmsvc_unlock_all_by_ip(sap);
 }
 
 /**


From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/13] NFSD: Support IPv6 addresses in write_failover_ip()
Date: Wed, 05 Nov 2008 12:29:51 -0500
Message-ID: <20081105172950.7330.38388.stgit@ingres.1015granger.net>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:36930 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752669AbYKERaM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:30:12 -0500
In-Reply-To: <20081105172351.7330.50739.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In write_failover_ip(), replace the sscanf() with a call to the common
NFS presentation address parser.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfsd/nfsctl.c |   22 ++++++++--------------
 1 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 19db9f4..a8e3f6b 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -38,6 +38,7 @@
 #include <linux/nfsd/xdr.h>
 #include <linux/nfsd/syscall.h>
 #include <linux/lockd/lockd.h>
+#include <linux/nfs_addr_parse.h>
 
 #include <asm/uaccess.h>
 #include <net/ipv6.h>
@@ -476,22 +477,18 @@ static ssize_t write_getfd(struct file *file, char *buf, size_t size)
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
@@ -505,14 +502,11 @@ static ssize_t write_unlock_ip(struct file *file, char *buf, size_t size)
 	if (qword_get(&buf, fo_path, size) < 0)
 		return -EINVAL;
 
-	/* get ipv4 address */
-	if (sscanf(fo_path, NIPQUAD_FMT "%c", &b1, &b2, &b3, &b4, &c) != 4)
-		return -EINVAL;
-	if (b1 > 255 || b2 > 255 || b3 > 255 || b4 > 255)
+	nfs_parse_ip_address(fo_path, size, sap, &salen);
+	if (sap->sa_family == AF_UNSPEC)
 		return -EINVAL;
-	sin.sin_addr.s_addr = htonl((b1 << 24) | (b2 << 16) | (b3 << 8) | b4);
 
-	return nlmsvc_unlock_all_by_ip((struct sockaddr *)&sin);
+	return nlmsvc_unlock_all_by_ip(sap);
 }
 
 /**


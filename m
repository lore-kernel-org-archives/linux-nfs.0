Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935928AbeF2Sm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 29 Jun 2018 14:42:58 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH V2] xdrstdio_create buffers do not output encoded values on ppc
Date: Fri, 29 Jun 2018 14:42:56 -0400
Message-Id: <20180629184256.20532-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Daniel Sands <dnsands@sandia.gov>

The cause is that the xdr_putlong uses a long to store the
converted value, then passes it to fwrite as a byte buffer.
Only the first 4 bytes are written, which is okay for a LE
system after byteswapping, but writes all zeroes on BE systems.

Fixes: https://bugzilla.redhat.com/show_bug.cgi?id=1261738

Signed-off-by: Steve Dickson <steved@redhat.com>
---
v2: Added bounds checking
    Changed from unsigned to signed

 src/xdr_stdio.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
index 4410262..b902acd 100644
--- a/src/xdr_stdio.c
+++ b/src/xdr_stdio.c
@@ -103,10 +103,12 @@ xdrstdio_getlong(xdrs, lp)
 	XDR *xdrs;
 	long *lp;
 {
+	int32_t mycopy;
 
-	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
+	if (fread(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
 		return (FALSE);
-	*lp = (long)ntohl((u_int32_t)*lp);
+
+	*lp = (long)ntohl(mycopy);
 	return (TRUE);
 }
 
@@ -115,8 +117,14 @@ xdrstdio_putlong(xdrs, lp)
 	XDR *xdrs;
 	const long *lp;
 {
-	long mycopy = (long)htonl((u_int32_t)*lp);
+	int32_t mycopy;
+
+#if defined(_LP64)
+	if ((*lp > INT32_MAX) || (*lp < INT32_MIN))
+		return (FALSE);
+#endif
 
+	mycopy = (int32_t)htonl((int32_t)*lp);
 	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
 		return (FALSE);
 	return (TRUE);
-- 
2.17.1


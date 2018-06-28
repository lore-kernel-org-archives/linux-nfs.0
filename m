Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32996 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965440AbeF1P3Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Jun 2018 11:29:16 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] xdrstdio_create buffers do not output encoded values on ppc
Date: Thu, 28 Jun 2018 11:29:14 -0400
Message-Id: <20180628152914.7445-1-steved@redhat.com>
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
 src/xdr_stdio.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/src/xdr_stdio.c b/src/xdr_stdio.c
index 4410262..b415f61 100644
--- a/src/xdr_stdio.c
+++ b/src/xdr_stdio.c
@@ -103,10 +103,10 @@ xdrstdio_getlong(xdrs, lp)
 	XDR *xdrs;
 	long *lp;
 {
-
-	if (fread(lp, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
+	u_int32_t mycopy;
+	if (fread(&mycopy, sizeof(u_int32_t), 1, (FILE *)xdrs->x_private) != 1)
 		return (FALSE);
-	*lp = (long)ntohl((u_int32_t)*lp);
+	*lp = (long)ntohl(mycopy);
 	return (TRUE);
 }
 
@@ -115,9 +115,9 @@ xdrstdio_putlong(xdrs, lp)
 	XDR *xdrs;
 	const long *lp;
 {
-	long mycopy = (long)htonl((u_int32_t)*lp);
+	u_int32_t mycopy = (u_int32_t)htonl((u_int32_t)*lp);
 
-	if (fwrite(&mycopy, sizeof(int32_t), 1, (FILE *)xdrs->x_private) != 1)
+	if (fwrite(&mycopy, sizeof(u_int32_t), 1, (FILE *)xdrs->x_private) != 1)
 		return (FALSE);
 	return (TRUE);
 }
-- 
2.17.1


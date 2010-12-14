Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47942 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757415Ab0LNOyy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 09:54:54 -0500
Received: by yxt3 with SMTP id 3so376245yxt.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 06:54:53 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/31] NFS: Update xdr_encode_foo() functions that we're
	keeping
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 14 Dec 2010 09:54:50 -0500
Message-ID: <20101214145450.2293.15343.stgit@matisse.1015granger.net>
In-Reply-To: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
References: <20101214144747.2293.68070.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The new helper functions are kept in order by section of RFC 1094.
Move the two timestamp encoders we're keeping, update their coding
style, and refresh their documenting comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/nfs2xdr.c |   59 ++++++++++++++++++++++++++++++------------------------
 1 files changed, 33 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index f5ea9dc..c799773 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -91,32 +91,6 @@ xdr_decode_fhandle(__be32 *p, struct nfs_fh *fhandle)
 }
 
 static inline __be32*
-xdr_encode_time(__be32 *p, const struct timespec *timep)
-{
-	*p++ = htonl(timep->tv_sec);
-	/* Convert nanoseconds into microseconds */
-	*p++ = htonl(timep->tv_nsec ? timep->tv_nsec / 1000 : 0);
-	return p;
-}
-
-static inline __be32*
-xdr_encode_current_server_time(__be32 *p, const struct timespec *timep)
-{
-	/*
-	 * Passing the invalid value useconds=1000000 is a
-	 * Sun convention for "set to current server time".
-	 * It's needed to make permissions checks for the
-	 * "touch" program across v2 mounts to Solaris and
-	 * Irix boxes work correctly. See description of
-	 * sattr in section 6.1 of "NFS Illustrated" by
-	 * Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5
-	 */
-	*p++ = htonl(timep->tv_sec);
-	*p++ = htonl(1000000);
-	return p;
-}
-
-static inline __be32*
 xdr_decode_time(__be32 *p, struct timespec *timep)
 {
 	timep->tv_sec = ntohl(*p++);
@@ -179,6 +153,39 @@ static void encode_fhandle(struct xdr_stream *xdr, const struct nfs_fh *fh)
 }
 
 /*
+ * 2.3.4.  timeval
+ *
+ *	struct timeval {
+ *		unsigned int seconds;
+ *		unsigned int useconds;
+ *	};
+ */
+static __be32 *xdr_encode_time(__be32 *p, const struct timespec *timep)
+{
+	*p++ = cpu_to_be32(timep->tv_sec);
+	if (timep->tv_nsec != 0)
+		*p++ = cpu_to_be32(timep->tv_nsec / NSEC_PER_USEC);
+	else
+		*p++ = cpu_to_be32(0);
+	return p;
+}
+
+/*
+ * Passing the invalid value useconds=1000000 is a Sun convention for
+ * "set to current server time".  It's needed to make permissions checks
+ * for the "touch" program across v2 mounts to Solaris and Irix servers
+ * work correctly.  See description of sattr in section 6.1 of "NFS
+ * Illustrated" by Brent Callaghan, Addison-Wesley, ISBN 0-201-32750-5.
+ */
+static __be32 *xdr_encode_current_server_time(__be32 *p,
+					      const struct timespec *timep)
+{
+	*p++ = cpu_to_be32(timep->tv_sec);
+	*p++ = cpu_to_be32(1000000);
+	return p;
+}
+
+/*
  * 2.3.6.  sattr
  *
  *	struct sattr {


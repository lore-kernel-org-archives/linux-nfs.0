From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/22] NFS: Move and update xdr_encode_foo() functions that
	we're keeping
Date: Fri, 02 Jul 2010 13:19:25 -0400
Message-ID: <20100702171925.8761.44736.stgit@ellison.1015granger.net>
References: <20100702165935.8761.88528.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51418 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759026Ab0GBRT1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jul 2010 13:19:27 -0400
Received: by mail-iw0-f174.google.com with SMTP id 7so3461836iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Jul 2010 10:19:27 -0700 (PDT)
In-Reply-To: <20100702165935.8761.88528.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   59 ++++++++++++++++++++++++++++++------------------------
 1 files changed, 33 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 0bcfab0..557286e 100644
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
@@ -180,6 +154,39 @@ static void encode_fhandle(struct xdr_stream *xdr, const struct nfs_fh *fh)
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


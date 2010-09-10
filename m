Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48864 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab0IJUJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 16:09:43 -0400
Received: by yxp4 with SMTP id 4so1305854yxp.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 13:09:42 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/11] NFS: Move and update xdr_encode_foo() functions that
	we're keeping
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 10 Sep 2010 16:09:39 -0400
Message-ID: <20100910200938.13321.52944.stgit@seurat.1015granger.net>
In-Reply-To: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
References: <20100910200512.13321.55605.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs2xdr.c |   59 ++++++++++++++++++++++++++++++------------------------
 1 files changed, 33 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index cd9e2d8..0a3f830 100644
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


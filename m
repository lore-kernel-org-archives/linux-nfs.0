From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 04/11] nfs-utils: clean up NFSCTL_* macros for handling protocol bits
Date: Mon,  8 Jun 2009 14:00:37 -0400
Message-ID: <1244484044-21355-5-git-send-email-jlayton@redhat.com>
References: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Cc: chuck.lever@oracle.com, steved@redhat.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48141 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750961AbZFHSAy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 14:00:54 -0400
In-Reply-To: <1244484044-21355-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

They are a little hard to follow currently. Clean them up and add new
macros that can set these bits in addition to the ones that unset them.

Also add a new macro that reports when any valid protocol bit is set.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 support/include/nfs/nfs.h |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 00b0028..a64eb0a 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -42,14 +42,21 @@ struct nfs_fh_old {
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define NFSCTL_GETFS		8	/* get an fh by path with max size (used by mountd) */
 
+#define NFSCTL_UDPBIT		      (1 << (17 - 1))
+#define NFSCTL_TCPBIT		      (1 << (18 - 1))
+
 #define NFSCTL_VERUNSET(_cltbits, _v) ((_cltbits) &= ~(1 << ((_v) - 1))) 
-#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (17 - 1))) 
-#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~(1 << (18 - 1))) 
+#define NFSCTL_UDPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_UDPBIT) 
+#define NFSCTL_TCPUNSET(_cltbits)     ((_cltbits) &= ~NFSCTL_TCPBIT) 
 
 #define NFSCTL_VERISSET(_cltbits, _v) ((_cltbits) & (1 << ((_v) - 1))) 
-#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & (1 << (17 - 1))) 
-#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & (1 << (18 - 1))) 
+#define NFSCTL_UDPISSET(_cltbits)     ((_cltbits) & NFSCTL_UDPBIT) 
+#define NFSCTL_TCPISSET(_cltbits)     ((_cltbits) & NFSCTL_TCPBIT) 
+
+#define NFSCTL_UDPSET(_cltbits)       ((_cltbits) |= NFSCTL_UDPBIT)
+#define NFSCTL_TCPSET(_cltbits)       ((_cltbits) |= NFSCTL_TCPBIT)
 
+#define NFSCTL_ANYPROTO(_cltbits)     ((_cltbits) & (NFSCTL_UDPBIT | NFSCTL_TCPBIT))
 #define NFSCTL_ALLBITS (~0)
 
 /* SVC */
-- 
1.6.0.6


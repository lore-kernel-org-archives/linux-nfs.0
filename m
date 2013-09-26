Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:12207 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752120Ab3IZOpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 10:45:17 -0400
Subject: [PATCH 1/4] SunRPC: Use the standard varargs macro method for
 dfprintk() and co.
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: David Howells <dhowells@redhat.com>
Cc: olof@lixom.net, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 26 Sep 2013 15:45:10 +0100
Message-ID: <20130926144510.29424.40094.stgit@warthog.procyon.org.uk>
In-Reply-To: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
References: <20130926144502.29424.21633.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the standard varargs macro method rather than the old gcc method for
dfprintk() and co.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/sunrpc/debug.h |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 9385bd7..889474b 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -32,33 +32,33 @@ extern unsigned int		nfsd_debug;
 extern unsigned int		nlm_debug;
 #endif
 
-#define dprintk(args...)	dfprintk(FACILITY, ## args)
-#define dprintk_rcu(args...)	dfprintk_rcu(FACILITY, ## args)
+#define dprintk(fmt, ...)	dfprintk(FACILITY, fmt, ## __VA_ARGS__)
+#define dprintk_rcu(fmt, ...)	dfprintk_rcu(FACILITY, fmt, ## __VA_ARGS__)
 
 #undef ifdebug
 #ifdef RPC_DEBUG			
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
 
-# define dfprintk(fac, args...)	\
+# define dfprintk(fac, fmt, ...)		\
 	do { \
 		ifdebug(fac) \
-			printk(KERN_DEFAULT args); \
+			printk(KERN_DEFAULT fmt, ##__VA_ARGS__);	\
 	} while (0)
 
-# define dfprintk_rcu(fac, args...)	\
+# define dfprintk_rcu(fac, fmt, ...)		\
 	do { \
 		ifdebug(fac) { \
 			rcu_read_lock(); \
-			printk(KERN_DEFAULT args); \
+			printk(KERN_DEFAULT fmt, ##__VA_ARGS__);	\
 			rcu_read_unlock(); \
 		} \
 	} while (0)
 
 # define RPC_IFDEBUG(x)		x
 #else
-# define ifdebug(fac)		if (0)
-# define dfprintk(fac, args...)	do {} while (0)
-# define dfprintk_rcu(fac, args...)	do {} while (0)
+# define ifdebug(fac)			if (0)
+# define dfprintk(fac, fmt, ...)	do {} while (0)
+# define dfprintk_rcu(fac, fmt, ...)	do {} while (0)
 # define RPC_IFDEBUG(x)
 #endif
 


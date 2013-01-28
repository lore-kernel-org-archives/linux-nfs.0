Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f178.google.com ([209.85.161.178]:62274 "EHLO
	mail-gg0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3A1Tlf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2013 14:41:35 -0500
Received: by mail-gg0-f178.google.com with SMTP id 21so462707ggh.37
        for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2013 11:41:35 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 01/16] nfsd: fix IPv6 address handling in the DRC
Date: Mon, 28 Jan 2013 14:41:07 -0500
Message-Id: <1359402082-29195-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it only stores the first 16 bytes of any address. struct
sockaddr_in6 is 28 bytes however, so we're currently ignoring the last
12 bytes of the address.

Expand the c_addr field to a sockaddr_in6, and cast it to a sockaddr_in
as necessary. Also fix the comparitor to use the existing RPC
helpers for this.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/cache.h             | 6 +++++-
 fs/nfsd/nfscache.c          | 7 +++++--
 include/linux/sunrpc/clnt.h | 4 +++-
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
index 93cc9d3..2cac76c 100644
--- a/fs/nfsd/cache.h
+++ b/fs/nfsd/cache.h
@@ -12,6 +12,10 @@
 
 /*
  * Representation of a reply cache entry.
+ *
+ * Note that we use a sockaddr_in6 to hold the address instead of the more
+ * typical sockaddr_storage. This is for space reasons, since sockaddr_storage
+ * is much larger than a sockaddr_in6.
  */
 struct svc_cacherep {
 	struct hlist_node	c_hash;
@@ -20,7 +24,7 @@ struct svc_cacherep {
 	unsigned char		c_state,	/* unused, inprog, done */
 				c_type,		/* status, buffer */
 				c_secure : 1;	/* req came from port < 1024 */
-	struct sockaddr_in	c_addr;
+	struct sockaddr_in6	c_addr;
 	__be32			c_xid;
 	u32			c_prot;
 	u32			c_proc;
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 2cbac34..5dd9ec2 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/slab.h>
+#include <linux/sunrpc/clnt.h>
 
 #include "nfsd.h"
 #include "cache.h"
@@ -146,7 +147,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 		    xid == rp->c_xid && proc == rp->c_proc &&
 		    proto == rp->c_prot && vers == rp->c_vers &&
 		    time_before(jiffies, rp->c_timestamp + 120*HZ) &&
-		    memcmp((char*)&rqstp->rq_addr, (char*)&rp->c_addr, sizeof(rp->c_addr))==0) {
+		    rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) &&
+		    rpc_get_port(svc_addr(rqstp)) == rpc_get_port((struct sockaddr *)&rp->c_addr)) {
 			nfsdstats.rchits++;
 			goto found_entry;
 		}
@@ -183,7 +185,8 @@ nfsd_cache_lookup(struct svc_rqst *rqstp)
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
 	rp->c_proc = proc;
-	memcpy(&rp->c_addr, svc_addr_in(rqstp), sizeof(rp->c_addr));
+	rpc_copy_addr((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
+	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
 	rp->c_prot = proto;
 	rp->c_vers = vers;
 	rp->c_timestamp = jiffies;
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 34206b8..47354a2 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -263,7 +263,9 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
  * @sap1: first sockaddr
  * @sap2: second sockaddr
  *
- * Just compares the family and address portion. Ignores port, scope, etc.
+ * Just compares the family and address portion. Ignores port, but
+ * compares the scope if it's a link-local address.
+ *
  * Returns true if the addrs are equal, false if they aren't.
  */
 static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
-- 
1.7.11.7


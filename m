From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] SUNRPC: Add documenting comments in net/sunrpc/timer.c
Date: Thu, 06 Aug 2009 14:55:45 -0400
Message-ID: <20090806185545.3458.47417.stgit@matisse.1015granger.net>
References: <20090806184944.3458.44739.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:45919
	"EHLO matisse.1015granger.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753537AbZHFSzr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 14:55:47 -0400
In-Reply-To: <20090806184944.3458.44739.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: provide documenting comments for the functions in
net/sunrpc/timer.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/timer.c |   45 +++++++++++++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/timer.c b/net/sunrpc/timer.c
index 31becbf..dd82434 100644
--- a/net/sunrpc/timer.c
+++ b/net/sunrpc/timer.c
@@ -25,8 +25,13 @@
 #define RPC_RTO_INIT (HZ/5)
 #define RPC_RTO_MIN (HZ/10)
 
-void
-rpc_init_rtt(struct rpc_rtt *rt, unsigned long timeo)
+/**
+ * rpc_init_rtt - Initialize an RPC RTT estimator context
+ * @rt: context to initialize
+ * @timeo: initial timeout value, in jiffies
+ *
+ */
+void rpc_init_rtt(struct rpc_rtt *rt, unsigned long timeo)
 {
 	unsigned long init = 0;
 	unsigned i;
@@ -43,12 +48,16 @@ rpc_init_rtt(struct rpc_rtt *rt, unsigned long timeo)
 }
 EXPORT_SYMBOL_GPL(rpc_init_rtt);
 
-/*
+/**
+ * rpc_update_rtt - Update an RPC RTT estimator context
+ * @rt: context to update
+ * @timer: timer array index (request type)
+ * @m: recent actual RTT, in jiffies
+ *
  * NB: When computing the smoothed RTT and standard deviation,
  *     be careful not to produce negative intermediate results.
  */
-void
-rpc_update_rtt(struct rpc_rtt *rt, unsigned timer, long m)
+void rpc_update_rtt(struct rpc_rtt *rt, unsigned timer, long m)
 {
 	long *srtt, *sdrtt;
 
@@ -79,21 +88,25 @@ rpc_update_rtt(struct rpc_rtt *rt, unsigned timer, long m)
 }
 EXPORT_SYMBOL_GPL(rpc_update_rtt);
 
-/*
- * Estimate rto for an nfs rpc sent via. an unreliable datagram.
- * Use the mean and mean deviation of rtt for the appropriate type of rpc
- * for the frequent rpcs and a default for the others.
- * The justification for doing "other" this way is that these rpcs
- * happen so infrequently that timer est. would probably be stale.
- * Also, since many of these rpcs are
- * non-idempotent, a conservative timeout is desired.
+/**
+ * rpc_calc_rto - Provide an estimated timeout value
+ * @rt: context to use for calculation
+ * @timer: timer array index (request type)
+ *
+ * Estimate RTO for an NFS RPC sent via an unreliable datagram.  Use
+ * the mean and mean deviation of RTT for the appropriate type of RPC
+ * for frequently issued RPCs, and a fixed default for the others.
+ *
+ * The justification for doing "other" this way is that these RPCs
+ * happen so infrequently that timer estimation would probably be
+ * stale.  Also, since many of these RPCs are non-idempotent, a
+ * conservative timeout is desired.
+ *
  * getattr, lookup,
  * read, write, commit     - A+4D
  * other                   - timeo
  */
-
-unsigned long
-rpc_calc_rto(struct rpc_rtt *rt, unsigned timer)
+unsigned long rpc_calc_rto(struct rpc_rtt *rt, unsigned timer)
 {
 	unsigned long res;
 


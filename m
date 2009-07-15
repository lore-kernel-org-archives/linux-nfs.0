Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:32769
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752115AbZGOVnE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:43:04 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/10] SUNRPC: Add documenting comments in net/sunrpc/timer.c
To: trond.myklebust@fys.uio.no
Cc: linux-nfs@vger.kernel.org
Date: Wed, 15 Jul 2009 17:43:00 -0400
Message-ID: <20090715214300.7883.95882.stgit@matisse.1015granger.net>
In-Reply-To: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
References: <20090715213842.7883.48947.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: provide documenting comments for the functions in
net/sunrpc/timer.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/timer.c |   45 +++++++++++++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/net/sunrpc/timer.c b/net/sunrpc/timer.c
index 31becbf..14ac71c 100644
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
+ * stale.  Also, since many of these rpcs are non-idempotent, a
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
 


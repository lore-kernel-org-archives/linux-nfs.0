From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/11] SUNRPC: Check explicitly for tk_status == 0 in
	call_transmit_status()
Date: Thu, 05 Nov 2009 13:22:57 -0500
Message-ID: <20091105182257.2796.50928.stgit@matisse.1015granger.net>
References: <20091105181924.2796.9313.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:37608
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758077AbZKESW7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Nov 2009 13:22:59 -0500
In-Reply-To: <20091105181924.2796.9313.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The success case, where task->tk_status == 0, is by far the most
frequent case in call_transmit_status().

The default: arm of the switch statement in call_transmit_status()
handles the 0 case.  default: was moved close to the top of the switch
statement in call_transmit_status() under the theory that the compiler
places object code for the earliest arms of a switch statement first,
making the CPU do less work.

The default: arm of a switch statement, however, is executed only
after all the other cases have been checked.  Even if the compiler
rearranges the object code, the default: arm is the "last resort",
meaning all of the other cases have been explicitly exhausted.  That
makes the current arrangement about as inefficient as it gets for the
common case.

To fix this, add an explicit check for zero before the switch
statement.  That forces the compiler to do the zero check first, no
matter what optimizations it might try to do to the switch statement.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 38829e2..7bcd931 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1180,10 +1180,22 @@ static void
 call_transmit_status(struct rpc_task *task)
 {
 	task->tk_action = call_status;
+
+	/*
+	 * Common case: success.  Force the compiler to put this
+	 * test first.
+	 */
+	if (task->tk_status == 0) {
+		xprt_end_transmit(task);
+		rpc_task_force_reencode(task);
+		return;
+	}
+
 	switch (task->tk_status) {
 	case -EAGAIN:
 		break;
 	default:
+		dprint_status(task);
 		xprt_end_transmit(task);
 		/*
 		 * Special cases: if we've been waiting on the


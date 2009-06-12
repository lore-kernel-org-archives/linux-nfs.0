From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 05/14] SQUASHME: Convert rpc_reply_expected() to inline function
Date: Thu, 11 Jun 2009 22:54:11 -0700
Message-ID: <1244786060-2200-6-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55147 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbZFLF6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:10 -0400
In-Reply-To: <1244786060-2200-5-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: Add backchannel processing support to RPC state machine]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/sunrpc.h |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index f753d51..045f175 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -21,15 +21,17 @@ SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************/
 
 /*
- * Functions and macros used internally by RPC
+ * Functions used internally by RPC
  */
 
 #ifndef _NET_SUNRPC_SUNRPC_H
 #define _NET_SUNRPC_SUNRPC_H
 
-#define rpc_reply_expected(task) \
-	(((task)->tk_msg.rpc_proc != NULL) && \
-	((task)->tk_msg.rpc_proc->p_decode != NULL))
+static inline int rpc_reply_expected(struct rpc_task *task)
+{
+	return (task->tk_msg.rpc_proc != NULL) &&
+		(task->tk_msg.rpc_proc->p_decode != NULL);
+}
 
 int svc_send_common(struct socket *sock, struct xdr_buf *xdr,
 		struct page *headpage, unsigned long headoffset,
-- 
1.5.4.3


From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 02/14] SQUASHME: Update copyright notice and explain page allocation
Date: Thu, 11 Jun 2009 22:54:08 -0700
Message-ID: <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55147 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751571AbZFLF6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:10 -0400
In-Reply-To: <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: New backchannel helper routines]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 net/sunrpc/backchannel_rqst.c |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
index 8f177a5..5a7d342 100644
--- a/net/sunrpc/backchannel_rqst.c
+++ b/net/sunrpc/backchannel_rqst.c
@@ -1,8 +1,9 @@
 /******************************************************************************
 
 (c) 2007 Network Appliance, Inc.  All Rights Reserved.
+(c) 2009 NetApp.  All Rights Reserved.
 
-Network Appliance provides this source code under the GPL v2 License.
+NetApp provides this source code under the GPL v2 License.
 The GPL v2 license is available at
 http://opensource.org/licenses/gpl-license.php.
 
@@ -75,6 +76,14 @@ static void xprt_free_allocation(struct rpc_rqst *req)
  * incoming callback request.  It's up to the higher levels in the
  * stack to enforce that the maximum number of session slots is not
  * being exceeded.
+ *
+ * Some callback arguments can be large.  For example, a pNFS server
+ * using multiple deviceids.  The list can be unbound, but the client
+ * has the ability to tell the server the maximum size of the callback
+ * requests.  Each deviceID is 16 bytes, so allocate one page
+ * for the arguments to have enough room to receive a number of these
+ * deviceIDs.  The NFS client indicates to the pNFS server that its
+ * callback requests can be up to 4096 bytes in size.
  */
 int xprt_setup_backchannel(struct rpc_xprt *xprt, unsigned int min_reqs)
 {
-- 
1.5.4.3


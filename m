From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [PATCH 03/14] SQUASHME: Update Copyright notice and fix formatting
Date: Thu, 11 Jun 2009 22:54:09 -0700
Message-ID: <1244786060-2200-4-git-send-email-Ricardo.Labiaga@netapp.com>
References: <>
 <1244786060-2200-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2056 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353AbZFLF6K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Jun 2009 01:58:10 -0400
In-Reply-To: <1244786060-2200-3-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[squash with: nfs41: New include/linux/sunrpc/bc_xprt.h]

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
---
 include/linux/sunrpc/bc_xprt.h |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/bc_xprt.h b/include/linux/sunrpc/bc_xprt.h
index 3016c00..6508f0d 100644
--- a/include/linux/sunrpc/bc_xprt.h
+++ b/include/linux/sunrpc/bc_xprt.h
@@ -1,8 +1,8 @@
 /******************************************************************************
 
-(c) 2008 Network Appliance, Inc.  All Rights Reserved.
+(c) 2008 NetApp.  All Rights Reserved.
 
-Network Appliance provides this source code under the GPL v2 License.
+NetApp provides this source code under the GPL v2 License.
 The GPL v2 license is available at
 http://opensource.org/licenses/gpl-license.php.
 
@@ -41,7 +41,9 @@ int bc_send(struct rpc_rqst *req);
 #else /* CONFIG_NFS_V4_1 */
 static inline int xprt_setup_backchannel(struct rpc_xprt *xprt,
 					 unsigned int min_reqs)
-{ return 0; }
+{
+	return 0;
+}
 #endif /* CONFIG_NFS_V4_1 */
 #endif /* _LINUX_SUNRPC_BC_XPRT_H */
 
-- 
1.5.4.3


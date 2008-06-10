From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd: eliminate unused nfs4_callback.cb_stat
Date: Tue, 10 Jun 2008 13:39:43 +0300
Message-ID: <1213094383-27759-1-git-send-email-bhalevy@panasas.com>
References: <1213091947-19618-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44633 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008AbYFJKj7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 06:39:59 -0400
In-Reply-To: <1213091947-19618-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cb_stat member of struct nfs4_callback is unused
since commit ff7d9756 nfsd: use static memory for callback program and stats

Signed-off-by: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/state.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 06e9686..d0fe2e3 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -98,7 +98,6 @@ struct nfs4_callback {
 	u32                     cb_ident;
 	/* RPC client info */
 	atomic_t		cb_set;     /* successful CB_NULL call */
-	struct rpc_stat         cb_stat;
 	struct rpc_clnt *       cb_client;
 };
 
-- 
1.5.3.3


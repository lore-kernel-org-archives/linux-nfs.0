From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd: eliminate unused nfs4_callback.cb_program
Date: Tue, 10 Jun 2008 12:59:07 +0300
Message-ID: <1213091947-19618-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:33746 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbYFJKOE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 06:14:04 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The cb_program member of struct nfs4_callback unused
since commit ff7d9756 nfsd: use static memory for callback program and stats

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfsd/state.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 0722162..2716f10 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -100,7 +100,6 @@ struct nfs4_callback {
 	u32			cb_ident;	/* minorversion 0 only */
 	/* RPC client info */
 	atomic_t		cb_set;     /* successful CB_NULL call */
-	struct rpc_program      cb_program;
 	struct rpc_stat         cb_stat;
 	struct rpc_clnt *       cb_client;
 };
-- 
1.5.3.3


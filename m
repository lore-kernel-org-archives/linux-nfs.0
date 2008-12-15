From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 3/6] nfsd: git rid of nfs4_cb_null_ops declaration
Date: Mon, 15 Dec 2008 19:41:10 +0200
Message-ID: <1229362870-9765-1-git-send-email-bhalevy@panasas.com>
References: <49469601.7020101@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53665 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbYLORl3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Dec 2008 12:41:29 -0500
In-Reply-To: <49469601.7020101@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's no use for nfs4_cb_null_ops's declaration in fs/nfsd/nfs4callback.c

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 094747a..e198ead 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -53,9 +53,6 @@
 #define NFSPROC4_CB_NULL 0
 #define NFSPROC4_CB_COMPOUND 1
 
-/* declarations */
-static const struct rpc_call_ops nfs4_cb_null_ops;
-
 /* Index of predefined Linux callback client operations */
 
 enum {
-- 
1.6.0.2


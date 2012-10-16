Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698Ab2JPQbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:38 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 19/25] SUNRPC: remove BUG_ON() from bc_malloc()
Date: Tue, 16 Oct 2012 12:30:37 -0400
Message-Id: <1350405043-39316-19-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace BUG_ON() with WARN_ON_ONCE() and NULL return - the caller will handle
this like a memory allocation failure.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/xprtsock.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4e76d38..84cf236 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2351,9 +2351,11 @@ static void *bc_malloc(struct rpc_task *task, size_t size)
 	struct page *page;
 	struct rpc_buffer *buf;
 
-	BUG_ON(size > PAGE_SIZE - sizeof(struct rpc_buffer));
-	page = alloc_page(GFP_KERNEL);
+	WARN_ON_ONCE(size > PAGE_SIZE - sizeof(struct rpc_buffer));
+	if (size > PAGE_SIZE - sizeof(struct rpc_buffer))
+		return NULL;
 
+	page = alloc_page(GFP_KERNEL);
 	if (!page)
 		return NULL;
 
-- 
1.7.9.6 (Apple Git-31.1)


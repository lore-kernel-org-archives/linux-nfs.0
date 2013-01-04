Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f47.google.com ([209.85.160.47]:46784 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3ADLzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 06:55:19 -0500
From: ycnian@gmail.com
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfsd: Remove write permission from file content
Date: Fri,  4 Jan 2013 19:45:35 +0800
Message-Id: <1357299935-9321-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The write function doesn't be implemented in file content, and it's meaningless
to write data into this file directly. Remove write permission from it.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 net/sunrpc/cache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 9afa439..9f84703 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1614,7 +1614,7 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 			goto out_nomem;
 	}
 	if (cd->cache_show) {
-		p = proc_create_data("content", S_IFREG|S_IRUSR|S_IWUSR,
+		p = proc_create_data("content", S_IFREG|S_IRUSR,
 				cd->u.procfs.proc_ent,
 				&content_file_operations_procfs, cd);
 		cd->u.procfs.content_ent = p;
-- 
1.7.4.4


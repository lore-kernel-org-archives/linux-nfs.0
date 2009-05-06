From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH] nfsd: nfs4_stat_init cleanup
Date: Wed, 06 May 2009 17:28:23 +0800
Message-ID: <4A015837.6050703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51859 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753795AbZEFJ3B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 May 2009 05:29:01 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From 6c43788cbe09b84df712df1546d6c462656cc801 Mon Sep 17 00:00:00 2001
From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 24 Apr 2009 15:41:57 +0800
Subject: [PATCH] nfsd: nfs4_stat_init cleanup

Save some loop time.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 fs/nfsd/nfs4state.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 86b9afd..2b4f70a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3988,6 +3988,7 @@ nfs4_state_init(void)
 		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_str_hashtbl[i]);
 		INIT_LIST_HEAD(&unconf_id_hashtbl[i]);
+		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
 	}
 	for (i = 0; i < SESSION_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sessionid_hashtbl[i]);
@@ -4010,8 +4011,6 @@ nfs4_state_init(void)
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
-	for (i = 0; i < CLIENT_HASH_SIZE; i++)
-		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
 	reclaim_str_hashtbl_size = 0;
 	return 0;
 }
-- 
1.6.0.6



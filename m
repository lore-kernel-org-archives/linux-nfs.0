Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33460 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbcIAHaf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Sep 2016 03:30:35 -0400
From: Chunyan Zhang <zhang.lyra@gmail.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, zhang.lyra@gmail.com,
        ke.wang@spreadtrum.com
Subject: [PATCH] sunrpc: queue work on system_power_efficient_wq
Date: Thu,  1 Sep 2016 15:30:26 +0800
Message-Id: <1472715026-11397-1-git-send-email-zhang.lyra@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ke Wang <ke.wang@spreadtrum.com>

sunrpc uses workqueue to clean cache regulary. There is no real dependency
of executing work on the cpu which queueing it.

On a idle system, especially for a heterogeneous systems like big.LITTLE,
it is observed that the big idle cpu was woke up many times just to service
this work, which against the principle of power saving. It would be better
if we can schedule it on a cpu which the scheduler believes to be the most
appropriate one.

After apply this patch, system_wq will be replaced by
system_power_efficient_wq for sunrpc. This functionality is enabled when
CONFIG_WQ_POWER_EFFICIENT is selected.

Signed-off-by: Ke Wang <ke.wang@spreadtrum.com>
---
 net/sunrpc/cache.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 4d8e11f..8aabe12 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -353,7 +353,7 @@ void sunrpc_init_cache_detail(struct cache_detail *cd)
 	spin_unlock(&cache_list_lock);
 
 	/* start the cleaning process */
-	schedule_delayed_work(&cache_cleaner, 0);
+	queue_delayed_work(system_power_efficient_wq, &cache_cleaner, 0);
 }
 EXPORT_SYMBOL_GPL(sunrpc_init_cache_detail);
 
@@ -476,7 +476,8 @@ static void do_cache_clean(struct work_struct *work)
 		delay = 0;
 
 	if (delay)
-		schedule_delayed_work(&cache_cleaner, delay);
+		queue_delayed_work(system_power_efficient_wq,
+				   &cache_cleaner, delay);
 }
 
 
-- 
2.7.4


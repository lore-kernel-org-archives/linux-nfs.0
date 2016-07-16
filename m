Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35600 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbcGPQFf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Jul 2016 12:05:35 -0400
Received: by mail-io0-f194.google.com with SMTP id q83so8263611iod.2
        for <linux-nfs@vger.kernel.org>; Sat, 16 Jul 2016 09:05:35 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix infinite looping in rpc_clnt_iterate_for_each_xprt
Date: Sat, 16 Jul 2016 12:04:50 -0400
Message-Id: <1468685090-5513-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there were less than 2 entries in the multipath list, then
xprt_iter_next_entry_multiple() would never advance beyond the
first entry, which is correct for round robin behaviour, but not
for the list iteration.

The end result would be infinite looping in rpc_clnt_iterate_for_each_xprt()
as we would never see the xprt == NULL condition fulfilled.

Reported-by: Oleg Drokin <green@linuxhacker.ru>
Fixes: 80b14d5e61ca ("SUNRPC: Add a structure to track multiple transports")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 net/sunrpc/xprtmultipath.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index e7fd76975d86..66c9d63f4797 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -271,14 +271,12 @@ struct rpc_xprt *xprt_iter_next_entry_multiple(struct rpc_xprt_iter *xpi,
 		xprt_switch_find_xprt_t find_next)
 {
 	struct rpc_xprt_switch *xps = rcu_dereference(xpi->xpi_xpswitch);
-	struct list_head *head;
 
 	if (xps == NULL)
 		return NULL;
-	head = &xps->xps_xprt_list;
-	if (xps->xps_nxprts < 2)
-		return xprt_switch_find_first_entry(head);
-	return xprt_switch_set_next_cursor(head, &xpi->xpi_cursor, find_next);
+	return xprt_switch_set_next_cursor(&xps->xps_xprt_list,
+			&xpi->xpi_cursor,
+			find_next);
 }
 
 static
-- 
2.7.4


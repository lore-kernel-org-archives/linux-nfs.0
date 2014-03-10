Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:60799 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753045AbaCJPdz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Mar 2014 11:33:55 -0400
Received: by mail-qa0-f48.google.com with SMTP id m5so7059225qaj.35
        for <linux-nfs@vger.kernel.org>; Mon, 10 Mar 2014 08:33:55 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] svcrdma: fix printk when memory allocation fails
Date: Mon, 10 Mar 2014 11:33:48 -0400
Message-Id: <1394465628-457-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It retries in 1s, not 1000 jiffies.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 62e4f9bcc387..25688fa2207f 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -477,8 +477,7 @@ struct page *svc_rdma_get_page(void)
 
 	while ((page = alloc_page(GFP_KERNEL)) == NULL) {
 		/* If we can't get memory, wait a bit and try again */
-		printk(KERN_INFO "svcrdma: out of memory...retrying in 1000 "
-		       "jiffies.\n");
+		printk(KERN_INFO "svcrdma: out of memory...retrying in 1s\n");
 		schedule_timeout_uninterruptible(msecs_to_jiffies(1000));
 	}
 	return page;
-- 
1.8.5.3


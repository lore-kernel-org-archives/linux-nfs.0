Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:32999 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab2EPRan (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 May 2012 13:30:43 -0400
Received: by gglu4 with SMTP id u4so934451ggl.19
        for <linux-nfs@vger.kernel.org>; Wed, 16 May 2012 10:30:43 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, andros@netapp.com
Subject: [PATCH] sunrpc: suppress page allocation warnings in xprt_alloc_slot()
Date: Wed, 16 May 2012 13:30:35 -0400
Message-Id: <1337189435-20611-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's easily possible for these allocations to fail since we're using
GFP_NOWAIT here. We don't want to spam the logs with warnings about
that though.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 0cbcd1a..b239e75 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -979,7 +979,7 @@ static void xprt_alloc_slot(struct rpc_task *task)
 		list_del(&req->rq_list);
 		goto out_init_req;
 	}
-	req = xprt_dynamic_alloc_slot(xprt, GFP_NOWAIT);
+	req = xprt_dynamic_alloc_slot(xprt, GFP_NOWAIT|__GFP_NOWARN);
 	if (!IS_ERR(req))
 		goto out_init_req;
 	switch (PTR_ERR(req)) {
-- 
1.7.7.6


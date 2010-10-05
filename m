Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:3753 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755637Ab0JEQrX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 12:47:23 -0400
Message-ID: <4CAB5694.5030400@parallels.com>
Date: Tue, 05 Oct 2010 20:47:16 +0400
From: Pavel Emelyanov <xemul@parallels.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: Remove useless if (task == NULL) from xprt_reserve_xprt
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The task in question is dereferenced above (and is actually never NULL).

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/sunrpc/xprt.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 953206d..64a4a94 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -199,8 +199,6 @@ int xprt_reserve_xprt(struct rpc_task *task)
 	if (test_and_set_bit(XPRT_LOCKED, &xprt->state)) {
 		if (task == xprt->snd_task)
 			return 1;
-		if (task == NULL)
-			return 0;
 		goto out_sleep;
 	}
 	xprt->snd_task = task;
-- 
1.5.5.6


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:55594 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbbIXOBJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2015 10:01:09 -0400
From: Andrzej Hajda <a.hajda@samsung.com>
To: linux-kernel@vger.kernel.org
Cc: Andrzej Hajda <a.hajda@samsung.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH 01/19] SUNRPC: fix variable type
Date: Thu, 24 Sep 2015 16:00:09 +0200
Message-id: <1443103227-25612-2-git-send-email-a.hajda@samsung.com>
In-reply-to: <1443103227-25612-1-git-send-email-a.hajda@samsung.com>
References: <1443103227-25612-1-git-send-email-a.hajda@samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Due to incorrect len type bc_send_request returned always zero.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
Hi,

To avoid problems with too many mail recipients I have sent whole
patchset only to LKML. Anyway patches have no dependencies.

Regards
Andrzej
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 1a85e0e..60fb002 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2472,7 +2472,7 @@ static int bc_send_request(struct rpc_task *task)
 {
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct svc_xprt	*xprt;
-	u32                     len;
+	int len;
 
 	dprintk("sending request with xid: %08x\n", ntohl(req->rq_xid));
 	/*
-- 
1.9.1


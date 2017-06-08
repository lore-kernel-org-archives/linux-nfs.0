Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33680 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdFHPvt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jun 2017 11:51:49 -0400
Subject: [PATCH v2 01/13] xprtrdma: On invalidation failure,
 remove MWs from rl_registered
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 08 Jun 2017 11:51:48 -0400
Message-ID: <20170608155147.18945.85705.stgit@manet.1015granger.net>
In-Reply-To: <20170608154339.18945.5500.stgit@manet.1015granger.net>
References: <20170608154339.18945.5500.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Callers assume the ro_unmap_sync and ro_unmap_safe methods empty
the list of registered MRs. Ensure that all paths through
fmr_op_unmap_sync() remove MWs from that list.

Fixes: 9d6b04097882 ("xprtrdma: Place registered MWs on a ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 59e6402..21f3cd5 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -295,6 +295,7 @@ enum {
 	pr_err("rpcrdma: ib_unmap_fmr failed (%i)\n", rc);
 
 	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+		list_del_init(&mw->mw_list);
 		list_del_init(&mw->fmr.fm_mr->list);
 		fmr_op_recover_mr(mw);
 	}


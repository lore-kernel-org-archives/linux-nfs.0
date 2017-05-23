Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36803 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968278AbdEWOyC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 10:54:02 -0400
Subject: [PATCH v1 02/12] xprtrdma: On invalidation failure,
 remove MWs from rl_registered
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 23 May 2017 10:53:54 -0400
Message-ID: <20170523145354.961.18377.stgit@manet.1015granger.net>
In-Reply-To: <20170523142629.961.81233.stgit@manet.1015granger.net>
References: <20170523142629.961.81233.stgit@manet.1015granger.net>
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
index 9ee573f..7b2de86 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -295,6 +295,7 @@ enum {
 	pr_err("rpcrdma: ib_unmap_fmr failed (%i)\n", rc);
 
 	list_for_each_entry_safe(mw, tmp, &req->rl_registered, mw_list) {
+		list_del_init(&mw->mw_list);
 		list_del_init(&mw->fmr.fm_mr->list);
 		fmr_op_recover_mr(mw);
 	}


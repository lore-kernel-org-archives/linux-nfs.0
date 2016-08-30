Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34447 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756417AbcH3AEh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 20:04:37 -0400
Received: by mail-it0-f66.google.com with SMTP id e63so635008ith.1
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2016 17:04:36 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFSv4.x: Fix a refcount leak in nfs_callback_up_net
Date: Mon, 29 Aug 2016 20:03:47 -0400
Message-Id: <1472515432-54202-2-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
References: <1472515432-54202-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On error, the callers expect us to return without bumping
nn->cb_users[].

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: stable@vger.kernel.org # v3.7+
---
 fs/nfs/callback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index a7f2e6e33305..52a28311e2a4 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -275,6 +275,7 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
 err_socks:
 	svc_rpcb_cleanup(serv, net);
 err_bind:
+	nn->cb_users[minorversion]--;
 	dprintk("NFS: Couldn't create callback socket: err = %d; "
 			"net = %p\n", ret, net);
 	return ret;
-- 
2.7.4


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35299 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdHPQTo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Aug 2017 12:19:44 -0400
Received: by mail-it0-f66.google.com with SMTP id 76so2666917ith.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Aug 2017 09:19:43 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 6/6] NFS: Throttle I/O to the NFS server
Date: Wed, 16 Aug 2017 12:19:29 -0400
Message-Id: <20170816161929.11271-7-trond.myklebust@primarydata.com>
In-Reply-To: <20170816161929.11271-6-trond.myklebust@primarydata.com>
References: <20170816161929.11271-1-trond.myklebust@primarydata.com>
 <20170816161929.11271-2-trond.myklebust@primarydata.com>
 <20170816161929.11271-3-trond.myklebust@primarydata.com>
 <20170816161929.11271-4-trond.myklebust@primarydata.com>
 <20170816161929.11271-5-trond.myklebust@primarydata.com>
 <20170816161929.11271-6-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we do not build up large queues of asynchronous I/O work in the
RPC layer that are not being handled by the socket.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 548ebc7256ff..c9a664730e94 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -625,7 +625,8 @@ int nfs_initiate_pgio(struct rpc_clnt *clnt, struct nfs_pgio_header *hdr,
 		ret = rpc_wait_for_completion_task(task);
 		if (ret == 0)
 			ret = task->tk_status;
-	}
+	} else
+		rpc_wait_for_msg_send(task);
 	rpc_put_task(task);
 out:
 	return ret;
-- 
2.13.5


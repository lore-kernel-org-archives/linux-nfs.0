Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33297 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751944AbdHCNqK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 09:46:10 -0400
Received: by mail-it0-f66.google.com with SMTP id m34so1323700iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 06:46:09 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 28/28] NFS: Throttle I/O to the NFS server
Date: Thu,  3 Aug 2017 09:45:23 -0400
Message-Id: <20170803134523.4922-29-trond.myklebust@primarydata.com>
In-Reply-To: <20170803134523.4922-28-trond.myklebust@primarydata.com>
References: <20170803134523.4922-1-trond.myklebust@primarydata.com>
 <20170803134523.4922-2-trond.myklebust@primarydata.com>
 <20170803134523.4922-3-trond.myklebust@primarydata.com>
 <20170803134523.4922-4-trond.myklebust@primarydata.com>
 <20170803134523.4922-5-trond.myklebust@primarydata.com>
 <20170803134523.4922-6-trond.myklebust@primarydata.com>
 <20170803134523.4922-7-trond.myklebust@primarydata.com>
 <20170803134523.4922-8-trond.myklebust@primarydata.com>
 <20170803134523.4922-9-trond.myklebust@primarydata.com>
 <20170803134523.4922-10-trond.myklebust@primarydata.com>
 <20170803134523.4922-11-trond.myklebust@primarydata.com>
 <20170803134523.4922-12-trond.myklebust@primarydata.com>
 <20170803134523.4922-13-trond.myklebust@primarydata.com>
 <20170803134523.4922-14-trond.myklebust@primarydata.com>
 <20170803134523.4922-15-trond.myklebust@primarydata.com>
 <20170803134523.4922-16-trond.myklebust@primarydata.com>
 <20170803134523.4922-17-trond.myklebust@primarydata.com>
 <20170803134523.4922-18-trond.myklebust@primarydata.com>
 <20170803134523.4922-19-trond.myklebust@primarydata.com>
 <20170803134523.4922-20-trond.myklebust@primarydata.com>
 <20170803134523.4922-21-trond.myklebust@primarydata.com>
 <20170803134523.4922-22-trond.myklebust@primarydata.com>
 <20170803134523.4922-23-trond.myklebust@primarydata.com>
 <20170803134523.4922-24-trond.myklebust@primarydata.com>
 <20170803134523.4922-25-trond.myklebust@primarydata.com>
 <20170803134523.4922-26-trond.myklebust@primarydata.com>
 <20170803134523.4922-27-trond.myklebust@primarydata.com>
 <20170803134523.4922-28-trond.myklebust@primarydata.com>
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
2.13.3


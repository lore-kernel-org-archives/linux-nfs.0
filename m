Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38408 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932144AbdGSWKW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Jul 2017 18:10:22 -0400
Received: by mail-io0-f194.google.com with SMTP id l7so808510iof.5
        for <linux-nfs@vger.kernel.org>; Wed, 19 Jul 2017 15:10:21 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 20/20] NFS: Throttle I/O to the NFS server
Date: Wed, 19 Jul 2017 18:09:55 -0400
Message-Id: <20170719220955.58210-21-trond.myklebust@primarydata.com>
In-Reply-To: <20170719220955.58210-20-trond.myklebust@primarydata.com>
References: <20170719220955.58210-1-trond.myklebust@primarydata.com>
 <20170719220955.58210-2-trond.myklebust@primarydata.com>
 <20170719220955.58210-3-trond.myklebust@primarydata.com>
 <20170719220955.58210-4-trond.myklebust@primarydata.com>
 <20170719220955.58210-5-trond.myklebust@primarydata.com>
 <20170719220955.58210-6-trond.myklebust@primarydata.com>
 <20170719220955.58210-7-trond.myklebust@primarydata.com>
 <20170719220955.58210-8-trond.myklebust@primarydata.com>
 <20170719220955.58210-9-trond.myklebust@primarydata.com>
 <20170719220955.58210-10-trond.myklebust@primarydata.com>
 <20170719220955.58210-11-trond.myklebust@primarydata.com>
 <20170719220955.58210-12-trond.myklebust@primarydata.com>
 <20170719220955.58210-13-trond.myklebust@primarydata.com>
 <20170719220955.58210-14-trond.myklebust@primarydata.com>
 <20170719220955.58210-15-trond.myklebust@primarydata.com>
 <20170719220955.58210-16-trond.myklebust@primarydata.com>
 <20170719220955.58210-17-trond.myklebust@primarydata.com>
 <20170719220955.58210-18-trond.myklebust@primarydata.com>
 <20170719220955.58210-19-trond.myklebust@primarydata.com>
 <20170719220955.58210-20-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we do not build up large queues of asynchronous I/O work in the
RPC layer that are not being handled by the socket.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index af6731dd4324..a5db892c272b 100644
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


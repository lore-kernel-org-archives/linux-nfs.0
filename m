Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:39274 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638Ab3FJOkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Jun 2013 10:40:31 -0400
Subject: [PATCH 3/3] SUNRPC: PipeFS MOUNT notification optimization for dying
	clients
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Mon, 10 Jun 2013 18:40:15 +0400
Message-ID: <20130610144015.7498.92979.stgit@localhost.localdomain>
In-Reply-To: <20130610143725.7498.72391.stgit@localhost.localdomain>
References: <20130610143725.7498.72391.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not need to create pipes for dying client. So just skip them.

Note: we can safely dereference the client structure, because notification
caller is holding sn->pipefs_sb_lock.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org
---
 net/sunrpc/clnt.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 3c133f2..fc4f4d1 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -185,6 +185,8 @@ static inline int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event
 	if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
 	    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
 		return 1;
+	if ((event == RPC_PIPEFS_MOUNT) && atomic_read(&clnt->cl_count) == 0)
+		return 1;
 	return 0;
 }
 


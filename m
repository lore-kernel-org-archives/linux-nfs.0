Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:4381 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647Ab3FXHxJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 03:53:09 -0400
Subject: [PATCH v3 4/4] SUNRPC: PipeFS MOUNT notification optimization for
	dying clients
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Mon, 24 Jun 2013 11:52:59 +0400
Message-ID: <20130624075259.17104.4743.stgit@localhost.localdomain>
In-Reply-To: <20130624075131.17104.55399.stgit@localhost.localdomain>
References: <20130624075131.17104.55399.stgit@localhost.localdomain>
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
index b4f1711..f0339ae 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -177,6 +177,8 @@ static inline int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event
 	if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
 	    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
 		return 1;
+	if ((event == RPC_PIPEFS_MOUNT) && atomic_read(&clnt->cl_count) == 0)
+		return 1;
 	return 0;
 }
 


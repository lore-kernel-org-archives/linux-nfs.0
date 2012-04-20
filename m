Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:43332 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752884Ab2DTOLM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 10:11:12 -0400
Subject: [PATCH v2] SUNRPC: skip dead but not buried clients on PipeFS events
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 20 Apr 2012 18:11:02 +0400
Message-ID: <20120420141042.7205.62608.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2: atomic_inc_return() was replaced by atomic_inc_not_zero().

These clients can't be safely dereferenced if their counter in 0.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6797246..d10ebc4 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -218,7 +218,8 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 		if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
 		    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
 			continue;
-		atomic_inc(&clnt->cl_count);
+		if (atomic_inc_not_zero(&clnt->cl_count) == 0)
+			continue;
 		spin_unlock(&sn->rpc_client_lock);
 		return clnt;
 	}


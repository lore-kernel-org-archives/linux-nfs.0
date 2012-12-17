Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24825 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab2LQRSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 12:18:22 -0500
Subject: [PATCH] SUNRPC: continue run over clients list on PipeFS event
	instead of break
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 17 Dec 2012 20:18:52 +0300
Message-ID: <20121217171852.26922.37774.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are SUNRPC clients, which program doesn't have pipe_dir_name. These
clients can be skipped on PipeFS events, because nothing have to be created or
destroyed. But instead of breaking in case of such a client was found, search
for suitable client over clients list have to be continued. Otherwise some
clients could not be covered by PipeFS event handler.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org [>= v3.4]
---
 net/sunrpc/clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index cdc7564..10b18b2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -234,7 +234,7 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 	spin_lock(&sn->rpc_client_lock);
 	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
 		if (clnt->cl_program->pipe_dir_name == NULL)
-			break;
+			continue;
 		if (rpc_clnt_skip_event(clnt, event))
 			continue;
 		if (atomic_inc_not_zero(&clnt->cl_count) == 0)


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41983 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754372Ab2DTOTa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 10:19:30 -0400
Subject: [PATCH 1/3] SUNRPC: skip clients with program without PipeFS entries
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Fri, 20 Apr 2012 18:19:18 +0400
Message-ID: <20120420141907.10848.74388.stgit@localhost6.localdomain6>
In-Reply-To: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

1) This is sane.
2) Otherwise there will be soft lockup:

do {
	rpc_get_client_for_event (clnt->cl_dentry == NULL ==> choose)
	__rpc_pipefs_event (clnt->cl_program->pipe_dir_name == NULL ==> return)
} while (1)


Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/clnt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d10ebc4..8a19849 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -184,8 +184,6 @@ static int __rpc_pipefs_event(struct rpc_clnt *clnt, unsigned long event,
 
 	switch (event) {
 	case RPC_PIPEFS_MOUNT:
-		if (clnt->cl_program->pipe_dir_name == NULL)
-			break;
 		dentry = rpc_setup_pipedir_sb(sb, clnt,
 					      clnt->cl_program->pipe_dir_name);
 		BUG_ON(dentry == NULL);
@@ -215,6 +213,8 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 
 	spin_lock(&sn->rpc_client_lock);
 	list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
+		if (clnt->cl_program->pipe_dir_name == NULL)
+			break;
 		if (((event == RPC_PIPEFS_MOUNT) && clnt->cl_dentry) ||
 		    ((event == RPC_PIPEFS_UMOUNT) && !clnt->cl_dentry))
 			continue;


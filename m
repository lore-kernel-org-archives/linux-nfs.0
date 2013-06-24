Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:12165 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753096Ab3FXHw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 03:52:56 -0400
Subject: [PATCH v3 2/4] SUNRPC: fix races on PipeFS UMOUNT notifications
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Mon, 24 Jun 2013 11:52:45 +0400
Message-ID: <20130624075245.17104.6279.stgit@localhost.localdomain>
In-Reply-To: <20130624075131.17104.55399.stgit@localhost.localdomain>
References: <20130624075131.17104.55399.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CPU#0                                   CPU#1
-----------------------------           -----------------------------
rpc_kill_sb
sn->pipefs_sb = NULL                    rpc_release_client
(UMOUNT_EVENT)                          rpc_free_auth
rpc_pipefs_event
rpc_get_client_for_event
!atomic_inc_not_zero(cl_count)
<skip the client>
                                        atomic_inc(cl_count)
                                        rpc_free_client
                                        rpc_clnt_remove_pipedir
                                        <skip client dir removing>

To fix this, this patch does the following:

1) Calls RPC_PIPEFS_UMOUNT notification with sn->pipefs_sb_lock being held.
2) Removes SUNRPC client from the list AFTER pipes destroying.
3) Doesn't hold RPC client on notification: if client in the list, then it
can't be destroyed while sn->pipefs_sb_lock in hold by notification caller.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: stable@vger.kernel.org
---
 net/sunrpc/clnt.c     |    5 +----
 net/sunrpc/rpc_pipe.c |    2 +-
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b827a4b..41f180c 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -236,8 +236,6 @@ static struct rpc_clnt *rpc_get_client_for_event(struct net *net, int event)
 			continue;
 		if (rpc_clnt_skip_event(clnt, event))
 			continue;
-		if (atomic_inc_not_zero(&clnt->cl_count) == 0)
-			continue;
 		spin_unlock(&sn->rpc_client_lock);
 		return clnt;
 	}
@@ -254,7 +252,6 @@ static int rpc_pipefs_event(struct notifier_block *nb, unsigned long event,
 
 	while ((clnt = rpc_get_client_for_event(sb->s_fs_info, event))) {
 		error = __rpc_pipefs_event(clnt, event, sb);
-		rpc_release_client(clnt);
 		if (error)
 			break;
 	}
@@ -641,8 +638,8 @@ rpc_free_client(struct rpc_clnt *clnt)
 			rcu_dereference(clnt->cl_xprt)->servername);
 	if (clnt->cl_parent != clnt)
 		rpc_release_client(clnt->cl_parent);
-	rpc_unregister_client(clnt);
 	rpc_clnt_remove_pipedir(clnt);
+	rpc_unregister_client(clnt);
 	rpc_free_iostats(clnt->cl_metrics);
 	kfree(clnt->cl_principal);
 	clnt->cl_metrics = NULL;
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index c512448..efca2f7 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1165,7 +1165,6 @@ static void rpc_kill_sb(struct super_block *sb)
 		goto out;
 	}
 	sn->pipefs_sb = NULL;
-	mutex_unlock(&sn->pipefs_sb_lock);
 	dprintk("RPC:       sending pipefs UMOUNT notification for net %p%s\n",
 		net, NET_NAME(net));
 	blocking_notifier_call_chain(&rpc_pipefs_notifier_list,
@@ -1173,6 +1172,7 @@ static void rpc_kill_sb(struct super_block *sb)
 					   sb);
 	put_net(net);
 out:
+	mutex_unlock(&sn->pipefs_sb_lock);
 	kill_litter_super(sb);
 }
 


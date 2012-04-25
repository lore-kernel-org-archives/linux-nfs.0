Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33787 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759222Ab2DYOW4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 10:22:56 -0400
Subject: [PATCH 1/6] LockD: pass service to per-net up and down functions
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 18:22:40 +0400
Message-ID: <20120425142240.22909.50321.stgit@localhost6.localdomain6>
In-Reply-To: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 3250f28..58ddc38 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -251,10 +251,9 @@ out_err:
 	return err;
 }
 
-static int lockd_up_net(struct net *net)
+static int lockd_up_net(struct svc_serv *serv, struct net *net)
 {
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
-	struct svc_serv *serv = nlmsvc_rqst->rq_server;
 	int error;
 
 	if (ln->nlmsvc_users++)
@@ -276,10 +275,9 @@ err_rpcb:
 	return error;
 }
 
-static void lockd_down_net(struct net *net)
+static void lockd_down_net(struct svc_serv *serv, struct net *net)
 {
 	struct lockd_net *ln = net_generic(net, lockd_net_id);
-	struct svc_serv *serv = nlmsvc_rqst->rq_server;
 
 	if (ln->nlmsvc_users) {
 		if (--ln->nlmsvc_users == 0) {
@@ -307,7 +305,7 @@ int lockd_up(struct net *net)
 	 * Check whether we're already up and running.
 	 */
 	if (nlmsvc_rqst) {
-		error = lockd_up_net(net);
+		error = lockd_up_net(nlmsvc_rqst->rq_server, net);
 		goto out;
 	}
 
@@ -378,7 +376,7 @@ out:
 	return error;
 
 err_start:
-	lockd_down_net(net);
+	lockd_down_net(serv, net);
 	goto destroy_and_out;
 }
 EXPORT_SYMBOL_GPL(lockd_up);
@@ -390,7 +388,7 @@ void
 lockd_down(struct net *net)
 {
 	mutex_lock(&nlmsvc_mutex);
-	lockd_down_net(net);
+	lockd_down_net(nlmsvc_rqst->rq_server, net);
 	if (nlmsvc_users) {
 		if (--nlmsvc_users)
 			goto out;


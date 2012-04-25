Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:35139 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753630Ab2DYOX1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 10:23:27 -0400
Subject: [PATCH 6/6] LockD: add debug message to start and stop functions
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 18:23:16 +0400
Message-ID: <20120425142316.22909.17901.stgit@localhost6.localdomain6>
In-Reply-To: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
References: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index b47bf77..80938fd 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -266,6 +266,7 @@ static int lockd_up_net(struct svc_serv *serv, struct net *net)
 	error = make_socks(serv, net);
 	if (error < 0)
 		goto err_socks;
+	dprintk("lockd_up_net: per-net data created; net=%p\n", net);
 	return 0;
 
 err_socks:
@@ -283,6 +284,7 @@ static void lockd_down_net(struct svc_serv *serv, struct net *net)
 		if (--ln->nlmsvc_users == 0) {
 			nlm_shutdown_hosts_net(net);
 			svc_shutdown_net(serv, net);
+			dprintk("lockd_down_net: per-net data destroyed; net=%p\n", net);
 		}
 	} else {
 		printk(KERN_ERR "lockd_down_net: no users! task=%p, net=%p\n",
@@ -360,6 +362,7 @@ static struct svc_serv *lockd_create_svc(void)
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		return ERR_PTR(-ENOMEM);
 	}
+	dprintk("lockd_up: service created\n");
 	return serv;
 }
 
@@ -426,7 +429,9 @@ lockd_down(struct net *net)
 		BUG();
 	}
 	kthread_stop(nlmsvc_task);
+	dprintk("lockd_down: service stopped\n");
 	svc_exit_thread(nlmsvc_rqst);
+	dprintk("lockd_down: service destroyed\n");
 	nlmsvc_task = NULL;
 	nlmsvc_rqst = NULL;
 out:


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:43264 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973AbaKSMvp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:45 -0500
Received: by mail-qg0-f43.google.com with SMTP id q108so323314qgd.30
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:44 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 10/10] sunrpc: require svc_create callers to pass in meaningful shutdown routine
Date: Wed, 19 Nov 2014 07:51:22 -0500
Message-Id: <1416401482-2562-11-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently all svc_create callers pass in NULL for the shutdown parm,
which then gets fixed up to be svc_rpcb_cleanup if the service uses
rpcbind.

Simplify this by instead having the the only caller that requires it
(lockd) pass in svc_rpcb_cleanup and get rid of the special casing.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/lockd/svc.c   | 2 +-
 net/sunrpc/svc.c | 3 ---
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index d1bb7ecfd201..e94c887da2d7 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -350,7 +350,7 @@ static struct svc_serv *lockd_create_svc(void)
 		printk(KERN_WARNING
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, svc_rpcb_cleanup);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		return ERR_PTR(-ENOMEM);
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 34019ee9eaa1..5d9a443d21f6 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -482,9 +482,6 @@ __svc_create(struct svc_program *prog, unsigned int bufsize, int npools,
 		spin_lock_init(&pool->sp_lock);
 	}
 
-	if (svc_uses_rpcbind(serv) && (!serv->sv_shutdown))
-		serv->sv_shutdown = svc_rpcb_cleanup;
-
 	return serv;
 }
 
-- 
2.1.0


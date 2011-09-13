Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:45642 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756184Ab1IMSO3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:14:29 -0400
Subject: [PATCH v3 06/11] Lockd: force creation of rpcbind clients during
	service creation
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:14:06 +0400
Message-ID: <20110913181406.3961.94003.stgit@localhost6.localdomain6>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Lockd sends requests to portmapper and thus requires rpcbind clients.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/lockd/svc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index abfff9d..bdf79dc 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -269,7 +269,7 @@ int lockd_up(void)
 			"lockd_up: no pid, %d users??\n", nlmsvc_users);
 
 	error = -ENOMEM;
-	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, NULL);
+	serv = svc_create(&nlmsvc_program, LOCKD_BUFSIZE, 1, NULL);
 	if (!serv) {
 		printk(KERN_WARNING "lockd_up: create service failed\n");
 		goto out;


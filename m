Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:2640 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932161Ab1IMSOu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Sep 2011 14:14:50 -0400
Subject: [PATCH v3 09/11] NFSd: call svc rpcbind cleanup explicitly
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Tue, 13 Sep 2011 22:14:29 +0400
Message-ID: <20110913181429.3961.38089.stgit@localhost6.localdomain6>
In-Reply-To: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
References: <20110913180953.3961.69217.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We have to call svc_rpcb_cleanup() explicitly from nfsd_last_thread() since
this function is registered as service shutdown callback and thus nobody else
will done it for us.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfssvc.c           |    2 ++
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc.c           |    3 ++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 88faab8..fe14cd2 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -256,6 +256,8 @@ static void nfsd_last_thread(struct svc_serv *serv)
 	nfsd_serv = NULL;
 	nfsd_shutdown();
 
+	svc_rpcb_cleanup(serv);
+
 	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
 			    "cache\n");
 	nfsd_export_flush();
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 528952a..35fa9ca 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -401,6 +401,7 @@ struct svc_procedure {
 /*
  * Function prototypes.
  */
+void svc_rpcb_cleanup(struct svc_serv *serv);
 struct svc_serv *svc_create(struct svc_program *, unsigned int,
 			    int setup_rpcbind,
 			    void (*shutdown)(struct svc_serv *));
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 1bf1b1a..71dd439 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -367,11 +367,12 @@ static int svc_rpcb_setup(struct svc_serv *serv)
 	return 0;
 }
 
-static void svc_rpcb_cleanup(struct svc_serv *serv)
+void svc_rpcb_cleanup(struct svc_serv *serv)
 {
 	svc_unregister(serv);
 	rpcb_put_local();
 }
+EXPORT_SYMBOL_GPL(svc_rpcb_cleanup);
 
 /*
  * Create an RPC service


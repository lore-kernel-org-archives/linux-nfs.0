Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:47274 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932628Ab1JYKQu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 06:16:50 -0400
Subject: [PATCH v6 5/8] SUNRPC: cleanup service destruction
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Tue, 25 Oct 2011 14:17:18 +0300
Message-ID: <20111025101716.12689.81697.stgit@localhost6.localdomain6>
In-Reply-To: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_unregister() call have to be removed from svc_destroy() since it will be
called in sv_shutdown callback.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/svc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 918edc3..407462f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -530,7 +530,6 @@ svc_destroy(struct svc_serv *serv)
 	if (svc_serv_is_pooled(serv))
 		svc_pool_map_put();
 
-	svc_unregister(serv);
 	kfree(serv->sv_pools);
 	kfree(serv);
 }


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33829 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757300Ab1LWOyI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Dec 2011 09:54:08 -0500
Subject: [PATCH 1/3] SUNPRC: remove marking service temporary sockets with
 XPT_CHNGBUF
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Fri, 23 Dec 2011 18:53:33 +0300
Message-ID: <20111223145333.847.8290.stgit@localhost6.localdomain6>
In-Reply-To: <20111223145145.847.46221.stgit@localhost6.localdomain6>
References: <20111223145145.847.46221.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch.
Temporary sockets can be TCP only. But XPT_CHNGBUF service socket flag is
checked only for UDP sockets on receive.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/svcsock.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 110735f..72b05f2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1381,8 +1381,6 @@ void svc_sock_update_bufs(struct svc_serv *serv)
 	spin_lock_bh(&serv->sv_lock);
 	list_for_each_entry(svsk, &serv->sv_permsocks, sk_xprt.xpt_list)
 		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
-	list_for_each_entry(svsk, &serv->sv_tempsocks, sk_xprt.xpt_list)
-		set_bit(XPT_CHNGBUF, &svsk->sk_xprt.xpt_flags);
 	spin_unlock_bh(&serv->sv_lock);
 }
 EXPORT_SYMBOL_GPL(svc_sock_update_bufs);


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29368 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756281Ab2AXRE3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jan 2012 12:04:29 -0500
Subject: [PATCH] NFS: don't mark freshly created callback sockets with
 XPT_CHNGBUF
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 24 Jan 2012 21:04:11 +0400
Message-ID: <20120124170411.22663.6138.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch.
Check for XPT_CHNGBUF is done only for UPD sockets. NFS callbacks doesn't use
them.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index d81040a..1bf3e9f 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -278,8 +278,6 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
 		goto out_err;
 	}
 
-	svc_sock_update_bufs(serv);
-
 	sprintf(svc_name, "nfsv4.%u-svc", minorversion);
 	cb_info->serv = serv;
 	cb_info->rqst = rqstp;


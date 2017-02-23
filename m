Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34260 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751889AbdBWRDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 12:03:41 -0500
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org, trond.myklebust@primarydata.com
Cc: schumaker.anna@gmail.com, linux-nfs@vger.kernel.org
Subject: [PATCH 4/4] sunrpc: don't register UDP port with rpcbind when version needs congestion control
Date: Thu, 23 Feb 2017 12:03:37 -0500
Message-Id: <20170223170337.10686-5-jlayton@redhat.com>
In-Reply-To: <20170223170337.10686-1-jlayton@redhat.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 028c91a07950..984f1e73722f 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -976,6 +976,13 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 			if (vers->vs_hidden)
 				continue;
 
+			/*
+			 * Don't register a UDP port if we need congestion
+			 * control.
+			 */
+			if (vers->vs_need_cong_ctrl && proto == IPPROTO_UDP)
+				continue;
+
 			error = __svc_register(net, progp->pg_name, progp->pg_prog,
 						i, family, proto, port);
 
-- 
2.9.3


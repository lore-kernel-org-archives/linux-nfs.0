Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15992 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698Ab2JPQbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 12:31:39 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 21/25] SUNRPC: remove BUG_ON() in svc_register()
Date: Tue, 16 Oct 2012 12:30:39 -0400
Message-Id: <1350405043-39316-21-git-send-email-dros@netapp.com>
In-Reply-To: <1350405043-39316-1-git-send-email-dros@netapp.com>
References: <1350405043-39316-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of calling BUG_ON() return -EINVAL.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/svc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3bf5a54..b5ac8b3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -950,7 +950,8 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 	unsigned int		i;
 	int			error = 0;
 
-	BUG_ON(proto == 0 && port == 0);
+	if (proto == 0 && port == 0)
+		return -EINVAL;
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
-- 
1.7.9.6 (Apple Git-31.1)


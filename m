Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:52206 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757154Ab2JWOxf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Oct 2012 10:53:35 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 21/25] SUNRPC: remove BUG_ON in svc_register
Date: Tue, 23 Oct 2012 10:43:45 -0400
Message-Id: <1351003429-18887-22-git-send-email-dros@netapp.com>
In-Reply-To: <1351003429-18887-1-git-send-email-dros@netapp.com>
References: <1351003429-18887-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of calling BUG_ON(), do a WARN_ON_ONCE() and return -EINVAL.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 net/sunrpc/svc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 3bf5a54..dfa4ba6 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -950,7 +950,9 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 	unsigned int		i;
 	int			error = 0;
 
-	BUG_ON(proto == 0 && port == 0);
+	WARN_ON_ONCE(proto == 0 && port == 0);
+	if (proto == 0 && port == 0)
+		return -EINVAL;
 
 	for (progp = serv->sv_program; progp; progp = progp->pg_next) {
 		for (i = 0; i < progp->pg_nvers; i++) {
-- 
1.7.9.6 (Apple Git-31.1)


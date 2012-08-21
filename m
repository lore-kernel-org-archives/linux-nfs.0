Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46793 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752382Ab2HUU5f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 16:57:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 03/14] svcrpc: make svc_create_xprt enqueue on clearing XPT_BUSY
Date: Tue, 21 Aug 2012 16:57:21 -0400
Message-Id: <1345582652-18476-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1345582652-18476-1-git-send-email-bfields@redhat.com>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The rule is that whever we clear XPT_BUSY we should call
svc_xprt_enqueue().  Without that we may fail to notice any events (such
as new connections) that arrived while XPT_BUSY was set.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index e1810b9..4801fda 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -238,7 +238,7 @@ int svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
 		list_add(&newxprt->xpt_list, &serv->sv_permsocks);
 		spin_unlock_bh(&serv->sv_lock);
 		newport = svc_xprt_local_port(newxprt);
-		clear_bit(XPT_BUSY, &newxprt->xpt_flags);
+		svc_xprt_received(newxprt);
 		return newport;
 	}
  err:
-- 
1.7.9.5


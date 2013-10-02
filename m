Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39263 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189Ab3JBNsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 09:48:18 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] sunrpc: comment typo fix
Date: Wed,  2 Oct 2013 09:48:15 -0400
Message-Id: <1380721695-14755-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1380721695-14755-1-git-send-email-bfields@redhat.com>
References: <1380721695-14755-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprtsock.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ee03d35..940d723 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2859,8 +2859,8 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	if (args->bc_xprt->xpt_bc_xprt) {
 		/*
 		 * This server connection already has a backchannel
-		 * export; we can't create a new one, as we wouldn't be
-		 * able to match replies based on xid any more.  So,
+		 * transport; we can't create a new one, as we wouldn't
+		 * be able to match replies based on xid any more.  So,
 		 * reuse the already-existing one:
 		 */
 		 return args->bc_xprt->xpt_bc_xprt;
-- 
1.7.9.5


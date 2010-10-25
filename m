Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54546 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495Ab0JYBVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 21:21:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: neilb@suse.de, Menyhart Zoltan <Zoltan.Menyhart@bull.net>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] svcrpc: assume svc_delete_xprt() called only once
Date: Sun, 24 Oct 2010 21:21:31 -0400
Message-Id: <1287969693-12340-2-git-send-email-bfields@redhat.com>
In-Reply-To: <20101025010923.GB11470@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

As long as DEAD exports are left BUSY, and svc_delete_xprt is called
only with BUSY held, then svc_delete_xprt() will never be called on an
xprt that is already DEAD.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index db90e4d..409881a 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -903,7 +903,7 @@ void svc_delete_xprt(struct svc_xprt *xprt)
 
 	/* Only do this once */
 	if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
-		return;
+		BUG();
 
 	dprintk("svc: svc_delete_xprt(%p)\n", xprt);
 	xprt->xpt_ops->xpo_detach(xprt);
-- 
1.7.1


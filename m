Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751407Ab0JYBVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 24 Oct 2010 21:21:42 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: neilb@suse.de, Menyhart Zoltan <Zoltan.Menyhart@bull.net>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/4] svcrpc: never clear XPT_BUSY on dead xprt
Date: Sun, 24 Oct 2010 21:21:30 -0400
Message-Id: <1287969693-12340-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20101025010923.GB11470@fieldses.org>
References: <20101025010923.GB11470@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Once an xprt has been deleted, there's no reason to allow it to be
enqueued--at worst, that might cause the xprt to be re-added to some
global list, resulting in later corruption.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svc_xprt.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index bef1e88..db90e4d 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -938,7 +938,6 @@ void svc_close_xprt(struct svc_xprt *xprt)
 
 	svc_xprt_get(xprt);
 	svc_delete_xprt(xprt);
-	clear_bit(XPT_BUSY, &xprt->xpt_flags);
 	svc_xprt_put(xprt);
 }
 EXPORT_SYMBOL_GPL(svc_close_xprt);
-- 
1.7.1


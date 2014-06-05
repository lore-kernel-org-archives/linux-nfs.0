Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58356 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbaFENs2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2014 09:48:28 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] xdr_rejected_reply: Don't crash with invalid server rejection
Date: Thu,  5 Jun 2014 09:48:16 -0400
Message-Id: <1401976096-16802-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It seems legacy servers like to return invalid
rejection status when a RPC is rejected. This
should not crash the app then it happens.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpc_prot.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/src/rpc_prot.c b/src/rpc_prot.c
index e562deb..5841e51 100644
--- a/src/rpc_prot.c
+++ b/src/rpc_prot.c
@@ -150,7 +150,6 @@ xdr_rejected_reply(xdrs, rr)
 		return (xdr_enum(xdrs, (enum_t *)&(rr->rj_why)));
 	}
 	/* NOTREACHED */
-	assert(0);
 	return (FALSE);
 }
 
-- 
1.9.0


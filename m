Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39266 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754189Ab3JBNsT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 09:48:19 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/2] rpc: change BUG to WARN in gss_encode_v1_msg
Date: Wed,  2 Oct 2013 09:48:14 -0400
Message-Id: <1380721695-14755-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Failure of this assertion would indeed be serious, but as we've seen a
BUG() in a worker thread (this can run from rpciod context) can screw up
the system so badly that the oops doesn't even get to the logs; better
to WARN() and soldier on.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 0846566..254a9f0 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -454,7 +454,7 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 	gss_msg->msg.len += len;
 
 	gss_msg->msg.data = gss_msg->databuf;
-	BUG_ON(gss_msg->msg.len > UPCALL_BUF_LEN);
+	WARN_ON_ONCE(gss_msg->msg.len > UPCALL_BUF_LEN);
 }
 
 static struct gss_upcall_msg *
-- 
1.7.9.5


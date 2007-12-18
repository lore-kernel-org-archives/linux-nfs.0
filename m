From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 3/7] SUNRPC: export svc_sock_update_bufs
Date: Tue, 18 Dec 2007 15:19:38 -0500
Message-ID: <1198009182-27895-4-git-send-email-jlayton@redhat.com>
References: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
 <1198009182-27895-2-git-send-email-jlayton@redhat.com>
 <1198009182-27895-3-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751715AbXLRUTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2007 15:19:44 -0500
In-Reply-To: <1198009182-27895-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Needed since the plan is to not have a svc_create_thread helper and to
have current users of that function just call kthread_run directly.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/sunrpc_syms.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 27bb185..618e84b 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -79,6 +79,7 @@ EXPORT_SYMBOL(svc_auth_register);
 EXPORT_SYMBOL(auth_domain_lookup);
 EXPORT_SYMBOL(svc_authenticate);
 EXPORT_SYMBOL(svc_set_client);
+EXPORT_SYMBOL(svc_sock_update_bufs);
 
 /* RPC statistics */
 #ifdef CONFIG_PROC_FS
-- 
1.5.3.3


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49858 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853Ab3HANR1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 09:17:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 3/4] svcrpc: fix kfree oops in gss-proxy code
Date: Thu,  1 Aug 2013 09:17:21 -0400
Message-Id: <1375363042-14440-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1375363042-14440-1-git-send-email-bfields@redhat.com>
References: <1375363042-14440-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

mech_oid.data is an array, not kmalloc()'d memory.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index 1e1ccf5..af7ffd4 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -328,7 +328,6 @@ void gssp_free_upcall_data(struct gssp_upcall_data *data)
 	kfree(data->in_handle.data);
 	kfree(data->out_handle.data);
 	kfree(data->out_token.data);
-	kfree(data->mech_oid.data);
 	free_svc_cred(&data->creds);
 }
 
-- 
1.7.9.5


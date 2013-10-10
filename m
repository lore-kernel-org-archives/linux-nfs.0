Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456Ab3JJPPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Oct 2013 11:15:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, Simo Sorce <simo@redhat.com>
Subject: [PATCH 1/4] svcrpc: fix gss-proxy NULL dereference in some error cases
Date: Thu, 10 Oct 2013 11:15:00 -0400
Message-Id: <1381418103-3852-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1381418103-3852-1-git-send-email-bfields@redhat.com>
References: <1381418103-3852-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

We depend on the xdr decoder to set this pointer, but if we error out
before we decode this piece it could be left NULL.

I think this is probably tough to hit without a buggy gss-proxy.

Reported-by: Andi Kleen <andi@firstfloor.org>
Cc: Simo Sorce <simo@redhat.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index f1eb0d1..458f85e 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -298,7 +298,8 @@ int gssp_accept_sec_context_upcall(struct net *net,
 	if (res.context_handle) {
 		data->out_handle = rctxh.exported_context_token;
 		data->mech_oid.len = rctxh.mech.len;
-		memcpy(data->mech_oid.data, rctxh.mech.data,
+		if (rctxh.mech.data)
+			memcpy(data->mech_oid.data, rctxh.mech.data,
 						data->mech_oid.len);
 		client_name = rctxh.src_name.display_name;
 	}
-- 
1.7.9.5


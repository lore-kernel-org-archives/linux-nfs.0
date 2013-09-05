Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37204 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753851Ab3IEPto (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Sep 2013 11:49:44 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] rpc: let xdr layer allocate gssproxy receieve pages
Date: Thu,  5 Sep 2013 11:49:33 -0400
Message-Id: <1378396173-22352-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1378396173-22352-1-git-send-email-bfields@redhat.com>
References: <1378396173-22352-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In theory the linux cred in a gssproxy reply can include up to
NGROUPS_MAX data, 256K of data.  In the common case we expect it to be
shorter.  So do as the nfsv3 ACL code does and let the xdr code allocate
the pages as they come in, instead of allocating a lot of pages that
won't typically be used.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_upcall.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
index be95af3..f1eb0d1 100644
--- a/net/sunrpc/auth_gss/gss_rpc_upcall.c
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -223,18 +223,14 @@ static void gssp_free_receive_pages(struct gssx_arg_accept_sec_context *arg)
 
 static int gssp_alloc_receive_pages(struct gssx_arg_accept_sec_context *arg)
 {
-	int i;
-
 	arg->npages = DIV_ROUND_UP(NGROUPS_MAX * 4, PAGE_SIZE);
 	arg->pages = kzalloc(arg->npages * sizeof(struct page *), GFP_KERNEL);
-
-	for (i=0; i < arg->npages; i++) {
-		arg->pages[i] = alloc_page(GFP_KERNEL);
-		if (arg->pages[i] == NULL) {
-			gssp_free_receive_pages(arg);
-			return -ENOMEM;
-		}
-	}
+	/*
+	 * XXX: actual pages are allocated by xdr layer in
+	 * xdr_partial_copy_from_skb.
+	 */
+	if (!arg->pages)
+		return -ENOMEM;
 	return 0;
 }
 
-- 
1.7.9.5


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49856 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754125Ab3HANR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 09:17:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 2/4] svcrpc: fix gss-proxy xdr decoding oops
Date: Thu,  1 Aug 2013 09:17:20 -0400
Message-Id: <1375363042-14440-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1375363042-14440-1-git-send-email-bfields@redhat.com>
References: <1375363042-14440-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Uninitialized stack data was being used as the destination for memcpy's.

Longer term we'll just delete some of this code; all we're doing is
skipping over xdr that we don't care about.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/auth_gss/gss_rpc_xdr.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
index 357f613..3c85d1c 100644
--- a/net/sunrpc/auth_gss/gss_rpc_xdr.c
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -430,7 +430,7 @@ static int dummy_enc_nameattr_array(struct xdr_stream *xdr,
 static int dummy_dec_nameattr_array(struct xdr_stream *xdr,
 				    struct gssx_name_attr_array *naa)
 {
-	struct gssx_name_attr dummy;
+	struct gssx_name_attr dummy = { .attr = {.len = 0} };
 	u32 count, i;
 	__be32 *p;
 
@@ -493,12 +493,13 @@ static int gssx_enc_name(struct xdr_stream *xdr,
 	return err;
 }
 
+
 static int gssx_dec_name(struct xdr_stream *xdr,
 			 struct gssx_name *name)
 {
-	struct xdr_netobj dummy_netobj;
-	struct gssx_name_attr_array dummy_name_attr_array;
-	struct gssx_option_array dummy_option_array;
+	struct xdr_netobj dummy_netobj = { .len = 0 };
+	struct gssx_name_attr_array dummy_name_attr_array = { .count = 0 };
+	struct gssx_option_array dummy_option_array = { .count = 0 };
 	int err;
 
 	/* name->display_name */
-- 
1.7.9.5


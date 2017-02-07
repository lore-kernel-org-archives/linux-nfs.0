Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34379 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753825AbdBGNqu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:46:50 -0500
Received: by mail-io0-f193.google.com with SMTP id c80so12849543iod.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:46:50 -0800 (PST)
Subject: [PATCH 1/7] sunrpc: error out if register_shrinker fail
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
References: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <03bfbff3-958a-0ae9-fbd9-1eba53fa1735@gmail.com>
Date: Tue, 7 Feb 2017 21:46:39 +0800
MIME-Version: 1.0
In-Reply-To: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

register_shrinker may return error when register fail, error out.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 net/sunrpc/auth.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index a7d03ea..4aa6ef1 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -873,8 +873,12 @@ int __init rpcauth_init_module(void)
 	err = rpc_init_generic_auth();
 	if (err < 0)
 		goto out2;
-	register_shrinker(&rpc_cred_shrinker);
+	err = register_shrinker(&rpc_cred_shrinker);
+	if (err < 0)
+		goto out3;
 	return 0;
+out3:
+	rpc_destroy_generic_auth();
 out2:
 	rpc_destroy_authunix();
 out1:
-- 
2.9.3


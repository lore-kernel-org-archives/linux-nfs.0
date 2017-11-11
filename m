Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout02.posteo.de ([185.67.36.66]:48247 "EHLO mout02.posteo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751757AbdKKSz7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 11 Nov 2017 13:55:59 -0500
Received: from submission (posteo.de [89.146.220.130])
        by mout02.posteo.de (Postfix) with ESMTPS id E3D0B20BA6
        for <linux-nfs@vger.kernel.org>; Sat, 11 Nov 2017 19:55:57 +0100 (CET)
Date: Sat, 11 Nov 2017 13:54:54 -0500
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] libtirpc.map: fix misspelled symbol key_secretkey_is_set
Message-ID: <20171111185454.GA30165@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 src/libtirpc.map | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/src/libtirpc.map b/src/libtirpc.map
index f385de5..21d6065 100644
--- a/src/libtirpc.map
+++ b/src/libtirpc.map
@@ -298,7 +298,7 @@ TIRPC_0.3.2 {
     key_gendes;
     key_get_conv;
     key_setsecret;
-    key_secret_is_set;
+    key_secretkey_is_set;
     key_setnet;
     netname2host;
     netname2user;
-- 
2.13.6

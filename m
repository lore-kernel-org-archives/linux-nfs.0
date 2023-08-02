Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81FA3C001DF
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Aug 2023 08:06:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232713AbjHBIG1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Aug 2023 04:06:27 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33402 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232756AbjHBIG0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Aug 2023 04:06:26 -0400
Received: from mail.nfschina.com (unknown [42.101.60.195])
        by lindbergh.monkeyblade.net (Postfix) with SMTP id 8F516F7;
        Wed,  2 Aug 2023 01:06:23 -0700 (PDT)
Received: from localhost.localdomain (unknown [180.167.10.98])
        by mail.nfschina.com (Maildata Gateway V2.8.8) with ESMTPA id A65DE606AC671;
        Wed,  2 Aug 2023 16:06:10 +0800 (CST)
X-MD-Sfrom: suhui@nfschina.com
X-MD-SrcIP: 180.167.10.98
From:   Su Hui <suhui@nfschina.com>
To:     chuck.lever@oracle.com, jlayton@kernel.org, neilb@suse.de,
        kolga@netapp.com, Dai.Ngo@oracle.com, tom@talpey.com,
        trond.myklebust@hammerspace.com, anna@kernel.org,
        nathan@kernel.org, ndesaulniers@google.com, trix@redhat.com
Cc:     bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, llvm@lists.linux.dev,
        kernel-janitors@vger.kernel.org, Su Hui <suhui@nfschina.com>
Subject: [PATCH] fs: lockd: avoid possible wrong NULL parameter
Date:   Wed,  2 Aug 2023 16:05:45 +0800
Message-Id: <20230802080544.3239967-1-suhui@nfschina.com>
X-Mailer: git-send-email 2.30.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

clang's static analysis warning: fs/lockd/mon.c: line 293, column 2:
Null pointer passed as 2nd argument to memory copy function.

Assuming 'hostname' is NULL and calling 'nsm_create_handle()', this will
pass NULL as 2nd argument to memory copy function 'memcpy()'. So return
NULL if 'hostname' is invalid.

Fixes: 77a3ef33e2de ("NSM: More clean up of nsm_get_handle()")
Signed-off-by: Su Hui <suhui@nfschina.com>
---
 fs/lockd/mon.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 1d9488cf0534..eebab013e063 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -358,6 +358,9 @@ struct nsm_handle *nsm_get_handle(const struct net *net,
 
 	spin_unlock(&nsm_lock);
 
+	if (!hostname)
+		return NULL;
+
 	new = nsm_create_handle(sap, salen, hostname, hostname_len);
 	if (unlikely(new == NULL))
 		return NULL;
-- 
2.30.2


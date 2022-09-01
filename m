Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FF91ECAAD2
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Sep 2022 05:27:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233026AbiIAF1a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Sep 2022 01:27:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37256 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233033AbiIAF11 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Sep 2022 01:27:27 -0400
Received: from smtp.smtpout.orange.fr (smtp04.smtpout.orange.fr [80.12.242.126])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C0A1713287B
        for <linux-nfs@vger.kernel.org>; Wed, 31 Aug 2022 22:27:23 -0700 (PDT)
Received: from pop-os.home ([90.11.190.129])
        by smtp.orange.fr with ESMTPA
        id TcjYoNolFez1rTcjZop1CC; Thu, 01 Sep 2022 07:27:21 +0200
X-ME-Helo: pop-os.home
X-ME-Auth: Y2hyaXN0b3BoZS5qYWlsbGV0QHdhbmFkb28uZnI=
X-ME-Date: Thu, 01 Sep 2022 07:27:21 +0200
X-ME-IP: 90.11.190.129
From:   Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
        Christophe JAILLET <christophe.jaillet@wanadoo.fr>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/3] nfsd: Propagate some error code returned by memdup_user()
Date:   Thu,  1 Sep 2022 07:27:19 +0200
Message-Id: <d8af52e13f53dcb14d72486d6ac92607d5f42716.1662009844.git.christophe.jaillet@wanadoo.fr>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <14d802144c88da0eb9e201b3acbf4bde376b2473.1662009844.git.christophe.jaillet@wanadoo.fr>
References: <14d802144c88da0eb9e201b3acbf4bde376b2473.1662009844.git.christophe.jaillet@wanadoo.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Propagate the error code returned by memdup_user() instead of a hard coded
-EFAULT.

Suggested-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
This patch is speculative. The whole call chains have not been checked to
see if there was no path explicitly expecting a -EFAULT.
---
 fs/nfsd/nfs4recover.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 2968cf604e3b..78b8cd9651d5 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -808,7 +808,7 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 				return -EFAULT;
 			name.data = memdup_user(&ci->cc_name.cn_id, namelen);
 			if (IS_ERR(name.data))
-				return -EFAULT;
+				return PTR_ERR(name.data);
 			name.len = namelen;
 			get_user(princhashlen, &ci->cc_princhash.cp_len);
 			if (princhashlen > 0) {
@@ -817,7 +817,7 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 						princhashlen);
 				if (IS_ERR(princhash.data)) {
 					kfree(name.data);
-					return -EFAULT;
+					return PTR_ERR(princhash.data);
 				}
 				princhash.len = princhashlen;
 			} else
@@ -830,7 +830,7 @@ __cld_pipe_inprogress_downcall(const struct cld_msg_v2 __user *cmsg,
 				return -EFAULT;
 			name.data = memdup_user(&cnm->cn_id, namelen);
 			if (IS_ERR(name.data))
-				return -EFAULT;
+				return PTR_ERR(name.data);
 			name.len = namelen;
 		}
 		if (name.len > 5 && memcmp(name.data, "hash:", 5) == 0) {
-- 
2.34.1


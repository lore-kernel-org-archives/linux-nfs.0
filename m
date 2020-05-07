Return-Path: <SRS0=BdmX=6V=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2E2EC47247
	for <linux-nfs@archiver.kernel.org>; Thu,  7 May 2020 14:33:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B4482218AC
	for <linux-nfs@archiver.kernel.org>; Thu,  7 May 2020 14:33:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1588861980;
	bh=cqW4Z+247hzHb4dini1qWArrhk5IzoBlZfzZ1WrIoo0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=w1++MNdggSAcluVHotEZzeXCOZwvwpSzzCv6FJNKznBJNHZWf4et3isP4d2B+UhOX
	 yt/4ftDUhhhnoIArAgTTPKRx7FeSCc0Ff2Gc2Ih11a6FaCh7+AHPVRYhWniC09mp8r
	 8VS29p0w2MRo3T9P1uHDVmyWVwveIPoCR44tP/n4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728547AbgEGOct (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 May 2020 10:32:49 -0400
Received: from mail.kernel.org ([198.145.29.99]:57896 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728663AbgEGO3q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 May 2020 10:29:46 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8CCB92145D;
        Thu,  7 May 2020 14:29:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1588861786;
        bh=cqW4Z+247hzHb4dini1qWArrhk5IzoBlZfzZ1WrIoo0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=J6VADxJj550/AttLHw++gGcOqYlsFAGQdRKzu+/+Af7PGRoy3nhUDFbe82U/Jk6gK
         rUmRVt+cVJaGZ3TWd70MglKmV7NL10J0MPEEQXGHyFoWYvCxPbOZLgat7vJgXBfVs2
         2tBdn4wldBWGtjEi22ltxHYPM6tDw2iiCRp9eBaE=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Andreas Gruenbacher <agruenba@redhat.com>,
        Xiyu Yang <xiyuyang19@fudan.edu.cn>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 02/16] nfs: Fix potential posix_acl refcnt leak in nfs3_set_acl
Date:   Thu,  7 May 2020 10:29:29 -0400
Message-Id: <20200507142943.26848-2-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200507142943.26848-1-sashal@kernel.org>
References: <20200507142943.26848-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Andreas Gruenbacher <agruenba@redhat.com>

[ Upstream commit 7648f939cb919b9d15c21fff8cd9eba908d595dc ]

nfs3_set_acl keeps track of the acl it allocated locally to determine if an acl
needs to be released at the end.  This results in a memory leak when the
function allocates an acl as well as a default acl.  Fix by releasing acls
that differ from the acl originally passed into nfs3_set_acl.

Fixes: b7fa0554cf1b ("[PATCH] NFS: Add support for NFSv3 ACLs")
Reported-by: Xiyu Yang <xiyuyang19@fudan.edu.cn>
Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs3acl.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 7173a4ee862cb..5e9f9c70fe701 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -253,37 +253,45 @@ int nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 
 int nfs3_set_acl(struct inode *inode, struct posix_acl *acl, int type)
 {
-	struct posix_acl *alloc = NULL, *dfacl = NULL;
+	struct posix_acl *orig = acl, *dfacl = NULL, *alloc;
 	int status;
 
 	if (S_ISDIR(inode->i_mode)) {
 		switch(type) {
 		case ACL_TYPE_ACCESS:
-			alloc = dfacl = get_acl(inode, ACL_TYPE_DEFAULT);
+			alloc = get_acl(inode, ACL_TYPE_DEFAULT);
 			if (IS_ERR(alloc))
 				goto fail;
+			dfacl = alloc;
 			break;
 
 		case ACL_TYPE_DEFAULT:
-			dfacl = acl;
-			alloc = acl = get_acl(inode, ACL_TYPE_ACCESS);
+			alloc = get_acl(inode, ACL_TYPE_ACCESS);
 			if (IS_ERR(alloc))
 				goto fail;
+			dfacl = acl;
+			acl = alloc;
 			break;
 		}
 	}
 
 	if (acl == NULL) {
-		alloc = acl = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
+		alloc = posix_acl_from_mode(inode->i_mode, GFP_KERNEL);
 		if (IS_ERR(alloc))
 			goto fail;
+		acl = alloc;
 	}
 	status = __nfs3_proc_setacls(inode, acl, dfacl);
-	posix_acl_release(alloc);
+out:
+	if (acl != orig)
+		posix_acl_release(acl);
+	if (dfacl != orig)
+		posix_acl_release(dfacl);
 	return status;
 
 fail:
-	return PTR_ERR(alloc);
+	status = PTR_ERR(alloc);
+	goto out;
 }
 
 const struct xattr_handler *nfs3_xattr_handlers[] = {
-- 
2.20.1


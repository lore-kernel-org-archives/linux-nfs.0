Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2325BC433B4
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 13:44:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DC38461139
	for <linux-nfs@archiver.kernel.org>; Wed, 14 Apr 2021 13:44:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231669AbhDNNoe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 14 Apr 2021 09:44:34 -0400
Received: from mail.kernel.org ([198.145.29.99]:52152 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1351587AbhDNNoS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Apr 2021 09:44:18 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id C702361139
        for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2021 13:43:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1618407837;
        bh=sT2d/on1CAyHGgslMALW6hr1OubO7FU6tJB89rV5Prs=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=N+Gyy3UAu9E8hLiLDZ0AOYzOsV09sem0z5CW5u8iuMtdqlPoA99aOYGKpGMn3yfpw
         A7q4/+Hb/+irdb3KnYqhQQP2Wpaiwzdm78t/UycGTXuzi8SOO2GBshGj8f84TxXoZX
         4Hj6LwCSusnfnQCbibxnha+ukp2oHbXxS2pIRxf3MO2CUGtdpm1STE+Uf3kn84Yi9C
         WIHceqPgteoCVa+R7W5sE+3pYbZ1S4P/3Qs6Nlc2xIJX63QP80WTnUv6fhKhYAfLgZ
         GkB6MymkMqEFhbgL0O1CwwZTou4Ai57ejkON25l6lPgrPCbRyrjNMrL/m9LcXaqUCd
         FMnhBp6DQBZ5A==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/26] NFS: NFS_INO_REVAL_PAGECACHE should mark the change attribute invalid
Date:   Wed, 14 Apr 2021 09:43:31 -0400
Message-Id: <20210414134353.11860-5-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210414134353.11860-4-trondmy@kernel.org>
References: <20210414134353.11860-1-trondmy@kernel.org>
 <20210414134353.11860-2-trondmy@kernel.org>
 <20210414134353.11860-3-trondmy@kernel.org>
 <20210414134353.11860-4-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

When we're looking to revalidate the page cache, we should just ensure
that we mark the change attribute invalid.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c429a5375b92..a9b302b389a7 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -219,7 +219,8 @@ void nfs_set_cache_invalid(struct inode *inode, unsigned long flags)
 				| NFS_INO_INVALID_SIZE
 				| NFS_INO_REVAL_PAGECACHE
 				| NFS_INO_INVALID_XATTR);
-	}
+	} else if (flags & NFS_INO_REVAL_PAGECACHE)
+		flags |= NFS_INO_INVALID_CHANGE | NFS_INO_INVALID_SIZE;
 
 	if (!nfs_has_xattr_cache(nfsi))
 		flags &= ~NFS_INO_INVALID_XATTR;
-- 
2.30.2


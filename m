Return-Path: <SRS0=ChQF=C3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD6B6C43464
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Sep 2020 03:09:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 84389206DB
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Sep 2020 03:09:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600398545;
	bh=vnqIYfPTu+rvfEetg3xuLYLSvU11yjq8XixlVaD1i4s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=Zr7zUqd3t9Sx2pdlH1hy82v0d9Lseb7+WqiFwe/OkkFvrcPN0nznxCEGKUt45o+QF
	 k+4YuZZsgXXuLVoviQzKC4RLeBraRSz8Q0BwcOJh3ss5qfSzrSH7OqP4RlfkA79bMt
	 DBwxAmcT/1m6BsAzoTQnhFdET9Jv42N8SCBB2Kxw=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727380AbgIRDI7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Sep 2020 23:08:59 -0400
Received: from mail.kernel.org ([198.145.29.99]:49174 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726980AbgIRCDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Sep 2020 22:03:12 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 93D4221734;
        Fri, 18 Sep 2020 02:03:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600394592;
        bh=vnqIYfPTu+rvfEetg3xuLYLSvU11yjq8XixlVaD1i4s=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=wrkX60JnfaCHXY37mmMUy+iYSK0f29xgHjLKNRcD9uUlXWkPS3qiFVLZp3rwyLT9J
         KYlZa9YgVKeINsOqFQyMHvRE+OHuR27WLosoKwtk8xkIFm4JTwXFYve49HeqNjIS0j
         SZu+VOIR4KoDdIX/LpQmxufXENfa+8zYQDUwdv38=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        "J . Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.4 100/330] nfsd: Fix a soft lockup race in nfsd_file_mark_find_or_create()
Date:   Thu, 17 Sep 2020 21:57:20 -0400
Message-Id: <20200918020110.2063155-100-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200918020110.2063155-1-sashal@kernel.org>
References: <20200918020110.2063155-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trondmy@gmail.com>

[ Upstream commit 90d2f1da832fd23290ef0c0d964d97501e5e8553 ]

If nfsd_file_mark_find_or_create() keeps winning the race for the
nfsd_file_fsnotify_group->mark_mutex against nfsd_file_mark_put()
then it can soft lock up, since fsnotify_add_inode_mark() ends
up always finding an existing entry.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/filecache.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 3007b8945d388..51c08ae79063c 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -133,9 +133,13 @@ nfsd_file_mark_find_or_create(struct nfsd_file *nf)
 						 struct nfsd_file_mark,
 						 nfm_mark));
 			mutex_unlock(&nfsd_file_fsnotify_group->mark_mutex);
-			fsnotify_put_mark(mark);
-			if (likely(nfm))
+			if (nfm) {
+				fsnotify_put_mark(mark);
 				break;
+			}
+			/* Avoid soft lockup race with nfsd_file_mark_put() */
+			fsnotify_destroy_mark(mark, nfsd_file_fsnotify_group);
+			fsnotify_put_mark(mark);
 		} else
 			mutex_unlock(&nfsd_file_fsnotify_group->mark_mutex);
 
-- 
2.25.1


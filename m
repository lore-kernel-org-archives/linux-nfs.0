Return-Path: <SRS0=TrC6=ZF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB2A6C17448
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Nov 2019 01:53:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 941092245A
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Nov 2019 01:53:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1573610007;
	bh=ZuxISFpjVcO7GCboqYdugbKvyKVhZhtr62RJc7RF7PY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=uVAPCWcyFj1S2JbqvbwzNkjOWxYHMP4HVWZJYTavt38lDolMTHhGE0ByEhk6wYe0A
	 uvZ3ZcR6hnhV1J7cGb+2gal2ZASDCJVOBlxcNKu+R0G0m/CjzrS4RoTsZbpbFmNqId
	 jUh25sblMFwSvg8HsQ6rfhxNnzeH7eNe6kkCZZ3U=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728570AbfKMBx0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Nov 2019 20:53:26 -0500
Received: from mail.kernel.org ([198.145.29.99]:43056 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728568AbfKMBxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Nov 2019 20:53:25 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 3E6EF222CF;
        Wed, 13 Nov 2019 01:53:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1573610004;
        bh=ZuxISFpjVcO7GCboqYdugbKvyKVhZhtr62RJc7RF7PY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=bxkbQO+dTD6qSwkMYygPHUv1Y8ZtrQGsI8LexJEa5ZrdtukLll03j7yjAyZbdD2td
         mgWNNvc/LmpQk/dbNhVHCJZAa/o6XiawDZGi16lxb4JJqnB4lGWXUM44e1aWyN0Qhb
         NnstcsRGFCXhuhhL97TIm2KwXxJQCsms9MIxJnzU=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 111/209] NFSv4.x: fix lock recovery during delegation recall
Date:   Tue, 12 Nov 2019 20:48:47 -0500
Message-Id: <20191113015025.9685-111-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191113015025.9685-1-sashal@kernel.org>
References: <20191113015025.9685-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

[ Upstream commit 44f411c353bf6d98d5a34f8f1b8605d43b2e50b8 ]

Running "./nfstest_delegation --runtest recall26" uncovers that
client doesn't recover the lock when we have an appending open,
where the initial open got a write delegation.

Instead of checking for the passed in open context against
the file lock's open context. Check that the state is the same.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/delegation.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 825a8c52165a2..bd8eac752a73a 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -93,7 +93,7 @@ int nfs4_check_delegation(struct inode *inode, fmode_t flags)
 	return nfs4_do_check_delegation(inode, flags, false);
 }
 
-static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid)
+static int nfs_delegation_claim_locks(struct nfs4_state *state, const nfs4_stateid *stateid)
 {
 	struct inode *inode = state->inode;
 	struct file_lock *fl;
@@ -108,7 +108,7 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 	spin_lock(&flctx->flc_lock);
 restart:
 	list_for_each_entry(fl, list, fl_list) {
-		if (nfs_file_open_context(fl->fl_file) != ctx)
+		if (nfs_file_open_context(fl->fl_file)->state != state)
 			continue;
 		spin_unlock(&flctx->flc_lock);
 		status = nfs4_lock_delegation_recall(fl, state, stateid);
@@ -155,7 +155,7 @@ static int nfs_delegation_claim_opens(struct inode *inode,
 		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
 		err = nfs4_open_delegation_recall(ctx, state, stateid);
 		if (!err)
-			err = nfs_delegation_claim_locks(ctx, state, stateid);
+			err = nfs_delegation_claim_locks(state, stateid);
 		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
 			err = -EAGAIN;
 		mutex_unlock(&sp->so_delegreturn_mutex);
-- 
2.20.1


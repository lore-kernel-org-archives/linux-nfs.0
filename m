Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C5EFC282E1
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 16:34:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D739F214AE
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 16:34:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555950869;
	bh=WgFmF4asMOD60lL951SNu1mGimwDZlbsQZhgnR9odmU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=dneWwIs1LB6eY1rXKvA5C11qYtKJOuPgZjABYLkF7IWxN4UgV3pJKMaGufwx0OdYb
	 q0aQ+kB1rbJ79yZJ3Pcc9dbUrtVd0LP/ye0JKAFa4Q8o2nBCdscVK0V+H14EOFi4dC
	 cGhcnyUAekzZpJgpOUg9J6R+f2wMhtSzQYlwzoKQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727378AbfDVQe2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 12:34:28 -0400
Received: from mail.kernel.org ([198.145.29.99]:48700 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727347AbfDVQe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 12:34:28 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E65A8214AF;
        Mon, 22 Apr 2019 16:34:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555950867;
        bh=WgFmF4asMOD60lL951SNu1mGimwDZlbsQZhgnR9odmU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=wEZm9b3eYyhqgYq9LwRm57H5hPPlmDcxO+oiegpfL/sNU1lLSxjnua+HqQjvvXiGp
         AwPqpZHsJEYs3Iqogv5oJYHJ1GubCq1+UQXesUQLh07K1d0BHi9upwPtiqZaOKVjtc
         CvMcbmsCG96wrVYGU6BRleIAxfsdbzUwdDPcCvP8=
From:   Jeff Layton <jlayton@kernel.org>
To:     bfields@fieldses.org
Cc:     slawek1211@gmail.com, neilb@suse.com, linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] nfsd: wake waiters blocked on file_lock before deleting it
Date:   Mon, 22 Apr 2019 12:34:23 -0400
Message-Id: <20190422163424.19402-2-jlayton@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190422163424.19402-1-jlayton@kernel.org>
References: <20190422163424.19402-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After a blocked nfsd file_lock request is deleted, knfsd will send a
callback to the client and then free the request. Commit 16306a61d3b7
("fs/locks: always delete_block after waiting.") changed it such that
locks_delete_block is always called on a request after it is awoken,
but that patch missed fixing up blocked nfsd request handling.

Call locks_delete_block on the block to wake up any locks still blocked
on the nfsd lock request before freeing it. Some of its callers already
do this however, so just remove those calls.

URL: https://bugzilla.kernel.org/show_bug.cgi?id=203363
Fixes: 16306a61d3b7 ("fs/locks: always delete_block after waiting.")
Reported-by: Slawomir Pryczek <slawek1211@gmail.com>
Cc: Neil Brown <neilb@suse.com>
Cc: stable@vger.kernel.org
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a45fb00c5fc..e87e15df2044 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -265,6 +265,7 @@ find_or_allocate_block(struct nfs4_lockowner *lo, struct knfsd_fh *fh,
 static void
 free_blocked_lock(struct nfsd4_blocked_lock *nbl)
 {
+	locks_delete_block(&nbl->nbl_lock);
 	locks_release_private(&nbl->nbl_lock);
 	kfree(nbl);
 }
@@ -293,7 +294,6 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
 		nbl = list_first_entry(&reaplist, struct nfsd4_blocked_lock,
 					nbl_lru);
 		list_del_init(&nbl->nbl_lru);
-		locks_delete_block(&nbl->nbl_lock);
 		free_blocked_lock(nbl);
 	}
 }
@@ -4863,7 +4863,6 @@ nfs4_laundromat(struct nfsd_net *nn)
 		nbl = list_first_entry(&reaplist,
 					struct nfsd4_blocked_lock, nbl_lru);
 		list_del_init(&nbl->nbl_lru);
-		locks_delete_block(&nbl->nbl_lock);
 		free_blocked_lock(nbl);
 	}
 out:
-- 
2.20.1


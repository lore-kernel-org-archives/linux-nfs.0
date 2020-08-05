Return-Path: <SRS0=oxud=BP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668A6C433E3
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Aug 2020 20:07:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2CDE022B42
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Aug 2020 20:07:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1596658073;
	bh=4ol8Q2ARGqWQEqcEcZ0uvFb9jFOBr6comhoz+z7h+4M=;
	h=From:To:Subject:Date:List-ID:From;
	b=zWZl3A78l1e6UKyPShh6QMfErJyeaWCNbrsjTtTYeJhwVuhEK4sneweYIdmzygex9
	 avrQSO1ucpJDD6jXuYK+5XWvo6Z88FHBktWRXElGvgdgU9RC9maBhwms67BlJ7gmCs
	 i39FO+FgpHDdE7O1e/KGlPvvxob2R/hRrG08n/Vg=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728659AbgHEUHg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Aug 2020 16:07:36 -0400
Received: from mail.kernel.org ([198.145.29.99]:49784 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726772AbgHEQcu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Aug 2020 12:32:50 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 6A615233FB
        for <linux-nfs@vger.kernel.org>; Wed,  5 Aug 2020 16:16:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1596644214;
        bh=4ol8Q2ARGqWQEqcEcZ0uvFb9jFOBr6comhoz+z7h+4M=;
        h=From:To:Subject:Date:From;
        b=EH00xuLyf5OWDi4f9QV8qngU4moxzgADg1LE25xvBYBQURqPPrSteC7+ITHdmkjol
         L3u/pvTRqErioNB5ZB4YPkzZIwUeZtkdE/y/GvbroxXfekA7sb2PRs0d5m6S56XKAe
         G8dmpDDPsGHbNhYHlwuOmQzABDGsFhMYl5Zk4+WU=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: Report the stateid + status in trace_nfs4_layoutreturn_on_close()
Date:   Wed,  5 Aug 2020 12:14:44 -0400
Message-Id: <20200805161446.383482-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Ensure we correctly report the stateid and status in the layoutreturn on
close tracepoint.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4trace.h | 2 +-
 fs/nfs/pnfs.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 543541173a3d..07ea8d847710 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1993,7 +1993,7 @@ TRACE_EVENT(nfs4_layoutget,
 
 DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_layoutcommit);
 DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_layoutreturn);
-DEFINE_NFS4_INODE_EVENT(nfs4_layoutreturn_on_close);
+DEFINE_NFS4_INODE_STATEID_EVENT(nfs4_layoutreturn_on_close);
 
 TRACE_DEFINE_ENUM(PNFS_UPDATE_LAYOUT_UNKNOWN);
 TRACE_DEFINE_ENUM(PNFS_UPDATE_LAYOUT_NO_PNFS);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dd2e14f5875d..d8cdb94c6668 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1549,12 +1549,12 @@ void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
 	default:
 		arg_stateid = &args->stateid;
 	}
+	trace_nfs4_layoutreturn_on_close(args->inode, &args->stateid, ret);
 	pnfs_layoutreturn_free_lsegs(lo, arg_stateid, &args->range,
 			res_stateid);
 	if (ld_private && ld_private->ops && ld_private->ops->free)
 		ld_private->ops->free(ld_private);
 	pnfs_put_layout_hdr(lo);
-	trace_nfs4_layoutreturn_on_close(args->inode, 0);
 }
 
 bool pnfs_wait_on_layoutreturn(struct inode *ino, struct rpc_task *task)
-- 
2.26.2


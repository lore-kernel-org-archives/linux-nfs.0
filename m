Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0545C433EF
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Apr 2022 18:52:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1347007AbiDGSyc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Apr 2022 14:54:32 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59868 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1347010AbiDGSya (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2022 14:54:30 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0975F194FD8
        for <linux-nfs@vger.kernel.org>; Thu,  7 Apr 2022 11:52:29 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id B975FB8260C
        for <linux-nfs@vger.kernel.org>; Thu,  7 Apr 2022 18:52:27 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5CD49C385AA
        for <linux-nfs@vger.kernel.org>; Thu,  7 Apr 2022 18:52:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1649357546;
        bh=67FHcUEJDcE6LZMJdrQMRSXw8wfeTRKDUHlK2IpEf2M=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=IusFPMdpAO84X90SCqwixdwBRFZrikfL21+WvJWNGXGoSIP+FTaos9aKG3GjpS3Ps
         Zvn1jHRTmevBPq2SXqLonSIF2u1tjtFxtLRITqH+Nr/DXM2PV3Vu8w0fBB44UIzVd6
         cgxqEWbF0+FfUeOLyKJLFnhkOo1KnCyStreUc5Fo3NxUobFoACy1zCYAuhfIVAMpy0
         re9YI0fCwCT3Wbfjx5B5L+L5LntsUP+Zj9IUOdgvozKWaUu+jL+qzPw8SMLI/nLFFS
         Qec9NbKFfXp048nYKKweJLZs01wVZL27RceRUQ9LyWY7+IDHTtvTJUp2DhRuIkfkL4
         fbgXdd2qYBfvg==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/8] NFSv4/pnfs: Handle RPC allocation errors in nfs4_proc_layoutget
Date:   Thu,  7 Apr 2022 14:45:57 -0400
Message-Id: <20220407184601.1064640-4-trondmy@kernel.org>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220407184601.1064640-3-trondmy@kernel.org>
References: <20220407184601.1064640-1-trondmy@kernel.org>
 <20220407184601.1064640-2-trondmy@kernel.org>
 <20220407184601.1064640-3-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

If rpc_run_task() fails due to an allocation error, then bail out early.

Fixes: 910ad38697d9 ("NFS: Fix memory allocation in rpc_alloc_task()")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e3f5b380cefe..16106f805ffa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -9615,6 +9615,8 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout)
 	nfs4_init_sequence(&lgp->args.seq_args, &lgp->res.seq_res, 0, 0);
 
 	task = rpc_run_task(&task_setup_data);
+	if (IS_ERR(task))
+		return ERR_CAST(task);
 
 	status = rpc_wait_for_completion_task(task);
 	if (status != 0)
-- 
2.35.1


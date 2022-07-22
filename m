Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47735C43334
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Jul 2022 18:12:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235585AbiGVSM0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Jul 2022 14:12:26 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60388 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230273AbiGVSMZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2022 14:12:25 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6431879687
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 11:12:25 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 021ED622E1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 18:12:25 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D2D32C341CF;
        Fri, 22 Jul 2022 18:12:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1658513544;
        bh=/lnHGoMzxCOpHwOwM+gO5/YNsfQgiN3swcXBrWhq5/0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=QMb5cbyg4uYXkhVg3BLjY61nJwkEOu/Q8A8TFCkqfnCGu33dvLNjZnnUVLcaiICiV
         v9Thljp7kPQqaq99xSdzhy1SjWV/NypoR8lEmv6bQcwLleETxkJqpIa2kMcHMEnriF
         EalBJVEXeuacee/MBcfX4Gm9Hiex0acUfCb3vrtuOXQIdzczzh+dhdHobHxTlFj6Xz
         9MkUTN3z2Kxdk1qDWJoe+afr1RSi56IEka9JgS06luUr52gjnfxEnz1i4WpM5+gMPM
         CIPUZAp7NlwsdzhTZynBvGCvDfkRjvXm3nMfDH2vRpyo18nTuT0h2vBwh9jRnk1xVe
         kx2yALwo/GMRA==
From:   Jeff Layton <jlayton@kernel.org>
To:     trond.myklebust@hammerspace.com, anna@kernel.org
Cc:     linux-nfs@vger.kernel.org, chuck.lever@oracle.com, bxue@redhat.com
Subject: [PATCH 2/3] nfs: always check dreq->error after a commit
Date:   Fri, 22 Jul 2022 14:12:19 -0400
Message-Id: <20220722181220.81636-3-jlayton@kernel.org>
X-Mailer: git-send-email 2.36.1
In-Reply-To: <20220722181220.81636-1-jlayton@kernel.org>
References: <20220722181220.81636-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When the client gets back a short DIO write, it will then attempt to
issue another write to finish the DIO request. If that write then fails
(as is often the case in an -ENOSPC situation), then we still may need
to issue a COMMIT if the earlier short write was unstable. If that COMMIT
then succeeds, then we don't want the client to reschedule the write
requests, and to instead just return a short write. Otherwise, we can
end up looping over the same DIO write forever.

Always consult dreq->error after a successful RPC, even when the flag
state is not NFS_ODIRECT_DONE.

Link: https://bugzilla.redhat.com/show_bug.cgi?id=2028370
Reported-by: Boyang Xue <bxue@redhat.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/direct.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index ad40e81857ee..a47d13296194 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -571,8 +571,9 @@ static void nfs_direct_commit_complete(struct nfs_commit_data *data)
 		dreq->max_count = 0;
 		dreq->count = 0;
 		dreq->flags = NFS_ODIRECT_DONE;
-	} else if (dreq->flags == NFS_ODIRECT_DONE)
+	} else {
 		status = dreq->error;
+	}
 
 	nfs_init_cinfo_from_dreq(&cinfo, dreq);
 
-- 
2.36.1


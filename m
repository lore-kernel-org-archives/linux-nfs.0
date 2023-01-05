Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23789C54EBD
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Jan 2023 12:15:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231365AbjAEMPV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 5 Jan 2023 07:15:21 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50514 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232926AbjAEMPS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jan 2023 07:15:18 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D98C458FAA
        for <linux-nfs@vger.kernel.org>; Thu,  5 Jan 2023 04:15:17 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 8E22FB81ABD
        for <linux-nfs@vger.kernel.org>; Thu,  5 Jan 2023 12:15:16 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 00D63C433D2;
        Thu,  5 Jan 2023 12:15:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1672920915;
        bh=RsJimtyejEI6shLrI7EHKX2SRLnEOu+qhk4RqOFVT50=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=XTZEYQfWcUR+yzNLUkcfLRS7y872q5zO0s9My8usT5lf6M6YN69GNY3MhmQQcBehQ
         jKH9DnKiTWKplSFzVeZ9FAtms+UhI3KKBOIg/7dITxFW/8MyiYYhIOXIsITJQ0ofvP
         lkgNg4MgqRH60vTp1Pz0aCuy4Obwqpwhotfj7kBb2UT9jnQCdHqGcYsQ5VY6jq9Gb+
         c4VAKj20t1FI/+HgresmDTvlwI0VupOVDiZwVL2E4+9GI1CyRxJpFHgfk/mGbzlEjf
         +r0Chf/N29xiS6VJNljKKlCVjkmmvwA7SsLO02RwsbA2cRXM8PmBBSE1Qat7K09l/c
         GuWkdF/UYI8ew==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] nfsd: don't open-code clear_and_wake_up_bit
Date:   Thu,  5 Jan 2023 07:15:09 -0500
Message-Id: <20230105121512.21484-2-jlayton@kernel.org>
X-Mailer: git-send-email 2.39.0
In-Reply-To: <20230105121512.21484-1-jlayton@kernel.org>
References: <20230105121512.21484-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/filecache.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 6674a86e1917..9fff1fa09d08 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1184,9 +1184,7 @@ nfsd_file_do_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		status = nfserr_jukebox;
 	if (status != nfs_ok)
 		nfsd_file_unhash(nf);
-	clear_bit_unlock(NFSD_FILE_PENDING, &nf->nf_flags);
-	smp_mb__after_atomic();
-	wake_up_bit(&nf->nf_flags, NFSD_FILE_PENDING);
+	clear_and_wake_up_bit(NFSD_FILE_PENDING, &nf->nf_flags);
 	goto out;
 }
 
-- 
2.39.0


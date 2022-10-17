Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C388C433FE
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Oct 2022 20:50:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229734AbiJQUt7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Oct 2022 16:49:59 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52492 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229996AbiJQUt6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2022 16:49:58 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A841D2125A
        for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2022 13:49:55 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id BBE0FB819D9
        for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2022 20:49:53 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1EBBEC433C1;
        Mon, 17 Oct 2022 20:49:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1666039792;
        bh=7vIEqzKn/WeUZeENnImwBdOLZTfGVhPS7bkfjywIcR8=;
        h=From:To:Cc:Subject:Date:From;
        b=hyeO/oqljVZVn2n4tkOmBCGO/XehgVVxry+3NHHKfp8IjtEn0CDY7zbZ+teEdwnYo
         3THvhuGtuZ59LeqsRItHKbr6uxGR1D7ZxHYc6XlvrKIvV62ZjtWGaLqpkGd3rNy9PD
         qz/NdHt859+NsCYiMh3YYigF0Fy/8uZ0bwBVtduA16I2NLe+6uOAm62fy/C97z3RLy
         4iFRk6G45W6HQeBNbJ4iALM39Kike+0wBUAgGd+PUQZD8rKkV8UnIm1WeSVLM1jsuR
         ZzzYpFs14kETLJvWIy5jiUMpGvVIMv91XTMz2v+DHCp9nSr0xaUAx5hqyjGLQs8Emh
         3jixa1E4YNsyw==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org, David Howells <dhowells@redhat.com>
Subject: [PATCH] nfsd: remove weird compile-time conditional for EDQUOT
Date:   Mon, 17 Oct 2022 16:49:50 -0400
Message-Id: <20221017204950.490306-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.37.3
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I don't see any other places in the kernel that test for this symbol
before trying to use it. Remove the #ifdef.

Cc: David Howells <dhowells@redhat.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/vfs.c | 2 --
 1 file changed, 2 deletions(-)

This builds for me, but I'm on a "standard" arch (x86_64). I think we'll
just have to put this in linux-next and see if any exotic arches or
configurations barf on it.

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 27dd9ac992ee..bee6f4a32f3b 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -84,9 +84,7 @@ nfserrno (int errno)
 		{ nfserr_mlink, -EMLINK },
 		{ nfserr_nametoolong, -ENAMETOOLONG },
 		{ nfserr_notempty, -ENOTEMPTY },
-#ifdef EDQUOT
 		{ nfserr_dquot, -EDQUOT },
-#endif
 		{ nfserr_stale, -ESTALE },
 		{ nfserr_jukebox, -ETIMEDOUT },
 		{ nfserr_jukebox, -ERESTARTSYS },
-- 
2.37.3


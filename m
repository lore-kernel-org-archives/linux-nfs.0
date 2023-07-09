Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8D9EB64DC
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Jul 2023 15:45:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232079AbjGIPpN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Jul 2023 11:45:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54838 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230155AbjGIPpN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Jul 2023 11:45:13 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 757DF91
        for <linux-nfs@vger.kernel.org>; Sun,  9 Jul 2023 08:45:12 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 0B0D260BE9
        for <linux-nfs@vger.kernel.org>; Sun,  9 Jul 2023 15:45:12 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F7C6C433C7;
        Sun,  9 Jul 2023 15:45:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688917511;
        bh=Hcgci1GBS7zMu9dFkEhzXLCsbAjNeJyI+sJrRbX6TXQ=;
        h=Subject:From:To:Cc:Date:From;
        b=s9K21s1GbioT5x4GTVyxfgwD8QolF+giGYpgk7ken4Zxyx5uyWNtBHtjdqWW4upkC
         P3yOFwYEiXlXKbxez3cR41KvsHCzB7n9nAcJ+1goqhRwiZ7d1PFChENQQshv8/r2iI
         7EP6EKR/9K/FXCD/yA4ck6qO+4iC5wX+Sk8Hof2TMX71uXkX4ncjiEM2VNEMVzXpSk
         GSke+AgsuNsBilHKZbVrpF1DqwipVthdI7e1U/Sdyt0eRvvlJ+vnzqd01xVCxtOkKt
         53HV9K7QEtfHTPeM8XpYGAL9e4FRyLWCj+HlFC38iF8cmusZ8exB0OAlcrGpAJVXOT
         xwzGXIxFKeleQ==
Subject: [PATCH v1 0/6] Fix some lock contention in the NFS server's DRC
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Sun, 09 Jul 2023 11:45:09 -0400
Message-ID: <168891733570.3964.15456501153247760888.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This series optimizes DRC scalability by freeing cache objects only
once the hash bucket lock is no longer held. There are a couple of
related clean-ups to go along with this optimization.

---

Chuck Lever (6):
      NFSD: Refactor nfsd_reply_cache_free_locked()
      NFSD: Rename nfsd_reply_cache_alloc()
      NFSD: Replace nfsd_prune_bucket()
      NFSD: Refactor the duplicate reply cache shrinker
      NFSD: Remove svc_rqst::rq_cacherep
      NFSD: Rename struct svc_cacherep


 fs/nfsd/cache.h            |   8 +-
 fs/nfsd/nfscache.c         | 203 ++++++++++++++++++++++++-------------
 fs/nfsd/nfssvc.c           |  10 +-
 fs/nfsd/trace.h            |  26 ++++-
 include/linux/sunrpc/svc.h |   1 -
 5 files changed, 165 insertions(+), 83 deletions(-)

--
Chuck Lever


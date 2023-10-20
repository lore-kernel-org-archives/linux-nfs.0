Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70CB7C001DF
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Oct 2023 20:25:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229659AbjJTUZ5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Oct 2023 16:25:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58690 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229555AbjJTUZ4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Oct 2023 16:25:56 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4F3D4D63
        for <linux-nfs@vger.kernel.org>; Fri, 20 Oct 2023 13:25:54 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4C987C433C8;
        Fri, 20 Oct 2023 20:25:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1697833553;
        bh=vrVwhk5iHhYIc+ppJzpzn5f34ZI922edXM4+7msAXvw=;
        h=From:To:Cc:Subject:Date:From;
        b=sZokF8/Y6tRz5jbEe/X6aJ9XhOx/YNO2oCx9OB2HKfbQjy2vetE5M+Q0C4yCYePZf
         /cy/ldhytmSlasdkd8+yM0X8CS2EiqAGspm/tKgECJVqtnkQlUM1qRNt/jzm+M3ibk
         Rfws4AQChT4S5eVWkSXymdZkZNUjAESWfkdouAQqc3JMChnQHY9ukjClG063Bl7xYR
         qv5D3htBTblkUMCSGeeZzC4IdJM+B1cs5aGFKsfR78hsehU3P2TWtGJtU1zAvBH1Ub
         hWADkNAs/hmwvmrpDa8aLKRGNEEEjD1KDU02MfLJ6Axl0z8um2ZQHIjNkaczzKeew1
         8XfVf/AWsJBVg==
From:   Anna Schumaker <anna@kernel.org>
To:     linux-nfs@vger.kernel.org, torvalds@linux-foundation.org
Cc:     anna@kernel.org
Subject: [GIT PULL] Please pull a few more NFS Client Bugfixes for Linux 6.6-rc
Date:   Fri, 20 Oct 2023 16:25:51 -0400
Message-ID: <20231020202551.162687-1-anna@kernel.org>
X-Mailer: git-send-email 2.42.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Linus,

The following changes since commit 94f6f0550c625fab1f373bb86a6669b45e9748b3:

  Linux 6.6-rc5 (2023-10-08 13:49:43 -0700)

are available in the Git repository at:

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-6.6-4

for you to fetch changes up to 379e4adfddd6a2f95a4f2029b8ddcbacf92b21f9:

  NFSv4.1: fixup use EXCHGID4_FLAG_USE_PNFS_DS for DS server (2023-10-18 15:16:53 -0400)

----------------------------------------------------------------

Stable Fix:
  * Fix a pNFS hang in nfs4_evict_inode()

Bugfixes:
  * Force update of suid/sgid bits after an NFS v4.2 ALLOCATE op
  * Fix a potential oops in nfs_inode_remove_request()
  * Check the validity of the layout pointer in ff_layout_mirror_prepare_stats()
  * Fix incorrectly marking the pNFS MDS with USE_PNFS_DS in some cases

Thanks,
Anna

----------------------------------------------------------------
Dai Ngo (1):
      nfs42: client needs to strip file mode's suid/sgid bit after ALLOCATE op

Olga Kornievskaia (1):
      NFSv4.1: fixup use EXCHGID4_FLAG_USE_PNFS_DS for DS server

Scott Mayhew (1):
      NFS: Fix potential oops in nfs_inode_remove_request()

Trond Myklebust (2):
      pNFS: Fix a hang in nfs4_evict_inode()
      pNFS/flexfiles: Check the layout validity in ff_layout_mirror_prepare_stats

 fs/nfs/flexfilelayout/flexfilelayout.c | 17 ++++++++++-------
 fs/nfs/nfs42proc.c                     |  3 ++-
 fs/nfs/nfs4proc.c                      |  2 --
 fs/nfs/pnfs.c                          | 33 +++++++++++++++++++++++----------
 fs/nfs/write.c                         |  4 +++-
 5 files changed, 38 insertions(+), 21 deletions(-)

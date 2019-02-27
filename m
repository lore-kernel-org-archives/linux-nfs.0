Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78FCEC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4738520863
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728651AbfB0OwA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 09:52:00 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:56049 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726590AbfB0OwA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 09:52:00 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 26405604E3BC6;
        Wed, 27 Feb 2019 15:51:58 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Cc:     Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH 0/4] nfs4.0: Refetch lease_time after clientID reset
Date:   Wed, 27 Feb 2019 15:51:26 +0100
Message-Id: <20190227145130.22323-1-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We've noticed, that nfs mounts with vers=4.0 do not pick up a updated
lease_time after a restart of the nfs server. This was discussed in
the thread "4.0 client and server restart with decreased lease time" on
linux-nfs [1].

This patch set fixes the issue for nsf4.0 clients so that hey behave as
nfs4.1 and nfs4.2 clients do.  After a new clientID is established, the
lease_time is re-fetched and used.

I've notcied, that the flag NFS_CS_CHECK_LEASE_TIME is not functional in
the existing code. It is set and tested, but never reset. Either
nfs4_setup_state_renewal should reset the flag after it verified the
lease_time or the flag could be removed altogether. I left it as is,
because I don't known what is preferred.

[1] https://marc.info/?t=154954022700002&r=1&w=2

Donald Buczek (4):
  nfs: Fix copy-and-paste error in debug message
  nfs4: Rename nfs41_setup_state_renewal
  nfs4: Move nfs4_setup_state_renewal
  nfs4.0: Refetch lease_time after clientid update

 fs/nfs/nfs4state.c | 46 +++++++++++++++++++++++-----------------------
 fs/nfs/nfs4xdr.c   |  2 +-
 2 files changed, 24 insertions(+), 24 deletions(-)

-- 
2.21.0


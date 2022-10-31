Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 113BFFA3740
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Oct 2022 11:37:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229881AbiJaLhs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Oct 2022 07:37:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37314 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229510AbiJaLhr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2022 07:37:47 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8643BE0A1
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2022 04:37:45 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id D5F3560FD6
        for <linux-nfs@vger.kernel.org>; Mon, 31 Oct 2022 11:37:44 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D4FC7C433D6;
        Mon, 31 Oct 2022 11:37:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1667216264;
        bh=XQCQfRdLCVxY3BttRLit/e8edx/LGiitHVt0Z4+xuO0=;
        h=From:To:Cc:Subject:Date:From;
        b=VxXZTCQe+vEYwW2zH81Kox6O1t/oYBL+R5Ip+NUMS66z99onieu2+DekWMoShqeci
         KVwropt36ugr3UoU/rhhRlgR+L9hTtwc9QyqG48m16LuWjvmjqCyMuGznFoNnqpfd0
         SapUpNLMql8f/bEBI+z2xzXWPiVj/YJl5c3+U0zZ/Uv6CTksiPC8XhkKXRn8jRtHTx
         svX5jlvp7TP6HPbGbLxxC5TaYl8/0wVjcmS2k8+KADyl4v4eALUuAR1fDX3xkhMRrZ
         4x7coMvC7xs/82juYWBcjPWgAl8Zt8z/h+IaCIESMBZw99WrwcmPAY5k7gHOqm9O7Q
         jSM+pRDMWluuw==
From:   Jeff Layton <jlayton@kernel.org>
To:     chuck.lever@oracle.com
Cc:     neilb@suse.de, linux-nfs@vger.kernel.org
Subject: [PATCH v4 0/5] nfsd: clean up refcounting in the filecache
Date:   Mon, 31 Oct 2022 07:37:37 -0400
Message-Id: <20221031113742.26480-1-jlayton@kernel.org>
X-Mailer: git-send-email 2.38.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a revision of the set that I posted late on Friday. The only
real difference is the introduction of a "reorganization" patch that
shuffles some of the code in filecache.c around without any functional
changes. That should make the functional changes I'm proposing in patch
#3 more evident.

Jeff Layton (5):
  nfsd: remove the pages_flushed statistic from filecache
  nfsd: reorganize filecache.c
  nfsd: rework refcounting in filecache
  nfsd: close race between unhashing and LRU addition
  nfsd: start non-blocking writeback after adding nfsd_file to the LRU

 fs/nfsd/filecache.c | 385 +++++++++++++++++++++++---------------------
 fs/nfsd/filecache.h |   1 +
 fs/nfsd/trace.h     |   5 +-
 3 files changed, 207 insertions(+), 184 deletions(-)

-- 
2.38.1


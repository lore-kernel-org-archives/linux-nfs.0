Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE414E71D3A
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Sep 2023 13:58:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231429AbjI2N6u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Sep 2023 09:58:50 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40128 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232748AbjI2N6t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Sep 2023 09:58:49 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 30DB31AE
        for <linux-nfs@vger.kernel.org>; Fri, 29 Sep 2023 06:58:48 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A11E2C433C8;
        Fri, 29 Sep 2023 13:58:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695995927;
        bh=M1gBABwAoebWdphjFpBClmp3cP55tJO5YDIZL3IJmrg=;
        h=Subject:From:To:Cc:Date:From;
        b=NBdnSifROpuvERPQ+QJznpXahkdgXkNeKr/p5VkEAuhyOmc3xl4ypkcvRxVkn00nc
         2eyy/J+v245eVzQqq/9XMesElH1RcedSha6rfDZZO9z/YHPuPq08cGEHZtAi+5oESm
         su4xluP7mUeofuAlYzyI1i9kXffD4q/x877yIAwnS5nyId+rp8fLAGXGAL/oJ2KmWt
         irj8k2lB4iP+9q96fGxWN0GA9cTjyK6sbEGxxuAZWJklzYewAxMRvEBmxwjYp0U61A
         gKHRMq0t31WMCbZk0hlDgz6nLXSljjVOGSU10Lwx90Xzmszuuw3h2Rc8Qy38vwxQzx
         E1I5eBm8BMRiw==
Subject: [PATCH v1 0/7] Clean up XDR encoders for NFSv4 OPEN and LOCK
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Fri, 29 Sep 2023 09:58:46 -0400
Message-ID: <169599581942.5622.15965175797823365235.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Tidy up the server-side XDR encoders for NFSv4 OPEN and LOCK
results. Series applies to nfsd-next. See topic branch
"nfsd4-encoder-overhaul" in this repo:

https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git

---

Chuck Lever (7):
      NFSD: Add nfsd4_encode_lock_owner4()
      NFSD: Refactor nfsd4_encode_lock_denied()
      NFSD: Add nfsd4_encode_open_read_delegation4()
      NFSD: Add nfsd4_encode_open_write_delegation4()
      NFSD: Add nfsd4_encode_open_none_delegation4()
      NFSD: Add nfsd4_encode_open_delegation4()
      NFSD: Clean up nfsd4_encode_open()


 fs/nfsd/nfs4state.c |   6 +-
 fs/nfsd/nfs4xdr.c   | 305 +++++++++++++++++++++++++++-----------------
 fs/nfsd/xdr4.h      |   2 +-
 3 files changed, 189 insertions(+), 124 deletions(-)

--
Chuck Lever


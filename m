Return-Path: <SRS0=1EG6=BD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4F41C433E1
	for <linux-nfs@archiver.kernel.org>; Fri, 24 Jul 2020 22:02:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B2FEE2070B
	for <linux-nfs@archiver.kernel.org>; Fri, 24 Jul 2020 22:02:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="zsWL5mAK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726591AbgGXWC0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 24 Jul 2020 18:02:26 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33610 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726552AbgGXWC0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2020 18:02:26 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7B373C0619D3;
        Fri, 24 Jul 2020 15:02:26 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id B7534201A; Fri, 24 Jul 2020 18:02:25 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org B7534201A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1595628145;
        bh=tWxR3BG39o5ECfKidEkWb6Hk3mHZtdLz2Tng+4hzrao=;
        h=Date:To:Cc:Subject:From:From;
        b=zsWL5mAKu1D8eq/kgQRSZlDBoQGJaskg6XShKViVwyw7NQl+ZGnnFw/iJ1/Xh2Peu
         QGSHxSbL+K6FDkeSeqBzx8D0PU1Uqky0yOHj39JKw04UE1wvT9hlg0Dw+0lg4IIOG5
         V+e4+PkXlmM6feAWky6jsVtS6ZCZ9D/88foa0nhA=
Date:   Fri, 24 Jul 2020 18:02:25 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfix for 5.8
Message-ID: <20200724220225.GE9244@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.8-2

This is just one fix for a NULL dereference if someone happens to read
/proc/fs/nfsd/client/../state at the wrong moment.

--b.

J. Bruce Fields (1):
      nfsd4: fix NULL dereference in nfsd/clients display code

 fs/nfsd/nfs4state.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

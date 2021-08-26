Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9205BC4320E
	for <linux-nfs@archiver.kernel.org>; Thu, 26 Aug 2021 19:17:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 79B6560F14
	for <linux-nfs@archiver.kernel.org>; Thu, 26 Aug 2021 19:17:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230189AbhHZTRt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 26 Aug 2021 15:17:49 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42178 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S243421AbhHZTRs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2021 15:17:48 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 13CADC061757;
        Thu, 26 Aug 2021 12:17:01 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 6B02D64B9; Thu, 26 Aug 2021 15:17:00 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 6B02D64B9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1630005420;
        bh=O4lrRkOAkCOCiu+xyrLxmjyWeL8QhTEnxGMRZIS8O3Y=;
        h=Date:To:Cc:Subject:From:From;
        b=AXNqWWGX+kQ8d819w58/ee9SjDgYzKaZA7s2JZT8NcWqKeCdOfM0kD2krZqMgCh4c
         xVojfilnoRgFZOtVQeR1sXgWwaqNiqDnoAsNny35j+HfkFiBy4bAr74sMkC2Ppie3g
         CXDt6+fUd4QagrDsuLu4yEpTUCMiEVtYWxCQrs3g=
Date:   Thu, 26 Aug 2021 15:17:00 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfix for 5.14
Message-ID: <20210826191700.GA10730@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.14-1

for an nfsd change for 5.14.

This is a one-liner fix for a serious bug that can cause the server to
become unresponsive to a client, so I think it's worth the last-minute
inclusion for 5.14.

--b.

Trond Myklebust (1):
      SUNRPC: Fix XPT_BUSY flag leakage in svc_handle_xprt()...

 net/sunrpc/svc_xprt.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Return-Path: <SRS0=BC+Y=QO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E024C282C2
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 21:44:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 53C192175B
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 21:44:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726622AbfBGVom (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Feb 2019 16:44:42 -0500
Received: from fieldses.org ([173.255.197.46]:55700 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726512AbfBGVom (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Feb 2019 16:44:42 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 679611C97; Thu,  7 Feb 2019 16:44:42 -0500 (EST)
Date:   Thu, 7 Feb 2019 16:44:42 -0500
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd fixes for 5.0
Message-ID: <20190207214442.GE27008@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.0-1

for two small nfsd bugfixes for 5.0, for an RDMA bug and a file clone bug.

--b.

Chuck Lever (1):
      svcrdma: Remove max_sge check at connect time

Trond Myklebust (1):
      nfsd: Fix error return values for nfsd4_clone_file_range()

 fs/nfsd/vfs.c                            |   6 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    | 105 +++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   9 +--
 3 files changed, 106 insertions(+), 14 deletions(-)

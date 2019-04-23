Return-Path: <SRS0=AvAq=SZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4567EC10F03
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 20:11:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1E055217D9
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 20:11:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727044AbfDWULk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Apr 2019 16:11:40 -0400
Received: from fieldses.org ([173.255.197.46]:47744 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725956AbfDWULk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 Apr 2019 16:11:40 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C4F2E1CC9; Tue, 23 Apr 2019 16:11:39 -0400 (EDT)
Date:   Tue, 23 Apr 2019 16:11:39 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 5.1
Message-ID: <20190423201139.GB10017@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.1-1

Fix miscellaneous nfsd bugs, in NFSv4.1 callbacks, NFSv4.1
lock-notification callbacks, NFSv3 readdir encoding, and the
cache/upcall code.

--b.

Jeff Layton (2):
      nfsd: wake waiters blocked on file_lock before deleting it
      nfsd: wake blocked file lock waiters before sending callback

Murphy Zhou (1):
      nfsd/nfsd3_proc_readdir: fix buffer count and page pointers

NeilBrown (1):
      sunrpc: don't mark uninitialised items as VALID.

Trond Myklebust (1):
      nfsd: Don't release the callback slot unless it was actually held

 fs/nfsd/nfs3proc.c     | 17 +++++++++++++++--
 fs/nfsd/nfs3xdr.c      | 11 +++++++++--
 fs/nfsd/nfs4callback.c |  8 +++++++-
 fs/nfsd/nfs4state.c    | 12 ++++++++++--
 fs/nfsd/state.h        |  1 +
 net/sunrpc/cache.c     |  3 +++
 6 files changed, 45 insertions(+), 7 deletions(-)

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37993 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754562Ab2JSM63 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Oct 2012 08:58:29 -0400
Date: Fri, 19 Oct 2012 08:58:27 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.7
Message-ID: <20121019125827.GC20324@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes for 3.7 from the for-3.7 branch at:

  git://linux-nfs.org/~bfields/linux.git for-3.7

--b.

----------------------------------------------------------------
Sasha Levin (1):
      SUNRPC: Prevent kernel stack corruption on long values of flush

Trond Myklebust (1):
      NLM: nlm_lookup_file() may return NLMv4-specific error codes

 fs/lockd/clntxdr.c |    2 +-
 fs/lockd/svcproc.c |    3 ++-
 net/sunrpc/cache.c |    4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

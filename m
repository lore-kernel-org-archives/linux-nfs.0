Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38130 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933187Ab2HWTAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Aug 2012 15:00:16 -0400
Date: Thu, 23 Aug 2012 15:00:14 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.6
Message-ID: <20120823190014.GB8591@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git for-3.6

Particular thanks to Michael Tokarev, Malahal Naineni, and Jamie Heilman
for their testing and debugging help.

--b.

----------------------------------------------------------------
J. Bruce Fields (4):
      nfsd4: fix security flavor of NFSv4.0 callback
      svcrpc: fix BUG() in svc_tcp_clear_pages
      svcrpc: sends on closed socket should stop immediately
      svcrpc: fix svc_xprt_enqueue/svc_recv busy-looping

 fs/nfsd/nfs4callback.c |    4 ++--
 fs/nfsd/state.h        |    1 -
 net/sunrpc/svc_xprt.c  |   10 ++++------
 net/sunrpc/svcsock.c   |    2 +-
 4 files changed, 7 insertions(+), 10 deletions(-)

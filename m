Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43860 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbaJ0VvC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Oct 2014 17:51:02 -0400
Date: Mon, 27 Oct 2014 17:51:01 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 3.18
Message-ID: <20141027215101.GA32743@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes from:

  git://linux-nfs.org/~bfields/linux.git for-3.18

One regression from the 3.16 xdr rewrite, one an older bug exposed by a
separate bug in the client's new SEEK code.

--b.

----------------------------------------------------------------
J. Bruce Fields (2):
      nfsd4: fix response size estimation for OP_SEQUENCE
      nfsd4: fix crash on unknown operation number

 fs/nfsd/nfs4proc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

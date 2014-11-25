Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55338 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbaKYXys (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Nov 2014 18:54:48 -0500
Date: Tue, 25 Nov 2014 18:54:47 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 3.18
Message-ID: <20141125235447.GE15033@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following nfsd bugfixes for 3.18:

  git://linux-nfs.org/~bfields/linux.git for-3.18

These fix one mishandling of the case when security labels are
configured out, and two races in the 4.1 backchannel code.

--b.

----------------------------------------------------------------
Christoph Hellwig (1):
      nfsd: correctly define v4.2 support attributes

Trond Myklebust (2):
      SUNRPC: Fix locking around callback channel reply receive
      nfsd: Fix slot wake up race in the nfsv4.1 callback code

 fs/nfsd/nfs4callback.c |  8 ++++++--
 fs/nfsd/nfsd.h         |  9 ++++++---
 net/sunrpc/svcsock.c   | 27 ++++++++++++++++-----------
 3 files changed, 28 insertions(+), 16 deletions(-)

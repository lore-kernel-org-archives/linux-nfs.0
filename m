Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49484 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756441Ab0AFWoI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 17:44:08 -0500
Date: Wed, 6 Jan 2010 17:44:55 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: nfsd bugfixes
Message-ID: <20100106224455.GA11677@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The for-2.6.33 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.33

has two new nfsd bugfixes, and one you already have*.  Please pull.

--b.

* I'd already pushed out a commit when you took it as a patch, and given
  the choice between a duplicate commit and rewinding the branch I
  figured the duplicate commit was the lesser evil.  Feel free to tell
  me I'm doing it all wrong.

Christoph Hellwig (1):
      nfsd: make sure data is on disk before calling ->fsync

J. Bruce Fields (1):
      nfsd: fix "insecure" export option

Xiaotian Feng (1):
      sunrpc: fix peername failed on closed listener

 fs/nfsd/nfsfh.c       |    2 +-
 fs/nfsd/vfs.c         |    5 +----
 net/sunrpc/svc_xprt.c |    3 ++-
 3 files changed, 4 insertions(+), 6 deletions(-)

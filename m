Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45183 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753041Ab3KUUUm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Nov 2013 15:20:42 -0500
Date: Thu, 21 Nov 2013 15:20:41 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.13
Message-ID: <20131121202041.GC20034@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a couple nfsd bugfixes ready to pull from:

  git://linux-nfs.org/~bfields/linux.git for-3.13

--b.

----------------------------------------------------------------
Christoph Hellwig (2):
      nfsd: split up nfsd_setattr
      nfsd: make sure to balance get/put_write_access

J. Bruce Fields (1):
      nfsd4: fix xdr decoding of large non-write compounds

 fs/nfsd/nfs4xdr.c |    3 +-
 fs/nfsd/vfs.c     |  173 ++++++++++++++++++++++++++++++-----------------------
 2 files changed, 101 insertions(+), 75 deletions(-)

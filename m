Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50120 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbaGCUUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jul 2014 16:20:10 -0400
Date: Thu, 3 Jul 2014 16:20:09 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: 3.16 nfsd bugfixes
Message-ID: <20140703202009.GE24322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes from

  git://linux-nfs.org/~bfields/linux.git for-3.16

By coincidence, two NFSv4 symlink bugs, one introduced in the 3.16 xdr
encoding rewrite, the other a decoding bug that I think we've had since
the start but that just doesn't trigger very often.

--b.

----------------------------------------------------------------
Avi Kivity (1):
      nfs: fix nfs4d readlink truncated packet

J. Bruce Fields (1):
      nfsd: fix rare symlink decoding bug

 fs/nfsd/nfs4proc.c |  9 ---------
 fs/nfsd/nfs4xdr.c  | 15 +++++++++++++--
 2 files changed, 13 insertions(+), 11 deletions(-)

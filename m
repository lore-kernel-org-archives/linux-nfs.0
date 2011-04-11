Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51298 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755092Ab1DKIQW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 04:16:22 -0400
Date: Mon, 11 Apr 2011 04:16:20 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org
Subject: 2.6.39 nfsd bugfixes
Message-ID: <20110411081620.GA31311@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A couple 2.6.39 nfsd bugfixes are available from:

  git://linux-nfs.org/~bfields/linux.git for-2.6.39

Please pull.

--b.

J. Bruce Fields (2):
      nfsd: fix auth_domain reference leak on nlm operations
      nfsd4: fix oops on lock failure

 fs/nfsd/lockd.c     |    1 -
 fs/nfsd/nfs4state.c |    9 ++++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

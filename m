Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36649 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751536Ab0HZSzo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Aug 2010 14:55:44 -0400
Date: Thu, 26 Aug 2010 14:55:31 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 2.6.36
Message-ID: <20100826185531.GA10636@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The following nfsd bugfixes are available in the for-2.6.36 branch of
the git repository at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.36

Please pull for 2.6.36.

--b.

J. Bruce Fields (4):
      nfsd4: bad BUG() in preprocess_stateid_op
      nfsd4: typo fix in find_any_file
      nfsd4: fix downgrade/lock logic
      Merge commit 'v2.6.36-rc1' into HEAD

Takashi Iwai (1):
      nfsd: fix NULL dereference in nfsd_statfs()

 fs/nfsd/nfs4state.c |   26 +++++++++++++++-----------
 fs/nfsd/state.h     |   14 +++++++-------
 fs/nfsd/vfs.c       |   14 ++++++++------
 3 files changed, 30 insertions(+), 24 deletions(-)

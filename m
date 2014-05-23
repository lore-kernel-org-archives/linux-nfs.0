Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994AbaEWUe1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2014 16:34:27 -0400
Date: Fri, 23 May 2014 16:34:26 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd bugfixes for 3.15
Message-ID: <20140523203426.GA3165@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes for 3.15:

  git://linux-nfs.org/~bfields/linux.git for-3.15

Just two bugfixes, one for a merge-window-introduced ACL regression, the
other for a longer-standing v4 state bug.

--b.

J. Bruce Fields (3):
      nfsd4: fix corruption on setting an ACL.
      nfsd4: remove lockowner when removing lock stateid
      nfsd4: warn on finding lockowner without stateid's

 fs/nfsd/nfs4acl.c   |    2 +-
 fs/nfsd/nfs4state.c |   15 +++++++++++++--
 2 files changed, 14 insertions(+), 3 deletions(-)

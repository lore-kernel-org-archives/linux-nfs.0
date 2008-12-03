From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.28
Date: Wed, 3 Dec 2008 14:10:04 -0500
Message-ID: <20081203191004.GL16846@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42080 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751753AbYLCTKG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Dec 2008 14:10:06 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull a few more small nfsd regression fixes for 2.6.28, from the
for-2.6.28 branch at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.28

Thanks to Jeff Moyer, Matthew Dodd, and others for testing.

--b.

Chuck Lever (1):
      NLM: client-side nlm_lookup_host() should avoid matching on srcaddr

J. Bruce Fields (2):
      nfsd: clean up grace period on early exit
      nfsd: use of unitialized list head on error exit in nfs4recover.c

Tom Tucker (1):
      Add a reference to sunrpc in svc_addsock

 fs/lockd/host.c       |    3 ++-
 fs/lockd/svc.c        |    1 +
 fs/nfsd/nfs4recover.c |    2 +-
 fs/nfsd/nfs4state.c   |    1 +
 net/sunrpc/svcsock.c  |    9 +++++++--
 5 files changed, 12 insertions(+), 4 deletions(-)

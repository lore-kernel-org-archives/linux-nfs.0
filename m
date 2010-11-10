Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57168 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756327Ab0KJU25 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Nov 2010 15:28:57 -0500
Date: Wed, 10 Nov 2010 15:28:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: nfsd, lease changes for 2.6.37
Message-ID: <20101110202853.GC27237@fieldses.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Please pull from:

  git://linux-nfs.org/~bfields/linux.git for-2.6.37

One nfsd 4.1 bugfix, and two more bits of mopup from the lease de-BKL
work.  (The last of which is really just cleanup--but obvious enough I
hoped to slip it past the functional-regressions-only-post-rc1
filter....)

--b.

J. Bruce Fields (3):
      nfsd4: fix 4.1 connection registration race
      locks: fix leak on merging leases
      locks: remove dead lease error-handling code

 fs/locks.c                      |   19 +++++++------------
 fs/nfsd/nfs4state.c             |   16 ++++++++++++----
 include/linux/sunrpc/svc_xprt.h |   18 ++++++++++++++----
 3 files changed, 33 insertions(+), 20 deletions(-)

commit 8896b93f42459b18b145c69d399b62870df48061
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Nov 3 18:09:18 2010 -0400

    locks: remove dead lease error-handling code
    
    A minor oversight from f7347ce4ee7c65415f84be915c018473e7076f31,
    "fasync: re-organize fasync entry insertion to allow it under a
    spinlock": this cleanup-on-error was only needed to handle -ENOMEM.  Now
    that we're preallocating it's unneeded.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 3df057ac9afe83c4af84016df3baf3a0eb1d3d33
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Nov 3 16:49:44 2010 -0400

    locks: fix leak on merging leases
    
    We must also free the passed-in lease in the case it wasn't used because
    an existing lease was upgrade/downgraded or already existed.
    
    Note the nfsd caller doesn't care because it's fl_change callback
    returns an error in those cases.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

commit 21b75b019983dfa5c2dda588f4b60b4ca69844a4
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Tue Oct 26 10:07:17 2010 -0400

    nfsd4: fix 4.1 connection registration race
    
    If a connection is closed just after a sequence or create_session
    is sent over it, we could end up trying to register a callback that will
    never get called since the xprt is already marked dead.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51580 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbaDXGZR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Apr 2014 02:25:17 -0400
Date: Thu, 24 Apr 2014 02:25:16 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Subject: nfsd bug fixes for 3.15
Message-ID: <20140424062516.GA8891@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull the following bug fixes for 3.15 from:

  git://linux-nfs.org/~bfields/linux.git for-3.15

Three small nfsd bugfixes (including one locks.c fix for a bug triggered
only from nfsd).

Jeff's patches are for long-existing problems that became easier to
trigger since the addition of vfs delegation support.

--b.

----------------------------------------------------------------
J. Bruce Fields (1):
      Revert "nfsd4: fix nfs4err_resource in 4.1 case"

Jeff Layton (2):
      locks: allow __break_lease to sleep even when break_time is 0
      nfsd: set timeparms.to_maxval in setup_callback_client

 fs/locks.c             | 7 +++----
 fs/nfsd/nfs4callback.c | 4 +++-
 fs/nfsd/nfs4xdr.c      | 8 --------
 3 files changed, 6 insertions(+), 13 deletions(-)

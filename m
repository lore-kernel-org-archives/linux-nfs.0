From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd fixes for 2.6.28
Date: Wed, 22 Oct 2008 17:41:16 -0400
Message-ID: <20081022214116.GA7454@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760371AbYJVVld@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following nfsd fixes are available in the git repository at:

  git://linux-nfs.org/~bfields/linux.git for-2.6.28

The patch from Chuck is the important one, fixing a regression we just
introduced which could cause nfsd to crash on shutdown.

The rest just fixes two memory leask in error paths, with some very
minor associated cleanup.

--b.

Chuck Lever (1):
      NFSD: Fix BUG during NFSD shutdown processing

J. Bruce Fields (1):
      nfsd: clean up expkey_parse error cases

Krishna Kumar (2):
      nfsd: Fix memory leak in nfsd_getxattr
      nfsd: Drop reference in expkey_parse error cases

 fs/nfsd/export.c |   19 ++++++++++---------
 fs/nfsd/nfssvc.c |    4 ++++
 fs/nfsd/vfs.c    |    6 +++++-
 3 files changed, 19 insertions(+), 10 deletions(-)

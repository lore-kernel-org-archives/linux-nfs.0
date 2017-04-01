Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33552 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750782AbdDABxB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 Mar 2017 21:53:01 -0400
Date: Fri, 31 Mar 2017 21:53:00 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 4.11
Message-ID: <20170401015300.GF14424@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.11-1

The restriction of NFSv4 to TCP went overboard and also broke the
backchannel; fix.  Also some minor refinements to the nfsd
version-setting interface that we'd like to get fixed before release.

--b.

Chuck Lever (1):
      svcrdma: set XPT_CONG_CTRL flag for bc xprt

Kinglong Mee (2):
      SUNRPC/backchanel: set XPT_CONG_CTRL flag for bc xprt
      nfsd: map the ENOKEY to nfserr_perm for avoiding warning

NeilBrown (3):
      NFSD: further refinement of content of /proc/fs/nfsd/versions
      NFSD: fix nfsd_minorversion(.., NFSD_AVAIL)
      NFSD: fix nfsd_reset_versions for NFSv4.

 fs/nfsd/nfsctl.c                         | 43 ++++++++++++++++++++++++--------
 fs/nfsd/nfsproc.c                        |  1 +
 fs/nfsd/nfssvc.c                         | 28 ++++++++++-----------
 net/sunrpc/svcsock.c                     |  1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  1 +
 5 files changed, 49 insertions(+), 25 deletions(-)

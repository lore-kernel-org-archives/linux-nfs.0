Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59348 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754355AbcFPPoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jun 2016 11:44:12 -0400
Date: Thu, 16 Jun 2016 11:44:10 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd bugfixes for 4.7
Message-ID: <20160616154410.GB15546@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd bugfixes for 4.7 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.7-1

--b.

----------------------------------------------------------------
Oleg Drokin found and fixed races in the nfsd4 state code that go back
to the big nfs4_lock_state removal around 3.17 (but that were also
probably hard to reproduce before client changes in 3.20 allowed the
client to perform parallel opens).

Also fix a 4.1 backchannel crash due to rpc multipath changes in 4.6.
Trond acked the client-side rpc fixes going through my tree.

----------------------------------------------------------------
Geert Uytterhoeven (1):
      nfsd: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL postfix

J. Bruce Fields (3):
      SUNRPC: fix xprt leak on xps allocation failure
      nfsd4/rpc: move backchannel create logic into rpc code
      rpc: share one xps between all backchannels

Oleg Drokin (3):
      nfsd: Always lock state exclusively.
      nfsd: Extend the mutex holding region around in nfsd4_process_open2()
      nfsd: Make init_open_stateid() a bit more whole

 fs/nfsd/blocklayout.c           |  2 +-
 fs/nfsd/nfs4callback.c          | 18 +----------
 fs/nfsd/nfs4state.c             | 67 +++++++++++++++++++++++------------------
 fs/nfsd/state.h                 |  2 +-
 include/linux/sunrpc/clnt.h     |  2 --
 include/linux/sunrpc/svc_xprt.h |  1 +
 include/linux/sunrpc/xprt.h     |  1 +
 net/sunrpc/clnt.c               | 31 +++++++++++++++----
 net/sunrpc/svc_xprt.c           |  2 ++
 net/sunrpc/xprtsock.c           |  1 +
 10 files changed, 70 insertions(+), 57 deletions(-)

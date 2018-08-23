Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52438 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727714AbeHWQ1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Aug 2018 12:27:46 -0400
Date: Thu, 23 Aug 2018 08:58:10 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.19
Message-ID: <20180823125810.GC32415@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.19 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.19

--b.

----------------------------------------------------------------
Chuck Lever fixed a problem with NFSv4.0 callbacks over GSS from
multi-homed servers.  The only new feature is a minor bit of protocol
(change_attr_type) which the client doesn't even use yet.  Other than
that, various bugfixes and cleanup.

----------------------------------------------------------------
Amir Goldstein (1):
      nfsd: fix leaked file lock with nfs exported overlayfs

Benjamin Coddington (1):
      nfsd: don't advertise a SCSI layout for an unsupported request_queue

Chuck Lever (4):
      svcrdma: Avoid releasing a page in svc_xprt_release()
      svcrdma: Clean up Read chunk path
      NFSD: Refactor the generic write vector fill helper
      NFSD: Handle full-length symlinks

Eric Biggers (1):
      nfsd: constify write_op[]

Gustavo A. R. Silva (2):
      nfsd: Mark expected switch fall-through
      nfsd: use true and false for boolean values

J. Bruce Fields (9):
      nfsd4: extend reclaim period for reclaiming clients
      nfsd4: return default lease period
      nfsd: fix NFSv4 time_delta attribute
      nfsd4: support change_attr_type attribute
      nfsd4: less confusing nfsd4_compound_in_session
      nfsd4: cleanup sessionid in nfsd4_destroy_session
      nfsd: update obselete comment referencing the BKL
      nfsd: clarify check_op_ordering
      nfsd: fix corrupted reply to badly ordered compound

YueHaibing (1):
      sunrpc: remove redundant variables 'checksumlen','blocksize' and 'data'

nixiaoming (1):
      fs/nfsd: Delete invalid assignment statements in nfsd4_decode_exchange_id

zhong jiang (1):
      rpc: remove unneeded variable 'ret' in rdma_listen_handler

 fs/lockd/clntlock.c                      |  2 +-
 fs/lockd/clntproc.c                      |  2 +-
 fs/lockd/svclock.c                       | 16 +++----
 fs/lockd/svcsubs.c                       |  4 +-
 fs/nfsd/netns.h                          |  1 +
 fs/nfsd/nfs3proc.c                       |  5 +-
 fs/nfsd/nfs4callback.c                   |  1 +
 fs/nfsd/nfs4layouts.c                    | 11 +----
 fs/nfsd/nfs4proc.c                       | 41 ++++++++---------
 fs/nfsd/nfs4state.c                      | 53 +++++++++++++++++-----
 fs/nfsd/nfs4xdr.c                        | 43 +++++++++++++++---
 fs/nfsd/nfsctl.c                         |  7 +--
 fs/nfsd/nfsd.h                           |  1 +
 fs/nfsd/nfsfh.c                          |  6 +--
 fs/nfsd/nfsproc.c                        |  5 +-
 include/linux/lockd/lockd.h              |  4 +-
 include/linux/nfs4.h                     |  8 ++++
 include/linux/sunrpc/svc.h               |  4 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c    |  2 -
 net/sunrpc/auth_gss/gss_krb5_wrap.c      |  2 -
 net/sunrpc/svc.c                         | 78 ++++++++++++--------------------
 net/sunrpc/xprtrdma/svc_rdma.c           |  2 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  9 ++--
 net/sunrpc/xprtrdma/svc_rdma_rw.c        | 32 ++++++-------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  4 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  3 +-
 26 files changed, 193 insertions(+), 153 deletions(-)

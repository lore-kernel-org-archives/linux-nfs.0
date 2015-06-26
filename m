Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52517 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417AbbFZUv1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jun 2015 16:51:27 -0400
Date: Fri, 26 Jun 2015 16:51:26 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.2
Message-ID: <20150626205126.GC4293@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes from

  git://linux-nfs.org/~bfields/linux.git for-4.2

A relatively quiet cycle, with a mix of cleanup and smaller bugfixes.

--b.

----------------------------------------------------------------
Andreas Gruenbacher (4):
      nfsd: Disable NFSv2 timestamp workaround for NFSv3+
      nfsd: Checking for acl support does not require fetching any acls
      nfsd: Remove dead declarations
      uapi/nfs: Add NFSv4.1 ACL definitions

Arnd Bergmann (1):
      nfsd: work around a gcc-5.1 warning

Christoph Hellwig (6):
      nfsd: remove nfsd_close
      nfsd: clean up raparams handling
      nfsd: refactor nfs4_preprocess_stateid_op
      nfsd: take struct file setup fully into nfs4_preprocess_stateid_op
      nfsd: fput rd_file from XDR encode context
      nfsd: wrap too long lines in nfsd4_encode_read

Chuck Lever (7):
      SUNRPC: Move EXPORT_SYMBOL for svc_process
      svcrdma: Remove svc_rdma_xdr_decode_deferred_req()
      svcrdma: Fix byte-swapping in svc_rdma_sendto.c
      svcrdma: Keep rpcrdma_msg fields in network byte-order
      svcrdma: Replace GFP_KERNEL in a loop with GFP_NOFAIL
      svcrdma: Add a separate "max data segs macro for svcrdma
      rpcrdma: Merge svcrdma and xprtrdma modules into one

Fabian Frederick (2):
      nfsd: use swap() in sort_pacl_range()
      sunrpc: use sg_init_one() in krb5_rc4_setup_enc/seq_key()

Kinglong Mee (2):
      nfsd: Reset cb_status in nfsd4_cb_prepare() at retrying
      nfsd: Update callback sequnce id only CB_SEQUENCE success

NeilBrown (1):
      nfsd: stop READDIRPLUS returning inconsistent attributes

Scott Mayhew (1):
      Documentation: remove overloads-avoided counter from knfsd-stats.txt

 Documentation/filesystems/nfs/knfsd-stats.txt |  44 +-------
 fs/nfsd/nfs3xdr.c                             |  12 ++-
 fs/nfsd/nfs4acl.c                             |  18 +---
 fs/nfsd/nfs4callback.c                        |  15 ++-
 fs/nfsd/nfs4proc.c                            |  43 +++-----
 fs/nfsd/nfs4state.c                           | 148 +++++++++++++++++---------
 fs/nfsd/nfs4xdr.c                             |  75 ++++++-------
 fs/nfsd/nfsproc.c                             |  52 ++++++++-
 fs/nfsd/state.h                               |   7 +-
 fs/nfsd/vfs.c                                 | 128 +++++-----------------
 fs/nfsd/vfs.h                                 |  11 +-
 fs/nfsd/xdr4.h                                |   1 +
 include/linux/sunrpc/svc_rdma.h               |  11 +-
 include/uapi/linux/nfs4.h                     |   7 ++
 net/sunrpc/Kconfig                            |  28 ++---
 net/sunrpc/Makefile                           |   3 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c         |   8 +-
 net/sunrpc/svc.c                              |   2 +-
 net/sunrpc/xprtrdma/Makefile                  |  14 ++-
 net/sunrpc/xprtrdma/module.c                  |  46 ++++++++
 net/sunrpc/xprtrdma/svc_rdma.c                |   8 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c        | 140 +++++++-----------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c       |   2 +-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c         |  16 +--
 net/sunrpc/xprtrdma/svc_rdma_transport.c      |  36 ++-----
 net/sunrpc/xprtrdma/transport.c               |  13 +--
 net/sunrpc/xprtrdma/xprt_rdma.h               |  11 +-
 27 files changed, 407 insertions(+), 492 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/module.c

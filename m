Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39722 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760117AbdKRSkU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 18 Nov 2017 13:40:20 -0500
Date: Sat, 18 Nov 2017 13:40:20 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PULL REQUEST] nfsd changes for 4.15
Message-ID: <20171118184020.GA22603@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes for 4.15 from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.15

Lots of good bugfixes, including:

	- fix a number of races in the NFSv4+ state code.
	- fix some shutdown crashes in multiple-network-namespace cases.
	- relax our 4.1 session limits; if you've an artificially low limit
	  to the number of 4.1 clients that can mount simultaneously, try
	  upgrading.

--b.

Andrew Elble (1):
      nfsd: deal with revoked delegations appropriately

Arnd Bergmann (1):
      nfds: avoid gettimeofday for nfssvc_boot time

Chuck Lever (2):
      svcrdma: Preserve CB send buffer across retransmits
      svcrdma: Enqueue after setting XPT_CLOSE in completion handlers

Colin Ian King (1):
      sunrcp: make function _svc_create_xprt static

Corentin Labbe (3):
      nfs_common: fix build warning in grace.c
      nfs_common: move locks_in_grace comment at the right place
      nfs_common: convert int to bool

Elena Reshetova (3):
      fs, nfsd: convert nfs4_stid.sc_count from atomic_t to refcount_t
      fs, nfsd: convert nfs4_cntl_odstate.co_odcount from atomic_t to refcount_t
      fs, nfsd: convert nfs4_file.fi_ref from atomic_t to refcount_t

J. Bruce Fields (6):
      nfsd: remove unnecessary nofilehandle checks
      nfsd: increase DRC cache limit
      nfsd: give out fewer session slots as limit approaches
      nfsd4: fix cached replies to solo SEQUENCE compounds
      nfsd4: catch some false session retries
      rpc: remove some BUG()s

Jérémy Lefaure (1):
      nfsd: use ARRAY_SIZE

Trond Myklebust (2):
      SUNRPC: Fix tracepoint storage issues with svc_recv and svc_rqst_status
      SUNRPC: Improve ordering of transport processing

Vasily Averin (2):
      lockd: double unregister of inetaddr notifiers
      nfsd: use nfs->ns.inum as net ID

 fs/lockd/svc.c                             |  20 ++---
 fs/nfs_common/grace.c                      |  24 +++---
 fs/nfsd/fault_inject.c                     |   5 +-
 fs/nfsd/netns.h                            |   2 +-
 fs/nfsd/nfs3xdr.c                          |  10 ++-
 fs/nfsd/nfs4layouts.c                      |   4 +-
 fs/nfsd/nfs4proc.c                         |  19 ++---
 fs/nfsd/nfs4state.c                        | 127 +++++++++++++++++++++++------
 fs/nfsd/nfssvc.c                           |   4 +-
 fs/nfsd/state.h                            |  11 ++-
 fs/nfsd/xdr4.h                             |  13 ++-
 include/linux/fs.h                         |   4 +-
 include/linux/sunrpc/svc.h                 |   1 +
 include/trace/events/sunrpc.h              |  17 ++--
 net/sunrpc/auth_gss/svcauth_gss.c          |  14 ++--
 net/sunrpc/svc_xprt.c                      | 106 ++++++++----------------
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   6 +-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  11 ++-
 18 files changed, 225 insertions(+), 173 deletions(-)

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59198 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755280AbcEXUw3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 May 2016 16:52:29 -0400
Date: Tue, 24 May 2016 16:52:27 -0400
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 4.7
Message-ID: <20160524205227.GA26288@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull nfsd changes from the nfsd-4.7 branch at:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.7

----------------------------------------------------------------
A very quiet cycle for nfsd, mainly just an RDMA update from Chuck Lever.

----------------------------------------------------------------
Chuck Lever (7):
      svcrdma: Do not add XDR padding to xdr_buf page vector
      svcrdma: svc_rdma_put_context() is invoked twice in Send error path
      svcrdma: Remove superfluous line from rdma_read_chunks()
      svcrdma: Post Receives only for forward channel requests
      svcrdma: Drain QP before freeing svcrdma_xprt
      svcrdma: Eliminate code duplication in svc_rdma_recvfrom()
      svcrdma: Generalize svc_rdma_xdr_decode_req()

J. Bruce Fields (2):
      Remove unnecessary allocation
      svcrpc: autoload rdma module

Jeff Layton (1):
      nfsd: handle seqid wraparound in nfsd4_preprocess_layout_stateid

Shirley Ma (1):
      svcrdma: Support IPv6 with NFS/RDMA

Tomáš Trnka (1):
      sunrpc: fix stripping of padded MIC tokens

 fs/nfsd/nfs3xdr.c                        |  2 +-
 fs/nfsd/nfs4layouts.c                    |  2 +-
 fs/nfsd/nfs4state.c                      |  8 +-------
 fs/nfsd/state.h                          |  5 +++++
 include/linux/sunrpc/svc_rdma.h          |  2 +-
 net/sunrpc/auth_gss/svcauth_gss.c        |  9 ++++-----
 net/sunrpc/svc_xprt.c                    | 23 +++++++++++++++++----
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   | 32 ++++++++++++++++++++----------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 34 ++++++++------------------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    | 28 ++++++++++++--------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 17 ++++++++++++++--
 11 files changed, 90 insertions(+), 72 deletions(-)

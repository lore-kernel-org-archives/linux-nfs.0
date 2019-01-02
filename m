Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B55EC43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 20:43:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D74AF2171F
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 20:43:11 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727193AbfABUnK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 15:43:10 -0500
Received: from fieldses.org ([173.255.197.46]:38374 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726009AbfABUnJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Jan 2019 15:43:09 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id F33DB3F3; Wed,  2 Jan 2019 15:43:07 -0500 (EST)
Date:   Wed, 2 Jan 2019 15:43:07 -0500
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd
Message-ID: <20190102204307.GA28209@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull nfsd changes from

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.21

Thanks to Vasily Averin for fixing a use-after-free in the containerized
NFSv4.2 client, and cleaning up some convoluted backchannel server code
in the process.  Otherwise, miscellaneous smaller bugfixes and cleanup.

--b.

----------------------------------------------------------------
Benjamin Coddington (1):
      lockd: Show pid of lockd for remote locks

Chuck Lever (1):
      svcrdma: Optimize the logic that selects the R_key to invalidate

Colin Ian King (1):
      nfsd: clean up indentation, increase indentation in switch statement

J. Bruce Fields (6):
      nfsd4: zero-length WRITE should succeed
      nfsd4: remove unused nfs4_check_olstateid parameter
      nfsd4: forbid all renames during grace period
      nfsd4: skip unused assignment
      lockd: fix decoding of TEST results
      nfsd4: fix crash on writing v4_end_grace before nfsd startup

Julia Lawall (1):
      nfsd: drop useless LIST_HEAD

Olga Kornievskaia (1):
      NFSD remove OP_CACHEME from 4.2 op_flags

Scott Mayhew (1):
      nfsd: fix a warning in __cld_pipe_upcall()

Vasily Averin (12):
      sunrpc: fix cache_head leak due to queued request
      sunrpc: use SVC_NET() in svcauth_gss_* functions
      sunrpc: use-after-free in svc_process_common()
      sunrpc: replace svc_serv->sv_bc_xprt by boolean flag
      sunrpc: remove unused bc_up operation from rpc_xprt_ops
      sunrpc: remove svc_tcp_bc_class
      sunrpc: remove svc_rdma_bc_class
      sunrpc: remove unused xpo_prep_reply_hdr callback
      sunrpc: make visible processing error in bc_svc_process()
      sunrpc: fix debug message in svc_create_xprt()
      nfs: minor typo in nfs4_callback_up_net()
      nfs: fixed broken compilation in nfs_callback_up_net()

zhengbin (1):
      nfsd: Return EPERM, not EACCES, in some SETATTR cases

 fs/lockd/clnt4xdr.c                      |  22 ++----
 fs/lockd/clntproc.c                      |   2 +-
 fs/lockd/clntxdr.c                       |  22 ++----
 fs/lockd/xdr.c                           |   4 +-
 fs/lockd/xdr4.c                          |   4 +-
 fs/nfs/callback.c                        |  10 +--
 fs/nfsd/nfs4layouts.c                    |   1 -
 fs/nfsd/nfs4proc.c                       |  15 ++--
 fs/nfsd/nfs4recover.c                    |  17 ++---
 fs/nfsd/nfs4state.c                      |  10 +--
 fs/nfsd/nfsctl.c                         |   2 +
 fs/nfsd/vfs.c                            |  17 ++++-
 include/linux/sunrpc/bc_xprt.h           |  19 +++--
 include/linux/sunrpc/svc.h               |   7 +-
 include/linux/sunrpc/svc_rdma.h          |   2 +-
 include/linux/sunrpc/svc_xprt.h          |   1 -
 include/linux/sunrpc/xprt.h              |   1 -
 include/trace/events/sunrpc.h            |   6 +-
 net/sunrpc/auth_gss/svcauth_gss.c        |   8 +--
 net/sunrpc/cache.c                       |  10 ++-
 net/sunrpc/svc.c                         |  24 +++++--
 net/sunrpc/svc_xprt.c                    |   9 +--
 net/sunrpc/svcsock.c                     | 120 -------------------------------
 net/sunrpc/xprtrdma/backchannel.c        |  20 ------
 net/sunrpc/xprtrdma/svc_rdma.c           |   6 --
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  63 ++++++++++++++++
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  57 ++++-----------
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  59 ---------------
 net/sunrpc/xprtrdma/transport.c          |   1 -
 net/sunrpc/xprtrdma/xprt_rdma.h          |   1 -
 net/sunrpc/xprtsock.c                    |  12 ----
 31 files changed, 192 insertions(+), 360 deletions(-)

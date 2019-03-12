Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9D6EC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 18:24:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B8E502087C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 18:24:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726451AbfCLSYA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 14:24:00 -0400
Received: from fieldses.org ([173.255.197.46]:57314 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726426AbfCLSYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Mar 2019 14:24:00 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 51E711C17; Tue, 12 Mar 2019 14:23:59 -0400 (EDT)
Date:   Tue, 12 Mar 2019 14:23:59 -0400
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [GIT PULL] nfsd changes for 5.1
Message-ID: <20190312182359.GC29990@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please pull nfsd changes from:

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-5.1

Miscellaneous NFS server fixes.  Probably the most visible bug is one
that could artificially limit NFSv4.1 performance by limiting the number
of oustanding rpcs from a single client.  Neil Brown also gets a special
mention for fixing a 14.5-year-old memory-corruption bug in the encoding
of NFSv3 readdir responses.

--b.

----------------------------------------------------------------
Chuck Lever (2):
      svcrdma: Squelch compiler warning when SUNRPC_DEBUG is disabled
      svcrdma: Remove syslog warnings in work completion handlers

Dan Carpenter (1):
      nfsd: fix an IS_ERR() vs NULL check

Gustavo A. R. Silva (1):
      svcrdma: Use struct_size() in kmalloc()

J. Bruce Fields (4):
      svcrpc: svc_xprt_has_something_to_do seems a little long
      svcrpc: fix unlikely races preventing queueing of sockets
      svcrpc: fix UDP on servers with lots of threads
      nfsd: fix performance-limiting session calculation

NeilBrown (2):
      nfsd: fix memory corruption caused by readdir
      nfsd: allow nfsv3 readdir request to be larger.

Trond Myklebust (1):
      SUNRPC: Don't allow compiler optimisation of svc_xprt_release_slot()

Yihao Wu (1):
      nfsd: fix wrong check in write_v4_end_grace()

 fs/nfsd/nfs3proc.c                       | 18 +++++++++++++++---
 fs/nfsd/nfs3xdr.c                        |  5 ++++-
 fs/nfsd/nfs4callback.c                   |  4 ++--
 fs/nfsd/nfs4state.c                      |  8 ++++----
 fs/nfsd/nfsctl.c                         |  2 +-
 net/sunrpc/svc_xprt.c                    | 24 +++++++++++++++++++-----
 net/sunrpc/svcsock.c                     | 20 ++++++++++----------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  | 12 +++---------
 net/sunrpc/xprtrdma/svc_rdma_rw.c        | 17 ++++-------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  4 ----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  9 +++------
 11 files changed, 65 insertions(+), 58 deletions(-)

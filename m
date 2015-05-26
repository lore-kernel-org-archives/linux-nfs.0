Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:34339 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbEZRsb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 13:48:31 -0400
Received: by qkgx75 with SMTP id x75so95629672qkg.1
        for <linux-nfs@vger.kernel.org>; Tue, 26 May 2015 10:48:30 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 00/10] NFS/RDMA server patches for 4.2
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 May 2015 13:48:26 -0400
Message-ID: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I'd like to see these merged into 4.2. This patch series includes:

 - Don't use a non-byte-swapped value as an array index
 - Fix use of copy_to_user() in a kernel/user space API
 - Annotate memory allocations
 - A server-side pre-requisite for increasing r/wsize on the client
 - A server-side pre-requisite for client RPC/RDMA bi-direction
 - Merged-together xprtrdma and svcrdma kernel modules
 - Miscellaneous clean-ups

You can find these in my git repo in the "nfsd-rdma-for-4.2" topic
branch. See:

  git://git.linux-nfs.org/projects/cel/cel-2.6.git


Changes since v1:
 - Rebased on v4.1-rc5
 - Add patch to merge xprtrdma.ko and svcrdma.ko into one module

---

Chuck Lever (10):
      rpcrdma: Merge svcrdma and xprtrdma modules into one
      SUNRPC: Clean up bc_send()
      svcrdma: Add backward direction service for RPC/RDMA transport
      svcrdma: Add a separate "max data segs macro for svcrdma
      svcrdma: Replace GFP_KERNEL in a loop with GFP_NOFAIL
      svcrdma: Keep rpcrdma_msg fields in network byte-order
      svcrdma: Remove svc_rdma_xdr_decode_deferred_req()
      SUNRPC: Move EXPORT_SYMBOL for svc_process
      svcrdma: Add missing access_ok() call in svc_rdma.c
      svcrdma: Fix byte-swapping in svc_rdma_sendto.c


 include/linux/sunrpc/bc_xprt.h           |    1 
 include/linux/sunrpc/svc_rdma.h          |   17 +++-
 include/linux/sunrpc/xprt.h              |    1 
 net/sunrpc/Kconfig                       |   28 ++----
 net/sunrpc/Makefile                      |    5 -
 net/sunrpc/bc_svc.c                      |   63 --------------
 net/sunrpc/svc.c                         |   35 ++++++--
 net/sunrpc/xprtrdma/Makefile             |   14 +--
 net/sunrpc/xprtrdma/module.c             |   46 ++++++++++
 net/sunrpc/xprtrdma/svc_rdma.c           |   22 +++--
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  140 ++++++++----------------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   16 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   95 ++++++++++++++------
 net/sunrpc/xprtrdma/transport.c          |   13 ---
 net/sunrpc/xprtrdma/xprt_rdma.h          |   11 +-
 16 files changed, 238 insertions(+), 271 deletions(-)
 delete mode 100644 net/sunrpc/bc_svc.c
 create mode 100644 net/sunrpc/xprtrdma/module.c

-- 
Chuck Lever

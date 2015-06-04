Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:33179 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbbFDPUc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 11:20:32 -0400
Received: by qkhg32 with SMTP id g32so25505646qkh.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 08:20:32 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 0/7] NFS/RDMA server patches for 4.2
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Thu, 04 Jun 2015 11:20:25 -0400
Message-ID: <20150604151716.7835.65047.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

This is a simple update of last week's v2, just to keep up to date
with review comments. You can find these in my git repo in the
"nfsd-rdma-for-4.2" topic branch. See:

 git://git.linux-nfs.org/projects/cel/cel-2.6.git


Changes since v2:
- Rebased on v4.1-rc6
- Dropped 2/10, 8/10, and 9/10, as discussed


Changes since v1:
- Rebased on v4.1-rc5
- Add patch to merge xprtrdma.ko and svcrdma.ko into one module

---

Chuck Lever (7):
      rpcrdma: Merge svcrdma and xprtrdma modules into one
      svcrdma: Add a separate "max data segs macro for svcrdma
      svcrdma: Replace GFP_KERNEL in a loop with GFP_NOFAIL
      svcrdma: Keep rpcrdma_msg fields in network byte-order
      svcrdma: Remove svc_rdma_xdr_decode_deferred_req()
      SUNRPC: Move EXPORT_SYMBOL for svc_process
      svcrdma: Fix byte-swapping in svc_rdma_sendto.c


 include/linux/sunrpc/svc_rdma.h          |   11 ++
 net/sunrpc/Kconfig                       |   28 ++----
 net/sunrpc/Makefile                      |    3 -
 net/sunrpc/svc.c                         |    2 
 net/sunrpc/xprtrdma/Makefile             |   14 +--
 net/sunrpc/xprtrdma/module.c             |   46 ++++++++++
 net/sunrpc/xprtrdma/svc_rdma.c           |    8 --
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |  140 ++++++++----------------------
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    2 
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   16 ++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   36 ++------
 net/sunrpc/xprtrdma/transport.c          |   13 ---
 net/sunrpc/xprtrdma/xprt_rdma.h          |   11 +-
 13 files changed, 135 insertions(+), 195 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/module.c

-- 
Chuck Lever

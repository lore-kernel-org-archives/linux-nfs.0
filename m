Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:35237 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbCMVVW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2015 17:21:22 -0400
Received: by ieclw3 with SMTP id lw3so127635193iec.2
        for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2015 14:21:21 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id g76sm2007235iod.8.2015.03.13.14.21.19
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:21:19 -0700 (PDT)
Subject: [PATCH v1 00/16] NFS/RDMA patches proposed for 4.1
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 13 Mar 2015 17:21:17 -0400
Message-ID: <20150313211124.22471.14517.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a series of client-side patches for NFS/RDMA. In preparation
for increasing the transport credit limit and maximum rsize/wsize,
I've re-factored the memory registration logic into separate files,
invoked via a method API.

Two optimizations appear in this series:

The old code pre-allocated 64 MRs for every RPC, and attached 64 MRs
to each RPC before posting it. The new code attaches just enough MRs
to handle each RPC. When no data payload chunk is needed, no MRs are
attached to the RPC. For modern HCAs, only one MR is needed for NFS
read or write data payloads.

The final patch in the series splits the rb_lock in two in order to
reduce lock contention.

The series is also available in the nfs-rdma-for-4.1 topic branch at

 git://linux-nfs.org/projects/cel/cel-2.6.git

---

Chuck Lever (16):
      xprtrdma: Display IPv6 addresses and port numbers correctly
      xprtrdma: Perform a full marshal on retransmit
      xprtrdma: Add vector of ops for each memory registration strategy
      xprtrdma: Add a "max_payload" op for each memreg mode
      xprtrdma: Add a "register_external" op for each memreg mode
      xprtrdma: Add a "deregister_external" op for each memreg mode
      xprtrdma: Add "init MRs" memreg op
      xprtrdma: Add "reset MRs" memreg op
      xprtrdma: Add "destroy MRs" memreg op
      xprtrdma: Add "open" memreg op
      xprtrdma: Handle non-SEND completions via a callout
      xprtrdma: Acquire FMRs in rpcrdma_fmr_register_external()
      xprtrdma: Acquire MRs in rpcrdma_register_external()
      xprtrdma: Remove rpcrdma_ia::ri_memreg_strategy
      xprtrdma: Make rpcrdma_{un}map_one() into inline functions
      xprtrdma: Split rb_lock


 include/linux/sunrpc/xprtrdma.h    |    3 
 net/sunrpc/xprtrdma/Makefile       |    3 
 net/sunrpc/xprtrdma/fmr_ops.c      |  270 +++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |  485 ++++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |  110 +++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |   82 ++-
 net/sunrpc/xprtrdma/transport.c    |   65 ++-
 net/sunrpc/xprtrdma/verbs.c        |  856 +++---------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |  108 ++++-
 9 files changed, 1096 insertions(+), 886 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/physical_ops.c

--
Chuck Lever

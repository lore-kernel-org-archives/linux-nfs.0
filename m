Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:33369 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217AbbC3Sd0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 14:33:26 -0400
Subject: [PATCH v3 00/15] NFS/RDMA patches proposed for 4.1
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 30 Mar 2015 14:33:22 -0400
Message-ID: <20150330182615.7856.61170.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a series of client-side patches for NFS/RDMA. In preparation
for increasing the transport credit limit and maximum rsize/wsize,
I've re-factored the memory registration logic into separate files,
invoked via a method API.

The series is available in the nfs-rdma-for-4.1 topic branch at

git://linux-nfs.org/projects/cel/cel-2.6.git

Changes since v2:
- Rebased on 4.0-rc6
- One minor fix squashed into 01/15
- Tested-by tags added

Changes since v1:
- Rebased on 4.0-rc5
- Main optimizations postponed to 4.2
- Addressed review comments from Anna, Sagi, and Devesh

---

Chuck Lever (15):
      SUNRPC: Introduce missing well-known netids
      xprtrdma: Display IPv6 addresses and port numbers correctly
      xprtrdma: Perform a full marshal on retransmit
      xprtrdma: Byte-align FRWR registration
      xprtrdma: Prevent infinite loop in rpcrdma_ep_create()
      xprtrdma: Add vector of ops for each memory registration strategy
      xprtrdma: Add a "max_payload" op for each memreg mode
      xprtrdma: Add a "register_external" op for each memreg mode
      xprtrdma: Add a "deregister_external" op for each memreg mode
      xprtrdma: Add "init MRs" memreg op
      xprtrdma: Add "reset MRs" memreg op
      xprtrdma: Add "destroy MRs" memreg op
      xprtrdma: Add "open" memreg op
      xprtrdma: Handle non-SEND completions via a callout
      xprtrdma: Make rpcrdma_{un}map_one() into inline functions


 include/linux/sunrpc/msg_prot.h    |    8 
 include/linux/sunrpc/xprtrdma.h    |    5 
 net/sunrpc/xprtrdma/Makefile       |    3 
 net/sunrpc/xprtrdma/fmr_ops.c      |  208 +++++++++++
 net/sunrpc/xprtrdma/frwr_ops.c     |  353 ++++++++++++++++++
 net/sunrpc/xprtrdma/physical_ops.c |   94 +++++
 net/sunrpc/xprtrdma/rpc_rdma.c     |   87 ++--
 net/sunrpc/xprtrdma/transport.c    |   61 ++-
 net/sunrpc/xprtrdma/verbs.c        |  699 +++---------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h    |   90 ++++-
 10 files changed, 882 insertions(+), 726 deletions(-)
 create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/physical_ops.c

--
Chuck Lever

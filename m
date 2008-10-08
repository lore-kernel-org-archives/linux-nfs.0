From: Tom Talpey <talpey@netapp.com>
Subject: [PATCH 00/15] RPC/RDMA patchset for next merge window
Date: Wed, 08 Oct 2008 11:46:53 -0400
Message-ID: <20081008154506.1336.59892.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:44118 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754471AbYJHQWP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 12:22:15 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m98FkrsW001395
	for <linux-nfs@vger.kernel.org>; Wed, 8 Oct 2008 11:46:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series updates the RPC/RDMA (NFS/RDMA) client to
support the new rdma "fastreg" memory registration mode, which
fixes operation on the Chelsio cxgb3 adapter and strengthens
the safety of others.

Additionally, it fixes many smaller issues in the code improving
its robustness and performance. Except for supporting large (>32KB)
rpc's, it addresses all known issues in the client.

It's my hope this patchset can be queued for the upcoming merge
window. It has been extensively tested with both IB and iWARP
adapters under Connectathon and heavy parallel load.

This patchset applies to the current nfs-2.6 git;
	(4330ed8ed4da360ac1ca14b0fddff4c05b10de16)

---

Tom Talpey (14):
      RPC/RDMA: optionally emit useful transport info upon connect/disconnect.
      RPC/RDMA: reformat a debug printk to keep lines together.
      RPC/RDMA: harden connection logic against missing/late rdma_cm upcalls.
      RPC/RDMA: correct a 5 second pause on reconnecting to an idle server.
      RPC/RDMA: fix connect/reconnect resource leak.
      RPC/RDMA: return a consistent error to mount, when connect fails.
      RPC/RDMA: adhere to protocol for unpadded client trailing write chunks.
      RPC/RDMA: avoid an oops due to disconnect racing with async upcalls.
      RPC/RDMA: maintain the RPC task bytes-sent statistic.
      RPC/RDMA: suppress retransmit on RPC/RDMA clients.
      RPC/RDMA: support FRMR client memory registration.
      RPC/RDMA: check selected memory registration mode at runtime.
      RPC/RDMA: add data types and new FRMR memory registration enum.
      RPC/RDMA: refactor the inline memory registration code.

Tom Tucker (1):
      RPC/RDMA: fix connection IRD/ORD setting


 net/sunrpc/xprtrdma/rpc_rdma.c  |   30 +-
 net/sunrpc/xprtrdma/transport.c |   39 +-
 net/sunrpc/xprtrdma/verbs.c     |  737 +++++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   12 +
 4 files changed, 570 insertions(+), 248 deletions(-)

-- 

Tom.

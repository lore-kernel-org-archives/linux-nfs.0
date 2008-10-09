From: Tom Talpey <talpey@netapp.com>
Subject: [UPDATED PATCH 00/14] RPC/RDMA patchset
Date: Thu, 09 Oct 2008 14:59:39 -0400
Message-ID: <20081009185643.13947.64733.stgit@tmt3.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [216.240.26.4] ([216.240.26.4]:15938 "EHLO tmt3.nane.netapp.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754894AbYJIS7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 14:59:40 -0400
Received: from tmt3.nane.netapp.com (localhost.localdomain [127.0.0.1])
	by tmt3.nane.netapp.com (8.14.2/8.14.2) with ESMTP id m99IxdBW014005
	for <linux-nfs@vger.kernel.org>; Thu, 9 Oct 2008 14:59:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following updated series modifies the RPC/RDMA (NFS/RDMA)
client to support the new rdma "fastreg" memory registration mode,
which fixes operation on the Chelsio cxgb3 adapter and strengthens
the safety of others. Additionally, it fixes many smaller issues
in the code improving its robustness and performance. Except for
supporting large (>32KB) rpc's, it addresses all known issues in
the client.

This updated patchset clarifies the author-vs-acked status of
the individual patches, tunes the git log text of some, and omits
the previous patch 12 ("5 second pause") which I'm currently
working on, as per comments.

This patchset applies to the current nfs-2.6 git;
	(69849375d6b13e94d08cdc94b49b11fbab454a0e)

---

Tom Talpey (13):
      RPC/RDMA: optionally emit useful transport info upon connect/disconnect.
      RPC/RDMA: reformat a debug printk to keep lines together.
      RPC/RDMA: harden connection logic against missing/late rdma_cm upcalls.
      RPC/RDMA: fix connect/reconnect resource leak.
      RPC/RDMA: return a consistent error, when connect fails.
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


 include/linux/sunrpc/xprtrdma.h |    4 
 net/sunrpc/xprtrdma/rpc_rdma.c  |   29 +-
 net/sunrpc/xprtrdma/transport.c |   34 +-
 net/sunrpc/xprtrdma/verbs.c     |  735 +++++++++++++++++++++++++++------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   17 +
 5 files changed, 571 insertions(+), 248 deletions(-)

-- 

Tom.

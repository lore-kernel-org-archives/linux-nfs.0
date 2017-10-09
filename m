Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35891 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754365AbdJIQDU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Oct 2017 12:03:20 -0400
Subject: [PATCH v1 0/3] NFS/RDMA client patches for v4.15
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 09 Oct 2017 12:03:17 -0400
Message-ID: <20171009155524.18726.32086.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna-

Here is the first set of NFS/RDMA client patches for v4.15. These
close a window where async RPCs that never receive a Reply will
terminate but let the memory invalidation happen later.

I don't think there was much of an exposure here. Hard async RPCs
typically just hang anyway, they can't be interrupted.

Please consider these patches for v4.15.

---

Chuck Lever (3):
      xprtrdma: Don't defer fencing an async RPC's chunks
      xprtrdma: Use ro_unmap_sync in xprt_rdma_send_request
      xprtrdma: Remove ro_unmap_safe


 net/sunrpc/xprtrdma/fmr_ops.c   |   19 -------------------
 net/sunrpc/xprtrdma/frwr_ops.c  |   19 -------------------
 net/sunrpc/xprtrdma/transport.c |    5 +++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 --
 4 files changed, 3 insertions(+), 42 deletions(-)

--
Chuck Lever

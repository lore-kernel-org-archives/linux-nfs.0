Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:38280 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751218AbdH1TF7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2017 15:05:59 -0400
Subject: [PATCH 0/3] Final NFS/RDMA server patches proposed for v4.14
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 15:05:57 -0400
Message-ID: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

These patches allow svcrdma to adjust more precisely to the limits
of the underlying RDMA device on the server.

These have been floating around for several months, and were posted
a few weeks ago for review on linux-rdma. They should be ready for
you to take for v4.14.

These are the final server-side patches I have for for v4.14 cycle.


---

Chuck Lever (3):
      svcrdma: Limit RQ depth
      rdma core: Add rdma_rw_mr_payload()
      svcrdma: Estimate Send Queue depth properly


 drivers/infiniband/core/rw.c             |   24 ++++++++++++++++++++
 include/rdma/rw.h                        |    2 ++
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   36 +++++++++++++++++++++---------
 3 files changed, 51 insertions(+), 11 deletions(-)

--
Chuck Lever

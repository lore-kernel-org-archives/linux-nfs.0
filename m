Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33077 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336AbbGIUpC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 16:45:02 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 0/5] NFS/RDMA server side for Linux 4.3
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Thu, 09 Jul 2015 16:44:55 -0400
Message-ID: <20150709204230.8481.45457.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some bug fixes and clean up patches, and one change to increase
the maximum NFS r/wsize to one megabyte.

These can be pulled from the "nfsd-rdma-for-4.3" branch in this repo:

  git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or can be browsed here:

  http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.3

---

Chuck Lever (4):
      svcrdma: Boost NFS READ/WRITE payload size maximum
      svcrdma: Remove svc_rdma_fastreg()
      svcrdma: Clean up svc_rdma_get_reply_array()
      svcrdma: Fix send_reply() scatter/gather set-up

Shirley Ma (1):
      NFS/RDMA Release resources in svcrdma when device is removed


 include/linux/sunrpc/svc_rdma.h          |   84 +-----------------------------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   83 +++++++++++++++++++++++++++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   35 -------------
 3 files changed, 86 insertions(+), 116 deletions(-)

-- 
Chuck Lever

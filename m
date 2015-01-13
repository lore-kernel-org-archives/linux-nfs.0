Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43124 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbbAMQCa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:02:30 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 00/10] NFS/RDMA server for 3.20
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:02:28 -0500
Message-ID: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In addition to miscellaneous clean up, the following series of
patches for the Linux NFS server introduces support in the
server’s RPC/RDMA transport implementation for RDMA_NOMSG type
messages, and fixes a bug that prevents the server from handling
RPC/RDMA messages with inline content following the read list.

These patches are contained in the topic branch "nfsd-rdma-for-3.20"
at:

 git://git.linux-nfs.org/projects/cel/cel-2.6.git

Changes since v1:
 - Rebased on 3.19-rc4
 - Patch descriptions clarified
 - Bug addressed in "svcrdma: Handle additional inline content"

---

Chuck Lever (10):
      svcrdma: Handle additional inline content
      svcrdma: Move read list XDR round-up logic
      svcrdma: Support RDMA_NOMSG requests
      svcrdma: rc_position sanity checking
      svcrdma: Plant reader function in struct svcxprt_rdma
      svcrdma: Find rmsgp more reliably
      svcrdma: Scrub BUG_ON() and WARN_ON() call sites
      svcrdma: Clean up read chunk counting
      svcrdma: Remove unused variable
      svcrdma: Clean up dprintk


 include/linux/sunrpc/svc_rdma.h          |   13 +-
 net/sunrpc/xprtrdma/svc_rdma_marshal.c   |   16 --
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |  244 +++++++++++++++++++-----------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |   46 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |   47 ++++--
 5 files changed, 217 insertions(+), 149 deletions(-)

-- 
Chuck Lever

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33781 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcBHRYY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2016 12:24:24 -0500
Subject: [PATCH v2 0/9] NFS/RDMA server patches for v4.6
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 08 Feb 2016 12:24:21 -0500
Message-ID: <20160208171756.13423.14384.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A round of fixes and clean-ups.

Also available in the "nfsd-rdma-for-4.6" topic branch of this git
repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.6


Changes since v1:
o Rebased on v4.5-rc3
o Patch 02/10 (pre-allocate frmrs) dropped
o Patch 04/10 replaced with more surgical patch
o Refined reporting of flushed completions
o Function names of completion methods changed to match client's
   new completion function naming convention

---

Chuck Lever (9):
      svcrdma: Do not send XDR roundup bytes for a write chunk
      svcrdma: svc_rdma_post_recv() should close connection on error
      rpcrdma: Add RPCRDMA_HDRLEN_ERR
      svcrdma: Make RDMA_ERROR messages work
      svcrdma: Use correct XID in error replies
      svcrdma: Hook up the logic to return ERR_CHUNK
      svcrdma: Remove close_out exit path
      svcrdma: Use new CQ API for RPC-over-RDMA server receive CQs
      svcrdma: Use new CQ API for RPC-over-RDMA server send CQs


 include/linux/sunrpc/rpc_rdma.h            |    1 
 include/linux/sunrpc/svc_rdma.h            |   18 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |   15 -
 net/sunrpc/xprtrdma/svc_rdma_marshal.c     |   62 +++-
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   61 ++--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |   79 ++++-
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |  446 +++++++++-------------------
 7 files changed, 299 insertions(+), 383 deletions(-)

--
Chuck Lever

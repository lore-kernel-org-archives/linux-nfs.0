Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:35488 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753838AbcKRPKL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 10:10:11 -0500
Subject: [PATCH v2 00/10] Server-side NFS/RDMA patches proposed for v4.10
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 18 Nov 2016 10:10:08 -0500
Message-ID: <20161118145940.13658.59105.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes proposed for v4.10 include:

- Drop connection on GSS sequence window overflow
- Remove unnecessary spin lock in the svc_rdma_send path
- A number of minor clean-ups

Available in the "nfsd-rdma-for-4.10" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git


Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfsd-rdma-for-4.10

Changes since v1:
 - Rebased on v4.9-rc5
 - Address checkpatch.pl warnings
 - Address compiler warnings
 - Remove a dprintk in svc_rdma_get_inv_rkey()
 - Patches reordered so fixes come before clean-ups


---

Chuck Lever (10):
      svcrdma: Clear xpt_bc_xps in xprt_setup_rdma_bc() error exit arm
      svcauth_gss: Close connection when dropping an incoming message
      svcrdma: Renovate sendto chunk list parsing
      svcrdma: Remove BH-disabled spin locking in svc_rdma_send()
      svcrdma: Remove DMA map accounting
      svcrdma: Remove svc_rdma_op_ctxt::wc_status
      svcrdma: Remove unused variables in xprt_rdma_bc_allocate()
      svcrdma: Remove unused variable in rdma_copy_tail()
      svcrdma: Break up dprintk format in svc_rdma_accept()
      svcrdma: Further clean-up of svc_rdma_get_inv_rkey()


 include/linux/sunrpc/svc_rdma.h            |    7 --
 net/sunrpc/auth_gss/svcauth_gss.c          |    2 
 net/sunrpc/svc.c                           |   14 ++-
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    5 -
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c    |   21 ++++-
 net/sunrpc/xprtrdma/svc_rdma_sendto.c      |  116 ++++++++--------------------
 net/sunrpc/xprtrdma/svc_rdma_transport.c   |   94 +++++++----------------
 7 files changed, 94 insertions(+), 165 deletions(-)

--
Chuck Lever

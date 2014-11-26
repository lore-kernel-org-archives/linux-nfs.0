Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:23990 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239AbaKZQJu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2014 11:09:50 -0500
Message-ID: <5475FB4A.5000502@Netapp.com>
Date: Wed, 26 Nov 2014 11:09:46 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client RDMA changes for 3.19
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond,

The following changes since commit 5d01410fe4d92081f349b013a2e7a95429e4f2c9:

  Linux 3.18-rc6 (2014-11-23 15:25:20 -0800)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-3.19

for you to fetch changes up to 7ff11de1bae02a41cac6503f858218ac1b9a3cbe:

  xprtrdma: Display async errors (2014-11-25 13:39:20 -0500)

Thanks!
Anna

----------------------------------------------------------------
NFS: Client side changes for RDMA

These patches various bugfixes and cleanups for using NFS over RDMA, including
better error handling and performance improvements by using pad optimization.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

----------------------------------------------------------------
Chuck Lever (7):
      xprtrdma: Return an errno from rpcrdma_register_external()
      xprtrdma: Cap req_cqinit
      xprtrdma: unmap all FMRs during transport disconnect
      xprtrdma: Refactor tasklet scheduling
      xprtrdma: Re-write rpcrdma_flush_cqs()
      xprtrdma: Enable pad optimization
      xprtrdma: Display async errors

 net/sunrpc/xprtrdma/transport.c |   4 ++--
 net/sunrpc/xprtrdma/verbs.c     | 114 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/xprt_rdma.h |   6 ++++++
 3 files changed, 107 insertions(+), 17 deletions(-)

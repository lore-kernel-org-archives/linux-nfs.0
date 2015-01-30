Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx142.netapp.com ([216.240.21.19]:60044 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750876AbbA3WHj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Jan 2015 17:07:39 -0500
Message-ID: <54CC00A8.1000808@Netapp.com>
Date: Fri, 30 Jan 2015 17:07:36 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFSoRDMA client changes
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

The following changes since commit ec6f34e5b552fb0a52e6aae1a5afbbb1605cc6cc:

  Linux 3.19-rc5 (2015-01-18 18:02:20 +1200)

are available in the git repository at:

  git://git.linux-nfs.org/projects/anna/nfs-rdma.git tags/nfs-rdma-for-3.20

for you to fetch changes up to a0a1d50cd1e80652142af5cddcde500d06c71bdd:

  xprtrdma: Update the GFP flags used in xprt_rdma_allocate() (2015-01-30 12:18:48 -0500)

Thanks,
Anna

----------------------------------------------------------------
NFS: Client side changes for RDMA

These patches improve the scalability of the NFSoRDMA client and take large
variables off of the stack.  Additionally, the GFP_* flags are updated to
match what TCP uses.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

----------------------------------------------------------------
Chuck Lever (21):
      xprtrdma: human-readable completion status
      xprtrdma: Modernize htonl and ntohl
      xprtrdma: Display XIDs in host byte order
      xprtrdma: Clean up hdrlen
      xprtrdma: Rename "xprt" and "rdma_connect" fields in struct rpcrdma_xprt
      xprtrdma: Remove rpcrdma_ep::rep_ia
      xprtrdma: Remove rl_mr field, and the mr_chunk union
      xprtrdma: Move credit update to RPC reply handler
      xprtrdma: Remove rpcrdma_ep::rep_func and ::rep_xprt
      xprtrdma: Free the pd if ib_query_qp() fails
      xprtrdma: Take struct ib_device_attr off the stack
      xprtrdma: Take struct ib_qp_attr and ib_qp_init_attr off the stack
      xprtrdma: Simplify synopsis of rpcrdma_buffer_create()
      xprtrdma: Refactor rpcrdma_buffer_create() and rpcrdma_buffer_destroy()
      xprtrdma: Add struct rpcrdma_regbuf and helpers
      xprtrdma: Allocate RPC send buffer separately from struct rpcrdma_req
      xprtrdma: Allocate RPC/RDMA send buffer separately from struct rpcrdma_req
      xprtrdma: Allocate RPC/RDMA receive buffer separately from struct rpcrdma_rep
      xprtrdma: Allocate zero pad separately from rpcrdma_buffer
      xprtrdma: Clean up after adding regbuf management
      xprtrdma: Update the GFP flags used in xprt_rdma_allocate()

 include/linux/sunrpc/rpc_rdma.h |  14 +++-
 include/linux/sunrpc/svc_rdma.h |   2 -
 net/sunrpc/xprtrdma/rpc_rdma.c  | 108 +++++++++++++++------------
 net/sunrpc/xprtrdma/transport.c | 182 ++++++++++++++++++++-------------------------
 net/sunrpc/xprtrdma/verbs.c     | 411 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---------------------------------------
 net/sunrpc/xprtrdma/xprt_rdma.h | 111 ++++++++++++++++++----------
 6 files changed, 481 insertions(+), 347 deletions(-)

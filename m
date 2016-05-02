Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:36362 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbcEBSkR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 14:40:17 -0400
Subject: [PATCH v3 00/20] NFS/RDMA client patches proposed for v4.7
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 02 May 2016 14:40:14 -0400
Message-ID: <20160502183144.10798.99847.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anna, IMO these are ready for you to consider for your for-next
branch.

This series implements the following:

Attempt to fence memory regions after a signal interrupts a
synchronous RPC. This prevents a server from writing a reply into a
client's memory after the memory has been released due to a signal.

Support providing a Read list and Reply chunk together in one RPC
call. This is a pre-requisite for using krb5i or krb5p on
RPC-over-RDMA.

In addition, the following changes and fixes are included:

- Use new ib_drain_qp() API
- Advertise max size of NFSv4.1 callbacks on RPC-over-RDMA
- Prevent overflowing server Receive buffers
- Send small NFS WRITEs inline rather than using a Read chunk
- Connection loss is detected sooner on some hardware
- IPv6 addressing for RPC-over-RDMA


Available in the "nfs-rdma-for-4.7" topic branch of this git repo:

git://git.linux-nfs.org/projects/cel/cel-2.6.git

Or for browsing:

http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.7


Client changes since v2:

- Rebased on v4.6-rc6
- Fixed a bug in the "Read list + Reply chunk" patch
- Added Tested-by and Reviewed-by tags
- Updated patch description of patch that introduces fr_dir
- Removed extra debugging from "fast disconnect recovery" patch
- Included Shirley's IPv6 patch
- Bumped RPCBIND_MAXNETIDLEN to accommodate "local" and "rdma6"


Changes since v1:
- Rebased on v4.6-rc5
- Updated patch description for "Avoid using Write list for ..."


---

Chuck Lever (19):
      sunrpc: Update RPCBIND_MAXNETIDLEN
      sunrpc: Advertise maximum backchannel payload size
      xprtrdma: Bound the inline threshold values
      xprtrdma: Limit number of RDMA segments in RPC-over-RDMA headers
      xprtrdma: Prevent inline overflow
      xprtrdma: Avoid using Write list for small NFS READ requests
      xprtrdma: Update comments in rpcrdma_marshal_req()
      xprtrdma: Allow Read list and Reply chunk simultaneously
      xprtrdma: Remove rpcrdma_create_chunks()
      xprtrdma: Use core ib_drain_qp() API
      xprtrdma: Rename rpcrdma_frwr::sg and sg_nents
      xprtrdma: Save I/O direction in struct rpcrdma_frwr
      xprtrdma: Reset MRs in frwr_op_unmap_sync()
      xprtrdma: Refactor the FRWR recovery worker
      xprtrdma: Move fr_xprt and fr_worker to struct rpcrdma_mw
      xprtrdma: Refactor __fmr_dma_unmap()
      xprtrdma: Add ro_unmap_safe memreg method
      xprtrdma: Remove ro_unmap() from all registration modes
      xprtrdma: Faster server reboot recovery

Shirley Ma (1):
      xprtrdma: Add rdma6 option to support NFS/RDMA IPv6


 fs/nfs/nfs4proc.c                  |   10 -
 fs/nfs/super.c                     |    4 
 include/linux/sunrpc/clnt.h        |    1 
 include/linux/sunrpc/msg_prot.h    |    4 
 include/linux/sunrpc/xprt.h        |    1 
 include/linux/sunrpc/xprtrdma.h    |    4 
 net/sunrpc/clnt.c                  |   17 +
 net/sunrpc/xprtrdma/backchannel.c  |   16 +
 net/sunrpc/xprtrdma/fmr_ops.c      |  134 +++++++--
 net/sunrpc/xprtrdma/frwr_ops.c     |  214 ++++++++-------
 net/sunrpc/xprtrdma/physical_ops.c |   39 ++-
 net/sunrpc/xprtrdma/rpc_rdma.c     |  517 ++++++++++++++++++++++--------------
 net/sunrpc/xprtrdma/transport.c    |   16 +
 net/sunrpc/xprtrdma/verbs.c        |   75 +----
 net/sunrpc/xprtrdma/xprt_rdma.h    |   46 +++
 net/sunrpc/xprtsock.c              |    6 
 16 files changed, 670 insertions(+), 434 deletions(-)

--
Chuck Lever

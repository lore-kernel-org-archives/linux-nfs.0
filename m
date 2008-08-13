From: Tom Tucker <tom@opengridcomputing.com>
Subject: [PATCH,RFC 00/02] xprtrdma: Client Fast Memory Registration Support
Date: Wed, 13 Aug 2008 11:17:21 -0500
Message-ID: <48A30911.90903@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Tom Talpey <Thomas.Talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:36766 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751993AbYHMQRW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 12:17:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This set of patches implements support for Fast Memory Registration in
the NFS client. Fast Memory Registration is enabled by writing 6 to
the rdma_memreg_strategy proc file as follows:

# echo 6 > /proc/sys/sunrpc/rdma_memreg_strategy

If Fast Memory Registration is not supported by the device, the
memory registration strategy reverts to a global default that
is supported by all RDMA adapters.

This patches are also available here:
git://git.linux-nfs.org/projects/tomtucker/xprt-switch-2.6.git

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>

[PATCH 01/02] xprtrdma: Add data types to support FRMR

  include/linux/sunrpc/xprtrdma.h |    1 +
  net/sunrpc/xprtrdma/xprt_rdma.h |   10 +++++++++-
  2 files changed, 10 insertions(+), 1 deletions(-)

[PATCH 02/02] xprtrdma: Update the RPC memory registration to use FRMR

  net/sunrpc/xprtrdma/verbs.c |  296 ++++++++++++++++++++++++++++++++++++++-----
  1 files changed, 263 insertions(+), 33 deletions(-)

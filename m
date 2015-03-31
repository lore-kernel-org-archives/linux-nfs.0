Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:54014 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754498AbbCaO0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 10:26:44 -0400
Message-ID: <551AAEA1.3010105@Netapp.com>
Date: Tue, 31 Mar 2015 10:26:41 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 00/15] NFS/RDMA patches proposed for 4.1
References: <20150330182615.7856.61170.stgit@manet.1015granger.net>
In-Reply-To: <20150330182615.7856.61170.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/30/2015 02:33 PM, Chuck Lever wrote:
> This is a series of client-side patches for NFS/RDMA. In preparation
> for increasing the transport credit limit and maximum rsize/wsize,
> I've re-factored the memory registration logic into separate files,
> invoked via a method API.
> 
> The series is available in the nfs-rdma-for-4.1 topic branch at
> 
> git://linux-nfs.org/projects/cel/cel-2.6.git

Thanks!  I've applied these and pushed them out to my nfs-rdma git tree.

Anna

> 
> Changes since v2:
> - Rebased on 4.0-rc6
> - One minor fix squashed into 01/15
> - Tested-by tags added
> 
> Changes since v1:
> - Rebased on 4.0-rc5
> - Main optimizations postponed to 4.2
> - Addressed review comments from Anna, Sagi, and Devesh
> 
> ---
> 
> Chuck Lever (15):
>       SUNRPC: Introduce missing well-known netids
>       xprtrdma: Display IPv6 addresses and port numbers correctly
>       xprtrdma: Perform a full marshal on retransmit
>       xprtrdma: Byte-align FRWR registration
>       xprtrdma: Prevent infinite loop in rpcrdma_ep_create()
>       xprtrdma: Add vector of ops for each memory registration strategy
>       xprtrdma: Add a "max_payload" op for each memreg mode
>       xprtrdma: Add a "register_external" op for each memreg mode
>       xprtrdma: Add a "deregister_external" op for each memreg mode
>       xprtrdma: Add "init MRs" memreg op
>       xprtrdma: Add "reset MRs" memreg op
>       xprtrdma: Add "destroy MRs" memreg op
>       xprtrdma: Add "open" memreg op
>       xprtrdma: Handle non-SEND completions via a callout
>       xprtrdma: Make rpcrdma_{un}map_one() into inline functions
> 
> 
>  include/linux/sunrpc/msg_prot.h    |    8 
>  include/linux/sunrpc/xprtrdma.h    |    5 
>  net/sunrpc/xprtrdma/Makefile       |    3 
>  net/sunrpc/xprtrdma/fmr_ops.c      |  208 +++++++++++
>  net/sunrpc/xprtrdma/frwr_ops.c     |  353 ++++++++++++++++++
>  net/sunrpc/xprtrdma/physical_ops.c |   94 +++++
>  net/sunrpc/xprtrdma/rpc_rdma.c     |   87 ++--
>  net/sunrpc/xprtrdma/transport.c    |   61 ++-
>  net/sunrpc/xprtrdma/verbs.c        |  699 +++---------------------------------
>  net/sunrpc/xprtrdma/xprt_rdma.h    |   90 ++++-
>  10 files changed, 882 insertions(+), 726 deletions(-)
>  create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
>  create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
>  create mode 100644 net/sunrpc/xprtrdma/physical_ops.c
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


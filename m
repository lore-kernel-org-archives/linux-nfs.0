From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH] SUNRPC xptrdma: simplify build configuration
Date: Wed, 12 Dec 2007 12:52:38 -0500
Message-ID: <5A1B985E-0098-488C-8724-2E0C017FC764@oracle.com>
References: <Pine.LNX.4.64.0712121059260.12638@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org,
	nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51200 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbXLLRzS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2007 12:55:18 -0500
In-Reply-To: <Pine.LNX.4.64.0712121059260.12638-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 12, 2007, at 11:03 AM, James Lentini wrote:
> During the review of Tom Tucker's server RPC/RDMA transport patchset,
> we receive a request to simplify the RPC/RDMA client and server build
> configuration.
>
> To simplify the configuration, we propose to make XPRT_RDMA a hidden
> config option that continues to depend on SUNRPC and INFINIBAND. The
> value of XPRT_RDMA will be
>
>  - N if either SUNRPC or INFINIBAND are N
>  - M if both SUNRPC and INFINIBAND are on (M or Y) and at least one  
> is M
>  - Y if both SUNRPC and INFINIBAND are Y
>
> In the next server RPC/RDMA transport patchset, we will group all the
> RPC/RDMA related files in net/sunrpc/xprtrdma and update the
> net/sunrpc/xprtrdma/Makefile to build both the client and server
> RPC/RDMA support using this config option.

That's a step in the right direction, IMO.

SUNRPC is always enabled (M or Y) if either the NFS client or server  
are requested.  So, is the intent then always to build the RPC RDMA  
transport module if NFS and INFINIBAND are enabled?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




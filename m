From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile (second thread)
Date: Mon, 3 Dec 2007 12:08:00 -0500
Message-ID: <2E823541-6441-4605-8F15-440954CED454@oracle.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071129224513.14887.8074.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:13176 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbXLCRJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 12:09:15 -0500
In-Reply-To: <20071129224513.14887.8074.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
> Add the NFSD_RDMA module to the sunrpc makefile.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  net/sunrpc/Makefile |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
>
> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> index 92e1dbe..6d03dbf 100644
> --- a/net/sunrpc/Makefile
> +++ b/net/sunrpc/Makefile
> @@ -15,3 +15,7 @@ sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o  
> sched.o \
>  	    svc_xprt.o
>  sunrpc-$(CONFIG_PROC_FS) += stats.o
>  sunrpc-$(CONFIG_SYSCTL) += sysctl.o
> +
> +obj-$(CONFIG_NFSD_RDMA) += svcrdma.o
> +svcrdma-y := svc_rdma.o svc_rdma_transport.o \
> +	svc_rdma_marshal.o svc_rdma_sendto.o svc_rdma_recvfrom.o


Maybe it would be better to enable server-side RPC RDMA provider  
support with a separate config option, like the client side does it,  
then build the NFS server dependency on that, instead of adding it  
here in the RPC makefile.

If the client-side and server-side providers are merged, then they  
could both be enabled via CONFIG_SUNRPC_XPRT_RDMA.

Comments?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

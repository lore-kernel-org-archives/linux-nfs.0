From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH 7/8] rdma: makefile
Date: Mon, 3 Dec 2007 12:00:56 -0500
Message-ID: <2F4C0A61-33B5-4D2D-9349-657EC856A8B2@oracle.com>
References: <20071129224412.14887.14136.stgit@dell3.ogc.int> <20071129224513.14887.8074.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:64794 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbXLCRDE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2007 12:03:04 -0500
In-Reply-To: <20071129224513.14887.8074.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 29, 2007, at 5:45 PM, Tom Tucker wrote:
> Add the NFSD_RDMA module to the sunrpc makefile.

General question about how the RPC level RDMA code is organized:  The  
client-side RDMA service provider lives in its own subdirectory of  
net/sunrpc.  Should the server side provider also live in that  
directory?  Should these two be glued together into a single module?

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


--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

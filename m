Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:39005 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932769AbaDVPFR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Apr 2014 11:05:17 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH V2 03/17] xprtrdma: Enable RDMA pad optimization by default
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20140421220111.12569.77783.stgit@manet.1015granger.net>
Date: Tue, 22 Apr 2014 11:05:06 -0400
Message-Id: <F58C1C4A-92FD-4A32-87FA-22ECA614B078@oracle.com>
References: <20140421214442.12569.8950.stgit@manet.1015granger.net> <20140421220111.12569.77783.stgit@manet.1015granger.net>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 21, 2014, at 6:01 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> Section 4 of RFC 5667 (NFS/RDMA) says:
> 
>> The server MUST ignore any Read list for other NFS procedures,
>> as well as additional Read list entries beyond the first in the
>> list.
> 
> Our XDR code adds a zero pad at the end of NFS WRITEs and SYMLINKs
> whose content is not a multiple of 4 octets long.  xprtrdma treats
> the tail buffer containing the zero pad as a separate read chunk,
> which the server ignores.
> 
> Enable the pad optimization so our NFS client avoids sending zeroes
> the server is just going to ignore.

Looks like the Linux NFS/RDMA server is not spec compliant here.
When pad optimization is enabled, the Linux NFS/RDMA server returns
GARBAGEARGS for WRITEs whose length does not align with an XDR_QUAD.

Dropping this one for now.


> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
> net/sunrpc/xprtrdma/transport.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
> index 1eb9c46..f94a6c4 100644
> --- a/net/sunrpc/xprtrdma/transport.c
> +++ b/net/sunrpc/xprtrdma/transport.c
> @@ -73,7 +73,7 @@ static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
> static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
> static unsigned int xprt_rdma_inline_write_padding;
> static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
> -                int xprt_rdma_pad_optimize = 0;
> +int		    xprt_rdma_pad_optimize = 1;
> 
> #ifdef RPC_DEBUG
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




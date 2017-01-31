Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:42040 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751749AbdAaTsY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jan 2017 14:48:24 -0500
Subject: Re: [PATCH 4.10-rc3 01/13] net: sunrpc: fix build errors when
 linux/phy*.h is removed from net/dsa.h
To: Russell King <rmk+kernel@armlinux.org.uk>, <linux-mips@linux-mips.org>,
        <linux-nfs@vger.kernel.org>, <linux-scsi@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
        <netdev@vger.kernel.org>, <target-devel@vger.kernel.org>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
 <E1cYdwi-0000Vs-97@rmk-PC.armlinux.org.uk>
CC: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <52ceb082-1e0a-7210-833a-f4ac22df4b8c@Netapp.com>
Date: Tue, 31 Jan 2017 14:48:02 -0500
MIME-Version: 1.0
In-Reply-To: <E1cYdwi-0000Vs-97@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Russell,

On 01/31/2017 02:18 PM, Russell King wrote:
> Removing linux/phy.h from net/dsa.h reveals a build error in the sunrpc
> code:
> 
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c: In function 'xprt_rdma_bc_put':
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c:277:2: error: implicit declaration of function 'module_put' [-Werror=implicit-function-declaration]
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c: In function 'xprt_setup_rdma_bc':
> net/sunrpc/xprtrdma/svc_rdma_backchannel.c:348:7: error: implicit declaration of function 'try_module_get' [-Werror=implicit-function-declaration]
> 
> Fix this by adding linux/module.h to svc_rdma_backchannel.c
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

This patch looks okay to me:

Acked-by: Anna Schumaker <Anna.Schumaker@Netapp.com>

> ---
>  net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> index 288e35c2d8f4..cb1e48e54eb1 100644
> --- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> +++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> @@ -4,6 +4,7 @@
>   * Support for backward direction RPCs on RPC/RDMA (server-side).
>   */
>  
> +#include <linux/module.h>
>  #include <linux/sunrpc/svc_rdma.h>
>  #include "xprt_rdma.h"
>  
> 

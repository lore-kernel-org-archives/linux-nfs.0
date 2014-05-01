Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f172.google.com ([74.125.82.172]:58115 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbaEAHgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 03:36:24 -0400
Received: by mail-we0-f172.google.com with SMTP id u57so2766370wes.31
        for <linux-nfs@vger.kernel.org>; Thu, 01 May 2014 00:36:23 -0700 (PDT)
Message-ID: <5361F973.20707@dev.mellanox.co.il>
Date: Thu, 01 May 2014 03:36:19 -0400
From: Hal Rosenstock <hal@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        Anna.Schumaker@netapp.com
Subject: Re: [PATCH V3 17/17] xprtrdma: Remove Tavor MTU setting
References: <20140430191433.5663.16217.stgit@manet.1015granger.net> <20140430193155.5663.86148.stgit@manet.1015granger.net>
In-Reply-To: <20140430193155.5663.86148.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/30/2014 3:31 PM, Chuck Lever wrote:
> Clean up.  Remove HCA-specific clutter in xprtrdma, which is
> supposed to be device-independent.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/xprtrdma/verbs.c |   14 --------------
>  1 files changed, 0 insertions(+), 14 deletions(-)
> 
> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 54edf2a..515dfc1 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -48,7 +48,6 @@
>   */
>  
>  #include <linux/interrupt.h>
> -#include <linux/pci.h>	/* for Tavor hack below */
>  #include <linux/slab.h>
>  #include <asm/bitops.h>
>  
> @@ -920,19 +919,6 @@ retry:
>  		}
>  	}
>  
> -/* XXX Tavor device performs badly with 2K MTU! */
> -if (strnicmp(ia->ri_id->device->dma_device->bus->name, "pci", 3) == 0) {
> -	struct pci_dev *pcid = to_pci_dev(ia->ri_id->device->dma_device);
> -	if (pcid->device == PCI_DEVICE_ID_MELLANOX_TAVOR &&
> -	    (pcid->vendor == PCI_VENDOR_ID_MELLANOX ||
> -	     pcid->vendor == PCI_VENDOR_ID_TOPSPIN)) {
> -		struct ib_qp_attr attr = {
> -			.path_mtu = IB_MTU_1024
> -		};
> -		rc = ib_modify_qp(ia->ri_id->qp, &attr, IB_QP_PATH_MTU);

Note that there is OpenSM option (enable_quirks) to return 1K MTU in SA
PathRecord responses for Tavor so that can be used for this. The default
setting for enable_quirks is FALSE so that would need changing.

-- Hal

> -	}
> -}
> -
>  	ep->rep_connected = 0;
>  
>  	rc = rdma_connect(ia->ri_id, &ep->rep_remote_cma);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


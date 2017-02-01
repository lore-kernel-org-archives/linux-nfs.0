Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtpout.microchip.com ([198.175.253.82]:36568 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751404AbdBAJkc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 04:40:32 -0500
Subject: Re: [PATCH 4.10-rc3 03/13] net: macb: fix build errors when
 linux/phy*.h is removed from net/dsa.h
To: Russell King <rmk+kernel@armlinux.org.uk>,
        <linux-mips@linux-mips.org>, <linux-nfs@vger.kernel.org>,
        <linux-scsi@vger.kernel.org>, <linux-usb@vger.kernel.org>,
        <linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
        <target-devel@vger.kernel.org>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
 <E1cYdws-0000W9-GV@rmk-PC.armlinux.org.uk>
CC: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
From: Nicolas Ferre <nicolas.ferre@atmel.com>
Message-ID: <0a75edf8-df17-fb7f-294f-8c1e04479a3b@atmel.com>
Date: Wed, 1 Feb 2017 10:40:53 +0100
MIME-Version: 1.0
In-Reply-To: <E1cYdws-0000W9-GV@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le 31/01/2017 à 20:18, Russell King a écrit :
> drivers/net/ethernet/cadence/macb.h:862:33: sparse: expected ; at end of declaration
> drivers/net/ethernet/cadence/macb.h:862:33: sparse: Expected } at end of struct-union-enum-specifier
> drivers/net/ethernet/cadence/macb.h:862:33: sparse: got phy_interface
> drivers/net/ethernet/cadence/macb.h:877:1: sparse: Expected ; at the end of type declaration
> drivers/net/ethernet/cadence/macb.h:877:1: sparse: got }
> In file included from drivers/net/ethernet/cadence/macb_pci.c:29:0:
> drivers/net/ethernet/cadence/macb.h:862:2: error: unknown type name 'phy_interface_t'
>      phy_interface_t  phy_interface;
>      ^~~~~~~~~~~~~~~
> 
> Add linux/phy.h to macb.h
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index d67adad67be1..383da8cf5f6d 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -10,6 +10,8 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +#include <linux/phy.h>
> +
>  #define MACB_GREGS_NBR 16
>  #define MACB_GREGS_VERSION 2
>  #define MACB_MAX_QUEUES 8
> 


-- 
Nicolas Ferre

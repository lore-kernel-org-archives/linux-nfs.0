Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47158 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751086AbdBAK11 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2017 05:27:27 -0500
Date: Wed, 1 Feb 2017 11:27:14 +0100
From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Russell King <rmk+kernel@armlinux.org.uk>
Cc: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4.10-rc3 07/13] net: mvneta: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Message-ID: <20170201112714.03fc236e@free-electrons.com>
In-Reply-To: <E1cYdxD-0000Wd-1D@rmk-PC.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
        <E1cYdxD-0000Wd-1D@rmk-PC.armlinux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Tue, 31 Jan 2017 19:18:59 +0000, Russell King wrote:
> drivers/net/ethernet/marvell/mvneta.c:2694:26: error: storage size of 'status' isn't known
> drivers/net/ethernet/marvell/mvneta.c:2695:26: error: storage size of 'changed' isn't known
> drivers/net/ethernet/marvell/mvneta.c:2695:9: error: variable 'changed' has initializer but incomplete type
> drivers/net/ethernet/marvell/mvneta.c:2709:2: error: implicit declaration of function 'fixed_phy_update_state' [-Werror=implicit-function-declaration]
> 
> Add linux/phy_fixed.h to mvneta.c
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

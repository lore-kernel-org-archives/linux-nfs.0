Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:49660 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750881AbdAaUP4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 15:15:56 -0500
Subject: Re: [PATCH 4.10-rc3 08/13] net: emac: fix build errors when
 linux/phy*.h is removed from net/dsa.h
To: Russell King <rmk+kernel@armlinux.org.uk>,
        linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
 <E1cYdxI-0000Wk-5w@rmk-PC.armlinux.org.uk>
From: Timur Tabi <timur@codeaurora.org>
Message-ID: <c7dd612a-fa69-12ca-fd53-44649a18dd11@codeaurora.org>
Date: Tue, 31 Jan 2017 14:15:50 -0600
MIME-Version: 1.0
In-Reply-To: <E1cYdxI-0000Wk-5w@rmk-PC.armlinux.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/31/2017 01:19 PM, Russell King wrote:
> drivers/net/ethernet/qualcomm/emac/emac-sgmii.c:58:12: error: dereferencing pointer to incomplete type 'struct phy_device'
>
> Add linux/phy.h to emac-sgmii.c
>
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> ---
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 1 +

The version of emac-sgmii.c on net-next does not need this fixed.  I already 
removed all references to phy_device in commit "net: qcom/emac: always use 
autonegotiation to configure the SGMII link".

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

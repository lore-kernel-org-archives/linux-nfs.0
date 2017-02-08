Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.linux-iscsi.org ([67.23.28.174]:58710 "EHLO
        linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751131AbdBHFBO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2017 00:01:14 -0500
Message-ID: <1486529606.13263.29.camel@haakon3.risingtidesystems.com>
Subject: Re: [PATCH net-next v2 08/12] iscsi: fix build errors when
 linux/phy*.h is removed from net/dsa.h
From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        target-devel@vger.kernel.org,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jiri Slaby <jirislaby@gmail.com>, Kalle Valo <kvalo@codeaurora.org>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        Nick Kossifidis <mickflemm@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Timur Tabi <timur@codeaurora.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung Huh <woojung.huh@microchip.com>
Date: Tue, 07 Feb 2017 20:53:26 -0800
In-Reply-To: <20170207230305.18222-9-f.fainelli@gmail.com>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
         <20170207230305.18222-9-f.fainelli@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Florian,

On Tue, 2017-02-07 at 15:03 -0800, Florian Fainelli wrote:
> From: Russell King <rmk+kernel@armlinux.org.uk>
> 
> drivers/target/iscsi/iscsi_target_login.c:1135:7: error: implicit declaration of function 'try_module_get' [-Werror=implicit-function-declaration]
> 
> Add linux/module.h to iscsi_target_login.c.
> 
> Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> Reviewed-by: Bart Van Assche <bart.vanassche@sandisk.com>
> ---

Acked-by: Nicholas Bellinger <nab@linux-iscsi.org>


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:32794 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932707AbdBGXLd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 18:11:33 -0500
From: Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org, linux-mips@linux-mips.org,
        linux-nfs@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: Russell King <rmk+kernel@armlinux.org.uk>,
        Andrew Lunn <andrew@lunn.ch>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Jiri Slaby <jirislaby@gmail.com>, Kalle Valo <kvalo@codeaurora.org>,
        "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
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
Subject: [PATCH net-next v2 03/12] net: macb: fix build errors when linux/phy*.h is removed from net/dsa.h
Date: Tue,  7 Feb 2017 15:02:56 -0800
Message-Id: <20170207230305.18222-4-f.fainelli@gmail.com>
In-Reply-To: <20170207230305.18222-1-f.fainelli@gmail.com>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>

drivers/net/ethernet/cadence/macb.h:862:33: sparse: expected ; at end of declaration
drivers/net/ethernet/cadence/macb.h:862:33: sparse: Expected } at end of struct-union-enum-specifier
drivers/net/ethernet/cadence/macb.h:862:33: sparse: got phy_interface
drivers/net/ethernet/cadence/macb.h:877:1: sparse: Expected ; at the end of type declaration
drivers/net/ethernet/cadence/macb.h:877:1: sparse: got }
In file included from drivers/net/ethernet/cadence/macb_pci.c:29:0:
drivers/net/ethernet/cadence/macb.h:862:2: error: unknown type name 'phy_interface_t'
     phy_interface_t  phy_interface;
     ^~~~~~~~~~~~~~~

Add linux/phy.h to macb.h

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index a2cf91223003..234a49eaccfd 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -10,6 +10,8 @@
 #ifndef _MACB_H
 #define _MACB_H
 
+#include <linux/phy.h>
+
 #define MACB_GREGS_NBR 16
 #define MACB_GREGS_VERSION 2
 #define MACB_MAX_QUEUES 8
-- 
2.9.3


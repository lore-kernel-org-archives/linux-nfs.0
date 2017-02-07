Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35136 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdBGXFa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 18:05:30 -0500
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
Subject: [PATCH net-next v2 05/12] net: bgmac: fix build errors when linux/phy*.h is removed from net/dsa.h
Date: Tue,  7 Feb 2017 15:02:58 -0800
Message-Id: <20170207230305.18222-6-f.fainelli@gmail.com>
In-Reply-To: <20170207230305.18222-1-f.fainelli@gmail.com>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>

drivers/net/ethernet/broadcom/bgmac.c:1015:17: error: dereferencing pointer to incomplete type 'struct mii_bus'
drivers/net/ethernet/broadcom/bgmac.c:1185:2: error: implicit declaration of function 'phy_start' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1198:2: error: implicit declaration of function 'phy_stop' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1239:9: error: implicit declaration of function 'phy_mii_ioctl' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1389:28: error: 'phy_ethtool_get_link_ksettings' undeclared here (not in a function)
drivers/net/ethernet/broadcom/bgmac.c:1390:28: error: 'phy_ethtool_set_link_ksettings' undeclared here (not in a function)
drivers/net/ethernet/broadcom/bgmac.c:1403:13: error: dereferencing pointer to incomplete type 'struct phy_device'
drivers/net/ethernet/broadcom/bgmac.c:1417:3: error: implicit declaration of function 'phy_print_status' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1424:26: error: storage size of 'fphy_status' isn't known
drivers/net/ethernet/broadcom/bgmac.c:1424:9: error: variable 'fphy_status' has initializer but incomplete type
drivers/net/ethernet/broadcom/bgmac.c:1425:11: warning: excess elements in struct initializer
drivers/net/ethernet/broadcom/bgmac.c:1425:3: error: unknown field 'link' specified in initializer
drivers/net/ethernet/broadcom/bgmac.c:1426:12: note: in expansion of macro 'SPEED_1000'
drivers/net/ethernet/broadcom/bgmac.c:1426:3: error: unknown field 'speed' specified in initializer
drivers/net/ethernet/broadcom/bgmac.c:1427:13: note: in expansion of macro 'DUPLEX_FULL'
drivers/net/ethernet/broadcom/bgmac.c:1427:3: error: unknown field 'duplex' specified in initializer
drivers/net/ethernet/broadcom/bgmac.c:1432:12: error: implicit declaration of function 'fixed_phy_register' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1432:31: error: 'PHY_POLL' undeclared (first use in this function)
drivers/net/ethernet/broadcom/bgmac.c:1438:8: error: implicit declaration of function 'phy_connect_direct' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1439:6: error: 'PHY_INTERFACE_MODE_MII' undeclared (first use in this function)
drivers/net/ethernet/broadcom/bgmac.c:1521:2: error: implicit declaration of function 'phy_disconnect' [-Werror=implicit-function-declaration]
drivers/net/ethernet/broadcom/bgmac.c:1541:15: error: expected declaration specifiers or '...' before string constant

Add linux/phy.h to bgmac.c

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
Acked-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/ethernet/broadcom/bgmac.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index fe88126b1e0c..20fe2520da42 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -12,6 +12,8 @@
 #include <linux/bcma/bcma.h>
 #include <linux/etherdevice.h>
 #include <linux/bcm47xx_nvram.h>
+#include <linux/phy.h>
+#include <linux/phy_fixed.h>
 #include "bgmac.h"
 
 static bool bgmac_wait_value(struct bgmac *bgmac, u16 reg, u32 mask,
-- 
2.9.3


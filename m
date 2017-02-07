Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35724 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754300AbdBGXFa (ORCPT
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
Subject: [PATCH net-next v2 11/12] net: ath5k: fix build errors when linux/phy*.h is removed from net/dsa.h
Date: Tue,  7 Feb 2017 15:03:04 -0800
Message-Id: <20170207230305.18222-12-f.fainelli@gmail.com>
In-Reply-To: <20170207230305.18222-1-f.fainelli@gmail.com>
References: <20170207230305.18222-1-f.fainelli@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Russell King <rmk+kernel@armlinux.org.uk>

Fix these errors reported by the 0-day builder by replacing the
linux/export.h include with linux/module.h.

In file included from include/linux/platform_device.h:14:0,
                 from drivers/net/wireless/ath/ath5k/ahb.c:20:
include/linux/device.h:1463:1: warning: data definition has no type or storage class
 module_init(__driver##_init); \
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
include/linux/device.h:1463:1: error: type defaults to 'int' in declaration of 'module_init' [-Werror=implicit-int]
 module_init(__driver##_init); \
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: warning: parameter names (without types) in function declaration
In file included from include/linux/platform_device.h:14:0,
                 from drivers/net/wireless/ath/ath5k/ahb.c:20:
include/linux/device.h:1468:1: warning: data definition has no type or storage class
 module_exit(__driver##_exit);
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
include/linux/device.h:1468:1: error: type defaults to 'int' in declaration of 'module_exit' [-Werror=implicit-int]
 module_exit(__driver##_exit);
 ^
include/linux/platform_device.h:228:2: note: in expansion of macro 'module_driver'
  module_driver(__platform_driver, platform_driver_register, \
  ^~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: warning: parameter names (without types) in function declaration
In file included from include/linux/platform_device.h:14:0,
                 from drivers/net/wireless/ath/ath5k/ahb.c:20:
drivers/net/wireless/ath/ath5k/ahb.c:233:24: warning: 'ath_ahb_driver_exit' defined but not used [-Wunused-function]
 module_platform_driver(ath_ahb_driver);
                        ^
include/linux/device.h:1464:20: note: in definition of macro 'module_driver'
 static void __exit __driver##_exit(void) \
                    ^~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:24: warning: 'ath_ahb_driver_init' defined but not used [-Wunused-function]
 module_platform_driver(ath_ahb_driver);
                        ^
include/linux/device.h:1459:19: note: in definition of macro 'module_driver'
 static int __init __driver##_init(void) \
                   ^~~~~~~~
drivers/net/wireless/ath/ath5k/ahb.c:233:1: note: in expansion of macro 'module_platform_driver'
 module_platform_driver(ath_ahb_driver);
 ^~~~~~~~~~~~~~~~~~~~~~

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
Acked-by: Kalle Valo <kvalo@codeaurora.org>
---
 drivers/net/wireless/ath/ath5k/ahb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath5k/ahb.c b/drivers/net/wireless/ath/ath5k/ahb.c
index 2ca88b593e4c..c0794f5988b3 100644
--- a/drivers/net/wireless/ath/ath5k/ahb.c
+++ b/drivers/net/wireless/ath/ath5k/ahb.c
@@ -16,10 +16,10 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#include <linux/module.h>
 #include <linux/nl80211.h>
 #include <linux/platform_device.h>
 #include <linux/etherdevice.h>
-#include <linux/export.h>
 #include <ath25_platform.h>
 #include "ath5k.h"
 #include "debug.h"
-- 
2.9.3


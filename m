Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:33064 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751675AbdAaTW2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 14:22:28 -0500
In-Reply-To: <20170131191704.GA8281@n2100.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
From: Russell King <rmk+kernel@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 4.10-rc3 13/13] net: dsa: remove unnecessary phy*.h includes
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Message-Id: <E1cYdxh-0000XJ-RN@rmk-PC.armlinux.org.uk>
Date: Tue, 31 Jan 2017 19:19:29 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Including phy.h and phy_fixed.h into net/dsa.h causes phy*.h to be an
unnecessary dependency for quite a large amount of the kernel.  There's
very little which actually requires definitions from phy.h in net/dsa.h
- the include itself only wants the declaration of a couple of
structures and IFNAMSIZ.

Add linux/if.h for IFNAMSIZ, declarations for the structures, phy.h to
mv88e6xxx.h as it needs it for phy_interface_t, and remove both phy.h
and phy_fixed.h from net/dsa.h.

This patch reduces from around 800 files rebuilt to around 40 - even
with ccache, the time difference is noticable.

Tested-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 1 +
 include/net/dsa.h                     | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index af54baea47cf..3a949095068a 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -15,6 +15,7 @@
 #include <linux/if_vlan.h>
 #include <linux/irq.h>
 #include <linux/gpio/consumer.h>
+#include <linux/phy.h>
 
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
diff --git a/include/net/dsa.h b/include/net/dsa.h
index b122196d5a1f..887b2f98f9ea 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -11,15 +11,17 @@
 #ifndef __LINUX_NET_DSA_H
 #define __LINUX_NET_DSA_H
 
+#include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/list.h>
 #include <linux/timer.h>
 #include <linux/workqueue.h>
 #include <linux/of.h>
-#include <linux/phy.h>
-#include <linux/phy_fixed.h>
 #include <linux/ethtool.h>
 
+struct phy_device;
+struct fixed_phy_status;
+
 enum dsa_tag_protocol {
 	DSA_TAG_PROTO_NONE = 0,
 	DSA_TAG_PROTO_DSA,
-- 
2.7.4


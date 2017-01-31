Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:33188 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751580AbdAaT3b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 14:29:31 -0500
In-Reply-To: <20170131191704.GA8281@n2100.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
From: Russell King <rmk+kernel@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 4.10-rc3 10/13] MIPS: Octeon: Remove unnecessary MODULE_*()
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Message-Id: <E1cYdxS-0000Wy-EM@rmk-PC.armlinux.org.uk>
Date: Tue, 31 Jan 2017 19:19:14 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

octeon-platform.c can not be built as a module for two reasons:

(a) the Makefile doesn't allow it:
    obj-y := cpu.o setup.o octeon-platform.o octeon-irq.o csrc-octeon.o

(b) the multiple *_initcall() statements, each of which are translated
    to a module_init() call when attempting a module build, become
    aliases to init_module().  Having more than one alias will cause a
    build error.

Hence, rather than adding a linux/module.h include, remove the redundant
MODULE_*() from this file.

Acked-by: David Daney <david.daney@cavium.com>
Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 arch/mips/cavium-octeon/octeon-platform.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/arch/mips/cavium-octeon/octeon-platform.c b/arch/mips/cavium-octeon/octeon-platform.c
index 37a932d9148c..8297ce714c5e 100644
--- a/arch/mips/cavium-octeon/octeon-platform.c
+++ b/arch/mips/cavium-octeon/octeon-platform.c
@@ -1060,7 +1060,3 @@ static int __init octeon_publish_devices(void)
 	return of_platform_bus_probe(NULL, octeon_ids, NULL);
 }
 arch_initcall(octeon_publish_devices);
-
-MODULE_AUTHOR("David Daney <ddaney@caviumnetworks.com>");
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Platform driver for Octeon SOC");
-- 
2.7.4


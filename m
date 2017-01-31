Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:33194 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752362AbdAaT3m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jan 2017 14:29:42 -0500
In-Reply-To: <20170131191704.GA8281@n2100.armlinux.org.uk>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
From: Russell King <rmk+kernel@armlinux.org.uk>
To: linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        target-devel@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 4.10-rc3 09/13] iscsi: fix build errors when linux/phy*.h is
 removed from net/dsa.h
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Message-Id: <E1cYdxN-0000Wr-AS@rmk-PC.armlinux.org.uk>
Date: Tue, 31 Jan 2017 19:19:09 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

drivers/target/iscsi/iscsi_target_login.c:1135:7: error: implicit declaration of function 'try_module_get' [-Werror=implicit-function-declaration]

Add linux/module.h to iscsi_target_login.c.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/target/iscsi/iscsi_target_login.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/iscsi/iscsi_target_login.c
index 450f51deb2a2..eab274d17b5c 100644
--- a/drivers/target/iscsi/iscsi_target_login.c
+++ b/drivers/target/iscsi/iscsi_target_login.c
@@ -17,6 +17,7 @@
  ******************************************************************************/
 
 #include <crypto/hash.h>
+#include <linux/module.h>
 #include <linux/string.h>
 #include <linux/kthread.h>
 #include <linux/idr.h>
-- 
2.7.4


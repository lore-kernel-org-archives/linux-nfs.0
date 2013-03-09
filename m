Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cpsmtpb-ews10.kpnxchange.com ([213.75.39.15]:53345 "EHLO
	cpsmtpb-ews10.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758702Ab3CIQHl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Mar 2013 11:07:41 -0500
Message-ID: <1362844951.3137.3.camel@x61.thuisdomein>
Subject: [PATCH] sunrpc: drop "select NETVM"
From: Paul Bolle <pebolle@tiscali.nl>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Sat, 09 Mar 2013 17:02:31 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The Kconfig entry for SUNRPC_SWAP selects NETVM. That select statement
was added in commit a564b8f0398636ba30b07c0eaebdef7ff7837249 ("nfs:
enable swap on NFS"). But there's no Kconfig symbol NETVM. It apparently
was only in used in development versions of the swap over nfs
functionality but never entered mainline. Anyhow, it is a nop and can
safely be dropped.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 net/sunrpc/Kconfig | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 516fe2c..262caf0 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -24,7 +24,6 @@ config SUNRPC_XPRT_RDMA
 config SUNRPC_SWAP
 	bool
 	depends on SUNRPC
-	select NETVM
 
 config RPCSEC_GSS_KRB5
 	tristate "Secure RPC: Kerberos V mechanism"
-- 
1.7.11.7


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42035 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab0I0Kme (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 06:42:34 -0400
From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
To: linux-kernel@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        "David S. Miller" <davem@davemloft.net>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Randy Dunlap <randy.dunlap@oracle.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH] sunrpc: prompt for RPCSEC_GSS_KRB5 even if NFS_V4 is enabled
Date: Mon, 27 Sep 2010 12:41:59 +0200
Message-Id: <1285584120-16860-1-git-send-email-u.kleine-koenig@pengutronix.de>
In-Reply-To: <20100909181454.GB14915@pengutronix.de>
References: <20100909181454.GB14915@pengutronix.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS_V4 works fine without RPCSEC_GSS_KRB5 (even without CRYPTO).
This dependency was introduced in

	df486a2 (NFS: Fix the selection of security flavours in Kconfig)

to fix a build failure as RPCSEC_GSS_KRB5 was thought to be needed for
NFS_V4.  The fix didn't work completely as NFS_V4 didn't enforce CRYPTO
and so the select on RPCSEC_GSS_KRB5 didn't work in all situations (e.g.
arm/mx1_defconfig).

This was rectified by

	827e345 (SUNRPC: Fix the NFSv4 and RPCSEC_GSS Kconfig dependencies)

but the magic for RPCSEC_GSS_KRB5 introduced by df486a2 wasn't reverted.

Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
---
Hello,

after Trond sent me the patch that later ended in 827e345702 I suggested
to fold the patch below into it[1], but without reaction and success as I
noticed just now. :-(

Best regards
Uwe

[1] http://thread.gmane.org/gmane.linux.kernel/1027380/focus=1033847

 net/sunrpc/Kconfig |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 3376d76..442efe1 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -20,8 +20,7 @@ config SUNRPC_XPRT_RDMA
 config RPCSEC_GSS_KRB5
 	tristate
 	depends on SUNRPC && CRYPTO
-	prompt "Secure RPC: Kerberos V mechanism" if !(NFS_V4 || NFSD_V4)
-	default y
+	prompt "Secure RPC: Kerberos V mechanism"
 	select SUNRPC_GSS
 	select CRYPTO_MD5
 	select CRYPTO_DES
-- 
1.7.2.3


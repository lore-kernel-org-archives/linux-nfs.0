Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:64063 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587AbcFPNtU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 09:49:20 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: netdev@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, Armin Schindler <mac@melware.de>,
        Karsten Keil <isdn@linux-pingi.de>,
        Claudiu Manoil <claudiu.manoil@freescale.com>,
        Thomas Sailer <t.sailer@alumni.ethz.ch>,
        Stanislav Yakovlev <stas.yakovlev@gmail.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-wireless@vger.kernel.org,
        brcm80211-dev-list@broadcom.com, linux-nfs@vger.kernel.org
Subject: [PATCH 0/8] net: fix old-style declarations
Date: Thu, 16 Jun 2016 15:50:05 +0200
Message-Id: <20160616135020.3154461-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"make W=1" enables -Wold-style-declaration, which is generally useful
to warn about pre-C89 code in the kernel, but it also warns about
some harmless variations (sometimes many of them from a single
file).

This fixes up the 8 instances I found in the networking code, there
is another series of 12 patches for the rest of the kernel.

Arnd Bergmann (8):
  wireless: airo: rename 'register' variable
  wireless: brcmsmac: fix old-style declaration
  wireless: ipw2200: fix old-style declaration
  hamradio: baycom: fix old-style declaration
  isdn: eicon: fix old-style declarations
  net: gianfar: fix old-style declaration
  net: xfrm: fix old-style declaration
  sunrpc: fix old-style declaration

 drivers/isdn/hardware/eicon/divasmain.c                 | 12 ++++++------
 drivers/isdn/hardware/eicon/platform.h                  |  6 +++---
 drivers/net/ethernet/freescale/gianfar.c                |  2 +-
 drivers/net/hamradio/baycom_par.c                       |  6 +++---
 drivers/net/wireless/broadcom/brcm80211/brcmsmac/main.c |  4 ++--
 drivers/net/wireless/cisco/airo.c                       |  4 ++--
 drivers/net/wireless/intel/ipw2x00/ipw2200.c            |  2 +-
 net/ipv4/xfrm4_policy.c                                 |  8 ++++----
 net/ipv6/xfrm6_policy.c                                 |  4 ++--
 net/sunrpc/clnt.c                                       |  2 +-
 10 files changed, 25 insertions(+), 25 deletions(-)

-- 
2.9.0

Cc: Armin Schindler <mac@melware.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Cc: Thomas Sailer <t.sailer@alumni.ethz.ch>
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-hams@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: brcm80211-dev-list@broadcom.com
Cc: linux-nfs@vger.kernel.org

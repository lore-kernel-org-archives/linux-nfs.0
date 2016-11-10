Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.135]:49928 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935225AbcKJQqu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 11:46:50 -0500
From: Arnd Bergmann <arnd@arndb.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Ilya Dryomov <idryomov@gmail.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Jiri Kosina <jikos@kernel.org>, Jonathan Cameron <jic23@kernel.org>,
        Ley Foon Tan <lftan@altera.com>,
        "Luis R . Rodriguez" <mcgrof@kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Mauro Carvalho Chehab <mchehab@kernel.org>,
        Michal Marek <mmarek@suse.com>, Russell King <linux@armlinux.org.uk>,
        Sean Young <sean@mess.org>, Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>, x86@kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-snps-arc@lists.infradead.org, nios2-dev@lists.rocketboards.org,
        linux-s390@vger.kernel.org, linux-crypto@vger.kernel.org,
        linux-media@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/11] [v3] infiniband: shut up a maybe-uninitialized warning
Date: Thu, 10 Nov 2016 17:44:52 +0100
Message-Id: <20161110164454.293477-10-arnd@arndb.de>
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Some configurations produce this harmless warning when built with
gcc -Wmaybe-uninitialized:

infiniband/core/cma.c: In function 'cma_get_net_dev':
infiniband/core/cma.c:1242:12: warning: 'src_addr_storage.sin_addr.s_addr' may be used uninitialized in this function [-Wmaybe-uninitialized]

I previously reported this for the powerpc64 defconfig, but have now
reproduced the same thing for x86 as well, using gcc-5 or higher.

The code looks correct to me, and this change just rearranges it
by making sure we alway initialize the entire address structure
to make the warning disappear. My first approach added an
initialization at the time of the declaration, which Doug commented
may be too costly, so I hope this version doesn't add overhead.

Link: http://arm-soc.lixom.net/buildlogs/mainline/v4.7-rc6/buildall.powerpc.ppc64_defconfig.log.passed
Link: https://patchwork.kernel.org/patch/9212825/
Acked-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>

---
This is marked v2 as the rest of the series but is actually version
three of the patch as I had to do some other changes already.

v3: remove accidental leftover change of the original patch

 drivers/infiniband/core/cma.c | 54 ++++++++++++++++++++++---------------------
 1 file changed, 28 insertions(+), 26 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 36bf50e..89a6b05 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1094,47 +1094,47 @@ static void cma_save_ib_info(struct sockaddr *src_addr,
 	}
 }
 
-static void cma_save_ip4_info(struct sockaddr *src_addr,
-			      struct sockaddr *dst_addr,
+static void cma_save_ip4_info(struct sockaddr_in *src_addr,
+			      struct sockaddr_in *dst_addr,
 			      struct cma_hdr *hdr,
 			      __be16 local_port)
 {
-	struct sockaddr_in *ip4;
-
 	if (src_addr) {
-		ip4 = (struct sockaddr_in *)src_addr;
-		ip4->sin_family = AF_INET;
-		ip4->sin_addr.s_addr = hdr->dst_addr.ip4.addr;
-		ip4->sin_port = local_port;
+		*src_addr = (struct sockaddr_in) {
+			.sin_family = AF_INET,
+			.sin_addr.s_addr = hdr->dst_addr.ip4.addr,
+			.sin_port = local_port,
+		};
 	}
 
 	if (dst_addr) {
-		ip4 = (struct sockaddr_in *)dst_addr;
-		ip4->sin_family = AF_INET;
-		ip4->sin_addr.s_addr = hdr->src_addr.ip4.addr;
-		ip4->sin_port = hdr->port;
+		*dst_addr = (struct sockaddr_in) {
+			.sin_family = AF_INET,
+			.sin_addr.s_addr = hdr->src_addr.ip4.addr,
+			.sin_port = hdr->port,
+		};
 	}
 }
 
-static void cma_save_ip6_info(struct sockaddr *src_addr,
-			      struct sockaddr *dst_addr,
+static void cma_save_ip6_info(struct sockaddr_in6 *src_addr,
+			      struct sockaddr_in6 *dst_addr,
 			      struct cma_hdr *hdr,
 			      __be16 local_port)
 {
-	struct sockaddr_in6 *ip6;
-
 	if (src_addr) {
-		ip6 = (struct sockaddr_in6 *)src_addr;
-		ip6->sin6_family = AF_INET6;
-		ip6->sin6_addr = hdr->dst_addr.ip6;
-		ip6->sin6_port = local_port;
+		*src_addr = (struct sockaddr_in6) {
+			.sin6_family = AF_INET6,
+			.sin6_addr = hdr->dst_addr.ip6,
+			.sin6_port = local_port,
+		};
 	}
 
 	if (dst_addr) {
-		ip6 = (struct sockaddr_in6 *)dst_addr;
-		ip6->sin6_family = AF_INET6;
-		ip6->sin6_addr = hdr->src_addr.ip6;
-		ip6->sin6_port = hdr->port;
+		*dst_addr = (struct sockaddr_in6) {
+			.sin6_family = AF_INET6,
+			.sin6_addr = hdr->src_addr.ip6,
+			.sin6_port = hdr->port,
+		};
 	}
 }
 
@@ -1159,10 +1159,12 @@ static int cma_save_ip_info(struct sockaddr *src_addr,
 
 	switch (cma_get_ip_ver(hdr)) {
 	case 4:
-		cma_save_ip4_info(src_addr, dst_addr, hdr, port);
+		cma_save_ip4_info((struct sockaddr_in *)src_addr,
+				  (struct sockaddr_in *)dst_addr, hdr, port);
 		break;
 	case 6:
-		cma_save_ip6_info(src_addr, dst_addr, hdr, port);
+		cma_save_ip6_info((struct sockaddr_in6 *)src_addr,
+				  (struct sockaddr_in6 *)dst_addr, hdr, port);
 		break;
 	default:
 		return -EAFNOSUPPORT;
-- 
2.9.0


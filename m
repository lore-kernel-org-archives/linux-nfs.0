Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:65234 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934921AbcKJQqq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 11:46:46 -0500
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
Subject: [PATCH v2 05/11] s390: pci: don't print uninitialized data for debugging
Date: Thu, 10 Nov 2016 17:44:48 +0100
Message-Id: <20161110164454.293477-6-arnd@arndb.de>
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gcc correctly warns about an incorrect use of the 'pa' variable
in case we pass an empty scatterlist to __s390_dma_map_sg:

arch/s390/pci/pci_dma.c: In function '__s390_dma_map_sg':
arch/s390/pci/pci_dma.c:309:13: warning: 'pa' may be used uninitialized in this function [-Wmaybe-uninitialized]

This adds a bogus initialization to the function to sanitize
the debug output.  I would have preferred a solution without
the initialization, but I only got the report from the
kbuild bot after turning on the warning again, and didn't
manage to reproduce it myself.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Acked-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
---
 arch/s390/pci/pci_dma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/s390/pci/pci_dma.c b/arch/s390/pci/pci_dma.c
index 7350c8b..6b2f72f 100644
--- a/arch/s390/pci/pci_dma.c
+++ b/arch/s390/pci/pci_dma.c
@@ -423,7 +423,7 @@ static int __s390_dma_map_sg(struct device *dev, struct scatterlist *sg,
 	dma_addr_t dma_addr_base, dma_addr;
 	int flags = ZPCI_PTE_VALID;
 	struct scatterlist *s;
-	unsigned long pa;
+	unsigned long pa = 0;
 	int ret;
 
 	size = PAGE_ALIGN(size);
-- 
2.9.0


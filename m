Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:55355 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935110AbcKJQrh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 11:47:37 -0500
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
Subject: [PATCH v2 04/11] nios2: fix timer initcall return value
Date: Thu, 10 Nov 2016 17:44:47 +0100
Message-Id: <20161110164454.293477-5-arnd@arndb.de>
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When called more than twice, the nios2_time_init() function
return an uninitialized value, as detected by gcc -Wmaybe-uninitialized

arch/nios2/kernel/time.c: warning: 'ret' may be used uninitialized in this function

This makes it return '0' here, matching the comment above the
function.

Acked-by: Ley Foon Tan <lftan@altera.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/nios2/kernel/time.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/nios2/kernel/time.c b/arch/nios2/kernel/time.c
index d9563dd..746bf5c 100644
--- a/arch/nios2/kernel/time.c
+++ b/arch/nios2/kernel/time.c
@@ -324,6 +324,7 @@ static int __init nios2_time_init(struct device_node *timer)
 		ret = nios2_clocksource_init(timer);
 		break;
 	default:
+		ret = 0;
 		break;
 	}
 
-- 
2.9.0


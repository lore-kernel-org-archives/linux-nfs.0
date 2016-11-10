Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:59362 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964887AbcKJQru (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 11:47:50 -0500
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
Subject: [PATCH v2 07/11] [media] rc: print correct variable for z8f0811
Date: Thu, 10 Nov 2016 17:44:50 +0100
Message-Id: <20161110164454.293477-8-arnd@arndb.de>
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A recent rework accidentally left a debugging printk untouched
while changing the meaning of the variables, leading to an
uninitialized variable being printed:

drivers/media/i2c/ir-kbd-i2c.c: In function 'get_key_haup_common':
drivers/media/i2c/ir-kbd-i2c.c:62:2: error: 'toggle' may be used uninitialized in this function [-Werror=maybe-uninitialized]

This prints the correct one instead, as we did before the patch.

Fixes: 00bb820755ed ("[media] rc: Hauppauge z8f0811 can decode RC6")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/media/i2c/ir-kbd-i2c.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

I submitted this repeatedly as it is a v4.9 regression, but
I never saw a reply for it.

diff --git a/drivers/media/i2c/ir-kbd-i2c.c b/drivers/media/i2c/ir-kbd-i2c.c
index f95a6bc..cede397 100644
--- a/drivers/media/i2c/ir-kbd-i2c.c
+++ b/drivers/media/i2c/ir-kbd-i2c.c
@@ -118,7 +118,7 @@ static int get_key_haup_common(struct IR_i2c *ir, enum rc_type *protocol,
 			*protocol = RC_TYPE_RC6_MCE;
 			dev &= 0x7f;
 			dprintk(1, "ir hauppauge (rc6-mce): t%d vendor=%d dev=%d code=%d\n",
-						toggle, vendor, dev, code);
+						*ptoggle, vendor, dev, code);
 		} else {
 			*ptoggle = 0;
 			*protocol = RC_TYPE_RC6_6A_32;
-- 
2.9.0


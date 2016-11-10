Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:50852 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935157AbcKJQr0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Nov 2016 11:47:26 -0500
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
Subject: [PATCH v2 03/11] x86: apm: avoid uninitialized data
Date: Thu, 10 Nov 2016 17:44:46 +0100
Message-Id: <20161110164454.293477-4-arnd@arndb.de>
In-Reply-To: <20161110164454.293477-1-arnd@arndb.de>
References: <20161110164454.293477-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

apm_bios_call() can fail, and return a status in its argument
structure. If that status however is zero during a call from
apm_get_power_status(), we end up using data that may have
never been set, as reported by "gcc -Wmaybe-uninitialized":

arch/x86/kernel/apm_32.c: In function ‘apm’:
arch/x86/kernel/apm_32.c:1729:17: error: ‘bx’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
arch/x86/kernel/apm_32.c:1835:5: error: ‘cx’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
arch/x86/kernel/apm_32.c:1730:17: note: ‘cx’ was declared here
arch/x86/kernel/apm_32.c:1842:27: error: ‘dx’ may be used uninitialized in this function [-Werror=maybe-uninitialized]
arch/x86/kernel/apm_32.c:1731:17: note: ‘dx’ was declared here

This changes the function to return "APM_NO_ERROR" here, which
makes the code more robust to broken BIOS versions, and avoids
the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Jiri Kosina <jkosina@suse.cz>
Reviewed-by: Luis R. Rodriguez <mcgrof@kernel.org>
---
 arch/x86/kernel/apm_32.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/apm_32.c b/arch/x86/kernel/apm_32.c
index c7364bd..51287cd 100644
--- a/arch/x86/kernel/apm_32.c
+++ b/arch/x86/kernel/apm_32.c
@@ -1042,8 +1042,11 @@ static int apm_get_power_status(u_short *status, u_short *bat, u_short *life)
 
 	if (apm_info.get_power_status_broken)
 		return APM_32_UNSUPPORTED;
-	if (apm_bios_call(&call))
+	if (apm_bios_call(&call)) {
+		if (!call.err)
+			return APM_NO_ERROR;
 		return call.err;
+	}
 	*status = call.ebx;
 	*bat = call.ecx;
 	if (apm_info.get_power_status_swabinminutes) {
-- 
2.9.0


Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f49.google.com ([209.85.160.49]:38889 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758044Ab3CDM7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 07:59:48 -0500
From: Akinobu Mita <akinobu.mita@gmail.com>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH -v3 17/23] net/sunrpc: rename random32() to prandom_u32()
Date: Mon,  4 Mar 2013 21:58:25 +0900
Message-Id: <1362401911-14074-18-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
References: <1362401911-14074-1-git-send-email-akinobu.mita@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
---

No change from v2

 net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 88edec9..1da52d1 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -130,8 +130,8 @@ gss_krb5_make_confounder(char *p, u32 conflen)
 
 	/* initialize to random value */
 	if (i == 0) {
-		i = random32();
-		i = (i << 32) | random32();
+		i = prandom_u32();
+		i = (i << 32) | prandom_u32();
 	}
 
 	switch (conflen) {
-- 
1.8.1.2


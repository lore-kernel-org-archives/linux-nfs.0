Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-da0-f52.google.com ([209.85.210.52]:56732 "EHLO
	mail-da0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab3ACMUU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2013 07:20:20 -0500
From: Akinobu Mita <akinobu.mita@gmail.com>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: [PATCH -v2 20/26] net/sunrpc: rename random32() to prandom_u32()
Date: Thu,  3 Jan 2013 21:19:16 +0900
Message-Id: <1357215562-6288-21-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
References: <1357215562-6288-1-git-send-email-akinobu.mita@gmail.com>
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

* Change from v1
- leave net_random() callers as-is because that is a useful indirection

 net/sunrpc/auth_gss/gss_krb5_wrap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 107c452..daf301f 100644
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
1.7.11.7


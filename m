Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:44835 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757574AbaGPKzx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 06:55:53 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so564749qge.2
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 03:55:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: davem@davemloft.net
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2] net: clean up some sparse endianness warnings in ipv6.h
Date: Wed, 16 Jul 2014 06:55:46 -0400
Message-Id: <1405508146-13004-1-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
References: <1405340746-10678-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

sparse is throwing warnings when building sunrpc modules due to some
endianness shenanigans in ipv6.h. Specifically:

  CHECK   net/sunrpc/addr.c
include/net/ipv6.h:573:17: warning: restricted __be64 degrades to integer
include/net/ipv6.h:577:34: warning: restricted __be32 degrades to integer
include/net/ipv6.h:573:17: warning: restricted __be64 degrades to integer
include/net/ipv6.h:577:34: warning: restricted __be32 degrades to integer

Sprinkle some endianness fixups to silence them. These should all get
fixed up at compile time, so I don't think this will add any extra work
to be done at runtime.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 include/net/ipv6.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 574337fe72dd..0535da61fe0b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -557,24 +557,29 @@ static inline u32 __ipv6_addr_jhash(const struct in6_addr *a, const u32 initval)
 static inline bool ipv6_addr_loopback(const struct in6_addr *a)
 {
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
-	const unsigned long *ul = (const unsigned long *)a;
+	const __be64 *be = (const __be64 *)a;
 
-	return (ul[0] | (ul[1] ^ cpu_to_be64(1))) == 0UL;
+	return (be[0] | (be[1] ^ cpu_to_be64(1))) == 0UL;
 #else
 	return (a->s6_addr32[0] | a->s6_addr32[1] |
-		a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) == 0;
+		a->s6_addr32[2] | (a->s6_addr32[3] ^ cpu_to_be32(1))) == 0;
 #endif
 }
 
+/*
+ * Note that we must __force cast these to unsigned long to make sparse happy,
+ * since all of the endian-annotated types are fixed size regardless of arch.
+ */
 static inline bool ipv6_addr_v4mapped(const struct in6_addr *a)
 {
 	return (
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && BITS_PER_LONG == 64
-		*(__be64 *)a |
+		*(unsigned long *)a |
 #else
-		(a->s6_addr32[0] | a->s6_addr32[1]) |
+		(__force unsigned long)(a->s6_addr32[0] | a->s6_addr32[1]) |
 #endif
-		(a->s6_addr32[2] ^ htonl(0x0000ffff))) == 0UL;
+		(__force unsigned long)(a->s6_addr32[2] ^
+					cpu_to_be32(0x0000ffff))) == 0UL;
 }
 
 /*
-- 
1.9.3


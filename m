Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793840008;
	b=hahLQ2mppr5zbc18potIz2vTm6VmtzxB4T2O5xW0ML7aq5QhXDqAPVegoUee22HuHJYR
	 IinUVk+mluOQB/IO6H7YR8VVS/Y6xYrScG+K+kmUaGkiXlcZlKO5RVttxjpVm5C2APOKK
	 06NaDroupHL+geIrfkTS66VfpuWbWGPRGhw9JWVMg/5eQrQjy5TzUxRbepMAEWxuwQLYm
	 Mv6+icxNEXZ7S6CeDh7uI9Ln55yQBTg0v+ZLU3TdaSuahW7qCx/qUzPDmdc7BoIVZDmZ0
	 OH7ri1a9DFb7e8bx+ONpPR4qKC3MKsTW2+KbK3/AMtGRDYWx1kXXLTR88EKINRxibpw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793840008;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=Ib5OOJ4ufUTeso4k1bDQ5VutJZ6SWyjJH7N1HGtkLgQ=;
	b=bwBXNSDfkBk4giNtgs68kTtUpKkWj7ejyilrjxaJ3J8unyLoc0b6zm287UITgve4QIwM
	 vFg8Cvy6rmmmLjDhL7jkGgOx5Ip9tO9Amjor/FlPXfUJ202EeNjHQU8utd20ojKt0oBuA
	 qn9JcSSSmy9+/pWKVtuYIadsmq8Lspl1zStG2WSjdyL/ziA+i5/1oyieNNVm07ayijqid
	 nL3nl83UuiVINzXkI3qKormrQKhENFYO3LF2v/eLAksxIw4wBZmucbDRbvIZQMkS85kEJ
	 5FiwdFJh8mqfTGLep2xMNtSDTMl5Y1egxl8IhdMARDjpcQUaLh7ThYTOaWSXYTGl06A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i2mTdTSs;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id BC7FE606A328;
	Thu,  5 Nov 2026 00:53:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i2mTdTSs
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id E41161F000C1;
	Thu,  5 Nov 2026 00:53:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793840007;
	bh=Ib5OOJ4ufUTeso4k1bDQ5VutJZ6SWyjJH7N1HGtkLgQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=i2mTdTSsyOMJoDLwcVZfpy3eMwM5fktC9y5FjSmLnMgu/hwuULP0FgBxzdoXrV13T
	 0mWWfgipE72avnVG9xlbikSclAsKMD+ulOKPKE4MHFbIE+o2aP0+Nnz/dPQxV5f9p4
	 LZEQd+/n9FyC/b7jdCvG95CH01DqN2w1u1zTXhOGF9O8zSuOTbAtjY1WGOnMCv2zXv
	 aHlv1cWp2RovZj16Ek8fVxqlx8FUvRGkA3ibtJ6cI9an2upyxQJ4Q7EMq13O1h8ekp
	 coEz3WrPtxpiQmY+C/iKPqyKX1ikPOIqWe4znLRZkgO+ZApj+VU1/oZxCOUa0fIlLj
	 HoV/9chyj7QaQ==
From: Jarkko Sakkinen <jarkko@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: Jarkko Sakkinen <jarkko@kernel.org>,
	keyrings@vger.kernel.org,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-integrity@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	Alexander Gordeev <agordeev@linux.ibm.com>,
	Anna Schumaker <anna@kernel.org>,
	Bharath SM <bharathsm@microsoft.com>,
	Christian Borntraeger <borntraeger@linux.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Biggers <ebiggers@kernel.org>,
	Eric Dumazet <edumazet@kernel.org>,
	Heiko Carstens <hca@linux.ibm.com>,
	Jakub Kicinski <kuba@kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	James Morris <jmorris@namei.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Mimi Zohar <zohar@linux.ibm.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Paul Moore <paul@paul-moore.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Simon Horman <horms@kernel.org>,
	Sumit Garg <sumit.garg@kernel.org>,
	Sven Schnelle <svens@linux.ibm.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Vasily Gorbik <gor@linux.ibm.com>
Subject: [RFC PATCH v3 02/11] dns_resolver: Move the key type into a separate module
Date: Thu,  5 Nov 2026 02:53:01 +0200
Message-ID: <20261105005311.804098-3-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261105005311.804098-1-jarkko@kernel.org>
References: <20261105005311.804098-1-jarkko@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Once keys pin to the kernel module of their key type, having the DNS key
type in the same modules as the resolver will introduce a circular
dependency preventing module_exit() from ever running.

Introduce dns_resolver_key.ko containing key_type_dns_resolver. On a module
exit, drop the credentials and call key_gc_flush() in order the drain the
remaining RCU callbacks.

Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 net/Makefile                 |  2 +-
 net/dns_resolver/Kconfig     | 15 +++++++++
 net/dns_resolver/Makefile    |  4 ++-
 net/dns_resolver/dns_key.c   | 65 +++++-------------------------------
 net/dns_resolver/dns_query.c | 64 +++++++++++++++++++++++++++++++++++
 net/dns_resolver/internal.h  |  5 ---
 6 files changed, 92 insertions(+), 63 deletions(-)

diff --git a/net/Makefile b/net/Makefile
index 5b2dd7f07a85..69c16a7851b4 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -55,7 +55,7 @@ obj-$(CONFIG_IEEE802154)	+= ieee802154/
 obj-$(CONFIG_MAC802154)		+= mac802154/
 
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
-obj-$(CONFIG_DNS_RESOLVER)	+= dns_resolver/
+obj-$(CONFIG_DNS_KEY)		+= dns_resolver/
 obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
diff --git a/net/dns_resolver/Kconfig b/net/dns_resolver/Kconfig
index 7c2dba273e35..2618bad2e771 100644
--- a/net/dns_resolver/Kconfig
+++ b/net/dns_resolver/Kconfig
@@ -1,10 +1,25 @@
 # SPDX-License-Identifier: GPL-2.0-only
+
+#
+# Configuration for DNS Resolver key type
+#
+config DNS_KEY
+	tristate "DNS Resolver key type"
+	depends on KEYS
+	help
+	  Support the key type used to cache DNS lookups independently of
+	  the in-kernel DNS query service.
+
+	  To compile this as a module, choose M here: the module is called
+	  dns_resolver_key.
+
 #
 # Configuration for DNS Resolver
 #
 config DNS_RESOLVER
 	tristate "DNS Resolver support"
 	depends on KEYS
+	select DNS_KEY
 	help
 	  Saying Y here will include support for the DNS Resolver key type
 	  which can be used to make upcalls to perform DNS lookups in
diff --git a/net/dns_resolver/Makefile b/net/dns_resolver/Makefile
index 877532d662d0..586e4c6514de 100644
--- a/net/dns_resolver/Makefile
+++ b/net/dns_resolver/Makefile
@@ -3,6 +3,8 @@
 # Makefile for the Linux DNS Resolver.
 #
 
+obj-$(CONFIG_DNS_KEY) += dns_resolver_key.o
 obj-$(CONFIG_DNS_RESOLVER) += dns_resolver.o
 
-dns_resolver-y :=  dns_key.o dns_query.o
+dns_resolver-y := dns_query.o
+dns_resolver_key-y := dns_key.o
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index 451247864a63..fecbdc1d6beb 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -9,8 +9,8 @@
  *              Wang Lei (wang840925@gmail.com)
  *		David Howells (dhowells@redhat.com)
  */
+
 #include <linux/module.h>
-#include <linux/moduleparam.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
@@ -22,15 +22,12 @@
 #include <keys/user-type.h>
 #include "internal.h"
 
-MODULE_DESCRIPTION("DNS Resolver");
+MODULE_DESCRIPTION("DNS Resolver key type");
 MODULE_AUTHOR("Wang Lei");
 MODULE_LICENSE("GPL");
 
 unsigned int dns_resolver_debug;
-module_param_named(debug, dns_resolver_debug, uint, 0644);
-MODULE_PARM_DESC(debug, "DNS Resolver debugging mask");
-
-const struct cred *dns_resolver_cache;
+EXPORT_SYMBOL_GPL(dns_resolver_debug);
 
 #define	DNS_ERRORNO_OPTION	"dnserror"
 
@@ -318,61 +315,17 @@ struct key_type key_type_dns_resolver = {
 	.describe	= dns_resolver_describe,
 	.read		= dns_resolver_read,
 };
+EXPORT_SYMBOL_GPL(key_type_dns_resolver);
 
-static int __init init_dns_resolver(void)
+static int __init init_dns_key(void)
 {
-	struct cred *cred;
-	struct key *keyring;
-	int ret;
-
-	/* create an override credential set with a special thread keyring in
-	 * which DNS requests are cached
-	 *
-	 * this is used to prevent malicious redirections from being installed
-	 * with add_key().
-	 */
-	cred = prepare_kernel_cred(&init_task);
-	if (!cred)
-		return -ENOMEM;
-
-	keyring = keyring_alloc(".dns_resolver",
-				GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
-				(KEY_POS_ALL & ~KEY_POS_SETATTR) |
-				KEY_USR_VIEW | KEY_USR_READ,
-				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
-	if (IS_ERR(keyring)) {
-		ret = PTR_ERR(keyring);
-		goto failed_put_cred;
-	}
-
-	ret = register_key_type(&key_type_dns_resolver);
-	if (ret < 0)
-		goto failed_put_key;
-
-	/* instruct request_key() to use this special keyring as a cache for
-	 * the results it looks up */
-	set_bit(KEY_FLAG_ROOT_CAN_CLEAR, &keyring->flags);
-	cred->thread_keyring = keyring;
-	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
-	dns_resolver_cache = cred;
-
-	kdebug("DNS resolver keyring: %d\n", key_serial(keyring));
-	return 0;
-
-failed_put_key:
-	key_put(keyring);
-failed_put_cred:
-	put_cred(cred);
-	return ret;
+	return register_key_type(&key_type_dns_resolver);
 }
 
-static void __exit exit_dns_resolver(void)
+static void __exit exit_dns_key(void)
 {
-	key_revoke(dns_resolver_cache->thread_keyring);
 	unregister_key_type(&key_type_dns_resolver);
-	put_cred(dns_resolver_cache);
 }
 
-module_init(init_dns_resolver)
-module_exit(exit_dns_resolver)
-MODULE_LICENSE("GPL");
+module_init(init_dns_key);
+module_exit(exit_dns_key);
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index b8fb9a1245bf..ae4dde190101 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -24,8 +24,10 @@
  */
 
 #include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/slab.h>
 #include <linux/cred.h>
+#include <linux/keyctl.h>
 #include <linux/dns_resolver.h>
 #include <linux/err.h>
 #include <net/net_namespace.h>
@@ -35,6 +37,8 @@
 
 #include "internal.h"
 
+static const struct cred *dns_resolver_cache;
+
 /**
  * dns_query - Query the DNS
  * @net: The network namespace to operate in.
@@ -137,3 +141,63 @@ int dns_query(struct net *net,
 	return ret;
 }
 EXPORT_SYMBOL(dns_query);
+
+static int __init init_dns_resolver(void)
+{
+	struct cred *cred;
+	struct key *keyring;
+	int ret;
+
+	/*
+	 * Create an override credential set with a special thread keyring in
+	 * which DNS requests are cached.  This prevents malicious redirections
+	 * from being installed with add_key().
+	 */
+	cred = prepare_kernel_cred(&init_task);
+	if (!cred)
+		return -ENOMEM;
+
+	keyring = keyring_alloc(".dns_resolver",
+				GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred,
+				(KEY_POS_ALL & ~KEY_POS_SETATTR) |
+				KEY_USR_VIEW | KEY_USR_READ,
+				KEY_ALLOC_NOT_IN_QUOTA, NULL, NULL);
+	if (IS_ERR(keyring)) {
+		ret = PTR_ERR(keyring);
+		goto failed_put_cred;
+	}
+
+	/*
+	 * Instruct request_key() to use this special keyring as a cache for
+	 * the results it looks up.
+	 */
+	set_bit(KEY_FLAG_ROOT_CAN_CLEAR, &keyring->flags);
+	cred->thread_keyring = keyring;
+	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
+	dns_resolver_cache = cred;
+
+	kdebug("DNS resolver keyring: %d\n", key_serial(keyring));
+	return 0;
+
+failed_put_cred:
+	put_cred(cred);
+	return ret;
+}
+
+static void __exit exit_dns_resolver(void)
+{
+	key_revoke(dns_resolver_cache->thread_keyring);
+	put_cred(dns_resolver_cache);
+	/* Drain deferred credential and keyring destruction. */
+	key_gc_flush();
+}
+
+module_init(init_dns_resolver);
+module_exit(exit_dns_resolver);
+
+MODULE_DESCRIPTION("DNS Resolver");
+MODULE_AUTHOR("Wang Lei");
+MODULE_LICENSE("GPL");
+
+module_param_named(debug, dns_resolver_debug, uint, 0644);
+MODULE_PARM_DESC(debug, "DNS Resolver debugging mask");
diff --git a/net/dns_resolver/internal.h b/net/dns_resolver/internal.h
index d0d8edcea092..3478bad78a9a 100644
--- a/net/dns_resolver/internal.h
+++ b/net/dns_resolver/internal.h
@@ -18,11 +18,6 @@ enum {
 	dns_key_error,
 };
 
-/*
- * dns_key.c
- */
-extern const struct cred *dns_resolver_cache;
-
 /*
  * debug tracing
  */
-- 
2.47.3


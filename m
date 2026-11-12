Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794456206;
	b=JY9BiQ91AxhzW1/+SmEtWwtiVAs1ZG9ZtO85idpUw8lGBCuV/6RgP8RjhUlhb/fE6N6m
	 K06at4j1esUUIIciEUs+4Pu5e5vRUr79EfxdgkCGnf8yAJDmmxViXjJsBH8MAvk8GrFAW
	 xpLyE11+ssLDqC9MHY91tWYcnC2QzPE2Dnv4iQYBoY5NKEOjZd2nR+yFjRQL1sK0vtEe1
	 3cAevBCZas8ntiq80rfpSsozuE6j9W7AwT0T+ibOoyPEG/PhM/k93uZ1W7qDDCIHqhKEN
	 Ms5aAcpsYdjS8kggnh5PY+G92yODKEx6hE7tWbMM0IxFaYks+XML0//m0VXoOG72IqQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794456206;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=utZWCVUwL9dxzbQPpp4mQBan0oHgMwAL+V4PtqAR+9k=;
	b=1fIUQJ4t3A+7HIMJKeC/5rJV+I9NB5nDDsZq1wvOiuFyi4GMBiTePTD+mkRsxZJifsvz
	 UZAuCfvJ3ssuoXujLpgyW5ikQ7i6x6K1YtUm7bHYsLXVYxT8rAaQYwfOt8gMqoJ/gX79K
	 bDYC1X//9rKL7/yvEGKMqAxlmbMeNAfpx8j0iTx6vKfYbcUbBy3PHpHBknQnqgLRUUfKU
	 dt9y49hfUmr73ccx4CsWuAJM6PnRBCbwTNERb9KGqfdy8xlsLL85tMooTy4oM89gUgFRv
	 ebG4zVAhtzhNCpnY2m0r1SFittLXMLXat7BnjOAAa4YzVW7NDeDxQTR48X6/epBgWgw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i23i5iHC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with UTF8SMTPS id 75F9460A6F7E;
	Thu, 12 Nov 2026 04:03:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i23i5iHC
Received: by smtp.kernel.org (Postfix) with UTF8SMTPSA id 7199A1F00A05;
	Thu, 12 Nov 2026 04:03:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794456206;
	bh=utZWCVUwL9dxzbQPpp4mQBan0oHgMwAL+V4PtqAR+9k=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=i23i5iHCPszZz1W/p1Ty38G+He+pZ0UpP/6sbJke7wTpf83e69Oa1fel7FvJJ6F1I
	 gSzKlpOtfPNwp+8AeixcFmNhzVagJxsQZFnq0Q0/Q1dYMZnJmNE0dws7RicGAAyUss
	 +cIf1RazK6PQn7BW2LzsHezng+j2TZ9NkyY6SZRTs61IWpPpl6HogemOyfTnuU+mdT
	 IF1jFq7zqfB3aCUhMR4uA51p4ef546Y14xIP0EceCLzlcY+dMiQrARw49+iJONuOTz
	 pLd+wsJFFAqflKOgYyX9B1ZxXQwjmNa797xGShodXBRqhE515HG26+lkmC4PK2KfyO
	 D7PoH+T+Tt9kw==
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
Subject: [PATCH v6 10/13] rxrpc: Move key types to their own module
Date: Thu, 12 Nov 2026 06:02:39 +0200
Message-ID: <20261112040242.247168-11-jarkko@kernel.org>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261112040242.247168-1-jarkko@kernel.org>
References: <20261112040242.247168-1-jarkko@kernel.org>
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

Once keys pin the kernel module implementing their key type, hosting rxrpc
and rxrpc_s keys inside the same module prevents unloading the transport
module while keys remain in keyrings or cached connections.

Split the key types and their preparse logic into a separate rxrpc_keys.ko
module that rxrpc.ko depends on, and flush key GC on rxrpc exit.

By doing this, rxrpc.ko can be removed while the persistent keys pin only
rxrpc_keys.ko.

Co-developed-by: David Howells <dhowells@redhat.com>
Signed-off-by: David Howells <dhowells@redhat.com>
Signed-off-by: Jarkko Sakkinen <jarkko@kernel.org>
---
 Documentation/networking/rxrpc.rst |   2 +-
 net/Makefile                       |   2 +-
 net/rxrpc/Kconfig                  |  20 +++
 net/rxrpc/Makefile                 |   7 +-
 net/rxrpc/af_rxrpc.c               |  19 +--
 net/rxrpc/ar-internal.h            |  25 +--
 net/rxrpc/key.c                    | 122 +++++---------
 net/rxrpc/rxgk.c                   |  66 --------
 net/rxrpc/rxkad.c                  |  47 ------
 net/rxrpc/security.c               | 184 ++++++++++++++++++++
 net/rxrpc/server_key.c             | 260 +++++++++++++++++------------
 11 files changed, 411 insertions(+), 343 deletions(-)

diff --git a/Documentation/networking/rxrpc.rst b/Documentation/networking/rxrpc.rst
index eca055a536aa..394190c40d6e 100644
--- a/Documentation/networking/rxrpc.rst
+++ b/Documentation/networking/rxrpc.rst
@@ -1165,5 +1165,5 @@ API Function Reference
 .. kernel-doc:: net/rxrpc/recvmsg.c
 .. kernel-doc:: net/rxrpc/rxgk.c
 .. kernel-doc:: net/rxrpc/rxkad.c
+.. kernel-doc:: net/rxrpc/security.c
 .. kernel-doc:: net/rxrpc/sendmsg.c
-.. kernel-doc:: net/rxrpc/server_key.c
diff --git a/net/Makefile b/net/Makefile
index 69c16a7851b4..97b2bd2ace7b 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -30,7 +30,7 @@ obj-$(CONFIG_LAPB)		+= lapb/
 obj-$(CONFIG_CAN)		+= can/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
-obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
+obj-$(CONFIG_RXRPC_KEYS)	+= rxrpc/
 obj-$(CONFIG_AF_KCM)		+= kcm/
 obj-$(CONFIG_STREAM_PARSER)	+= strparser/
 obj-$(CONFIG_ATM)		+= atm/
diff --git a/net/rxrpc/Kconfig b/net/rxrpc/Kconfig
index 2cebb666dc07..30135ae62bd6 100644
--- a/net/rxrpc/Kconfig
+++ b/net/rxrpc/Kconfig
@@ -3,6 +3,18 @@
 # RxRPC session sockets
 #
 
+config RXRPC_KEYS
+	tristate "RxRPC key types"
+	select CRYPTO
+	select CRYPTO_LIB_DES if RXKAD
+	select KEYS
+	help
+	  Say Y or M here to include support for rxrpc and rxrpc_s key types
+	  independently of RxRPC session sockets.
+
+	  To compile this as a module, choose M here: the module will be called
+	  rxrpc_keys.
+
 config AF_RXRPC
 	tristate "RxRPC session sockets"
 	depends on INET
@@ -10,6 +22,7 @@ config AF_RXRPC
 	select CRYPTO_LIB_DES if RXKAD
 	select KEYS
 	select NET_UDP_TUNNEL
+	select RXRPC_KEYS
 	help
 	  Say Y or M here to include support for RxRPC session sockets (just
 	  the transport part, not the presentation part: (un)marshalling is
@@ -54,6 +67,9 @@ config AF_RXRPC_DEBUG
 
 	  See Documentation/networking/rxrpc.rst.
 
+endif
+
+if RXRPC_KEYS
 
 config RXKAD
 	bool "RxRPC Kerberos security"
@@ -86,6 +102,10 @@ config RXGK
 
 	  See Documentation/networking/rxrpc.rst.
 
+endif
+
+if AF_RXRPC
+
 config RXPERF
 	tristate "RxRPC test service"
 	help
diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index f994f9f30a29..196e0ce085ba 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -3,6 +3,7 @@
 # Makefile for Linux kernel RxRPC
 #
 
+obj-$(CONFIG_RXRPC_KEYS) += rxrpc_keys.o
 obj-$(CONFIG_AF_RXRPC) += rxrpc.o
 
 rxrpc-y := \
@@ -19,7 +20,6 @@ rxrpc-y := \
 	input_rack.o \
 	insecure.o \
 	io_thread.o \
-	key.o \
 	local_event.o \
 	local_object.o \
 	misc.o \
@@ -32,7 +32,6 @@ rxrpc-y := \
 	rtt.o \
 	security.o \
 	sendmsg.o \
-	server_key.o \
 	skbuff.o \
 	txbuf.o \
 	utils.o
@@ -45,5 +44,9 @@ rxrpc-$(CONFIG_RXGK) += \
 	rxgk_app.o \
 	rxgk_kdf.o
 
+rxrpc_keys-y := \
+	key.o \
+	server_key.o
+
 obj-$(CONFIG_RXPERF) += rxperf.o
 obj-$(CONFIG_KUNIT) += tests/
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 9ab0f22c881e..6ccb99a992b9 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -1077,18 +1077,6 @@ static int __init af_rxrpc_init(void)
 		goto error_sock;
 	}
 
-	ret = register_key_type(&key_type_rxrpc);
-	if (ret < 0) {
-		pr_crit("Cannot register client key type\n");
-		goto error_key_type;
-	}
-
-	ret = register_key_type(&key_type_rxrpc_s);
-	if (ret < 0) {
-		pr_crit("Cannot register server key type\n");
-		goto error_key_type_s;
-	}
-
 	ret = rxrpc_sysctl_init();
 	if (ret < 0) {
 		pr_crit("Cannot register sysctls\n");
@@ -1098,10 +1086,6 @@ static int __init af_rxrpc_init(void)
 	return 0;
 
 error_sysctls:
-	unregister_key_type(&key_type_rxrpc_s);
-error_key_type_s:
-	unregister_key_type(&key_type_rxrpc);
-error_key_type:
 	sock_unregister(PF_RXRPC);
 error_sock:
 	proto_unregister(&rxrpc_proto);
@@ -1124,8 +1108,6 @@ static void __exit af_rxrpc_exit(void)
 {
 	_enter("");
 	rxrpc_sysctl_exit();
-	unregister_key_type(&key_type_rxrpc_s);
-	unregister_key_type(&key_type_rxrpc);
 	sock_unregister(PF_RXRPC);
 	proto_unregister(&rxrpc_proto);
 	unregister_pernet_device(&rxrpc_net_ops);
@@ -1139,6 +1121,7 @@ static void __exit af_rxrpc_exit(void)
 	destroy_workqueue(rxrpc_workqueue);
 	rxrpc_exit_security();
 	kmem_cache_destroy(rxrpc_call_jar);
+	key_gc_flush();
 	_leave("");
 }
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 865f05fe37ab..b5deab0e1ed9 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -273,18 +273,6 @@ struct rxrpc_security {
 	/* Clean up a security service */
 	void (*exit)(void);
 
-	/* Parse the information from a server key */
-	int (*preparse_server_key)(struct key_preparsed_payload *);
-
-	/* Clean up the preparse buffer after parsing a server key */
-	void (*free_preparse_server_key)(struct key_preparsed_payload *);
-
-	/* Destroy the payload of a server key */
-	void (*destroy_server_key)(struct key *);
-
-	/* Describe a server key */
-	void (*describe_server_key)(const struct key *, struct seq_file *);
-
 	/* initialise a connection's security */
 	int (*init_connection_security)(struct rxrpc_connection *,
 					struct rxrpc_key_token *);
@@ -1307,10 +1295,6 @@ extern const struct rxrpc_security rxrpc_no_security;
  */
 extern struct key_type key_type_rxrpc;
 
-int rxrpc_request_key(struct rxrpc_sock *, sockptr_t , int);
-int rxrpc_get_server_data_key(struct rxrpc_connection *, const void *, time64_t,
-			      u32);
-
 /*
  * local_event.c
  */
@@ -1492,6 +1476,11 @@ const struct rxrpc_security *rxrpc_get_incoming_security(struct rxrpc_sock *,
 							 struct sk_buff *);
 struct key *rxrpc_look_up_server_security(struct rxrpc_connection *,
 					  struct sk_buff *, u32, u32);
+int rxrpc_request_key(struct rxrpc_sock *rx, sockptr_t optval, int optlen);
+int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
+			      const void *session_key, time64_t expiry,
+			      u32 kvno);
+int rxrpc_server_keyring(struct rxrpc_sock *rx, sockptr_t optval, int optlen);
 
 /*
  * sendmsg.c
@@ -1505,8 +1494,6 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *, struct msghdr *, size_t);
  */
 extern struct key_type key_type_rxrpc_s;
 
-int rxrpc_server_keyring(struct rxrpc_sock *, sockptr_t, int);
-
 /*
  * skbuff.c
  */
@@ -1633,7 +1620,7 @@ extern unsigned int rxrpc_debug;
 #define _leave(FMT,...)	kleave(FMT,##__VA_ARGS__)
 #define _debug(FMT,...)	kdebug(FMT,##__VA_ARGS__)
 
-#elif defined(CONFIG_AF_RXRPC_DEBUG)
+#elif defined(CONFIG_AF_RXRPC_DEBUG) && !defined(RXRPC_KEY_PROVIDER)
 #define RXRPC_DEBUG_KENTER	0x01
 #define RXRPC_DEBUG_KLEAVE	0x02
 #define RXRPC_DEBUG_KDEBUG	0x04
diff --git a/net/rxrpc/key.c b/net/rxrpc/key.c
index cbd26da44951..49d0871beaf9 100644
--- a/net/rxrpc/key.c
+++ b/net/rxrpc/key.c
@@ -9,6 +9,7 @@
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define RXRPC_KEY_PROVIDER
 
 #include <linux/module.h>
 #include <linux/net.h>
@@ -615,89 +616,6 @@ static void rxrpc_describe(const struct key *key, struct seq_file *m)
 	}
 }
 
-/*
- * grab the security key for a socket
- */
-int rxrpc_request_key(struct rxrpc_sock *rx, sockptr_t optval, int optlen)
-{
-	struct key *key;
-	char *description;
-
-	_enter("");
-
-	if (optlen <= 0 || optlen > PAGE_SIZE - 1 || rx->key)
-		return -EINVAL;
-
-	description = memdup_sockptr_nul(optval, optlen);
-	if (IS_ERR(description))
-		return PTR_ERR(description);
-
-	key = request_key_net(&key_type_rxrpc, description, sock_net(&rx->sk), NULL);
-	if (IS_ERR(key)) {
-		kfree(description);
-		_leave(" = %ld", PTR_ERR(key));
-		return PTR_ERR(key);
-	}
-
-	rx->key = key;
-	kfree(description);
-	_leave(" = 0 [key %x]", key->serial);
-	return 0;
-}
-
-/*
- * generate a server data key
- */
-int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
-			      const void *session_key,
-			      time64_t expiry,
-			      u32 kvno)
-{
-	const struct cred *cred = current_cred();
-	struct key *key;
-	int ret;
-
-	struct {
-		u32 kver;
-		struct rxrpc_key_data_v1 v1;
-	} data;
-
-	_enter("");
-
-	key = key_alloc(&key_type_rxrpc, "x",
-			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred, 0,
-			KEY_ALLOC_NOT_IN_QUOTA, NULL);
-	if (IS_ERR(key)) {
-		_leave(" = -ENOMEM [alloc %ld]", PTR_ERR(key));
-		return -ENOMEM;
-	}
-
-	_debug("key %d", key_serial(key));
-
-	data.kver = 1;
-	data.v1.security_index = RXRPC_SECURITY_RXKAD;
-	data.v1.ticket_length = 0;
-	data.v1.expiry = rxrpc_time64_to_u32(expiry);
-	data.v1.kvno = 0;
-
-	memcpy(&data.v1.session_key, session_key, sizeof(data.v1.session_key));
-
-	ret = key_instantiate_and_link(key, &data, sizeof(data), NULL, NULL);
-	if (ret < 0)
-		goto error;
-
-	conn->key = key;
-	_leave(" = 0 [%d]", key_serial(key));
-	return 0;
-
-error:
-	key_revoke(key);
-	key_put(key);
-	_leave(" = -ENOMEM [ins %d]", ret);
-	return -ENOMEM;
-}
-EXPORT_SYMBOL(rxrpc_get_server_data_key);
-
 /**
  * rxrpc_get_null_key - Generate a null RxRPC key
  * @keyname: The name to give the key.
@@ -893,3 +811,41 @@ static long rxrpc_read(const struct key *key,
 	_leave(" = %zu", size);
 	return size;
 }
+
+static int __init rxrpc_keys_init(void)
+{
+	int ret;
+
+	ret = register_key_type(&key_type_rxrpc);
+	if (ret < 0) {
+		pr_crit("Cannot register client key type\n");
+		goto error_key_type;
+	}
+
+	ret = register_key_type(&key_type_rxrpc_s);
+	if (ret < 0) {
+		pr_crit("Cannot register server key type\n");
+		goto error_key_type_s;
+	}
+
+	return 0;
+
+error_key_type_s:
+	unregister_key_type(&key_type_rxrpc);
+
+error_key_type:
+	return ret;
+}
+
+static void __exit rxrpc_keys_exit(void)
+{
+	unregister_key_type(&key_type_rxrpc_s);
+	unregister_key_type(&key_type_rxrpc);
+}
+
+module_init(rxrpc_keys_init);
+module_exit(rxrpc_keys_exit);
+
+MODULE_DESCRIPTION("RxRPC key types");
+MODULE_AUTHOR("David Howells <dhowells@redhat.com>");
+MODULE_LICENSE("GPL");
diff --git a/net/rxrpc/rxgk.c b/net/rxrpc/rxgk.c
index 77a67ace1d24..5fb3ce15cac4 100644
--- a/net/rxrpc/rxgk.c
+++ b/net/rxrpc/rxgk.c
@@ -14,68 +14,6 @@
 #include "ar-internal.h"
 #include "rxgk_common.h"
 
-/*
- * Parse the information from a server key
- */
-static int rxgk_preparse_server_key(struct key_preparsed_payload *prep)
-{
-	const struct krb5_enctype *krb5;
-	struct krb5_buffer *server_key = (void *)&prep->payload.data[2];
-	unsigned int service, sec_class, kvno, enctype;
-	int n = 0;
-
-	_enter("%zu", prep->datalen);
-
-	if (sscanf(prep->orig_description, "%u:%u:%u:%u%n",
-		   &service, &sec_class, &kvno, &enctype, &n) != 4)
-		return -EINVAL;
-
-	if (prep->orig_description[n])
-		return -EINVAL;
-
-	krb5 = crypto_krb5_find_enctype(enctype);
-	if (!krb5)
-		return -ENOPKG;
-
-	prep->payload.data[0] = (struct krb5_enctype *)krb5;
-
-	if (prep->datalen != krb5->key_len)
-		return -EKEYREJECTED;
-
-	server_key->len = prep->datalen;
-	server_key->data = kmemdup(prep->data, prep->datalen, GFP_KERNEL);
-	if (!server_key->data)
-		return -ENOMEM;
-
-	_leave(" = 0");
-	return 0;
-}
-
-static void rxgk_free_server_key(union key_payload *payload)
-{
-	struct krb5_buffer *server_key = (void *)&payload->data[2];
-
-	kfree_sensitive(server_key->data);
-}
-
-static void rxgk_free_preparse_server_key(struct key_preparsed_payload *prep)
-{
-	rxgk_free_server_key(&prep->payload);
-}
-
-static void rxgk_destroy_server_key(struct key *key)
-{
-	rxgk_free_server_key(&key->payload);
-}
-
-static void rxgk_describe_server_key(const struct key *key, struct seq_file *m)
-{
-	const struct krb5_enctype *krb5 = key->payload.data[0];
-
-	if (krb5)
-		seq_printf(m, ": %s", krb5->name);
-}
-
 /*
  * Handle rekeying the connection when we see our limits overrun or when the
  * far side decided to rekey.
@@ -1335,10 +1273,6 @@ const struct rxrpc_security rxgk_yfs = {
 	.no_key_abort			= RXGK_NOTAUTH,
 	.init				= rxgk_init,
 	.exit				= rxgk_exit,
-	.preparse_server_key		= rxgk_preparse_server_key,
-	.free_preparse_server_key	= rxgk_free_preparse_server_key,
-	.destroy_server_key		= rxgk_destroy_server_key,
-	.describe_server_key		= rxgk_describe_server_key,
 	.init_connection_security	= rxgk_init_connection_security,
 	.alloc_txbuf			= rxgk_alloc_txbuf,
 	.secure_packet			= rxgk_secure_packet,
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index ca9f0e82cb9a..2936c6effae3 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -47,50 +47,6 @@ struct rxkad_level2_hdr {
 static void rxkad_prime_packet_security(struct rxrpc_connection *conn,
 					const struct fcrypt_key *cipher);
 
-/*
- * Parse the information from a server key
- *
- * The data should be the 8-byte secret key.
- */
-static int rxkad_preparse_server_key(struct key_preparsed_payload *prep)
-{
-	struct des_ctx *des_key;
-	int err;
-
-	if (prep->datalen != 8)
-		return -EINVAL;
-
-	memcpy(&prep->payload.data[2], prep->data, 8);
-
-	des_key = kmalloc_obj(*des_key);
-	if (!des_key) {
-		_leave(" = -ENOMEM");
-		return -ENOMEM;
-	}
-
-	err = des_expand_key(des_key, prep->data, 8);
-	if (err) {
-		kfree_sensitive(des_key);
-		_leave(" = %d", err);
-		return err;
-	}
-
-	prep->payload.data[0] = des_key;
-	_leave(" = 0");
-	return 0;
-}
-
-static void rxkad_free_preparse_server_key(struct key_preparsed_payload *prep)
-{
-	kfree_sensitive(prep->payload.data[0]);
-}
-
-static void rxkad_destroy_server_key(struct key *key)
-{
-	kfree_sensitive(key->payload.data[0]);
-	key->payload.data[0] = NULL;
-}
-
 /*
  * initialise connection security
  */
@@ -1124,9 +1080,6 @@ const struct rxrpc_security rxkad = {
 	.no_key_abort			= RXKADUNKNOWNKEY,
 	.init				= rxkad_init,
 	.exit				= rxkad_exit,
-	.preparse_server_key		= rxkad_preparse_server_key,
-	.free_preparse_server_key	= rxkad_free_preparse_server_key,
-	.destroy_server_key		= rxkad_destroy_server_key,
 	.init_connection_security	= rxkad_init_connection_security,
 	.alloc_txbuf			= rxkad_alloc_txbuf,
 	.secure_packet			= rxkad_secure_packet,
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 2bfbf2b2bb37..28883a70c9e8 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -10,6 +10,8 @@
 #include <linux/skbuff.h>
 #include <linux/udp.h>
 #include <linux/crypto.h>
+#include <linux/key-type.h>
+#include <linux/slab.h>
 #include <net/sock.h>
 #include <net/af_rxrpc.h>
 #include <keys/rxrpc-type.h>
@@ -208,3 +210,185 @@ struct key *rxrpc_look_up_server_security(struct rxrpc_connection *conn,
 	read_unlock(&conn->local->services_lock);
 	return key;
 }
+
+/*
+ * grab the security key for a socket
+ */
+int rxrpc_request_key(struct rxrpc_sock *rx, sockptr_t optval, int optlen)
+{
+	struct key *key;
+	char *description;
+
+	_enter("");
+
+	if (optlen <= 0 || optlen > PAGE_SIZE - 1 || rx->key)
+		return -EINVAL;
+
+	description = memdup_sockptr_nul(optval, optlen);
+	if (IS_ERR(description))
+		return PTR_ERR(description);
+
+	key = request_key_net(&key_type_rxrpc, description, sock_net(&rx->sk), NULL);
+	if (IS_ERR(key)) {
+		kfree(description);
+		_leave(" = %ld", PTR_ERR(key));
+		return PTR_ERR(key);
+	}
+
+	rx->key = key;
+	kfree(description);
+	_leave(" = 0 [key %x]", key->serial);
+	return 0;
+}
+
+/*
+ * generate a server data key
+ */
+int rxrpc_get_server_data_key(struct rxrpc_connection *conn,
+			      const void *session_key,
+			      time64_t expiry,
+			      u32 kvno)
+{
+	const struct cred *cred = current_cred();
+	struct {
+		u32 kver;
+		struct rxrpc_key_data_v1 v1;
+	} data;
+	struct key *key;
+	int ret;
+
+	_enter("");
+
+	key = key_alloc(&key_type_rxrpc, "x",
+			GLOBAL_ROOT_UID, GLOBAL_ROOT_GID, cred, 0,
+			KEY_ALLOC_NOT_IN_QUOTA, NULL);
+	if (IS_ERR(key)) {
+		_leave(" = -ENOMEM [alloc %ld]", PTR_ERR(key));
+		return -ENOMEM;
+	}
+
+	_debug("key %d", key_serial(key));
+
+	data.kver = 1;
+	data.v1.security_index = RXRPC_SECURITY_RXKAD;
+	data.v1.ticket_length = 0;
+	data.v1.expiry = rxrpc_time64_to_u32(expiry);
+	data.v1.kvno = 0;
+
+	memcpy(&data.v1.session_key, session_key, sizeof(data.v1.session_key));
+
+	ret = key_instantiate_and_link(key, &data, sizeof(data), NULL, NULL);
+	if (ret < 0)
+		goto error;
+
+	conn->key = key;
+	_leave(" = 0 [%d]", key_serial(key));
+	return 0;
+
+error:
+	key_revoke(key);
+	key_put(key);
+	_leave(" = -ENOMEM [ins %d]", ret);
+	return -ENOMEM;
+}
+EXPORT_SYMBOL(rxrpc_get_server_data_key);
+
+/*
+ * grab the security keyring for a server socket
+ */
+int rxrpc_server_keyring(struct rxrpc_sock *rx, sockptr_t optval, int optlen)
+{
+	struct key *key;
+	char *description;
+
+	_enter("");
+
+	if (rx->securities)
+		return -EINVAL;
+
+	if (optlen <= 0 || optlen > PAGE_SIZE - 1)
+		return -EINVAL;
+
+	description = memdup_sockptr_nul(optval, optlen);
+	if (IS_ERR(description))
+		return PTR_ERR(description);
+
+	key = request_key(&key_type_keyring, description, NULL);
+	if (IS_ERR(key)) {
+		kfree(description);
+		_leave(" = %ld", PTR_ERR(key));
+		return PTR_ERR(key);
+	}
+
+	rx->securities = key;
+	kfree(description);
+	_leave(" = 0 [key %x]", key->serial);
+	return 0;
+}
+
+/**
+ * rxrpc_sock_set_security_keyring - Set the security keyring for a kernel service
+ * @sk: The socket to set the keyring on
+ * @keyring: The keyring to set
+ *
+ * Set the server security keyring on an rxrpc socket.  This is used to provide
+ * the encryption keys for a kernel service.
+ *
+ * Return: %0 if successful and a negative error code otherwise.
+ */
+int rxrpc_sock_set_security_keyring(struct sock *sk, struct key *keyring)
+{
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	int ret = 0;
+
+	lock_sock(sk);
+	if (rx->securities)
+		ret = -EINVAL;
+	else if (rx->sk.sk_state != RXRPC_UNBOUND)
+		ret = -EISCONN;
+	else
+		rx->securities = key_get(keyring);
+	release_sock(sk);
+	return ret;
+}
+EXPORT_SYMBOL(rxrpc_sock_set_security_keyring);
+
+/**
+ * rxrpc_sock_set_manage_response - Set the manage-response flag for a kernel service
+ * @sk: The socket to set the keyring on
+ * @set: True to set, false to clear the flag
+ *
+ * Set the flag on an rxrpc socket to say that the caller wants to manage the
+ * RESPONSE packet and the user-defined data it may contain.  Setting this
+ * means that recvmsg() will return messages with RXRPC_CHALLENGED in the
+ * control message buffer containing information about the challenge.
+ *
+ * The user should respond to the challenge by passing RXRPC_RESPOND or
+ * RXRPC_RESPOND_ABORT control messages with sendmsg() to the same call.
+ * Supplementary control messages, such as RXRPC_RESP_RXGK_APPDATA, may be
+ * included to indicate the parts the user wants to supply.
+ *
+ * The server will be passed the response data with a RXRPC_RESPONDED control
+ * message when it gets the first data from each call.
+ *
+ * Note that this is only honoured by security classes that need auxiliary data
+ * (e.g. RxGK).  Those that don't offer the facility (e.g. RxKAD) respond
+ * without consulting userspace.
+ *
+ * Return: The previous setting.
+ */
+int rxrpc_sock_set_manage_response(struct sock *sk, bool set)
+{
+	struct rxrpc_sock *rx = rxrpc_sk(sk);
+	int ret;
+
+	lock_sock(sk);
+	ret = !!test_bit(RXRPC_SOCK_MANAGE_RESPONSE, &rx->flags);
+	if (set)
+		set_bit(RXRPC_SOCK_MANAGE_RESPONSE, &rx->flags);
+	else
+		clear_bit(RXRPC_SOCK_MANAGE_RESPONSE, &rx->flags);
+	release_sock(sk);
+	return ret;
+}
+EXPORT_SYMBOL(rxrpc_sock_set_manage_response);
diff --git a/net/rxrpc/server_key.c b/net/rxrpc/server_key.c
index 3efe104b1930..0be259dd0df0 100644
--- a/net/rxrpc/server_key.c
+++ b/net/rxrpc/server_key.c
@@ -9,6 +9,11 @@
  */
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+#define RXRPC_KEY_PROVIDER
+
+#include <crypto/des.h>
+#include <crypto/krb5.h>
+#include <linux/fips.h>
 
 #include <linux/module.h>
 #include <linux/net.h>
@@ -42,6 +47,7 @@ struct key_type key_type_rxrpc_s = {
 	.destroy	= rxrpc_destroy_s,
 	.describe	= rxrpc_describe_s,
 };
+EXPORT_SYMBOL(key_type_rxrpc_s);
 
 /*
  * Vet the description for an RxRPC server key.
@@ -60,156 +66,198 @@ static int rxrpc_vet_description_s(const char *desc)
 	return 0;
 }
 
+#ifdef CONFIG_RXKAD
 /*
- * Preparse a server secret key.
+ * Parse the information from a server key
+ *
+ * The data should be the 8-byte secret key.
  */
-static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
+static int rxkad_preparse_server_key(struct key_preparsed_payload *prep)
 {
-	const struct rxrpc_security *sec;
-	unsigned int service, sec_class;
-	int n;
+	struct des_ctx *des_key;
+	int err;
+
+	if (fips_enabled)
+		return -ENOPKG;
+
+	if (prep->datalen != 8)
+		return -EINVAL;
+
+	memcpy(&prep->payload.data[2], prep->data, 8);
+
+	des_key = kmalloc_obj(*des_key);
+	if (!des_key) {
+		_leave(" = -ENOMEM");
+		return -ENOMEM;
+	}
+
+	err = des_expand_key(des_key, prep->data, 8);
+	if (err) {
+		kfree_sensitive(des_key);
+		_leave(" = %d", err);
+		return err;
+	}
+
+	prep->payload.data[0] = des_key;
+	_leave(" = 0");
+	return 0;
+}
+
+static void rxkad_free_preparse_server_key(struct key_preparsed_payload *prep)
+{
+	kfree_sensitive(prep->payload.data[0]);
+}
+
+static void rxkad_destroy_server_key(struct key *key)
+{
+	kfree_sensitive(key->payload.data[0]);
+	key->payload.data[0] = NULL;
+}
+#endif
+
+#ifdef CONFIG_RXGK
+/*
+ * Parse the information from a server key
+ */
+static int rxgk_preparse_server_key(struct key_preparsed_payload *prep)
+{
+	const struct krb5_enctype *krb5;
+	struct krb5_buffer *server_key = (void *)&prep->payload.data[2];
+	unsigned int service, sec_class, kvno, enctype;
+	int n = 0;
 
 	_enter("%zu", prep->datalen);
 
-	if (!prep->orig_description)
+	if (sscanf(prep->orig_description, "%u:%u:%u:%u%n",
+		   &service, &sec_class, &kvno, &enctype, &n) != 4)
 		return -EINVAL;
 
-	if (sscanf(prep->orig_description, "%u:%u%n", &service, &sec_class, &n) != 2)
+	if (prep->orig_description[n])
 		return -EINVAL;
 
-	sec = rxrpc_security_lookup(sec_class);
-	if (!sec)
+	krb5 = crypto_krb5_find_enctype(enctype);
+	if (!krb5)
 		return -ENOPKG;
 
-	prep->payload.data[1] = (struct rxrpc_security *)sec;
+	prep->payload.data[0] = (struct krb5_enctype *)krb5;
 
-	if (!sec->preparse_server_key)
-		return -EINVAL;
+	if (prep->datalen != krb5->key_len)
+		return -EKEYREJECTED;
+
+	server_key->len = prep->datalen;
+	server_key->data = kmemdup(prep->data, prep->datalen, GFP_KERNEL);
+	if (!server_key->data)
+		return -ENOMEM;
 
-	return sec->preparse_server_key(prep);
+	_leave(" = 0");
+	return 0;
 }
 
-static void rxrpc_free_preparse_s(struct key_preparsed_payload *prep)
+static void rxgk_free_server_key(union key_payload *payload)
 {
-	const struct rxrpc_security *sec = prep->payload.data[1];
+	struct krb5_buffer *server_key = (void *)&payload->data[2];
 
-	if (sec && sec->free_preparse_server_key)
-		sec->free_preparse_server_key(prep);
+	kfree_sensitive(server_key->data);
 }
 
-static void rxrpc_destroy_s(struct key *key)
+static void rxgk_free_preparse_server_key(struct key_preparsed_payload *prep)
 {
-	const struct rxrpc_security *sec = key->payload.data[1];
+	rxgk_free_server_key(&prep->payload);
+}
 
-	if (sec && sec->destroy_server_key)
-		sec->destroy_server_key(key);
+static void rxgk_destroy_server_key(struct key *key)
+{
+	rxgk_free_server_key(&key->payload);
 }
 
-static void rxrpc_describe_s(const struct key *key, struct seq_file *m)
+static void rxgk_describe_server_key(const struct key *key, struct seq_file *m)
 {
-	const struct rxrpc_security *sec = key->payload.data[1];
+	const struct krb5_enctype *krb5 = key->payload.data[0];
 
-	seq_puts(m, key->description);
-	if (sec && sec->describe_server_key)
-		sec->describe_server_key(key, m);
+	if (krb5)
+		seq_printf(m, ": %s", krb5->name);
 }
+#endif
 
 /*
- * grab the security keyring for a server socket
+ * Preparse a server secret key.
  */
-int rxrpc_server_keyring(struct rxrpc_sock *rx, sockptr_t optval, int optlen)
+static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 {
-	struct key *key;
-	char *description;
+	unsigned int service, sec_class;
+	int n;
 
-	_enter("");
+	_enter("%zu", prep->datalen);
 
-	if (rx->securities)
+	if (!prep->orig_description)
 		return -EINVAL;
 
-	if (optlen <= 0 || optlen > PAGE_SIZE - 1)
+	if (sscanf(prep->orig_description, "%u:%u%n", &service, &sec_class, &n) != 2)
 		return -EINVAL;
 
-	description = memdup_sockptr_nul(optval, optlen);
-	if (IS_ERR(description))
-		return PTR_ERR(description);
+	prep->payload.data[1] = (void *)(uintptr_t)sec_class;
 
-	key = request_key(&key_type_keyring, description, NULL);
-	if (IS_ERR(key)) {
-		kfree(description);
-		_leave(" = %ld", PTR_ERR(key));
-		return PTR_ERR(key);
+	switch (sec_class) {
+#ifdef CONFIG_RXKAD
+	case RXRPC_SECURITY_RXKAD:
+		return rxkad_preparse_server_key(prep);
+#endif
+#ifdef CONFIG_RXGK
+	case RXRPC_SECURITY_YFS_RXGK:
+		return rxgk_preparse_server_key(prep);
+#endif
+	default:
+		return -ENOPKG;
 	}
+}
 
-	rx->securities = key;
-	kfree(description);
-	_leave(" = 0 [key %x]", key->serial);
-	return 0;
+static void rxrpc_free_preparse_s(struct key_preparsed_payload *prep)
+{
+	switch ((uintptr_t)prep->payload.data[1]) {
+#ifdef CONFIG_RXKAD
+	case RXRPC_SECURITY_RXKAD:
+		rxkad_free_preparse_server_key(prep);
+		break;
+#endif
+#ifdef CONFIG_RXGK
+	case RXRPC_SECURITY_YFS_RXGK:
+		rxgk_free_preparse_server_key(prep);
+		break;
+#endif
+	default:
+		break;
+	}
 }
 
-/**
- * rxrpc_sock_set_security_keyring - Set the security keyring for a kernel service
- * @sk: The socket to set the keyring on
- * @keyring: The keyring to set
- *
- * Set the server security keyring on an rxrpc socket.  This is used to provide
- * the encryption keys for a kernel service.
- *
- * Return: %0 if successful and a negative error code otherwise.
- */
-int rxrpc_sock_set_security_keyring(struct sock *sk, struct key *keyring)
+static void rxrpc_destroy_s(struct key *key)
 {
-	struct rxrpc_sock *rx = rxrpc_sk(sk);
-	int ret = 0;
-
-	lock_sock(sk);
-	if (rx->securities)
-		ret = -EINVAL;
-	else if (rx->sk.sk_state != RXRPC_UNBOUND)
-		ret = -EISCONN;
-	else
-		rx->securities = key_get(keyring);
-	release_sock(sk);
-	return ret;
+	switch ((uintptr_t)key->payload.data[1]) {
+#ifdef CONFIG_RXKAD
+	case RXRPC_SECURITY_RXKAD:
+		rxkad_destroy_server_key(key);
+		break;
+#endif
+#ifdef CONFIG_RXGK
+	case RXRPC_SECURITY_YFS_RXGK:
+		rxgk_destroy_server_key(key);
+		break;
+#endif
+	default:
+		break;
+	}
 }
-EXPORT_SYMBOL(rxrpc_sock_set_security_keyring);
 
-/**
- * rxrpc_sock_set_manage_response - Set the manage-response flag for a kernel service
- * @sk: The socket to set the keyring on
- * @set: True to set, false to clear the flag
- *
- * Set the flag on an rxrpc socket to say that the caller wants to manage the
- * RESPONSE packet and the user-defined data it may contain.  Setting this
- * means that recvmsg() will return messages with RXRPC_CHALLENGED in the
- * control message buffer containing information about the challenge.
- *
- * The user should respond to the challenge by passing RXRPC_RESPOND or
- * RXRPC_RESPOND_ABORT control messages with sendmsg() to the same call.
- * Supplementary control messages, such as RXRPC_RESP_RXGK_APPDATA, may be
- * included to indicate the parts the user wants to supply.
- *
- * The server will be passed the response data with a RXRPC_RESPONDED control
- * message when it gets the first data from each call.
- *
- * Note that this is only honoured by security classes that need auxiliary data
- * (e.g. RxGK).  Those that don't offer the facility (e.g. RxKAD) respond
- * without consulting userspace.
- *
- * Return: The previous setting.
- */
-int rxrpc_sock_set_manage_response(struct sock *sk, bool set)
+static void rxrpc_describe_s(const struct key *key, struct seq_file *m)
 {
-	struct rxrpc_sock *rx = rxrpc_sk(sk);
-	int ret;
-
-	lock_sock(sk);
-	ret = !!test_bit(RXRPC_SOCK_MANAGE_RESPONSE, &rx->flags);
-	if (set)
-		set_bit(RXRPC_SOCK_MANAGE_RESPONSE, &rx->flags);
-	else
-		clear_bit(RXRPC_SOCK_MANAGE_RESPONSE, &rx->flags);
-	release_sock(sk);
-	return ret;
+	seq_puts(m, key->description);
+
+	switch ((uintptr_t)key->payload.data[1]) {
+#ifdef CONFIG_RXGK
+	case RXRPC_SECURITY_YFS_RXGK:
+		rxgk_describe_server_key(key, m);
+		break;
+#endif
+	default:
+		break;
+	}
 }
-EXPORT_SYMBOL(rxrpc_sock_set_manage_response);
-- 
2.47.3


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:58226 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186AbcAXNVB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:21:01 -0500
Subject: [PATCH 26/26] tcp: Use ahash
References: <20160124131021.GA31153@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Message-Id: <E1aNKad-0008H5-Ax@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:20:23 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of the long obsolete hash interface with
ahash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/tcp.h       |    6 +-----
 net/ipv4/tcp.c          |   41 ++++++++++++++++++++++++++---------------
 net/ipv4/tcp_fastopen.c |    1 +
 net/ipv4/tcp_ipv4.c     |   23 +++++++++++++----------
 net/ipv6/tcp_ipv6.c     |   23 +++++++++++++----------
 5 files changed, 54 insertions(+), 40 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8ea1997..2a5b3b8 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -27,7 +27,6 @@
 #include <linux/cache.h>
 #include <linux/percpu.h>
 #include <linux/skbuff.h>
-#include <linux/crypto.h>
 #include <linux/cryptohash.h>
 #include <linux/kref.h>
 #include <linux/ktime.h>
@@ -1325,9 +1324,6 @@ static inline void tcp_clear_all_retrans_hints(struct tcp_sock *tp)
 	tp->retransmit_skb_hint = NULL;
 }
 
-/* MD5 Signature */
-struct crypto_hash;
-
 union tcp_md5_addr {
 	struct in_addr  a4;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1376,7 +1372,7 @@ union tcp_md5sum_block {
 
 /* - pool: digest algorithm, hash description and scratch buffer */
 struct tcp_md5sig_pool {
-	struct hash_desc	md5_desc;
+	struct ahash_request	*md5_req;
 	union tcp_md5sum_block	md5_blk;
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index fd17eec..91ffef3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -247,6 +247,7 @@
 
 #define pr_fmt(fmt) "TCP: " fmt
 
+#include <crypto/hash.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/types.h>
@@ -266,7 +267,6 @@
 #include <linux/swap.h>
 #include <linux/cache.h>
 #include <linux/err.h>
-#include <linux/crypto.h>
 #include <linux/time.h>
 #include <linux/slab.h>
 
@@ -2939,17 +2939,26 @@ static bool tcp_md5sig_pool_populated = false;
 
 static void __tcp_alloc_md5sig_pool(void)
 {
+	struct crypto_ahash *hash;
 	int cpu;
 
+	hash = crypto_alloc_ahash("md5", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR_OR_NULL(hash))
+		return;
+
 	for_each_possible_cpu(cpu) {
-		if (!per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm) {
-			struct crypto_hash *hash;
+		struct ahash_request *req;
 
-			hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-			if (IS_ERR_OR_NULL(hash))
-				return;
-			per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm = hash;
-		}
+		if (per_cpu(tcp_md5sig_pool, cpu).md5_req)
+			continue;
+
+		req = ahash_request_alloc(hash, GFP_KERNEL);
+		if (!req)
+			return;
+
+		ahash_request_set_callback(req, 0, NULL, NULL);
+
+		per_cpu(tcp_md5sig_pool, cpu).md5_req = req;
 	}
 	/* before setting tcp_md5sig_pool_populated, we must commit all writes
 	 * to memory. See smp_rmb() in tcp_get_md5sig_pool()
@@ -2999,7 +3008,6 @@ int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 {
 	struct scatterlist sg;
 	struct tcphdr hdr;
-	int err;
 
 	/* We are not allowed to change tcphdr, make a local copy */
 	memcpy(&hdr, th, sizeof(hdr));
@@ -3007,8 +3015,8 @@ int tcp_md5_hash_header(struct tcp_md5sig_pool *hp,
 
 	/* options aren't included in the hash */
 	sg_init_one(&sg, &hdr, sizeof(hdr));
-	err = crypto_hash_update(&hp->md5_desc, &sg, sizeof(hdr));
-	return err;
+	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(hdr));
+	return crypto_ahash_update(hp->md5_req);
 }
 EXPORT_SYMBOL(tcp_md5_hash_header);
 
@@ -3017,7 +3025,7 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 {
 	struct scatterlist sg;
 	const struct tcphdr *tp = tcp_hdr(skb);
-	struct hash_desc *desc = &hp->md5_desc;
+	struct ahash_request *req = hp->md5_req;
 	unsigned int i;
 	const unsigned int head_data_len = skb_headlen(skb) > header_len ?
 					   skb_headlen(skb) - header_len : 0;
@@ -3027,7 +3035,8 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 	sg_init_table(&sg, 1);
 
 	sg_set_buf(&sg, ((u8 *) tp) + header_len, head_data_len);
-	if (crypto_hash_update(desc, &sg, head_data_len))
+	ahash_request_set_crypt(req, &sg, NULL, head_data_len);
+	if (crypto_ahash_update(req))
 		return 1;
 
 	for (i = 0; i < shi->nr_frags; ++i) {
@@ -3037,7 +3046,8 @@ int tcp_md5_hash_skb_data(struct tcp_md5sig_pool *hp,
 
 		sg_set_page(&sg, page, skb_frag_size(f),
 			    offset_in_page(offset));
-		if (crypto_hash_update(desc, &sg, skb_frag_size(f)))
+		ahash_request_set_crypt(req, &sg, NULL, skb_frag_size(f));
+		if (crypto_ahash_update(req))
 			return 1;
 	}
 
@@ -3054,7 +3064,8 @@ int tcp_md5_hash_key(struct tcp_md5sig_pool *hp, const struct tcp_md5sig_key *ke
 	struct scatterlist sg;
 
 	sg_init_one(&sg, key->key, key->keylen);
-	return crypto_hash_update(&hp->md5_desc, &sg, key->keylen);
+	ahash_request_set_crypt(hp->md5_req, &sg, NULL, key->keylen);
+	return crypto_ahash_update(hp->md5_req);
 }
 EXPORT_SYMBOL(tcp_md5_hash_key);
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 55be6ac..4c65ca1 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -1,3 +1,4 @@
+#include <linux/crypto.h>
 #include <linux/err.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index c7d1fb5..989bfd1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -82,7 +82,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
-#include <linux/crypto.h>
+#include <crypto/hash.h>
 #include <linux/scatterlist.h>
 
 int sysctl_tcp_tw_reuse __read_mostly;
@@ -1032,21 +1032,22 @@ static int tcp_v4_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	bp->len = cpu_to_be16(nbytes);
 
 	sg_init_one(&sg, bp, sizeof(*bp));
-	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(*bp));
+	return crypto_ahash_update(hp->md5_req);
 }
 
 static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, const struct tcphdr *th)
 {
 	struct tcp_md5sig_pool *hp;
-	struct hash_desc *desc;
+	struct ahash_request *req;
 
 	hp = tcp_get_md5sig_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
+	req = hp->md5_req;
 
-	if (crypto_hash_init(desc))
+	if (crypto_ahash_init(req))
 		goto clear_hash;
 	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
 		goto clear_hash;
@@ -1054,7 +1055,8 @@ static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 		goto clear_hash;
 	if (tcp_md5_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	ahash_request_set_crypt(req, NULL, md5_hash, 0);
+	if (crypto_ahash_final(req))
 		goto clear_hash;
 
 	tcp_put_md5sig_pool();
@@ -1072,7 +1074,7 @@ int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
 			const struct sk_buff *skb)
 {
 	struct tcp_md5sig_pool *hp;
-	struct hash_desc *desc;
+	struct ahash_request *req;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 saddr, daddr;
 
@@ -1088,9 +1090,9 @@ int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
 	hp = tcp_get_md5sig_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
+	req = hp->md5_req;
 
-	if (crypto_hash_init(desc))
+	if (crypto_ahash_init(req))
 		goto clear_hash;
 
 	if (tcp_v4_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
@@ -1101,7 +1103,8 @@ int tcp_v4_md5_hash_skb(char *md5_hash, const struct tcp_md5sig_key *key,
 		goto clear_hash;
 	if (tcp_md5_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	ahash_request_set_crypt(req, NULL, md5_hash, 0);
+	if (crypto_ahash_final(req))
 		goto clear_hash;
 
 	tcp_put_md5sig_pool();
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4ad8edb..ad20d50 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -67,7 +67,7 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
-#include <linux/crypto.h>
+#include <crypto/hash.h>
 #include <linux/scatterlist.h>
 
 static void	tcp_v6_send_reset(const struct sock *sk, struct sk_buff *skb);
@@ -541,7 +541,8 @@ static int tcp_v6_md5_hash_pseudoheader(struct tcp_md5sig_pool *hp,
 	bp->len = cpu_to_be32(nbytes);
 
 	sg_init_one(&sg, bp, sizeof(*bp));
-	return crypto_hash_update(&hp->md5_desc, &sg, sizeof(*bp));
+	ahash_request_set_crypt(hp->md5_req, &sg, NULL, sizeof(*bp));
+	return crypto_ahash_update(hp->md5_req);
 }
 
 static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
@@ -549,14 +550,14 @@ static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
 			       const struct tcphdr *th)
 {
 	struct tcp_md5sig_pool *hp;
-	struct hash_desc *desc;
+	struct ahash_request *req;
 
 	hp = tcp_get_md5sig_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
+	req = hp->md5_req;
 
-	if (crypto_hash_init(desc))
+	if (crypto_ahash_init(req))
 		goto clear_hash;
 	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, th->doff << 2))
 		goto clear_hash;
@@ -564,7 +565,8 @@ static int tcp_v6_md5_hash_hdr(char *md5_hash, struct tcp_md5sig_key *key,
 		goto clear_hash;
 	if (tcp_md5_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	ahash_request_set_crypt(req, NULL, md5_hash, 0);
+	if (crypto_ahash_final(req))
 		goto clear_hash;
 
 	tcp_put_md5sig_pool();
@@ -584,7 +586,7 @@ static int tcp_v6_md5_hash_skb(char *md5_hash,
 {
 	const struct in6_addr *saddr, *daddr;
 	struct tcp_md5sig_pool *hp;
-	struct hash_desc *desc;
+	struct ahash_request *req;
 	const struct tcphdr *th = tcp_hdr(skb);
 
 	if (sk) { /* valid for establish/request sockets */
@@ -599,9 +601,9 @@ static int tcp_v6_md5_hash_skb(char *md5_hash,
 	hp = tcp_get_md5sig_pool();
 	if (!hp)
 		goto clear_hash_noput;
-	desc = &hp->md5_desc;
+	req = hp->md5_req;
 
-	if (crypto_hash_init(desc))
+	if (crypto_ahash_init(req))
 		goto clear_hash;
 
 	if (tcp_v6_md5_hash_pseudoheader(hp, daddr, saddr, skb->len))
@@ -612,7 +614,8 @@ static int tcp_v6_md5_hash_skb(char *md5_hash,
 		goto clear_hash;
 	if (tcp_md5_hash_key(hp, key))
 		goto clear_hash;
-	if (crypto_hash_final(desc, md5_hash))
+	ahash_request_set_crypt(req, NULL, md5_hash, 0);
+	if (crypto_ahash_final(req))
 		goto clear_hash;
 
 	tcp_put_md5sig_pool();

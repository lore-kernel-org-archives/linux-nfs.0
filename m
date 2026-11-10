Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332672;
	b=ocUamSSmFuj0XEKzJH/vKQpqHdSQ62Y+AshFywwgrezmMBe2FAnsu5GbcQdhzHmvTlrU
	 O7fi9241acUZZRKBS5EuESYRUWJp0vJ4LqsaOOnU5hkqwvT5SeeStCHLtaIKVkvWvoKbs
	 JRSg+aN21eh0F/44BZS/Dl2BWX6bTvk0LK6ihYpUg4Zop7w0EOwX9svoDPFT21cDJZ5Ji
	 eOyJb/8voyBGV0eiZD3bmCuo+4GkRc+nmO+OQ+mkJlct07AyNfjTfnCdUdloNhgySc08F
	 VfBXWRhToR0oCH7TWaAhMlKjg5AOj5EPg1fynRXoj1h/UGOKHj3AHFsDkVbMeGSTCfQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332672;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=dfLHPJbRStpMK3wBdbhIbmWD5i52opk/aSDp/zggraM=;
	b=NIWf5cACK+QdxOB+XS8PUGDdDGyWbqCK+yw8cUo0zDHDl9TpfGgdyNrlPiePl1wdW8dH
	 0afar6ak3/oN9YL7xPYRDHmAHrxOYE9o3oZve9DN7iapd5RnLjoYxSjoWyui/jU2lFN9Q
	 b3dfgzuQfB3YwiyBNqBo5D3/r/rOTP2vsxWIkVDVcxfjDzNwAEDggK0o983ap2CMZL2wj
	 e9USw6NHITOTHyuu2C93lVM8APiQAgxSmRpR4WUCuZ3Ho1yrJioB9j2qYPEz9cwnXb7fz
	 dvaAPewRGjCfnyTgn4GPI6259kTdYKR5G0P38QEiO+03qJZHfxoyBWSMcB69CBpzzQA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="OHAX/j41";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72606606A32E
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=OHAX/j41
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AC0471F0089F;
	Tue, 10 Nov 2026 17:44:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332671;
	bh=dfLHPJbRStpMK3wBdbhIbmWD5i52opk/aSDp/zggraM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=OHAX/j41b24TBVVfjO9jz5Rhdn97SVKLEw7a+VExLE0ymLYokTLEPPd78YA6IKXT1
	 2OQl7OZe8/fUrTLOodfomI8zuePLefGW9UtDAwYHVBFjSAkNL1mM+OovsPtpGrB+px
	 7S9gp3XioBDIvaASc30mfr23M1Vm3o82PBU4j287i8kx4FNFm4FDAvDCVJ1p2tjhUP
	 bnwBarazptKCFuAkb+fHXbiRqmWX8khlUkN9wk+aDhp0ynUHxmLoUpn9BZr/XheVIT
	 1pnFoKRbwIJ3vNfW+hPeXsZe//Yju5506Cxk0g+7nMhfXxrwSubxXF/XehQePlhMoF
	 wEPEKGrgC6ezQ==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:17 -0500
Subject: [PATCH v2 10/10] NFSD: Add KUnit tests for the random identifier
 generators
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261110-random-stateids-v2-10-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=35036; i=cel@kernel.org;
 h=from:subject:message-id; bh=/OxMPtRCvoCZmztYyeIIOSebUYJgrxFINjS2n7ZxDw8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0Ml+nDbS7UtR/IJfm2XQVvug3FrHScISmp
 zndHwn687+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l/06EAC+HjTGDv2HufFVzVf6cR/gqw2yqbns9IDefSuZ63KHZoj0q9pHJ11bxx1BOz9zobnnJl5
 C+GaAT4is7Rx4GaPbOiPYSP7fnoQkTlIqg6V1Io5TN4/p/3Qz8wYM+gUk4s+D4yqKfDY2Inv/bm
 79OMYxsu5svDYRgIykycNOBsQ+xwPdmX95LwuxOc570WiUjZ6VrMbxr2XQMijbf+Hgv/5U4u7Eg
 6M7gXAmZMIml+jMKfDG+zHY8UVJUCLfS/Ih4Kssz7QO5t1UOyca2zb51cqj9ShxSodRYQadKM5v
 Cwk625DGnQUdIRsbroaGRHjnYLHYatBrUDuw+BhQdUxGEBzOBm8BCOQA706sGTDaVsmJn3amgd9
 dRnq3nAlRnyjEfESvi1lov+vvTbK+9gogfqINLXvuzb5FQuA44YWqt6BVrpoeSUn5T/+mfPDMtu
 NvW0bkggfM+qi4gqiDskxKYtCEkcyWkz7Sr7iO5MQrsZgBWdiol/WV02pIxNd0Iw6IQToRfovNM
 5OoXGMk++p01ZYTWDblp1j6GzPH8x1c/1igkqlAOune5wrP7ErBTBzm8r6RS+ocQZsQxthZLUV+
 p6643Kfd0KxrJ2jHqdE1ut7eEP289sauNoc79idlbH6QeolsB35nm0u8FbwAtnyyTrq/6rMnla/
 Y7ihipQM5C04S5A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The retry, mask, and collision branches of the clientid and session
ID generators fire about once in 2^31 attempts per hashed client, and
far less often for a session ID, so no workload reaches them and no
wire test can force them. The same holds for the boot_time bump on a
same-second restart and for the so_id allocator's non-reuse of a
freed id. Nothing in the tree today can execute those paths on
demand.

Add CONFIG_NFSD_STATE_KUNIT_TEST and fs/nfsd/tests/nfsd_state_kunit.c,
built as a separate module. Export the static helpers under test with
EXPORT_SYMBOL_IF_KUNIT so the module can reach them. Wrap the three
random identifier generators in functions that
KUNIT_STATIC_STUB_REDIRECT can script, and factor the boot_time bump
out of nfs4_state_create_net() into nfsd4_next_boot_time(), callable
on a hand-built nfsd_net. Because the redirect applies only in the
KUnit task, the suite scripts the random source and calls the helpers
directly. It covers the retries, masks, and collisions at each
generation site, the boot_time bump, the COPY_NOTIFY token checks,
and so_id non-reuse. The ordering guarantees in EXCHANGE_ID,
SETCLIENTID, and CREATE_SESSION need a constructed svc_rqst and are
not tested here.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/Kconfig                  |  14 +
 fs/nfsd/Makefile                 |   2 +
 fs/nfsd/nfs4state.c              |  90 +++---
 fs/nfsd/nfsctl.c                 |   2 +
 fs/nfsd/state.h                  |  29 ++
 fs/nfsd/tests/Makefile           |   3 +
 fs/nfsd/tests/nfsd_state_kunit.c | 634 +++++++++++++++++++++++++++++++++++++++
 7 files changed, 740 insertions(+), 34 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 3e4030b70194..7e9ba3ecba47 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -178,3 +178,17 @@ config NFSD_V4_POSIX_ACLS
 	  clients that implement this draft is required.
 
 	  If unsure, say N.
+
+config NFSD_STATE_KUNIT_TEST
+	tristate "KUnit tests for NFSD state allocation" if !KUNIT_ALL_TESTS
+	depends on NFSD && NFSD_V4 && KUNIT
+	default KUNIT_ALL_TESTS
+	help
+	  This builds the KUnit tests for the random clientid, session ID,
+	  and COPY_NOTIFY stateid generators and related state allocation in
+	  nfs4state.c. The tests report their results in TAP format.
+
+	  For more information on KUnit and unit tests in general, refer
+	  to the KUnit documentation in Documentation/dev-tools/kunit/.
+
+	  If unsure, say N.
diff --git a/fs/nfsd/Makefile b/fs/nfsd/Makefile
index 96af6d479731..ad363fabf85e 100644
--- a/fs/nfsd/Makefile
+++ b/fs/nfsd/Makefile
@@ -26,6 +26,8 @@ nfsd-$(CONFIG_NFSD_FLEXFILELAYOUT) += flexfilelayout.o flexfilelayoutxdr.o
 nfsd-$(CONFIG_NFS_LOCALIO) += localio.o
 nfsd-$(CONFIG_DEBUG_FS) += debugfs.o
 
+obj-$(CONFIG_NFSD_STATE_KUNIT_TEST) += tests/
+
 #
 # XDR code generation (requires Python and additional packages)
 #
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 77a73246c0f4..5d578b6a05c7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -46,6 +46,8 @@
 #include <linux/fsnotify.h>
 #include <linux/rhashtable.h>
 #include <linux/nfsd_ssc.h>
+#include <kunit/static_stub.h>
+#include <kunit/visibility.h>
 
 #include "xdr4.h"
 #include "nfs4ctl.h"
@@ -63,20 +65,6 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
-/*
- * Bound the cl_id retries so a stuck random source cannot spin under
- * client_lock. A random id collides about N times in 2^32 for N hashed
- * clients, so the bound is not reached in practice.
- */
-#define NFSD4_RANDOM_RETRIES	16
-
-/*
- * Set in every COPY_NOTIFY token's cl_id word and cleared in every
- * clientid, so the per-client stateid lookup never resolves a token
- * before the IDR lookup runs.
- */
-#define NFSD4_CPNTF_CLID_BIT	BIT(31)
-
 #define all_ones {{ ~0, ~0}, ~0}
 static const stateid_t one_stateid = {
 	.si_generation = ~0,
@@ -994,19 +982,36 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	kmem_cache_free(slab, stid);
 	return NULL;
 }
+EXPORT_SYMBOL_IF_KUNIT(nfs4_alloc_stid);
+
+/* Wrap the random sources so the nfsd_state KUnit suite can script them. */
+VISIBLE_IF_KUNIT u32 nfsd4_get_random_u32(void)
+{
+	KUNIT_STATIC_STUB_REDIRECT(nfsd4_get_random_u32);
+	return get_random_u32();
+}
+EXPORT_SYMBOL_IF_KUNIT(nfsd4_get_random_u32);
+
+VISIBLE_IF_KUNIT u64 nfsd4_get_random_u64(void)
+{
+	KUNIT_STATIC_STUB_REDIRECT(nfsd4_get_random_u64);
+	return get_random_u64();
+}
+EXPORT_SYMBOL_IF_KUNIT(nfsd4_get_random_u64);
 
 /*
  * Publish a COPY_NOTIFY stateid in nn->s2s_cp_stateids and link it onto the
  * parent's sc_cp_list. That IDR holds only COPY_NOTIFY stateids.
  */
-static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
-			      struct nfs4_stid *p_stid)
+VISIBLE_IF_KUNIT int nfs4_init_cp_state(struct nfsd_net *nn,
+					copy_stateid_t *stid,
+					struct nfs4_stid *p_stid)
 {
 	int new_id;
 
 	stid->cs_stid.si_opaque.so_clid.cl_boot = (u32)nn->boot_time;
 	/* so_id is cyclic, so this word carries the token's secret. */
-	stid->cs_stid.si_opaque.so_clid.cl_id = get_random_u32() |
+	stid->cs_stid.si_opaque.so_clid.cl_id = nfsd4_get_random_u32() |
 						NFSD4_CPNTF_CLID_BIT;
 
 	idr_preload(GFP_KERNEL);
@@ -1033,6 +1038,7 @@ static int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
 		return 0;
 	return 1;
 }
+EXPORT_SYMBOL_IF_KUNIT(nfs4_init_cp_state);
 
 /* sc_free for a copy offload stateid; runs from nfs4_put_stid(). */
 static void nfsd4_free_async_copy_stid(struct nfs4_stid *stid)
@@ -1658,10 +1664,11 @@ static void revoke_delegation(struct nfs4_delegation *dp)
  * SETCLIENTID state
  */
 
-static unsigned int clientid_hashval(u32 id)
+VISIBLE_IF_KUNIT unsigned int clientid_hashval(u32 id)
 {
 	return id & CLIENT_HASH_MASK;
 }
+EXPORT_SYMBOL_IF_KUNIT(clientid_hashval);
 
 static unsigned int clientstr_hashval(struct xdr_netobj name)
 {
@@ -2700,8 +2707,9 @@ __find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net)
 }
 
 /* A candidate need only differ from the ID of every live session. */
-static __be32 nfsd4_assign_sessionid_locked(struct net *net,
-					    const clientid_t *clid, u64 *rand)
+VISIBLE_IF_KUNIT __be32 nfsd4_assign_sessionid_locked(struct net *net,
+						      const clientid_t *clid,
+						      u64 *rand)
 {
 	struct nfs4_sessionid candidate __aligned(4);
 	struct nfsd4_sessionid *sid = (struct nfsd4_sessionid *)candidate.data;
@@ -2709,7 +2717,7 @@ static __be32 nfsd4_assign_sessionid_locked(struct net *net,
 
 	sid->clientid = *clid;
 	for (i = 0; i < NFSD4_RANDOM_RETRIES; i++) {
-		u64 value = get_random_u64();
+		u64 value = nfsd4_get_random_u64();
 
 		nfsd4_sessionid_set_rand(sid, value);
 		if (!__find_in_sessionid_hashtbl(&candidate, net)) {
@@ -2721,6 +2729,7 @@ static __be32 nfsd4_assign_sessionid_locked(struct net *net,
 			    NFSD4_RANDOM_RETRIES);
 	return nfserr_jukebox;
 }
+EXPORT_SYMBOL_IF_KUNIT(nfsd4_assign_sessionid_locked);
 
 static struct nfsd4_session *
 find_in_sessionid_hashtbl(struct nfs4_sessionid *sessionid, struct net *net,
@@ -3074,8 +3083,8 @@ static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
 
 static void copy_clid(struct nfs4_client *target, struct nfs4_client *source)
 {
-	target->cl_clientid.cl_boot = source->cl_clientid.cl_boot; 
-	target->cl_clientid.cl_id = source->cl_clientid.cl_id; 
+	target->cl_clientid.cl_boot = source->cl_clientid.cl_boot;
+	target->cl_clientid.cl_id = source->cl_clientid.cl_id;
 }
 
 static int copy_cred(struct svc_cred *target, struct svc_cred *source)
@@ -3220,7 +3229,7 @@ static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
  * that matches a hashed client of another minor version, or one marked
  * expired but not yet unhashed, is still a collision.
  */
-static bool cl_id_in_use_locked(struct nfsd_net *nn, u32 id)
+VISIBLE_IF_KUNIT bool cl_id_in_use_locked(struct nfsd_net *nn, u32 id)
 {
 	unsigned int idhashval = clientid_hashval(id);
 	struct nfs4_client *clp;
@@ -3235,6 +3244,7 @@ static bool cl_id_in_use_locked(struct nfsd_net *nn, u32 id)
 			return true;
 	return false;
 }
+EXPORT_SYMBOL_IF_KUNIT(cl_id_in_use_locked);
 
 /*
  * The caller inserts @clp with add_to_unconfirmed() under the same
@@ -3243,10 +3253,10 @@ static bool cl_id_in_use_locked(struct nfsd_net *nn, u32 id)
  * cl_id from @conf with copy_clid() instead, so no random id is
  * assigned.
  */
-static __be32 nfsd4_assign_clid_locked(struct nfs4_client *clp,
-				       struct nfsd_net *nn,
-				       struct nfs4_client *conf,
-				       nfs4_verifier *verf)
+VISIBLE_IF_KUNIT __be32 nfsd4_assign_clid_locked(struct nfs4_client *clp,
+						 struct nfsd_net *nn,
+						 struct nfs4_client *conf,
+						 nfs4_verifier *verf)
 {
 	u32 id;
 	int i;
@@ -3257,7 +3267,7 @@ static __be32 nfsd4_assign_clid_locked(struct nfs4_client *clp,
 		return nfs_ok;
 
 	for (i = 0; i < NFSD4_RANDOM_RETRIES; i++) {
-		id = get_random_u32() & ~NFSD4_CPNTF_CLID_BIT;
+		id = nfsd4_get_random_u32() & ~NFSD4_CPNTF_CLID_BIT;
 		if (!cl_id_in_use_locked(nn, id)) {
 			clp->cl_clientid.cl_id = id;
 			return nfs_ok;
@@ -3267,6 +3277,7 @@ static __be32 nfsd4_assign_clid_locked(struct nfs4_client *clp,
 			    NFSD4_RANDOM_RETRIES);
 	return nfserr_jukebox;
 }
+EXPORT_SYMBOL_IF_KUNIT(nfsd4_assign_clid_locked);
 
 static struct nfs4_stid *
 find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
@@ -8712,6 +8723,7 @@ __be32 manage_cpntf_state(struct nfsd_net *nn, stateid_t *st,
 		*cps = state;
 	return 0;
 }
+EXPORT_SYMBOL_IF_KUNIT(manage_cpntf_state);
 
 static __be32 nfs4_check_io_stateid(struct svc_fh *fhp, stateid_t *stateid,
 				    struct nfs4_stid *s, int flags, bool has_session)
@@ -10324,10 +10336,23 @@ set_max_delegations(void)
 	max_delegations = nr_free_buffer_pages() >> (20 - 2 - PAGE_SHIFT);
 }
 
+/*
+ * Keep boot_time strictly increasing across a restart so clientids and
+ * stateids issued before the restart stay recognizably stale.
+ */
+VISIBLE_IF_KUNIT time64_t nfsd4_next_boot_time(struct nfsd_net *nn)
+{
+	time64_t now = ktime_get_real_seconds();
+
+	if (now <= nn->boot_time)
+		return nn->boot_time + 1;
+	return now;
+}
+EXPORT_SYMBOL_IF_KUNIT(nfsd4_next_boot_time);
+
 static int nfs4_state_create_net(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
-	time64_t previous_boot;
 	int i;
 
 	nn->conf_id_hashtbl = kmalloc_objs(struct list_head, CLIENT_HASH_SIZE);
@@ -10349,10 +10374,7 @@ static int nfs4_state_create_net(struct net *net)
 		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
 	nn->conf_name_tree = RB_ROOT;
 	nn->unconf_name_tree = RB_ROOT;
-	previous_boot = nn->boot_time;
-	nn->boot_time = ktime_get_real_seconds();
-	if (nn->boot_time <= previous_boot)
-		nn->boot_time = previous_boot + 1;
+	nn->boot_time = nfsd4_next_boot_time(nn);
 	nn->boot_time_bt = ktime_get_boottime_seconds();
 	clear_bit(NFSD_NET_GRACE_ENDED, &nn->flags);
 	clear_bit(NFSD_NET_GRACE_END_FORCED, &nn->flags);
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 703d5367cb7f..b4411b253ad8 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -19,6 +19,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/module.h>
 #include <linux/fsnotify.h>
+#include <kunit/visibility.h>
 #include <linux/nfslocalio.h>
 #include <linux/sunrpc/xdrgen/nfs3.h>
 
@@ -1366,6 +1367,7 @@ static int create_proc_exports_entry(void)
 #endif
 
 unsigned int nfsd_net_id;
+EXPORT_SYMBOL_IF_KUNIT(nfsd_net_id);
 
 struct nfsd_genl_rqstp {
 	struct sockaddr_storage	rq_daddr;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index d9aecef95bae..e9816000c943 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -1047,4 +1047,33 @@ struct nfsd4_get_dir_delegation;
 struct nfs4_delegation *nfsd_get_dir_deleg(struct nfsd4_compound_state *cstate,
 						struct nfsd4_get_dir_delegation *gdd,
 						struct nfsd_file *nf);
+
+/*
+ * Bound the cl_id retries so a stuck random source cannot spin under
+ * client_lock. A random id collides about N times in 2^32 for N hashed
+ * clients, so the bound is not reached in practice.
+ */
+#define NFSD4_RANDOM_RETRIES	16
+
+/*
+ * Set in every COPY_NOTIFY token's cl_id word and cleared in every
+ * clientid, so the per-client stateid lookup never resolves a token
+ * before the IDR lookup runs.
+ */
+#define NFSD4_CPNTF_CLID_BIT	BIT(31)
+
+#if IS_ENABLED(CONFIG_KUNIT)
+/* nfs4state.c helpers exported for tests/nfsd_state_kunit.c */
+u32 nfsd4_get_random_u32(void);
+u64 nfsd4_get_random_u64(void);
+int nfs4_init_cp_state(struct nfsd_net *nn, copy_stateid_t *stid,
+		       struct nfs4_stid *p_stid);
+unsigned int clientid_hashval(u32 id);
+__be32 nfsd4_assign_sessionid_locked(struct net *net, const clientid_t *clid,
+				     u64 *rand);
+bool cl_id_in_use_locked(struct nfsd_net *nn, u32 id);
+__be32 nfsd4_assign_clid_locked(struct nfs4_client *clp, struct nfsd_net *nn,
+				struct nfs4_client *conf, nfs4_verifier *verf);
+time64_t nfsd4_next_boot_time(struct nfsd_net *nn);
+#endif
 #endif   /* NFSD4_STATE_H */
diff --git a/fs/nfsd/tests/Makefile b/fs/nfsd/tests/Makefile
new file mode 100644
index 000000000000..a098757ccc54
--- /dev/null
+++ b/fs/nfsd/tests/Makefile
@@ -0,0 +1,3 @@
+# SPDX-License-Identifier: GPL-2.0
+
+obj-$(CONFIG_NFSD_STATE_KUNIT_TEST) += nfsd_state_kunit.o
diff --git a/fs/nfsd/tests/nfsd_state_kunit.c b/fs/nfsd/tests/nfsd_state_kunit.c
new file mode 100644
index 000000000000..09f70085dbc3
--- /dev/null
+++ b/fs/nfsd/tests/nfsd_state_kunit.c
@@ -0,0 +1,634 @@
+// SPDX-License-Identifier: GPL-2.0
+/*
+ * KUnit tests for the random clientid, session ID, and COPY_NOTIFY
+ * stateid generators in nfs4state.c. The helpers under test are
+ * exported to the EXPORTED_FOR_KUNIT_TESTING namespace.
+ * KUNIT_STATIC_STUB_REDIRECT() replaces a random source only in the
+ * KUnit task, so the tests call the helpers directly rather than
+ * driving them over the wire.
+ */
+#include <kunit/test.h>
+#include <kunit/test-bug.h>
+#include <kunit/static_stub.h>
+#include <kunit/visibility.h>
+#include <linux/xarray.h>
+
+#include "../xdr4.h"
+#include "../nfserr.h"
+#include "../netns.h"
+
+MODULE_IMPORT_NS("EXPORTED_FOR_KUNIT_TESTING");
+
+/*
+ * Scripts for nfsd4_get_random_u32() and nfsd4_get_random_u64(), kept
+ * in test->priv. Past a script's end the last value repeats, so a
+ * one-value script models a source stuck on one value.
+ */
+struct nfsd_state_test_rng {
+	u32		clid[NFSD4_RANDOM_RETRIES + 2];
+	unsigned int	clid_len;
+	unsigned int	clid_pos;
+	unsigned int	clid_calls;
+
+	u64		sid[NFSD4_RANDOM_RETRIES + 2];
+	unsigned int	sid_len;
+	unsigned int	sid_pos;
+	unsigned int	sid_calls;
+};
+
+static int nfsd_state_test_init(struct kunit *test)
+{
+	test->priv = kunit_kzalloc(test, sizeof(struct nfsd_state_test_rng),
+				   GFP_KERNEL);
+	return test->priv ? 0 : -ENOMEM;
+}
+
+static u32 nfsd_clid_test_random_u32(void)
+{
+	struct nfsd_state_test_rng *rng = kunit_get_current_test()->priv;
+
+	rng->clid_calls++;
+	if (rng->clid_pos < rng->clid_len)
+		return rng->clid[rng->clid_pos++];
+	return rng->clid_len ? rng->clid[rng->clid_len - 1] : 0;
+}
+
+static void nfsd_clid_test_script(struct kunit *test, const u32 *vals,
+				  unsigned int n)
+{
+	struct nfsd_state_test_rng *rng = test->priv;
+	unsigned int i;
+
+	n = min_t(unsigned int, n, ARRAY_SIZE(rng->clid));
+	for (i = 0; i < n; i++)
+		rng->clid[i] = vals[i];
+	rng->clid_len = n;
+	rng->clid_pos = 0;
+	rng->clid_calls = 0;
+}
+
+static unsigned int nfsd_clid_test_calls(struct kunit *test)
+{
+	return ((struct nfsd_state_test_rng *)test->priv)->clid_calls;
+}
+
+static u64 nfsd_sid_test_random_u64(void)
+{
+	struct nfsd_state_test_rng *rng = kunit_get_current_test()->priv;
+
+	rng->sid_calls++;
+	if (rng->sid_pos < rng->sid_len)
+		return rng->sid[rng->sid_pos++];
+	return rng->sid_len ? rng->sid[rng->sid_len - 1] : 0;
+}
+
+static void nfsd_sid_test_script(struct kunit *test, const u64 *vals,
+				 unsigned int n)
+{
+	struct nfsd_state_test_rng *rng = test->priv;
+	unsigned int i;
+
+	n = min_t(unsigned int, n, ARRAY_SIZE(rng->sid));
+	for (i = 0; i < n; i++)
+		rng->sid[i] = vals[i];
+	rng->sid_len = n;
+	rng->sid_pos = 0;
+	rng->sid_calls = 0;
+}
+
+static unsigned int nfsd_sid_test_calls(struct kunit *test)
+{
+	return ((struct nfsd_state_test_rng *)test->priv)->sid_calls;
+}
+
+static struct nfsd_net *nfsd_clid_test_net(struct kunit *test)
+{
+	struct nfsd_net *nn;
+	unsigned int i;
+
+	nn = kunit_kzalloc(test, sizeof(*nn), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, nn);
+	nn->conf_id_hashtbl = kunit_kmalloc_array(test, CLIENT_HASH_SIZE,
+						  sizeof(struct list_head),
+						  GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, nn->conf_id_hashtbl);
+	nn->unconf_id_hashtbl = kunit_kmalloc_array(test, CLIENT_HASH_SIZE,
+						    sizeof(struct list_head),
+						    GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, nn->unconf_id_hashtbl);
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		INIT_LIST_HEAD(&nn->conf_id_hashtbl[i]);
+		INIT_LIST_HEAD(&nn->unconf_id_hashtbl[i]);
+	}
+	spin_lock_init(&nn->client_lock);
+	return nn;
+}
+
+static struct nfs4_client *nfsd_clid_test_client(struct kunit *test,
+						 struct list_head *tbl, u32 id)
+{
+	struct nfs4_client *clp;
+
+	clp = kunit_kzalloc(test, sizeof(*clp), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, clp);
+	clp->cl_clientid.cl_id = id;
+	list_add(&clp->cl_idhash, &tbl[clientid_hashval(id)]);
+	return clp;
+}
+
+/*
+ * cl_id_in_use_locked() finds a hashed client of any minor version or
+ * expiry state, so no random id aliases one find_client_in_id_table()
+ * skips.
+ */
+static void nfsd_clid_in_use_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_clid_test_net(test);
+	struct nfs4_client *expired, *other;
+	bool conf, unconf, exp, minor, free;
+
+	nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0x1111);
+	nfsd_clid_test_client(test, nn->unconf_id_hashtbl, 0x2222);
+	expired = nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0x3333);
+	expired->cl_time = 0;
+	other = nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0x4444);
+	other->cl_minorversion = 1;
+
+	/* A failed expectation allocates with GFP_KERNEL, so check unlocked. */
+	spin_lock(&nn->client_lock);
+	conf = cl_id_in_use_locked(nn, 0x1111);
+	unconf = cl_id_in_use_locked(nn, 0x2222);
+	exp = cl_id_in_use_locked(nn, 0x3333);
+	minor = cl_id_in_use_locked(nn, 0x4444);
+	free = cl_id_in_use_locked(nn, 0x5555);
+	spin_unlock(&nn->client_lock);
+
+	KUNIT_EXPECT_TRUE(test, conf);
+	KUNIT_EXPECT_TRUE(test, unconf);
+	KUNIT_EXPECT_TRUE(test, exp);
+	KUNIT_EXPECT_TRUE(test, minor);
+	KUNIT_EXPECT_FALSE(test, free);
+}
+
+/*
+ * The COPY_NOTIFY bit is cleared from a random clientid without a retry,
+ * so no clientid can equal a token's cl_id word.
+ */
+static void nfsd_clid_mask_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_clid_test_net(test);
+	struct nfs4_client *new;
+	static const u32 seq[] = { 0x1234 | NFSD4_CPNTF_CLID_BIT };
+	__be32 status;
+
+	new = kunit_kzalloc(test, sizeof(*new), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, new);
+	kunit_activate_static_stub(test, nfsd4_get_random_u32,
+				   nfsd_clid_test_random_u32);
+	nfsd_clid_test_script(test, seq, ARRAY_SIZE(seq));
+
+	spin_lock(&nn->client_lock);
+	status = nfsd4_assign_clid_locked(new, nn, NULL, NULL);
+	spin_unlock(&nn->client_lock);
+
+	KUNIT_EXPECT_TRUE(test, status == nfs_ok);
+	KUNIT_EXPECT_EQ(test, new->cl_clientid.cl_id, 0x1234);
+	KUNIT_EXPECT_EQ(test, nfsd_clid_test_calls(test), 1);
+}
+
+static void nfsd_clid_collision_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_clid_test_net(test);
+	struct nfs4_client *new, *expired, *other;
+	static const u32 seq[] = { 0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD, 0xEEEE };
+	__be32 status;
+
+	nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0xAAAA);
+	nfsd_clid_test_client(test, nn->unconf_id_hashtbl, 0xBBBB);
+	expired = nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0xCCCC);
+	expired->cl_time = 0;
+	other = nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0xDDDD);
+	other->cl_minorversion = 1;
+
+	new = kunit_kzalloc(test, sizeof(*new), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, new);
+	kunit_activate_static_stub(test, nfsd4_get_random_u32,
+				   nfsd_clid_test_random_u32);
+	nfsd_clid_test_script(test, seq, ARRAY_SIZE(seq));
+
+	spin_lock(&nn->client_lock);
+	status = nfsd4_assign_clid_locked(new, nn, NULL, NULL);
+	spin_unlock(&nn->client_lock);
+
+	KUNIT_EXPECT_TRUE(test, status == nfs_ok);
+	KUNIT_EXPECT_EQ(test, new->cl_clientid.cl_id, 0xEEEE);
+	KUNIT_EXPECT_EQ(test, nfsd_clid_test_calls(test), 5);
+}
+
+static void nfsd_clid_stuck_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_clid_test_net(test);
+	struct nfs4_client *new;
+	static const u32 seq[] = { 0xCAFE };
+	bool conf, unconf;
+	__be32 status;
+
+	nfsd_clid_test_client(test, nn->conf_id_hashtbl, 0xCAFE);
+	nfsd_clid_test_client(test, nn->unconf_id_hashtbl, 0xBEEF);
+
+	new = kunit_kzalloc(test, sizeof(*new), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, new);
+	kunit_activate_static_stub(test, nfsd4_get_random_u32,
+				   nfsd_clid_test_random_u32);
+	nfsd_clid_test_script(test, seq, ARRAY_SIZE(seq));
+
+	spin_lock(&nn->client_lock);
+	status = nfsd4_assign_clid_locked(new, nn, NULL, NULL);
+	conf = cl_id_in_use_locked(nn, 0xCAFE);
+	unconf = cl_id_in_use_locked(nn, 0xBEEF);
+	spin_unlock(&nn->client_lock);
+
+	KUNIT_EXPECT_TRUE(test, status == nfserr_jukebox);
+	KUNIT_EXPECT_EQ(test, new->cl_clientid.cl_id, 0);
+	KUNIT_EXPECT_EQ(test, nfsd_clid_test_calls(test), NFSD4_RANDOM_RETRIES);
+	KUNIT_EXPECT_TRUE(test, conf);
+	KUNIT_EXPECT_TRUE(test, unconf);
+}
+
+/*
+ * A confirmed client with a matching verifier gets no random id. The
+ * SETCLIENTID callback-update path copies the confirmed client's
+ * clientid in copy_clid() instead.
+ */
+static void nfsd_clid_copy_clid_skip_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_clid_test_net(test);
+	struct nfs4_client *new, *conf;
+	nfs4_verifier verf;
+	__be32 status;
+
+	conf = kunit_kzalloc(test, sizeof(*conf), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, conf);
+	memset(conf->cl_verifier.data, 0x5a, sizeof(conf->cl_verifier.data));
+	memcpy(verf.data, conf->cl_verifier.data, sizeof(verf.data));
+
+	new = kunit_kzalloc(test, sizeof(*new), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, new);
+	kunit_activate_static_stub(test, nfsd4_get_random_u32,
+				   nfsd_clid_test_random_u32);
+	nfsd_clid_test_script(test, NULL, 0);
+
+	spin_lock(&nn->client_lock);
+	status = nfsd4_assign_clid_locked(new, nn, conf, &verf);
+	spin_unlock(&nn->client_lock);
+
+	KUNIT_EXPECT_TRUE(test, status == nfs_ok);
+	KUNIT_EXPECT_EQ(test, new->cl_clientid.cl_id, 0);
+	KUNIT_EXPECT_EQ(test, nfsd_clid_test_calls(test), 0);
+}
+
+/*
+ * A boot_time an hour ahead of the clock forces the same-second branch
+ * whatever the clock does during the test.
+ */
+static void nfsd_clid_boot_time_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_clid_test_net(test);
+	time64_t previous = ktime_get_real_seconds() + 3600;
+
+	nn->boot_time = previous;
+
+	KUNIT_EXPECT_EQ(test, nfsd4_next_boot_time(nn), previous + 1);
+}
+
+static void nfsd_cp_test_idr_destroy(void *ctx)
+{
+	idr_destroy(ctx);
+}
+
+static struct nfsd_net *nfsd_cp_test_net(struct kunit *test)
+{
+	struct nfsd_net *nn;
+
+	nn = kunit_kzalloc(test, sizeof(*nn), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, nn);
+	spin_lock_init(&nn->s2s_cp_lock);
+	idr_init(&nn->s2s_cp_stateids);
+	KUNIT_ASSERT_EQ(test, 0,
+			kunit_add_action_or_reset(test, nfsd_cp_test_idr_destroy,
+						  &nn->s2s_cp_stateids));
+	return nn;
+}
+
+static void nfsd_cp_word_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_cp_test_net(test);
+	static const u32 seq[] = { 0x1234, 0x5678 };
+	struct nfs4_cpntf_state *first, *second;
+	struct nfs4_stid *parent;
+
+	parent = kunit_kzalloc(test, sizeof(*parent), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, parent);
+	INIT_LIST_HEAD(&parent->sc_cp_list);
+	first = kunit_kzalloc(test, sizeof(*first), GFP_KERNEL);
+	second = kunit_kzalloc(test, sizeof(*second), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, first);
+	KUNIT_ASSERT_NOT_NULL(test, second);
+	INIT_LIST_HEAD(&first->cp_list);
+	INIT_LIST_HEAD(&second->cp_list);
+
+	kunit_activate_static_stub(test, nfsd4_get_random_u32,
+				   nfsd_clid_test_random_u32);
+	nfsd_clid_test_script(test, seq, ARRAY_SIZE(seq));
+	KUNIT_EXPECT_EQ(test, nfs4_init_cp_state(nn, &first->cp_stateid,
+						 parent), 1);
+	KUNIT_EXPECT_EQ(test, nfs4_init_cp_state(nn, &second->cp_stateid,
+						 parent), 1);
+
+	KUNIT_EXPECT_EQ(test, nfsd_clid_test_calls(test), 2);
+	KUNIT_EXPECT_EQ(test, first->cp_stateid.cs_stid.si_opaque.so_clid.cl_id,
+			0x1234 | NFSD4_CPNTF_CLID_BIT);
+	KUNIT_EXPECT_EQ(test, second->cp_stateid.cs_stid.si_opaque.so_clid.cl_id,
+			0x5678 | NFSD4_CPNTF_CLID_BIT);
+	KUNIT_EXPECT_EQ(test, first->cp_stateid.cs_stid.si_opaque.so_id, 0);
+	KUNIT_EXPECT_EQ(test, second->cp_stateid.cs_stid.si_opaque.so_id, 1);
+	KUNIT_EXPECT_PTR_EQ(test, idr_find(&nn->s2s_cp_stateids, 1),
+			    &second->cp_stateid);
+}
+
+static struct nfs4_cpntf_state *nfsd_cp_test_entry(struct kunit *test,
+						   struct nfsd_net *nn,
+						   struct list_head *parent,
+						   const clientid_t *owner,
+						   u32 key, u32 word)
+{
+	struct nfs4_cpntf_state *cps;
+	u32 k = key;
+	int ret;
+
+	/* Not kunit_kzalloc(): a successful revoke frees the entry. */
+	cps = kzalloc_obj(*cps);
+	KUNIT_ASSERT_NOT_NULL(test, cps);
+	cps->cp_p_clid = *owner;
+	cps->cp_stateid.cs_stid.si_opaque.so_clid.cl_boot = (u32)nn->boot_time;
+	cps->cp_stateid.cs_stid.si_opaque.so_clid.cl_id = word;
+	cps->cp_stateid.cs_stid.si_opaque.so_id = key;
+	cps->cp_stateid.cs_type = NFS4_COPYNOTIFY_STID;
+	refcount_set(&cps->cp_stateid.cs_count, 1);
+	list_add(&cps->cp_list, parent);
+	ret = idr_alloc_u32(&nn->s2s_cp_stateids, &cps->cp_stateid, &k, k,
+			    GFP_KERNEL);
+	if (ret) {
+		list_del(&cps->cp_list);
+		kfree(cps);
+	}
+	KUNIT_ASSERT_EQ(test, 0, ret);
+	return cps;
+}
+
+/*
+ * A NULL @clp is the READ/SEEK form, which accepts any holder of a
+ * matching token, not only the creator. The creator's @clp is the
+ * OFFLOAD_CANCEL form. The checks run in an order that keeps the entry
+ * alive until the final revoke.
+ */
+static void nfsd_cp_token_check_test(struct kunit *test)
+{
+	struct nfsd_net *nn = nfsd_cp_test_net(test);
+	clientid_t a = { .cl_boot = 1000, .cl_id = 0xA },
+		   b = { .cl_boot = 1000, .cl_id = 0xB };
+	struct nfs4_client *clp_a, *clp_b;
+	struct nfs4_cpntf_state *cps, *found = NULL;
+	LIST_HEAD(parent);
+	stateid_t st = { };
+	__be32 bad_word, bad_boot, wrong_client, read_form, cancel_form;
+	void *after;
+
+	nn->boot_time = 1000;
+	clp_a = kunit_kzalloc(test, sizeof(*clp_a), GFP_KERNEL);
+	clp_b = kunit_kzalloc(test, sizeof(*clp_b), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, clp_a);
+	KUNIT_ASSERT_NOT_NULL(test, clp_b);
+	clp_a->cl_clientid = a;
+	clp_b->cl_clientid = b;
+
+	cps = nfsd_cp_test_entry(test, nn, &parent, &a, 0x4321, 0xC0FFEE);
+	st.si_opaque.so_clid.cl_boot = (u32)nn->boot_time;
+	st.si_opaque.so_clid.cl_id = 0xC0FFEE;
+	st.si_opaque.so_id = 0x4321;
+
+	st.si_opaque.so_clid.cl_id = 0xC0FFEE + 1;
+	bad_word = manage_cpntf_state(nn, &st, NULL, &found);
+	st.si_opaque.so_clid.cl_id = 0xC0FFEE;
+
+	st.si_opaque.so_clid.cl_boot = (u32)nn->boot_time + 1;
+	bad_boot = manage_cpntf_state(nn, &st, clp_a, &found);
+	st.si_opaque.so_clid.cl_boot = (u32)nn->boot_time;
+
+	wrong_client = manage_cpntf_state(nn, &st, clp_b, &found);
+	KUNIT_EXPECT_NULL(test, found);
+
+	read_form = manage_cpntf_state(nn, &st, NULL, &found);
+	KUNIT_EXPECT_PTR_EQ(test, found, cps);
+	KUNIT_EXPECT_EQ(test, refcount_read(&cps->cp_stateid.cs_count), 2);
+	if (read_form == nfs_ok)
+		refcount_dec(&cps->cp_stateid.cs_count);
+
+	cancel_form = manage_cpntf_state(nn, &st, clp_a, &found);
+	after = idr_find(&nn->s2s_cp_stateids, 0x4321);
+
+	KUNIT_EXPECT_TRUE(test, bad_word == nfserr_bad_stateid);
+	KUNIT_EXPECT_TRUE(test, bad_boot == nfserr_bad_stateid);
+	KUNIT_EXPECT_TRUE(test, wrong_client == nfserr_bad_stateid);
+	KUNIT_EXPECT_TRUE(test, read_form == nfs_ok);
+	KUNIT_EXPECT_TRUE(test, cancel_form == nfs_ok);
+	KUNIT_EXPECT_NULL(test, after);
+
+	/* A failed cancel leaves the entry in place, so free it here. */
+	if (after) {
+		idr_remove(&nn->s2s_cp_stateids, 0x4321);
+		kfree(cps);
+	}
+}
+
+static void nfsd_so_id_free_stid(struct nfs4_client *cl, struct kmem_cache *slab,
+				 struct nfs4_stid *stid)
+{
+	spin_lock(&cl->cl_lock);
+	idr_remove(&cl->cl_stateids, stid->sc_stateid.si_opaque.so_id);
+	spin_unlock(&cl->cl_lock);
+	kmem_cache_free(slab, stid);
+}
+
+static void nfsd_so_id_destroy_slab(void *ctx)
+{
+	kmem_cache_destroy(ctx);
+}
+
+static void nfsd_so_id_destroy_xa(void *ctx)
+{
+	xa_destroy(ctx);
+}
+
+/*
+ * nfs4_alloc_stid() hands out so_id values cyclically, so an id freed
+ * a moment ago is not handed out again.
+ */
+#define NFSD_SO_ID_TEST_COUNT	4096
+
+static void nfsd_so_id_nonreuse_test(struct kunit *test)
+{
+	struct kmem_cache *slab;
+	struct nfs4_client *cl;
+	struct xarray *seen;
+	unsigned int i;
+	int err;
+
+	cl = kunit_kzalloc(test, sizeof(*cl), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, cl);
+	spin_lock_init(&cl->cl_lock);
+	idr_init(&cl->cl_stateids);
+	KUNIT_ASSERT_EQ(test, 0,
+			kunit_add_action_or_reset(test, nfsd_cp_test_idr_destroy,
+						  &cl->cl_stateids));
+	slab = kmem_cache_create("nfsd_test_stid", sizeof(struct nfs4_stid), 0,
+				 0, NULL);
+	KUNIT_ASSERT_NOT_NULL(test, slab);
+	KUNIT_ASSERT_EQ(test, 0,
+			kunit_add_action_or_reset(test, nfsd_so_id_destroy_slab,
+						  slab));
+	/* Cleanup runs on another kthread, so @seen cannot live on this stack. */
+	seen = kunit_kzalloc(test, sizeof(*seen), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, seen);
+	xa_init(seen);
+	KUNIT_ASSERT_EQ(test, 0,
+			kunit_add_action_or_reset(test, nfsd_so_id_destroy_xa,
+						  seen));
+
+	for (i = 0; i < NFSD_SO_ID_TEST_COUNT; i++) {
+		struct nfs4_stid *stid = nfs4_alloc_stid(cl, slab, NULL);
+
+		KUNIT_ASSERT_NOT_NULL(test, stid);
+		err = xa_insert(seen, stid->sc_stateid.si_opaque.so_id,
+				xa_mk_value(1), GFP_KERNEL);
+		nfsd_so_id_free_stid(cl, slab, stid);
+		KUNIT_ASSERT_EQ(test, err, 0);
+		if (!(i & 1023))
+			cond_resched();
+	}
+}
+
+/*
+ * nfsd4_assign_sessionid_locked() takes a struct net, so build one whose
+ * net_generic() slot for nfsd points at the bare nfsd_net.
+ */
+static struct net *nfsd_sid_test_net(struct kunit *test, struct nfsd_net **nnp)
+{
+	struct net_generic *ng;
+	struct nfsd_net *nn;
+	struct net *net;
+	unsigned int i;
+
+	net = kunit_kzalloc(test, sizeof(*net), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, net);
+	ng = kunit_kzalloc(test, struct_size(ng, ptr, nfsd_net_id + 1),
+			   GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, ng);
+	nn = kunit_kzalloc(test, sizeof(*nn), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, nn);
+	nn->sessionid_hashtbl = kunit_kmalloc_array(test, SESSION_HASH_SIZE,
+						    sizeof(struct list_head),
+						    GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, nn->sessionid_hashtbl);
+	for (i = 0; i < SESSION_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&nn->sessionid_hashtbl[i]);
+	spin_lock_init(&nn->client_lock);
+	ng->ptr[nfsd_net_id] = nn;
+	rcu_assign_pointer(net->gen, ng);
+	*nnp = nn;
+	return net;
+}
+
+static unsigned int nfsd_sid_test_count(struct nfsd_net *nn)
+{
+	struct nfsd4_session *se;
+	unsigned int i, n = 0;
+
+	for (i = 0; i < SESSION_HASH_SIZE; i++)
+		list_for_each_entry(se, &nn->sessionid_hashtbl[i], se_hash)
+			n++;
+	return n;
+}
+
+static void nfsd_sid_test(struct kunit *test)
+{
+	static const u64 taken = 0x1122334455667788ULL;
+	static const u64 seq[] = { taken, 0x0102030405060708ULL };
+	static const u64 stuck[] = { taken };
+	const clientid_t clid = { .cl_boot = 7, .cl_id = 0x99 };
+	struct nfsd4_sessionid *sid;
+	struct nfsd4_session *se;
+	struct nfsd_net *nn;
+	struct net *net;
+	__be32 status, stuck_status;
+	u64 rand = 0, stuck_rand = 0;
+	unsigned int before, after;
+
+	net = nfsd_sid_test_net(test, &nn);
+	se = kunit_kzalloc(test, sizeof(*se), GFP_KERNEL);
+	KUNIT_ASSERT_NOT_NULL(test, se);
+	sid = (struct nfsd4_sessionid *)se->se_sessionid.data;
+	sid->clientid = clid;
+	sid->sequence = lower_32_bits(taken);
+	sid->reserved = upper_32_bits(taken);
+	list_add(&se->se_hash, &nn->sessionid_hashtbl[sid->sequence %
+						      SESSION_HASH_SIZE]);
+
+	kunit_activate_static_stub(test, nfsd4_get_random_u64,
+				   nfsd_sid_test_random_u64);
+	nfsd_sid_test_script(test, seq, ARRAY_SIZE(seq));
+	spin_lock(&nn->client_lock);
+	status = nfsd4_assign_sessionid_locked(net, &clid, &rand);
+	spin_unlock(&nn->client_lock);
+
+	KUNIT_EXPECT_TRUE(test, status == nfs_ok);
+	KUNIT_EXPECT_EQ(test, rand, seq[1]);
+	KUNIT_EXPECT_EQ(test, nfsd_sid_test_calls(test), 2);
+
+	nfsd_sid_test_script(test, stuck, ARRAY_SIZE(stuck));
+	before = nfsd_sid_test_count(nn);
+	spin_lock(&nn->client_lock);
+	stuck_status = nfsd4_assign_sessionid_locked(net, &clid, &stuck_rand);
+	spin_unlock(&nn->client_lock);
+	after = nfsd_sid_test_count(nn);
+
+	KUNIT_EXPECT_TRUE(test, stuck_status == nfserr_jukebox);
+	KUNIT_EXPECT_EQ(test, stuck_rand, 0);
+	KUNIT_EXPECT_EQ(test, nfsd_sid_test_calls(test), NFSD4_RANDOM_RETRIES);
+	KUNIT_EXPECT_EQ(test, before, after);
+}
+
+static struct kunit_case nfsd_state_test_cases[] = {
+	KUNIT_CASE(nfsd_clid_in_use_test),
+	KUNIT_CASE(nfsd_clid_mask_test),
+	KUNIT_CASE(nfsd_clid_collision_test),
+	KUNIT_CASE(nfsd_clid_stuck_test),
+	KUNIT_CASE(nfsd_clid_copy_clid_skip_test),
+	KUNIT_CASE(nfsd_clid_boot_time_test),
+	KUNIT_CASE(nfsd_cp_word_test),
+	KUNIT_CASE(nfsd_cp_token_check_test),
+	KUNIT_CASE(nfsd_so_id_nonreuse_test),
+	KUNIT_CASE(nfsd_sid_test),
+	{}
+};
+
+static struct kunit_suite nfsd_state_test_suite = {
+	.name = "nfsd_state",
+	.init = nfsd_state_test_init,
+	.test_cases = nfsd_state_test_cases,
+};
+
+kunit_test_suite(nfsd_state_test_suite);
+
+MODULE_DESCRIPTION("KUnit tests for NFSD state allocation");
+MODULE_LICENSE("GPL");

-- 
2.56.0


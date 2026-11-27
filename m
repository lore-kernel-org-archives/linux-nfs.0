Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795801293;
	b=RH8gW5epslxZaGHmid8drxgJTXCjPdL8lQzOjPd5S9xvFX5qNZjSwyVg5HpvbfbpVdLv
	 dfxxF/jowGuIMWVigrt4GsYA3CkH5Zt4NJzHq1UxUw91dyECHF1k2T4yfKFAbLLcI3NPw
	 sjYA9klVZ6eC9sr8u9gycSc1fEETJ+4idZsOcLTXIhvH9Z4xdYRWcMlhgBK/7dRs9wJ9m
	 Jn6fSftLOTWM5xLVRHnpQY0tX2OTh2J8asHNVTMqFFRXioyBQrFexSMK0afBlDT+G9w9J
	 U7r/zhjj9ST7QHLfpW5VDst0zpsRAx43DEu3RDa9oPK14cd5oVC4i/9adjJm4YGiuWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795801293;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Rm24O4KXJh4+S6a1Gqwo//gQ0ArVbXdYLfdR7nrdWMk=;
	b=LbXvNXlFNf52w50Kqe7ga6TNHltqbBbEGaNoR2xR2OKntVmRhSOUQIA3QsDExL9pCASR
	 fzjL/i6qcGbwQzkd9PdPyyp5JLfRrMnNe4DcM13hXjC9zmNX81njOpA8bBYn/SxHeIqm/
	 lYNoMOVe8C6dF6IECcYMN9GxhyX2XHsudk6g6znPN30wmmetkcoqxGPDHjpMD6NO8EaTk
	 ooDGS/frC5qW/R7nYshPr6wlGk9EbEUB6nh9XbuB1G6PhJZWfxT+2hyGr9ejEptqC61qG
	 CBei73SP30AcpgUUwTsCZvq3l+T6ynfKKPB9ZDiWlWPSu7eBZf141iijnep27GFUaaw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="LEwfio8/";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B256F606A321
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 17:41:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LEwfio8/
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C004D1F00893;
	Fri, 27 Nov 2026 17:41:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795801293;
	bh=Rm24O4KXJh4+S6a1Gqwo//gQ0ArVbXdYLfdR7nrdWMk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LEwfio8/OQmPqH7Gt6aVWOM54ridLWLVmHuzDhRYMTJ19o4J9OpZYyvXGqNPcbpx7
	 xI0slgmZazN6IeP6UifPut1eRPVKGXMvc172ahea3NNdMzizhQIbdY40hUZeB1L7ew
	 5tmfgJr+QfwSJ4Ir89pmgq+3FBS5W50SqgNxq/atLfTAfOb3BjOuA+ev45HaNDrOCO
	 cncR4gL7vwWuHsZXUuzpR6x7n8uo5tXz/J8MsyIViefNsyJMtL9wb4gUU8VPIGszev
	 f8fLWl11fMleDcJPRMeK1MNd8z6h4BIZ9nng45Sz4EFL6eCGx9ElI29LkgleBP6Ugj
	 yo0aIlPxTfZew==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 27 Nov 2026 12:41:24 -0500
Subject: [PATCH RFC 2/5] NFSD: Remove the session slot shrinker
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
Message-Id: <20261127-nfsd-slot-retire-v1-2-d9f6636cc713@kernel.org>
References: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
In-Reply-To: <20261127-nfsd-slot-retire-v1-0-d9f6636cc713@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 linux-nfs@vger.kernel.org, Kari Pulli <kari@smasint.com>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=6752; i=cel@kernel.org;
 h=from:subject:message-id; bh=c/5YlN529Cfnk6i36N0uDYCJJyzKFBNiV16ljLRzvfs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrCcDKeXDq5p2U56PjVDNd26+hiF0BY6xZH9FuE
 rDRTXRCC8WJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawnAygAKCRAzarMzb2Z/
 l7wcD/43DqeSKLFK7GGVcJ2JxLeXe+2ilbCD/ZtxfEToMUAKHENG8Q07xs98kNUYe7gj7ijr873
 iOcLPSkV055WlbC5/kP3T0idoPHHvs8Hp7urEWESVTg2lggTUV/rySJoXxCB+vTinVNZgurerBF
 KM2gMNJBzohpiF9G+lRbSe/G+TMnwQhYAlm00TIEQjul2AAyIdXOu0oCGQHO2He95Jc740PUl/H
 jHWDC+P5qOeuKUnARv1z6G/m9NjvYVz/o+z9/W7CbTGBJGSeuCc8Mp7XbGvyQlLI1TOOTSdZGjc
 e6NfgfhLYRchVFuDk3ZPGdDtwiGUcT0+h4PsIuN19/DrBNLt/zDB3VWxcEkBWhKPHDfpwZaXKMY
 JBVeV4s6ihmBr4cc/A9SCtf+t2iYh6jd1VB6RuFRjREKh3oVfPgGJ5b2IrBi0/07Dku+QAw2gdd
 ZCKoMtjzKdqkJ3B/tiDNGjBdkwravReT1idYkTRcQ2ozwt/OMdBw/8Eg24k1VifR/aMuFR2vjPg
 2z6oVR8veEimO64DI5WqGO/3TgyDJdaY3ycQ/uMv+/eEdyQuH18OVNp44YFOCHNjlK3GA8Bec5j
 RqrOUKbbVoKNmEaLnz2xU8zmYFq4kI1IjM8uQCTOKqxY7ku04Qtg6AbvY8YeGoh+ee0tRIURVkP
 tn40Jx1YIZ//6og==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Under memory pressure the shrinker lowers se_target_maxslots, and
nfsd4_sequence() frees the slots above the target when a request
arrives that it takes as the client's acknowledgment. RFC 8881 gives
a server no such acknowledgment. sa_highest_slotid is the highest
slot the client has a request outstanding on, so it is low whenever
the upper slots are idle, whether or not the client still holds
them.

The Linux NFS client discards a slot when a reply lowers
sr_highest_slotid below it, and replies that arrive late can raise
its limit over that slot again. The client then sends sequence ID 1
on a slot NFSD still holds at a higher sequence ID. NFSD returns
NFS4ERR_SEQ_MISORDERED, and the client retries the same request
every 15 seconds without releasing the slot. While it holds that
slot, every SEQUENCE carries a high sa_highest_slotid, so NFSD never
frees the slots above the target. The session makes no progress on
those slots until it is destroyed. On a v7.0 server whose target had
been driven to 1 on sessions of 96 to 444 slots, WRITEs stalled for
more than a day.

Remove the shrinker. se_target_maxslots is then never lowered, NFSD
never retires a slot while its session lives, and the client is
never told to discard one. A slot table still grows on demand, and
its memory is returned when the session is destroyed. A slot with a
full NFSD_SLOT_CACHE_SIZE reply cache occupies a 4 KB allocation, so
a session at NFSD_MAX_SLOTS_PER_SESSION holds up to 8 MB that memory
pressure can no longer reclaim.

The code in nfsd4_sequence() that frees slots above the target can
no longer run. That code and the session list and counters the
shrinker used are left for a later cleanup.

Fixes: 35e34642b599 ("nfsd: add shrinker to reduce number of slots allocated per session")
Reported-by: Kari Pulli <kari@smasint.com>
Closes: https://lore.kernel.org/linux-nfs/CAPJN3b=1qd=5E7BVTCG6UtR7=BqUenM6j7zTuDHCEno5oj77hQ@mail.gmail.com/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 106 ----------------------------------------------------
 1 file changed, 106 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 29f675b14670..80c2fb487ffe 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2372,7 +2372,6 @@ gen_sessionid(struct nfsd4_session *ses, u64 rand)
  */
 #define NFSD_MIN_HDR_SEQ_SZ  (24 + 12 + 44)
 
-static struct shrinker *nfsd_slot_shrinker;
 static DEFINE_SPINLOCK(nfsd_session_list_lock);
 static LIST_HEAD(nfsd_session_list);
 /* The sum of "target_slots" on every session, slot 0 included. */
@@ -2410,41 +2409,6 @@ free_session_slots(struct nfsd4_session *ses, int from)
 	}
 }
 
-/*
- * This interface can be used by a shrinker to reduce the target max-slots
- * for a session so that some slots can eventually be freed.
- * It uses spin_trylock() as it may be called in a context where another
- * spinlock is held that has a dependency on client_lock.  As shrinkers are
- * best-effort, skipping a session with the client_lock already held has no
- * great cost.
- */
-static int
-reduce_session_slots(struct nfsd4_session *ses, int dec)
-{
-	struct nfsd_net *nn = net_generic(ses->se_client->net,
-					  nfsd_net_id);
-	int ret = 0;
-
-	if (ses->se_target_maxslots <= 1)
-		return ret;
-	if (!spin_trylock(&nn->client_lock))
-		return ret;
-	ret = min(dec, ses->se_target_maxslots-1);
-	ses->se_target_maxslots -= ret;
-	atomic_sub(ret, &nfsd_total_target_slots);
-	ses->se_slot_gen += 1;
-	if (ses->se_slot_gen == 0) {
-		int i;
-		ses->se_slot_gen = 1;
-		for (i = 0; i < ses->se_fchannel.maxreqs; i++) {
-			struct nfsd4_slot *slot = xa_load(&ses->se_slots, i);
-			slot->sl_generation = 0;
-		}
-	}
-	spin_unlock(&nn->client_lock);
-	return ret;
-}
-
 static struct nfsd4_slot *nfsd4_alloc_slot(struct nfsd4_channel_attrs *fattrs,
 					   int index, gfp_t gfp)
 {
@@ -2620,66 +2584,6 @@ static void free_session(struct nfsd4_session *ses)
 	__free_session(ses);
 }
 
-/**
- * nfsd_slot_shrinker_count - report reclaimable DRC slots
- * @s: shrinker descriptor (unused)
- * @sc: shrink control (unused)
- *
- * Return: a positive count of reclaimable slots, or SHRINK_EMPTY when
- * there is nothing to reclaim.
- */
-static unsigned long
-nfsd_slot_shrinker_count(struct shrinker *s, struct shrink_control *sc)
-{
-	int count;
-
-	/*
-	 * To prevent session deadlock, one slot of each session (slot 0)
-	 * is not reclaimable while the session is active. Thus the number
-	 * of sessions is subtracted from the total number of target slots.
-	 */
-	count = atomic_read(&nfsd_total_target_slots) -
-		atomic_read(&nfsd_total_sessions);
-
-	return count > 0 ? count : SHRINK_EMPTY;
-}
-
-/**
- * nfsd_slot_shrinker_scan - reclaim DRC slots under memory pressure
- * @s: shrinker descriptor (unused)
- * @sc: shrink control; @sc->nr_to_scan bounds the sessions visited,
- *      @sc->nr_scanned reports how many were visited
- *
- * Return: the number of session slots NFSD will release.
- */
-static unsigned long
-nfsd_slot_shrinker_scan(struct shrinker *s, struct shrink_control *sc)
-{
-	struct nfsd4_session *ses;
-	unsigned long scanned = 0;
-	unsigned long freed = 0;
-
-	/*
-	 * Each visited session releases at most one slot. After
-	 * nr_to_scan sessions have been visited, the list head is
-	 * rotated past the last visited session so the next scan
-	 * resumes from there.
-	 */
-	spin_lock(&nfsd_session_list_lock);
-	list_for_each_entry(ses, &nfsd_session_list, se_all_sessions) {
-		freed += reduce_session_slots(ses, 1);
-		scanned += 1;
-		if (scanned >= sc->nr_to_scan) {
-			/* Move starting point for next scan */
-			list_move(&nfsd_session_list, &ses->se_all_sessions);
-			break;
-		}
-	}
-	spin_unlock(&nfsd_session_list_lock);
-	sc->nr_scanned = scanned;
-	return freed;
-}
-
 static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new,
 			 struct nfs4_client *clp,
 			 struct nfsd4_create_session *cses, u64 sessionid_rand)
@@ -10690,15 +10594,6 @@ nfs4_state_start(void)
 	if (ret)
 		return ret;
 
-	nfsd_slot_shrinker = shrinker_alloc(0, "nfsd-DRC-slot");
-	if (!nfsd_slot_shrinker) {
-		rhltable_destroy(&nfs4_file_rhltable);
-		return -ENOMEM;
-	}
-	nfsd_slot_shrinker->count_objects = nfsd_slot_shrinker_count;
-	nfsd_slot_shrinker->scan_objects = nfsd_slot_shrinker_scan;
-	shrinker_register(nfsd_slot_shrinker);
-
 	set_max_delegations();
 	return 0;
 }
@@ -10742,7 +10637,6 @@ void
 nfs4_state_shutdown(void)
 {
 	rhltable_destroy(&nfs4_file_rhltable);
-	shrinker_free(nfsd_slot_shrinker);
 }
 
 static void

-- 
2.56.0


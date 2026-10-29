Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297188;
	b=kxriAEGUr6iYjt7P4NyDo6LaN5hvNsdFzAKTwb1Z+rCvu8QTJ0IPm/aXArR8iVjLmsd8
	 OW+/RV7USQNX2cZliqrtEz1HwHlekkPLbqg6B2GGJu8oyw/90Lz0talzK5b3QLA8JFoCR
	 0YKaZWI4rvo/EQ9F0umHWKjA/JmSXSw3pFQiBNOrGQKydA3kZpRFMcNIOS5M7bBPSY4dD
	 UHqui/ofS9SJvhfTzTEVP/QdsfrpQ16+zQRv4bX8/LJqv9alJNWWiVemSVYNyCJ414uYW
	 5ESgmmDZHts9SoGEjC5rtZ99cpptsWtcxQYbcN0Od0nwt9x2lWTJKs0wGLzd70pzorg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297188;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=hOsDpYExlCMSzAVzunquBr0tLWSv0I2nzLD4kk8hi0Q=;
	b=scHT9/WiVwTe4EcHeSR4h3FZv43JRa5mdxutNkwSHKrw7OahLlaIubqrfYaeEcXL1dhL
	 MJ1k0j/D/7khmPnDpiRj14qKMCW49oThuLqiSmwPMPXcRP2zxVrBoXabTXlhu2HD6sWOU
	 sHJcmUgGO2SpAd0uL6qfV4RAhIfw1wrMK7OrJmqFQ0De31JH1QM9b2wc2ncHsmZmbSOJE
	 4MBl0bLIGr8LSXm2gXQxUe9hhlc0KtYbcx2pYFr1R1qcJc5WtYgBIxz0qx5vYeOQoeiaH
	 RTkSzZcQyiNKsLLymjwECDtqF1hgC9MFd7UZ7xn9ISKvNoe+YMJEDFB3XvMCMoR8Tng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=itB9NCs4;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD5D5606A323
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=itB9NCs4
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BEE151F031E0;
	Thu, 29 Oct 2026 18:06:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297187;
	bh=hOsDpYExlCMSzAVzunquBr0tLWSv0I2nzLD4kk8hi0Q=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=itB9NCs4W2WNpFPROdU0biaq2lPAHdawxGsGq0PiS/zlOimQwHYEDN6By9fQMAwxP
	 wrOUudH7J2XOWC6Tx0Odm1Iy4SavXXFTybM8JaGtv+i0I81/Z9p3cI7ikWJ1/H8QhX
	 FMC+fFIofZakQWgUKX3LEytlrnRcWF9jZBTdMv2LXDUuvQeCa/fH4Rj8cI262kfrbB
	 ccfpoyJTjm7uvC80PRcyeUBrwSNwFduzTyAur7lq2t3tPQ9MH9GdsXzRPatgL092KF
	 l1EOPwVBlm8oNEiiS5Gw6XJd4I6ww1Zd264QH7v3detrWEH1wtXjNXyan7sSR5Mq9r
	 6Vc8G3kahr3KA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:12 -0400
Subject: [PATCH v7 06/13] NFSD: Add tracepoints for DRC entry eviction
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
Message-Id: <20261029-duplicate-reply-cache-v7-6-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2973; i=cel@kernel.org;
 h=from:subject:message-id; bh=h810vjQ0K97+ubOxuAuRoBYZAaRHUxDswlV67CJzl/0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scTPOs4SUpJuQZi8XP004MQRYmc+/NLBVZB
 I6umcnwr0WJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l1KmEACzICD+OQWzuF9U4Kek71yPJxWaXDecsBLo9vJIixSt6E5ej4rTfeyr19v5LRxpgYGJGOU
 nBHnIf95GNRBeGfVA2j7/XwxZgEbESm43q5SsBWj/Q80uR+PAzskIORoJU0ZFyaQ2Cr5tfKGfhQ
 633+Q9OYMRj2po/xACxp8axO2/5/fvkwbL6gXxhdErArZB0EkgDleB1kbSlILuZC4epoDHJN+CP
 z8UkP1NvoO7+1AOpqo8rijtWFJWig4CI+ZTPV9TfcvLcCgfAgzS6G7wp0/NSdcLAbouRcIVztn3
 Mwbij/DAoEP4Jnl02bIK+9spkm+Z4SfmZDJ7i7FhJoE6VOL/C+kKVXr5qEZtgXJakkgbl8MCAMR
 Z5moNCf+bhgIrrSHmq3P9V58IvHuO1MZYoKZp130rxUOIwW+Cd9WJz3/37aZRDtafw2peGHQFTR
 f3Bh91MbERnQRcnKI7DpmfgYepp+2HR5/GqCjguQl+mVJd57kzhyiHkj2fqwZNey3EW5rBKoEPR
 y72g0wh2vdSm1E9MslZzLmQ9aho8NJDY7c3QzQ2ZtS3oPGz4gZK4mu24xBodmAAfVtkwWeFAjzv
 0fCSWW9CYSXxjoDC75P8Hf6C97Bzjv9xDN2wvEBBk3iOOi59hIPoKbG/PoY8R2stVstc4a7m+mo
 2wUftkpfMu0fBLA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The DRC pruning path evicts entries for memory pressure and expiry,
and neither emits a trace event, so there is no way to see which
reason is retiring entries or how old they are when it happens. A
further eviction reason needs the same visibility.

Add an event class that records the cache population, the XID, the
transport, and the entry's age, and define an event for each
eviction reason.

Assisted-by: LLM
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-6-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  8 ++++++--
 fs/nfsd/trace.h    | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 988b955590cc..680025334f1f 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -274,10 +274,14 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries) {
+			trace_nfsd_drc_evict_pressure(nn, rp);
 			goto evict;
-		if (time_before_eq(rp->c_timestamp, expiry))
+		}
+		if (time_before_eq(rp->c_timestamp, expiry)) {
+			trace_nfsd_drc_evict_expired(nn, rp);
 			goto evict;
+		}
 		break;
 
 evict:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index e7b186307c21..e19e7075d879 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1708,6 +1708,43 @@ TRACE_EVENT(nfsd_drc_mismatch,
 		__entry->ingress)
 );
 
+DECLARE_EVENT_CLASS(nfsd_drc_entry_class,
+	TP_PROTO(
+		const struct nfsd_net *nn,
+		const struct nfsd_cacherep *rp
+	),
+	TP_ARGS(nn, rp),
+	TP_STRUCT__entry(
+		__field(unsigned long long, boot_time)
+		__field(unsigned int, num_drc_entries)
+		__field(u32, xid)
+		__field(u64, xprt)
+		__field(unsigned long, age)
+	),
+	TP_fast_assign(
+		__entry->boot_time = nn->boot_time;
+		__entry->num_drc_entries = atomic_read(&nn->num_drc_entries);
+		__entry->xid = be32_to_cpu(rp->c_key.k_xid);
+		__entry->xprt = rp->c_xprt;
+		__entry->age = time_is_after_jiffies(rp->c_timestamp) ?
+				1 : jiffies - rp->c_timestamp;
+	),
+	TP_printk("boot_time=%16llx entries=%u xid=0x%08x xprt=%llu age=%lu",
+		__entry->boot_time, __entry->num_drc_entries,
+		__entry->xid, __entry->xprt, __entry->age)
+);
+
+#define DEFINE_NFSD_DRC_ENTRY_EVENT(name)			\
+DEFINE_EVENT(nfsd_drc_entry_class, nfsd_drc_##name,		\
+	TP_PROTO(						\
+		const struct nfsd_net *nn,			\
+		const struct nfsd_cacherep *rp			\
+	),							\
+	TP_ARGS(nn, rp))
+
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_pressure);
+DEFINE_NFSD_DRC_ENTRY_EVENT(evict_expired);
+
 TRACE_EVENT(nfsd_cb_args,
 	TP_PROTO(
 		const struct nfs4_client *clp,

-- 
2.56.0


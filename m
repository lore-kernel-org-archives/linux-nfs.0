Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C5C59455624
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996966; cv=none; b=MN6XZPvnSns3y+UVWn5bb2KJPGBbrHXafttNzctjcASt/6XhYpHiS74mshNqFq+fkiq45TjYqNCiu8Pl7RPytM3KIh+WOK2j9MMJuBo0zG0j4woZYKn06ECukY3ZRS6SX2Awqp8C1Ou5caFrrwDIl5ZZ71KF1x0DitRMizYt9YY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996966; c=relaxed/simple;
	bh=swZE5iB3x/OhEKxYqlCjvkbzFbGVPLE3QYypEebBf5s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gWuCzaenkcm5v8+EWlYCR/aeFl3HD94lDMGRTf1Qhafvumv7QuNM958fFx8oMM6mmqFj6mLnNfp1CYQND7FmVa9E1VLAq//3lJXK7xfFzM3hWvMTFBD6A2JenIrEaLfEJAIcma3hD9WTqJvJCq9OBEV2DErc/iYgRMh/yfj8wok=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mGAYIZKJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mGAYIZKJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A4DE1F000FF;
	Mon, 21 Sep 2026 13:22:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996964;
	bh=dOIcj+IStGBXYqs67dZ3kMSjN2FP6mUI70TFX1rOF4A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mGAYIZKJ55u7JK9nuuY4l1BpQLMoN3mYfi1Opq+ythWlNbG+j0NbWF2BnrSKLJZtl
	 C7EyxkbFmCBcTcmmXF5a0MZ9W0cInikUj1ZSiuKEf+BOAutb4xB4iQq3TmZHKdhJxJ
	 8HQwJtzwJlUBzmFGOkbQFZXXrNVBqiDe3cexNPzqrCPuquryXA7JJ8v3pxMEhReDH7
	 SVC07byPVpWP7XL08x3imnt1o3fpXONMLHljQS5bzSv34seSyNBL4/DlkJs7Lr0FRg
	 B3/0hT9aqEU3LO92BhwkRNOLK2E/Z6w3drRCo92fGOPC7L00GTGYWooLrNImO9MUdG
	 gXUrcVWf1sG7w==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:32 -0400
Subject: [PATCH v6 06/12] NFSD: Add tracepoints for DRC entry eviction
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-6-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2839; i=cel@kernel.org;
 h=from:subject:message-id; bh=swZE5iB3x/OhEKxYqlCjvkbzFbGVPLE3QYypEebBf5s=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+dH8wUXCbRD01vCBgi212hx1W8ywGfproE3
 7+3FeSID9qJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 l1SoD/4xKd5YqroPVpbwmrQwiKpuCppP3ztRlz/gkH5mB2Fcn3N3us4brt3YoS4RWoMp6KHHHbH
 ulkpk5oQTWTnMandyqm1PUwqqYRI/q1EPiHmu8RRt25bvZnAPwkoqmtQSZT+ZzUAzMeFSoFYhGS
 8FLVlOBYIv6qgAz6rF2CjirNOWEUvpjucqvT5l9cQOWfAFx2TQffPMo0+R7D+fYrBY/YcBCjyzQ
 9GIyW1f7hW1j3orbUb0C/uX8t17BIZG7sPkGk8W/kva4V40c4Gj8r7PjhUpcToTPegn1dNLzkOZ
 ZtppStmJvr/VLccq3Qx7A57XkvZl8SMRKldu3DSCLctGSvh7L1V00WHmcjdjXsqNwoCF8SrLtOs
 cA7oHAkg2bvn2XCfXfT6huLa8hew9G7ik9Hk4+ZHlseeRB0NClw0wm2IsUIIYZSedNlJCCgz5TB
 J3ipJMcovmGhE2l390hOoT6LbYCXrdl+DpdrKJJMCEu1Drrn7pEXjUi/tWeqp7sxS6Otw0Z+bp1
 RODW7Tqp/w6xSXof6CqOlxPdpEhvxT+DcpoF6PhmR8ydeEJ0MLWPVC9LfvaORVlV2a3//LY+5W4
 vgMxMt/6ye/kFOjbLyNzyTVbIlrKAlTJCrN6znYndPF6aMQWHXvOkHjQ7uEVrp8jTx7BgygNNX5
 Q6kXhbM01AUDLVw==
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
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  8 ++++++--
 fs/nfsd/trace.h    | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 27c369b1f11b..1cdb53e9e807 100644
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
index 2ae7f150a72c..ed4efcfa3961 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1557,6 +1557,43 @@ TRACE_EVENT(nfsd_drc_mismatch,
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
2.55.0


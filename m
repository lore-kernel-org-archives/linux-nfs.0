Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F39AD37E5F7
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933891; cv=none; b=j9Hc8JNrzRTxJKvQPO9EY/mu/+QWWw2hVBLIryWeEKfPuZyQvNohBRx8q/h/3twnjcC1orDxmreDWjwgWyz927rDfwwkyI9fLKWOP3Djbmcq6L2rstSKDeI0NoPYRzzst2QTLzekgGEfe6Fjvn4TLz5sFlWeLNaX4q3WylzQHxU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933891; c=relaxed/simple;
	bh=vSy4tCOb4aJoJ6NJILu1c6YKZPJRVlTX7LmKdh6oF1A=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=emqxHrf94sSUvxEhkKiJHh3kJmHPbIL4PfyYXvETAxhTM/7ORLMusdq65AZskvq5XxsxAiu+WWUD8S0mm5zvUMeg0u7Bx696/UYYGS1Ulzq06qVLwH3h3SFdzSY4P9b9NbEL/5P4Xn9GNHNlGoYTYJ2fdtZSqEmJOY7XMssAm5E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=S3rD7PNX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="S3rD7PNX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48DC31F00A3F;
	Fri, 28 Aug 2026 16:18:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933889;
	bh=WATS6BIRPQvln5ycgogXC61b2OixTG+6U9QOzx4I1IQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=S3rD7PNXryeHaSIJzF/1GrIhRkMK6WIp3VskQIRhvU/xWWW1mVy9Iw6vun96fFmkJ
	 Hal9FmmRY8fFXhNtibkZJKVX5XRtvCcfzpaBNOai5Tl3w1yos8cufGr91c1aDxuBrs
	 BrSAklD6jKaXX+WOrrkYSVLlj9cjDyyvGa5sXAw0R8nPy33iN9X9ePQO1dr/Viyk/q
	 HGCYhBLKpcF+Dk1CnX3srVb4DLZ4Qh2bsbr/PhDt8cCUtHninj/ODfVoW9NbNNviWt
	 67JnTMnrKM2BBrhM6KdgVWnfSGu4ISciYWEbYbFHc9uAjUTumCZ3/MKm7nBKe1b3qc
	 iYokwe1F1kfMQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:59 -0400
Subject: [PATCH v2 7/7] NFSD: Record DRC population in lookup tracepoints
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-7-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2153; i=cel@kernel.org;
 h=from:subject:message-id; bh=vSy4tCOb4aJoJ6NJILu1c6YKZPJRVlTX7LmKdh6oF1A=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS7pPz6e+ubVPsFT6+u/aRydrn1p4Nrw4YfE
 ftIhkMgaKuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0uwAKCRAzarMzb2Z/
 l+xzD/4sGDCABQroUrWdYBRJ0msjWLEicW/g9bJQaoznh1HgMwZrJiLRTX6Avu8/Q3fMYRda5gX
 7u+ZafIANwInrqDuOyI5lnp/tqKPjUwbUbLt/RxjquY8iEzMdlaq1h6NM76Fryd65bbKzjVIyLD
 vRwk8bI7h67tmVnkWGvmOcNFrhSz3QHVxJJbOuWp1M5ZBdFfBzPv0uU1Prf0mYYhOc195PcjyUo
 x74tMjCCZuFV6pO1W26khULhtHlZIDCPfIHORk/C2F+RSbKA5kQikOrgvTjgd1u0lxmimskk8Nr
 amw5hTdZXvWaMFkem5kFhlYxUbuvf+rSzVVX6hI8BPMUCyL6n9+pSgKB6Qw47R60r7HzT0p4tU6
 YC9UKFRRtqJiNyxAxpBv+xCkjLqEclJS8p+jLBerC+7ti7lyKpfA4ThKc39YrVPcqfAOuZpDo/B
 Q8T8EclkYuA4QDEXr1mZ7h/o2dvAFjN5p8Cc4oDbBmHcQx2WvHKWWH2nMwDdEO5qbG1KfbsSamr
 DIc2qTZOXtXxDiEwlEkZCQ197hCACoqUBwXYBGYI4P1LPHTAAsydumX0a7m7Q07cgrhu30sb115
 g+0iQWi0vZUd6MwjTK1g6FrNNN+3q0i/qa3sy/85vvhswOssQDvncBbKYT1yecGAk6b4+sBR5P8
 ox85pmp8jzgUbRg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_drc_found reports the outcome of a lookup but not how full the
cache was at the time, so a trace cannot show whether retransmits are
being caught while the cache runs near its cap.

Add an entries= field. The count is passed as an explicit argument
rather than read from nn->num_drc_entries in TP_fast_assign, so that
per-connection lookup paths can later supply their own depth without
changing the tracepoint format.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  3 ++-
 fs/nfsd/trace.h    | 11 +++++++----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index dfbcc75fbb12..b917af667a89 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -606,7 +606,8 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	}
 
 out_trace:
-	trace_nfsd_drc_found(nn, rqstp, rtn);
+	trace_nfsd_drc_found(nn, atomic_read(&nn->num_drc_entries),
+			     rqstp, rtn);
 out_unlock:
 	spin_unlock(&b->cache_lock);
 out:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index c8468f67abe0..af3e0c3f36d2 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1500,23 +1500,26 @@ TRACE_DEFINE_ENUM(RC_DOIT);
 TRACE_EVENT(nfsd_drc_found,
 	TP_PROTO(
 		const struct nfsd_net *nn,
+		unsigned int num_drc_entries,
 		const struct svc_rqst *rqstp,
 		int result
 	),
-	TP_ARGS(nn, rqstp, result),
+	TP_ARGS(nn, num_drc_entries, rqstp, result),
 	TP_STRUCT__entry(
 		__field(unsigned long long, boot_time)
+		__field(unsigned int, num_drc_entries)
 		__field(unsigned long, result)
 		__field(u32, xid)
 	),
 	TP_fast_assign(
 		__entry->boot_time = nn->boot_time;
+		__entry->num_drc_entries = num_drc_entries;
 		__entry->result = result;
 		__entry->xid = be32_to_cpu(rqstp->rq_xid);
 	),
-	TP_printk("boot_time=%16llx xid=0x%08x result=%s",
-		__entry->boot_time, __entry->xid,
-		show_drc_retval(__entry->result))
+	TP_printk("boot_time=%16llx entries=%u xid=0x%08x result=%s",
+		__entry->boot_time, __entry->num_drc_entries,
+		__entry->xid, show_drc_retval(__entry->result))
 
 );
 

-- 
2.55.0


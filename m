Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E62DC4A2630
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 17:21:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789752104; cv=none; b=EQMPT88EI0C7jRvRFxT05SleB+JZn/tnYXVQtshfHOabNJ3I9H9i+vOOGDWEAsrjtWzE22rQwOlhpgnXDijNqZv2kZGufyTc+XLVUVwntLXB7xMtpdwKrUhm+HcxQRivfuxrr8EHxMDJeqQ8T96ieB/nL03nKFsEogmi6NJJcok=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789752104; c=relaxed/simple;
	bh=P+7bwdE2Q2dK7jHFews2MPwshwmDfR0H8/shMSOf6VI=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Xr0jPDF8ZMF3SgdNSNmkAJEa9TK0aJFf/1AtqsmpleYKNA1Zuqpl6PhWT26ptPDKa7dCvZDFcmroS7DZB/9nEMoaAQyYYC2ltyJ6XYiIEtRWrZbpO5lWVa6Om2OmY7LPIXsmr8JnDS7e2PwAFwqb23oDg5LTfMcr1ahNx6XiS9k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k+KGID7E; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k+KGID7E"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 169781F0089F;
	Fri, 18 Sep 2026 17:21:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789752092;
	bh=edFGTlpqs/nkZDb0jXzbY8Giwq8F/mDn8ozWbb8cG0k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=k+KGID7E5qab+MnPXtToUQuPkJn/eZWSP0HZqlHLVmTvKsMmh0YKxRbwVyJrFtO8C
	 5avW1kw8CjS3Og/zYZ8hgmKUi77YueHDHas8ZeU0FjSEbaechoH1uz1Ycs8iS5eBv0
	 jEyyDLHoDTsUAziauZFvGYxn2fObWuvAOi6CGzyOntZDLXjaO/METKrTvbZraDYfwN
	 zuphq9F4I+h/lArlpXf4xCswE3G8D7Q+jKDt3/ZWblLeiWdW2JabZznlky3xXhNHkP
	 UohBhZTc11xikSvgUZfFz9csI6TQ1Vq/kY1htyODaC6RIpzT+dP8wOa+ltScLiZj3E
	 ojSDdf4/3Zx1Q==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 13:21:18 -0400
Subject: [PATCH v5 06/11] NFSD: Record DRC population in lookup tracepoints
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-duplicate-reply-cache-v5-6-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
In-Reply-To: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2197; i=cel@kernel.org;
 h=from:subject:message-id; bh=P+7bwdE2Q2dK7jHFews2MPwshwmDfR0H8/shMSOf6VI=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrXMWw+boAR67JtwzYCiNm91nTNqakV/QEXIRr
 oz0+a/xr5uJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1zFgAKCRAzarMzb2Z/
 l3SdEAC+c0nExs3sQcEq3QfO228cl8R11jcKitWIiTqAk2E5Dpbfhuv+Joay81o99nq0lRp75qY
 GdcFYJaN3urNTJpOzihiy8ataCCEsOjdvVxXeaGd9ZBcX2AbjkWNojaG3u5OFdhg6YgDVZB2vP0
 zNGE7DD6XssufUU8QX5U/S6wHRh7YquN5MXPtcK7/sX79ovlklfC1jti0uH7suePCuWXHIoB4ug
 6k0Qp11/FTwmwQquyHU1J/VlDX2giql4ITQ390B3MR55fbCQBFkM3kkYtUg31kCQQbt4+C9ge0+
 bq12D2k+v55OGg7oZ0FXuQVCCN/W22+eWXtDq0F2E4iiqI2i5v3EZpvfoDlCOhztyEGV53px4y3
 FpyFYQ7ia+cz3sldnwdQnCFfwHGgbZQtvpgjQIzDa28FhF6Dtp/4O8CgAR+yYkzal8e5GnqyG0x
 w/Fuc0iydRi6J+WC508I4tVOhNJSd5MXmYNHzp5ROwyMH3dYQfCEYUJhl+oAi+MLQPLlkXcqc5J
 ZVlw2akyvEVvJlLzK89ZOLhc9p0NuTsIMAbQ69TfAaO+c3DukeoezZgYsg1erbE8Wnj6bKARL9I
 NpytTUHTJpFHLuQwM64vaOzYH/I05A0AMYpVEpI/QbogocvwbZFxR+OBLTNNuQVPxdsBAFJybOe
 //7KL8IkU/SfvHQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_drc_found reports the outcome of a lookup but not how full the
cache was at the time, so a trace cannot show whether retransmits are
being caught while the cache runs near its cap.

Assisted-by: LLM
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  4 +++-
 fs/nfsd/trace.h    | 11 +++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 4d0101e93add..cd1011bd148d 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -487,6 +487,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	struct nfsd_drc_bucket	*b;
 	int type = ntli->ntli_cachetype;
 	LIST_HEAD(dispose);
+	unsigned int entries;
 	int rtn = RC_DOIT;
 
 	if (type == RC_NOCACHE) {
@@ -556,7 +557,8 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	}
 
 out_trace:
-	trace_nfsd_drc_found(nn, rqstp, rtn);
+	entries = atomic_read(&nn->num_drc_entries);
+	trace_nfsd_drc_found(nn, entries, rqstp, rtn);
 out_unlock:
 	spin_unlock(&b->cache_lock);
 out:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index ed4efcfa3961..631682a76f9c 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1513,23 +1513,26 @@ TRACE_DEFINE_ENUM(RC_DOIT);
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


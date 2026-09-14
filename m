Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62DC32264A7
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 14:45:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789397150; cv=none; b=NK2LwIHKUx5D4B/0tdaQ0TeZ2Dd/qivSz77e936VMnbvgGXgXvYXatPDi/EA1XVRa56mSqUASOw72+WJ2H1Mi/o5J8at+YScHm37BBS6jEoynfN/NXpktvP+mEwb55meF04L90hi0NZ++QGtKsUSfrQMPX0hCnPktMbm/M/9h4g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789397150; c=relaxed/simple;
	bh=NRjHOKJP6O4bWkbhGmhey3J/gvKxHssBretqUM0ezIM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iW4yKznJADvj/UXbNPDYiDiihudAwUIMY4QaIF6yEDyP0t01bEIsB7nkEh2CdYi1SPuTUPv4re13vNfUB1UspfLvrLvHPIw7IayZ8CCRaqnQbZtRIBjc4b/nXmOo4hhYCnr8xHgfes1ual1RjOm+ODPkZyS5tpv3Vu0uigWgcUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZOBdWneU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZOBdWneU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BCD21F00893;
	Mon, 14 Sep 2026 14:45:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789397148;
	bh=bEvH/q5xnrTUNJUmL5IwukZs5NSBRHB08ElHSfd34kw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ZOBdWneUXuGJ2tJrMFJeoxshg5meoCQd415JFtOE1LUjuOYkDdDdwD439Zd6YteS7
	 JOoXh+KDRQf9v7pllrL6vZWS5hBzJwTve4aAoF2dB2XE7c7qXobICB4FEPCju8DVtl
	 AO1LtLi4wjie72k7VrR15Ic6GJ/SY9FBwnlYoq233AHQI3LdOU9d6IT88dy3NMm2hV
	 5/pVQaSqe8qpEPFR6DFzex/VG/2uhqlIyDDYCbeSeRmsig+2mCMFKKdgBtS8vUi49f
	 +pcblSozITPVj1AK9QwKKm+zTmCFBZ1XtvSY7COkL0b/WH2Td/xZmk9BigiEW+q2fL
	 QM2KVber9A+7Q==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 14 Sep 2026 10:45:35 -0400
Subject: [PATCH v4 05/11] NFSD: Record DRC population in lookup tracepoints
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-duplicate-reply-cache-v4-5-bcf9d2628a94@kernel.org>
References: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
In-Reply-To: <20260914-duplicate-reply-cache-v4-0-bcf9d2628a94@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2197; i=cel@kernel.org;
 h=from:subject:message-id; bh=NRjHOKJP6O4bWkbhGmhey3J/gvKxHssBretqUM0ezIM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqqAiWAUPibdwRMvGJZ2GmjI/6VHyWJ2xvLypvP
 7NU8SLZLfKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqgIlgAKCRAzarMzb2Z/
 ly8AEADAsWlPBejlXqlNAyIDHrMQbHkuqjFILviryw4Lm6cJetdawJUOapPKQywP2v7rCy4L61L
 1yGgRNH6ETBh3Q4fIcf3uhjuUV0JnHQSdIn0Uh3j70SIqGOXvLUC+juWHAVJR2u8eoqPoVd0V41
 WsWL4/jqRpygmBx09H8LY7A+ipRA02clExLkoGIrsHLKIF05psVqXt+oeuZ6SZg1VtT4IuStXvQ
 9As2tQP0uao71OD2v0yhQfuYtlYzdw3zMFG1l4cuIHoDP1W855KYYB0wZYfsog4zYfeSUoIJ5BW
 Z3KoWf4JTHdlKLwxNiIwV4782P9fpMml8wmkTmlpUy0ZHCdvoZTjfKNftzW2CCC2dH8WqtbKslR
 UlW0AlPbyNW94UGUVosrOkWisn1T8Y7KhzGUW9rQEMo+tSofQq6nSQp5esFlLZyjZbc/FwuxUbS
 um8pveZmG14Oo9qlNuS0LjgVk+KsQ/brvru10GCPnlXARcGi594q6p2qVOSAuoHNYWF/hF0hgB/
 Nfep7DeBMIU4CWzO/KU+yTFOr4dIV2Fzp47Km51WD5qA/MK5j9QYpcFZQUmhE1WmotwFUpTrbLE
 lMwdKnQeNnrux99F4yWTJZM9EEhmsbVhVBT/3bSooCMps6Ge0QYGf8gSWEF0TzPYUa85tIXRpx+
 80EPvh8UtQ/K9KQ==
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
index b9fe9662dcf0..e639c8c81c4d 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -492,6 +492,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	struct nfsd_drc_bucket	*b;
 	int type = ntli->ntli_cachetype;
 	LIST_HEAD(dispose);
+	unsigned int entries;
 	int rtn = RC_DOIT;
 
 	if (type == RC_NOCACHE) {
@@ -561,7 +562,8 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	}
 
 out_trace:
-	trace_nfsd_drc_found(nn, rqstp, rtn);
+	entries = atomic_read(&nn->num_drc_entries);
+	trace_nfsd_drc_found(nn, entries, rqstp, rtn);
 out_unlock:
 	spin_unlock(&b->cache_lock);
 out:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index c92863027896..73205106b312 100644
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


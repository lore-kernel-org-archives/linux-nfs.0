Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A963649DBBC
	for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2026 13:22:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789996966; cv=none; b=gf8oKrOqTKeymVI7BRrk48uqygv2GqWFUkG639sWeqIq60ryOnvugOVKwbRS3rXn85O5UoNFpaCWbjYLrUoIZTIcvVXBvRUB5U0mD9IJJwFm+dAoWoj4SiWK//MsZ0Dwe9wN7LzsjF8P0pCWHpbpTSwcg2VU+sVuqHy4lNZ3hN0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789996966; c=relaxed/simple;
	bh=24bb4CKc4RUNBG0DXNzaoeeegno0wRmfIBQm5Vr9p88=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=dJbu53c3usZlR9QRZmx6auOBUGYy+elnaLINTV9wZpvF/yYmy1v8bwPRtR/JqIifUCQI1/HNPjQBwJZskvXkNMG1gNA342xaVpv2sq+iwwKoSaYroUABHkJ1RZlDRBBEgjCvulYhbJbeuk28CtuBJDQJ0/IfHSZ5Gaux0HyQHbM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WtOM6wxp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WtOM6wxp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9ADF1F00899;
	Mon, 21 Sep 2026 13:22:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789996965;
	bh=mmErwahB0YVwuiSxTPRrvWODxEp/YTaiKxpvMV53K+E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=WtOM6wxpLPMlrM8b61LCwJc9twyKCO0qIC4faGU+e8Nd0vQ3mN8orLxcdUih0lv1A
	 LHXBiCbHm4GZdLBo/Ahxo8xc4GTv7gFtZtcs7eyJ+HrSVy13rlk338wf5nNDCPompT
	 HX1VNv5YSGzvC5948wOKK+X0PQz3IjgjqguOU9hrVCrplPZJLsb24bqyn6xKo22PDc
	 /HhNIprHTKSz5SXwYmsCs0yQ69o93XH0cSGhVReCgfN+culAtRxhJeciZ9baYlhB75
	 ECMM7LuVBUNoQjMCn3PmgXINo25LEff0xNL0Kn8F08dTNlPuo8TG8K7b9mTJNJDtz/
	 xPrSecwmnNnkA==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 21 Sep 2026 09:22:33 -0400
Subject: [PATCH v6 07/12] NFSD: Record DRC population in lookup tracepoints
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-duplicate-reply-cache-v6-7-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
In-Reply-To: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2197; i=cel@kernel.org;
 h=from:subject:message-id; bh=24bb4CKc4RUNBG0DXNzaoeeegno0wRmfIBQm5Vr9p88=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqsS+d+bm6G9UEF4u2Cq/mMv4RidSXx02mU9F3M
 N1ymj6lVLuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarEvnQAKCRAzarMzb2Z/
 l4CVEACF5wl6FY56rOGby8I5B6uOpEjsnfzg9bWGWOZmBqGcpgS6gptByhIwd/02s/1fbwnUiRc
 EhtYGcgqJY5YbnK7hvAcLDx8lhlzmIkt2eXkCMO1KtLYFfKNKHvhzAI0DZ7dWLMXsCrEp/yJ1HI
 uXsHze8tuAOFpAt0hFVJE3/kyIktngnuJ0B5dOLYNURWp+i5nuwIrNWLT6g0S4DPvTCFCb72B5L
 Q7GoO/hozXJvS+lFjomd+AsKDwzbPCpc9DxlOD/Wvu7DWMWRMzgSkrelXemfts9L6AHPW4++s8y
 IlHYpuPp8MK/cg9KFDRcv9yz54KZayi3MbIsVBSWi17agPPjoExZg4HaXQ2+lWb1FpTdHW6ZTTR
 NR9SbLatHWqhV1VQ77Wt/PiiCU/9s6+/99IsgGM4QV0DfPW4fWkCVhllAi6xOnNZRaqV6qw1Pco
 D7gepA0v8tUp0Fm+/QyDLyrd5xttCJFvcXp2JffNgm2cS8/VIGoGDjWgx09vVA+eq85avyxtbyH
 ydl5L8QEc9Pf+i4okKj99HeS1qi7GEEzpj1mh9BqeUpmSQjaXsh7/ISIKr/T0ym2DY44ojkQ4cl
 Ez5xbMtADOrIYFwBFX+R7M+H0JS9HnqAveFkgO3WwKYvKU4UsXu4LdRX/5wTut2u5Zg3GTbmIp8
 jJZZuXOolFtrZeA==
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
index 1cdb53e9e807..0e01ae4f2218 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -486,6 +486,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	struct nfsd_drc_bucket	*b;
 	int type = ntli->ntli_cachetype;
 	LIST_HEAD(dispose);
+	unsigned int entries;
 	int rtn = RC_DOIT;
 
 	if (type == RC_NOCACHE) {
@@ -555,7 +556,8 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
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


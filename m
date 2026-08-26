Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3BA29483BFC
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 20:27:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787776031; cv=none; b=WF6z2ya6qGTLlJybMu8TUsGgS8Te1gRiyfMZQGtTO9WFP3K2N8V1UpUJ6mx+Lf9xH5CxNebBMrZ0Ps0zc7DawY8qGzp6r3cskEkVc2SaXx32C4/VHWwszih/i7v+vbqGZuy6ttIsBGvhZ7Q5Rw6CvlRSCzbJ7/guPO85Tb51Vc8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787776031; c=relaxed/simple;
	bh=UCrkwucRTt37vOQ+X53rhjiRRwEA8Ly58dJbUhbjDZg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Dp1vJsJ0P/SuQuZ2Mj3y1OKt3X8kHnDOV+dZSByVmnUJ3I4xmOGvCeU/uasjim6xe7WGpkTjNObcHQzmDSjOw9QqxQRyUheSfBFhjsds6M8pUKbY/6rMvVWYnkx1V4XwHWBWRW/I7fwJHBWCcd8NHOy2Q27oM5BgzDxRaJ7FLD4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Sq03GgOK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sq03GgOK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED7391F00A3F;
	Wed, 26 Aug 2026 20:27:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787776028;
	bh=gok/pIU7vIVYoaJLq0wu1LIiPcziNcqxWMMHmw0+gnE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Sq03GgOKI3m5jrfJDkHYZk4y/avOuhLU5+XxOXlJZ0hpha5+Q5ARYemx3/8g4w4EG
	 Y7fC4nQz+UTToImsJXaWblDS57HTAtt9gAB8IWQKW1TaoLaqHPN505wuv78v5eKVG4
	 1PyfL7fBN1pGtNGetdSw53/CEdzucAFDNuhf5f+GulG9Qo7qSDixzdkc9lhaN7XaFU
	 6Px3mu9b1gtW4hY95ZhXFEo7kVwPvGZdbZIGkFxsWealIWMk6QLRQJIKguabsmTFvI
	 iKH55T+vlCpymA9qvIt+pTG+PdH+Z38wXYLHfztuwGFFWOlmbt/WrShJCaypqRt5nl
	 bTkaaaXYPM+PQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 26 Aug 2026 16:26:57 -0400
Subject: [PATCH 7/7] NFSD: Record DRC population in lookup tracepoints
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260826-duplicate-reply-cache-v1-7-b1d51e1af5c7@kernel.org>
References: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
In-Reply-To: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2121; i=cel@kernel.org;
 h=from:subject:message-id; bh=UCrkwucRTt37vOQ+X53rhjiRRwEA8Ly58dJbUhbjDZg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqj0wWxzMjk793FJDZI1FG7hy813M6Kc5sX98jR
 sFo+69T41OJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCao9MFgAKCRAzarMzb2Z/
 l3tbD/wIvLx1Z7qHudQRKyq+p41mFLeRJv6hzJgSaaGUmKWzgGK5MlMZ3OuZ2mPzyoVNVByRPjk
 ZGZ3vhqC+zpSmHfB8Rv2vxFa/XH+j0WMRForqwU+V0wJNZhpCCfEWznWykNSz7nPi9Lhc5NqwDg
 XiiEmcZ36yH6KEaDaW4Gs89fquQu9nQxBxZAoK5Y5iPNMP5V89mMJKJsg6Bn9D5R4CO9AM2f5p6
 setMGeE42hZZYU4t0OrSctzmVjkRzVJPrGTgisOTxkLzwMQUpH9VFQD3jt28p45b9ltKtNptvMK
 pkPBCrv1VKtgZ7dgiBWVv7FWjXRgIrhDHBHGJcp1h+XD2CqP3cVFsPmhTJOklHE9qLBZuf6TxOS
 deYY5cRrj72rRD/Bh/2k27mSitfchAlyjc3Iort+TM3IYR0tpwzXLonF8RqU4lr4Mvc4qQGJxUU
 vaCj2HjOLOjiMmji5wPXkMmEeoRAm5zSb6Vla14Y9kW0DM0fNaK3QW97izzGbd5kGpel/wH6Gmz
 rMVGyOVj65MOBvjObSJlWZWiKtJnr8FJe7gCN2N4P/UKHjBsyuXaxqoc+efTRBh5rAkwHxIZLMK
 XvOu6pILhgC++3K5CrKwYoVP9pfBiuukUnOJLuNnLJq7KhXv2IxUE7ozF3Ne6SWVP4MVKVXfoZN
 IZD169nN1wyVkKw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_drc_found reports the outcome of a lookup but not how full the
cache was at the time, so a trace cannot show whether a miss happened
under pressure.

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
index f1d399b3e51c..75b1d828f2e0 100644
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


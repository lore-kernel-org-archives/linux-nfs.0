Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5D6B492531
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 13:55:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789048503; cv=none; b=Nr4F3TnKClezZRFOI/cG9NccXwu5lXmVuxOhtTv7FaYbTJ9hdbE0MUlDqbvs7jQCeIbdF8wtb5uaixyAC/gjzFx0pS3XmacfjSeJ+1XXhUKA+oPZS+4n8rWtsKegEqaphWvHN6TryxZsDOH0sjHJAwz3mS3D8djPQa4u8i3d+Bw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789048503; c=relaxed/simple;
	bh=A6lc19zdB/VdtIIguYVppHFyJPP2shaNtVaJ2nzD8gg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=vGWZscm5JtuCnAJXYeOKMPjc6RQPuhcKXIRaFNHa3Mk5BSQfW1x+SQ1g4Cjn1XL7G/f3/PUiZ5Kk4Vlioe/jJy5cdKIbUlztXfjQdFuQICY/YVUjUOtO2Xo5ElNbtZb+uqwrDwKPpy7fHfd9p4PVd1Ya08W51acAJY+OAGgGr8g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=j8GpHmX9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="j8GpHmX9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0541D1F00893;
	Thu, 10 Sep 2026 13:55:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789048501;
	bh=4xPGmUdXtrWxkgoNBGXFb1W1fHC/HycXxSUc3NTNvjw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=j8GpHmX9qpofLoVyCQlRR1fO4mNhHe7ERTOdwLACjUyWrFamBPcX9Zkoo7ngCxxn9
	 tHZvniZgU3CqtND38BcS/7TEV8ol68P9k9oGCG8r0x7mh9cbzFZ5C9IzuC6j/v0X9y
	 UaY+hNSxcBxjoKceBTzHN51rqr98SbmV3zCuxH6+ury6mHjxY3An7oMHpoNJZifCyE
	 H1fAB3TokA3ksr1v5QsqTkl5yADOlHC991b9ATO9b0py0EKBU5RMzFk+1MUbyUfiV0
	 kQhj6fDjn+hZMj7ladHdkWyWgsVmyleU9avdI5KpOM3cTWzhtm6DTrfxk5JWssNL4+
	 AdX6K1ab461hw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 10 Sep 2026 09:54:45 -0400
Subject: [PATCH v3 05/12] NFSD: Record DRC population in lookup tracepoints
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260910-duplicate-reply-cache-v3-5-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1910; i=cel@kernel.org;
 h=from:subject:message-id; bh=A6lc19zdB/VdtIIguYVppHFyJPP2shaNtVaJ2nzD8gg=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqorawO1BRgangflAiFJRs1E0BHH/Eu0D8bS/gg
 PR5ygp9JHmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaqK2sAAKCRAzarMzb2Z/
 lyy2D/0YNO61Igs4219fTrBbY8QfXBvCz8ogEGBQQbF8AZcVOA7OUQxoxb6dlwisEDtrDxkTGR1
 ccQzY+aeOYmVd72Ri7Ye7Tn+63LM3/NYxglSY/4MKU4rt6iHmBzf4ATg8xelig0Ec31cwE1QcPg
 vGT7TWtmLuRxcDdzxCuypDE0UMMJqsg60XRA+AudIJ6Em37/zP13/GPW1ohr+FaghyTyxwMt9ed
 JKBvr7nOcDEDErw5u12aqwlZbj3zjarz8aOpG+V9Vn8kHwyPjGYOI6kPQOijkdkhZoe0MAdmBdl
 TwmX4G9wfV2Lo+UvDF7z1KcFYPq8setKJJrx/jlMEEXXigaXTTZkHALbJV6BSnEYq0QPguHAQHg
 bvUDwTpAMpQYb9aVpVX9lROZY0i5hORc+F7a2C616jZs+QY2PjrindObfm/Ey8xAoNGGmSh9uEB
 K3xPF26GCPWP3ZHM43wFhX9lKA2K34UmQrek/ffCu1erz8X4VISfNDNy+fdAap9HIi2+7BOxzGE
 NYP+FvzU2GwqshT+JkEBjgCfZiWkHDgQFO4zBfxWQDWjfbRAlp0JH9I9IsmICeAm0QnhHC8NQOW
 9+QyACxn8gvCJxsob3TAqZJJWbDFExcZyQhE3InVyctbsCYde5yUaaeMLfav8urwWAChyISnHte
 08aaGexGOPh55oA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_drc_found reports the outcome of a lookup but not how full the
cache was at the time, so a trace cannot show whether retransmits are
being caught while the cache runs near its cap.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  3 ++-
 fs/nfsd/trace.h    | 11 +++++++----
 2 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index ec8c40781cb2..10fdc60f9bb9 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -562,7 +562,8 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
 	}
 
 out_trace:
-	trace_nfsd_drc_found(nn, rqstp, rtn);
+	trace_nfsd_drc_found(nn, atomic_read(&nn->num_drc_entries),
+			     rqstp, rtn);
 out_unlock:
 	spin_unlock(&b->cache_lock);
 out:
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 255877e65d7c..a07d3dc76f27 100644
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


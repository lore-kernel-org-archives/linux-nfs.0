Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801484;
	b=I7egYCuJJvZpXcoUnc8wKc+/VcLXzqUsKF4o7oAlDKOct2WB3RnbgqaYZWtrmkh6IpOs
	 7L/CUGF5ay3pURPjhiCSPU/NCkl/O4TbEf2t5QqvsGQCvIWjHfC+NQZSb+vpzvqRru6qP
	 7GWiVvv18k99einxHh0EBTQTBGOi9V+91+xuRDRizEsh8QVX00obMZHiFIVTxvdor+Mhn
	 uRX8Blegbfu+1Ur6VHQbxkuMq3Qk9+qDcZ5pXvRtn37rWE/Z2ZuZCuwOs8bpiJw2VUo37
	 WX5mnL6qp9aVFaVcY17B2PpJaNEQ2+vT7TIn1b9g+7ExbI2mEb9XKvZ7aWoCgOrAEDg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801484;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=+xr3eqd0vBxTGlYm4ANkWJ5lOp4YIAHB70CYaazfXHU=;
	b=VkHV4fT+Z5iwzZ/H8Hri3r6s+Qk08TCJUSHnaG4H0ip9s8X1Fg95sEdiR4M5/pO0HUe+
	 gLDyePGhzz3ur/HfZB43jvr2z7E57GRGOcdxNup4UDVu9kVIyDOb+2L8KqygUOKNsYqTH
	 SQPT5WEgz2WljvxLyT5cbrKB32pbj4GnuXBdczTrDVK+uc8F/7EgMIwE5EGwV+kAKi3IU
	 afsGGiWYlQY3ki7L2BBn9aeRyEtz+T0t+iK0nelqk9hMXAyW17grB1/UXcU61e8ooksxK
	 /gtOB+MOraT9lxhMryFEjnCNiBk188701KjKGfs1TzbRxEnseYwPkdD3Eic82atHg3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hA6xSI+l;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 84A6C606D808;
	Wed,  4 Nov 2026 14:11:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hA6xSI+l
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 513761F00A15;
	Wed,  4 Nov 2026 14:11:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801484;
	bh=+xr3eqd0vBxTGlYm4ANkWJ5lOp4YIAHB70CYaazfXHU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hA6xSI+lgBhbNrAx8FdsdrgS0suJju/Fr/3XTphZSzrgrRKd7GYIvzQxk68f1puLb
	 p4Uu+TAR/XXGBl/K60wdN8F6JFTWPV9QYBaD2ojmS4zs0v50vWuUBdEgELtkNoC0Mg
	 gX/nKSYjuis22xacHzU43dITBX5iqGhsq4unctPW53NYXQmoLp+DMbugrVPxnaKJT0
	 30sbGykl6InH48Jmr2uFK4oWmeaIRjqY0q/6CHjAZEOsceMTJqwyOUdt1x+6B0ETkF
	 EBq6Hyy9Wsmek4bezul/hGACRjlpg17cQpVmY0F6mjbUok8qkwHBfBkOEqmxPOje6c
	 1NGUB9jOQRnow==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:08 -0500
Subject: [PATCH v8 08/14] NFSD: Record DRC population in lookup tracepoints
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
Message-Id: <20261104-duplicate-reply-cache-v8-8-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2313; i=cel@kernel.org;
 h=from:subject:message-id; bh=yAP10rIxx5WEEKb/w623MFYCkYiGfXSSifnGIFqU1h4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0A34PJPrLS0tDOUT76UoAmivAsBJVXI5F0n
 v1jrHuiM/6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 l9WWEACcOJmptQu53n5HEOvnJRypyLfAi3zO3utg4fc/K+W3NVGRGSgBEbYjoyHW7aNMORfjAOZ
 xv30oBRyMka421t6hXa0On5ryg0n5RprAxSuWZchKkjOIxliAhe+Wa2//G64bqeatxL0UHwYBNl
 0IB7tnnlzqwYDGh+njrPDFj3yW3GZt12ey2JODJbTHVdDixBdmqZlxSSyfMBlmvaFg8hJet4eSl
 Ur//Yvh8mCwGLARFfRPldJBOKDD+1SWJXHexGXcKMtIeXIA72CE8vVOQAqxu3I6+1vfdndCrmJ5
 PIa9NEZEXKU8oulP7j3J46mA2m7106aI5Qg71avFQi5vgVTj67MVGqRiCE/kKXB4ljO48XVCvZq
 DkuOfyY6AGVlppbbZtGYGlbUw7NJAunF/q06NwwphB+Xq+N8/JGrHysqxAVroQBzFWCayvFLShF
 FRlHfpf5FFpd4M4+VfwtonryQ+9Z4dzou2O+nF+frOnLep011kCRxwFeX6/BnmhFm0nZ6/q+/sk
 mL2RgbwDcHfxXrauQLyOU89KBWQbahtjALZI1WffiB+un3vcezHw3Oc8T3hy9rW+k+SOrrqdhLU
 /GVFDcmR4cqPyqLSeN/ZhG6rGSpZombBWHlqNMQMyHlY4ZHVvPhJ19KZTjUf83+glWxPs3hgrW5
 yVQhzFoqmtK+0TQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_drc_found reports the outcome of a lookup but not how full the
cache was at the time, so a trace cannot show whether retransmits are
being caught while the cache runs near its cap.

Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-7-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c |  4 +++-
 fs/nfsd/trace.h    | 11 +++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 680025334f1f..453ff718ff6c 100644
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
index 4a3623b3899a..41a9407e3efa 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1665,23 +1665,26 @@ TRACE_DEFINE_ENUM(RC_DOIT);
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
2.56.0


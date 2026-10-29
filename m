Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297188;
	b=OWtc5awrfJBBnl6udrpmSY8bIeHtsIJJ8YiH71lhNdOZnWDsdcQE5Mo/5V8i6pBdsiti
	 KVxqESkHGAX4WEBF0JPdZLljzBvMb/BlG4wams4mHC88vMDKjL4E0BKXgJC++iaByI6XZ
	 Wy8Nwwl5H75Crs2Q/GgZsXTBCiXKf6jDjLuNLNBPBmLUrKlL+Fp0Hy8gRGIXtRjyD8qNe
	 kFpDqhjei9gnpDGsDuOrpcRCezfaparF3ZAQ83uka91PVmMA1n2OdKOjWAVNasaGtMhFG
	 KJvV73GqgD2KjOKLDhioe/T1KuzOeZQgDNfw5KPtDY1dfqulEo+f7FQEWi6++REqQWA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297188;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=7jAz2DhB0OXR2EDL7qyJEtGH68720M0J2BSUo7hi2aw=;
	b=MYQhkfJf6a86dzBvhuzK0UqjUrNZlAwWdL6HXYkF7YG67D+GzrbHFomhxA3PU568gyjB
	 cJHwbCZWkJ9im1HMHDxo3hX1R/DY8rwcByfXJ+xK4fb5AfPqQtNNYpgD83S5+t6uEm+4r
	 UBICu3eOonyqKqfSvKtgqZ594DRHQkhiEJDHf6ygr72hA6zz3KZ8L3hZyZDp1bkPW3tZ+
	 UBJz5C3SGJjQQQTiWj3P5mday29HpPF4bGWhYZ/v/La8bE37M7B+dR9DqRNMBuxo5brRl
	 fYZOjVy5hBYFOPM2RmRHzbwgv8aONzzZwcc+S3fNcfWj2akx/lsHYIrUKzGBL7iz6lw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LGn8NVC6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6089F606A31E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:06:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LGn8NVC6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BFBF1F031E7;
	Thu, 29 Oct 2026 18:06:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793297188;
	bh=7jAz2DhB0OXR2EDL7qyJEtGH68720M0J2BSUo7hi2aw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=LGn8NVC6oK0pSEAcnnjompG63WXmXG8X+VmnqE2RCi1OL+QnY5z3V5xtpkeqZ7gjW
	 r+L5f0nLG9qWfTUxJsuxKnkffOTkN0YFRgm8WLgWTyHEpUdh1bq+nW0F4NVgeugWAG
	 3ZZNC62fAqjXjiGlbsdtLs6uHfqllFhCKAe7iQCYBXCBzzMI9B3cZt0+gArUubr7Jy
	 veXWi0YBMYF3kdiCMf29GcE/2jroTxtRpDPiT0j2NGv+5t6Tr+Scvel8KYUH81LGG0
	 /wgh/9qOrSWyfOExMbNN9MjuzmAr74Vqh5uGc11BCBuhHZXSd/jJPei7FLILSiMITm
	 gPjJY7JM7DIpg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 14:06:13 -0400
Subject: [PATCH v7 07/13] NFSD: Record DRC population in lookup tracepoints
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
Message-Id: <20261029-duplicate-reply-cache-v7-7-f3b0f3cf5bc7@kernel.org>
References: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
In-Reply-To: <20261029-duplicate-reply-cache-v7-0-f3b0f3cf5bc7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2331; i=cel@kernel.org;
 h=from:subject:message-id; bh=KrBfux6cxgxTCyDwKtQTFtgUXnQmzgG1eth83PMzpRU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq44scY1DnABAbHx0XNfIbih2KSRyx4HKeO7Q6B
 MRZzaRQjT+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauOLHAAKCRAzarMzb2Z/
 l8hTD/9h+1QWeWZevsdeVgwwjGFnQg3HbzrWxZiisrF0Vv2qpCEIPcDq8iOPMAPEw0Pi0TZJxJg
 bdIgeVYZZ1SKzf5r9dsaFEkmE/ITgyKNJUFMJI0i7qOEzDbplvQsmZrDcpvLPfZV/KfDm83ZRei
 7k2+i3u285Pb/Lif7Ex7h1YtF00DRReeH9hFogHZ8ga2uwBGlaHZcnj1PDFq2yFnpAc5dQexU4B
 T+6IgtPJZTNEw7QqCXSspIKHfjUGZ0adAzYhm40t3IndHKMZAtEN4JsQHk43ZKFZF8/UugIUXbE
 XjJWfUZ1Ld99v3P52Nt7vGZMaYLiot521XJVJWD1pkeGpXut5X+E3EC6sCZ+AEjaDtoZIHcWOZj
 7WDJnPvSTNhKV84jea2OqN9uc8psZ3E9m/sJ+IJaJcqkSXDg49pd0UTuU6YSwWPxaAuFxe/YKhc
 Wxd3bfRCV5kIOmc7DqRp8UD9yE14ZTZI3F0ItSRMEhWYAHpUQKjVMZvFdY/HoPGAaDQwA3Lmfft
 7w2GBEiLugaonI4a9NeF9b5EJcRXyy8ZmvjNj64gTujJizn9GazDSLP2Fc9O7kOIA9HTd38Dgdu
 IggQphFvd1+/bNVPyJDz7sTRNb5wdSHEuzC75UD8fXuL1yUgmWUEcJB+V+WVHxSU/JtIuMy9VPY
 uzF3d7Z3lnQ2auQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_drc_found reports the outcome of a lookup but not how full the
cache was at the time, so a trace cannot show whether retransmits are
being caught while the cache runs near its cap.

Assisted-by: LLM
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
index e19e7075d879..b1ee0f468206 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -1664,23 +1664,26 @@ TRACE_DEFINE_ENUM(RC_DOIT);
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


Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.197
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793745111;
	b=QzSNbih28QDeRSIIPqNpx1xb4nCPngkWUaWB63bhGwggm0rLeWpX903FbZTFOjo553Hw
	 ZRrqFKN0xjNMMsc7nUzd5O4vmzeC1l5E3ZTLfmSMh4n1PkzX3zizfbgzzC8jTcwgmwg/h
	 HL46je3TyHh3lbIfbL42FXIQb+4cJ7Dve2Eua6ad/F2FXVUDrnPdunk/xe9LOrY0CarVN
	 JD+X13SAv4c7m7r+/4tu/5IrfrLDiQ4ZKocGrz4hYcAWDl6JEWDE/eO7K1bLo0zrh1iOC
	 j6Cb4KzPD0s4A8pF589d7fsl7EgVj2HWvpuPbDvNT2aToLsZGSuIu9ZJbsTjLZkB5fg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793745111;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=BrTX3wJjILuApgcUkXldz9A0fDSI5dqDukx6+R/xaJI=;
	b=4BNfml28zrQ8zGgX209lzr1h+zcX0wIYZa1VfEpIItrJlMpe/E4MvOwWTcD3YYgXP4uE
	 edclC8GgLmHy14JdoCHeJUzEE3BHTSr3jz0ZhUdwh3Iy9XZcj3FgVyNjx1QMwrMez41cR
	 B5L+4IOZSaViMaHziKXL4IUdaZXYZnoFHOgJ7AGa9CWLDcnJ+UvCqKyTZOGixtDxYFP35
	 PQ+FiSF+8SmemKBx2fQorRUEDvQ2903i5OZn+FWdggpOREIV4c1n8TJBQsWaNI6wfu4js
	 oPyPNoH+LPjZlXB1ZjnMrnNgkLUd1wyr3ykrIM6n252zCpK9ZQY9CjB18eBwMMDit3Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--nhuhuan.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=g60ZR+5c;
	arc=none smtp.remote-ip=74.125.82.197
Received: from mail-dy1-f197.google.com (mail-dy1-f197.google.com [74.125.82.197])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16F59606A326
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 22:31:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16F59606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--nhuhuan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=g60ZR+5c
Received: by mail-dy1-f197.google.com with SMTP id 5a478bee46e88-30c0d568830so49521eec.1
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2026 14:31:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1793745110; x=1794349910; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BrTX3wJjILuApgcUkXldz9A0fDSI5dqDukx6+R/xaJI=;
        b=g60ZR+5cGx3Kne5HRSgfcrUxFoC16c0uMvrcSowkwdKoy9+5+Q/Pxyi2+op5jAm8p4
         Yyuqh4SsQLKZ5cHnuMhClKxfLJniePL/BjlkxzWDIoHdoWEmbuWIywaV2pOOr/4SNp3B
         29y9lAgoxKELBeYFg38vm4dSle6GRGgfoQ3Iy5VwOEeJkyr1pU+Nd1vGvrYIHGQM0sxO
         Q6317b86To14Zmz74Bta2GAO17929qdtFilbiLiybY/14xbyP702k1CK/BQkctHAwBlt
         fT/1ASy8B2y0ayIn77VCIuijFr32uLBy4WVdcA0E6nZam9NhHmjx3mM2fy7sl01debTW
         6knw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793745110; x=1794349910;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BrTX3wJjILuApgcUkXldz9A0fDSI5dqDukx6+R/xaJI=;
        b=gBzn1WBzf2oWe6EQY7xfsaT7Pk98OLcW2gtlY21lbYFA69VaQJ6M1qdrR8dKISvTSe
         OLE4RKQhVFGL0Ibnhxej8ps0INb9AAeXQYCab6K37ZT10Ru9i4X28ASIL6yG867oLXfD
         kGNBkLuN6lmSEwdY0X23X44XsJxNlRN8xe4so9VU9mmSs9kioKv3iYrsxAybpWoHIO49
         vjqJ+NjWKkbNXHViQyTSRg3Qd/KqthqLNZRFLpjT40mfC3ccVrU69zIP6lgoIsHum3qR
         BKdgPIdKVfUJhxWVbj0kdSCyGm+YtSghpocdcprEdJvPYCehw3JA/MUcDrVPddodng5l
         Nb7A==
X-Forwarded-Encrypted: i=1; AKwUvBy9In5CLZsPcBV0sW0RZgSNWVXZOpKJEvAcTxdEoEiQOpx3FjtVsXj7HqZcBeX8xGRK3d68tip3ke4=@vger.kernel.org
X-Gm-Message-State: APuU4Z93MRXJFyLwQkD/YpzFNHxsOBfW26DMxa2Qs7K+RKvDywBhetZx
	foLPs2R+NocLasjurXyR0h7eTatknMEGiLDJ9c2UX8Pj1e99VBqvZOwXsRgBxBpxB1z2hPBdzQv
	yz9FnvpzNxw==
X-Received: from dlbsv7.prod.google.com ([2002:a05:7022:3a07:b0:1b2:3bdb:f218])
 (user=nhuhuan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:701b:4244:10b0:149:1b5b:1f25
 with SMTP id a92af1059eb24-1ac5b211405mr22122314c88.15.1793745109795; Tue, 03
 Nov 2026 14:31:49 -0800 (PST)
Date: Tue,  3 Nov 2026 14:30:22 -0800
In-Reply-To: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com>
X-Mailer: git-send-email 2.56.0.398.g882cbad275-goog
Message-ID: <20261103223025.2482227-1-nhuhuan@google.com>
Subject: [RFC PATCH v3 0/3] mm: use non-temporal stores for demotion
From: Huan Nguyen <nhuhuan@google.com>
To: tglx@kernel.org, mingo@redhat.com, bp@alien8.de, 
	dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, 
	akpm@linux-foundation.org, david@kernel.org, ljs@kernel.org, 
	Liam.Howlett@oracle.com, vbabka@kernel.org, rppt@kernel.org, 
	surenb@google.com, mhocko@suse.com, trondmy@kernel.org, anna@kernel.org, 
	ziy@nvidia.com, matthew.brost@intel.com, joshua.hahnjy@gmail.com, 
	rakie.kim@sk.com, byungchul@sk.com, gourry@gourry.net, 
	ying.huang@linux.alibaba.com, apopple@nvidia.com, rostedt@goodmis.org, 
	mhiramat@kernel.org, mathieu.desnoyers@efficios.com, jackmanb@google.com, 
	hannes@cmpxchg.org, shivankg@amd.com
Cc: rientjes@google.com, dave@stgolabs.net, nifan.cxl@gmail.com, 
	fvdl@google.com, jic23@kernel.org, rkodsara@amd.com, bharata@amd.com, 
	sj@kernel.org, weixugc@google.com, xuezhengchu@huawei.com, 
	yiannis@zptcorp.com, yiannis.nikolakop@gmail.com, 
	dimitrios.palyvos@zptcorp.com, alirad.malek@zptcorp.com, ryan.roberts@arm.com, 
	nhuhuan@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
	linux-nfs@vger.kernel.org, linux-trace-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

This series continues the non-temporal demotion work originally posted
by Yiannis Nikolakopoulos [1].

Motivation
==========
Memory tier demotion moves cold folios from local DRAM to slower memory
tiers, such as CXL or remote NUMA nodes. Standard store instructions
force the CPU to allocate cache lines for cold data that is unlikely to
be referenced in the near term.

Using non-temporal stores and prefetching on x86 bypasses CPU cache
allocation, protecting active workload working sets and improving
demotion throughput.

Changes in v3
=============
- Unified MCE-safe NT copy (addressing v2 Open #1):
  Implement copy_mc_page_nt() in x86 assembly to provide machine-check
  safe copying using non-temporal stores (movnti) and prefetchnta.

- Architecture abstraction (addressing v2 Open #2):
  v2 relied on memcpy_flushcache(), which lacks non-temporal stores on
  architectures like arm64. RFC v3 replaces this with a dedicated
  __HAVE_ARCH_COPY_PAGE_NT interface and generic fallback, enabling
  architectures to plug in native non-temporal routines independently.

- Memory ordering:
  Add a wmb() barrier at the end of folio_mc_copy_nt() to ensure weakly
  ordered non-temporal stores are drained before page tables are updated.

Discussions
===========
1. Migration mode vs. migration control refactoring:
   Currently, this series introduces MIGRATE_ASYNC_NONTEMPORAL into
   enum migrate_mode. In parallel, Shivank Garg's migration refactoring
   series [2] consolidates migration arguments into migrate_control.
   Once that lands, demotion can simply rely on the migration reason
   instead of adding a dedicated migration mode and helper.

2. Large folio copy optimization:
   Multi-page folios (such as 2MiB THP) are supported by iterating over
   constituent 4KiB pages via copy_mc_page_nt(). Once the batch page
   copy series [3] lands, copy_mc_page_nt() can be extended to copy an
   entire multi-page folio in a single invocation, eliminating per-4KiB
   loop overhead and keeping the prefetchnta stream uninterrupted.

Thanks to Yiannis Nikolakopoulos, Alirad Malek, and Dimitrios
Palyvos-Giannas for their original work, feedback, and collaboration.

References
==========
[1] https://lore.kernel.org/linux-mm/20260730-rfc-nt-demote-v2-0-452dbe3b5073@zptcorp.com/
[2] https://lore.kernel.org/linux-mm/20260902-migrate-refactor-shivank-v1-9-9dcca87669c4@amd.com/
[3] https://lore.kernel.org/linux-mm/20261019-batpagecopy-v2-1-d75e7d0dfaae@amd.com/

Signed-off-by: Huan Nguyen <nhuhuan@google.com>

Huan Nguyen (3):
  mm, x86: support copying a folio using non-temporal stores
  mm/migrate: introduce async non-temporal migration mode
  mm/vmscan: demote folios using non-temporal stores

 arch/x86/include/asm/page_64.h |  2 ++
 arch/x86/lib/copy_page_64.S    | 65 ++++++++++++++++++++++++++++++++++
 fs/nfs/write.c                 |  2 +-
 include/linux/highmem.h        | 21 +++++++++++
 include/linux/migrate.h        |  5 +++
 include/linux/migrate_mode.h   |  1 +
 include/linux/mm.h             |  1 +
 include/trace/events/migrate.h |  1 +
 mm/compaction.c                | 18 +++++-----
 mm/migrate.c                   | 29 +++++++++------
 mm/util.c                      | 29 +++++++++++++++
 mm/vmscan.c                    |  2 +-
 12 files changed, 154 insertions(+), 22 deletions(-)

base-commit: 05441d697f7f9a927264f4058cbbc6a03dfcac9d
-- 
2.56.0.398.g882cbad275-goog


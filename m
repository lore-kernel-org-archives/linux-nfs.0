Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646674;
	b=PN19Uau4TYiKJZaHWKVjDfjg92KKozqIcizIjG9dz2QJ4vd103IcRpwFJFvqsM0n79Dy
	 BOyKXls+x6nwoPQ+OAo1Gi2UzSDE8HFE689/cnxXeE8SvkqHE2HvgnpiP5Jy5WisUyqtp
	 Yvuc00Pyb5vq7IMWQq2FQ5+VV4KcLteZSRIM/DqnnGPxwgQl0BtpIcK/HjbdrSr2KQAN+
	 tmMfSHAOKwdwafETZNV8DLxvOLQ42HZWklDXEMk4kYYTmJ9mrjuga1qrMBl1gebHHzLUL
	 rKPSC0D6FkvSkaScCAJVlc2WnQ3mj7YELh3Voj/rrLba25UvCQ7HUo2LtfO8h2L7BYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646674;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=3q0iQg6twuS65syhRpiyxXa214b4tiOiHc1s8DxhziM=;
	b=s7ya1kVAZqi3lpu58dz2Y+AgisoIuTNTGTViRbzhpeDGu1LLkv8z8XSChOwUKP/6Tr2+
	 F2PWEFfucLg0Cbpr0o3dPBKLlC+f8rWX+rDsqMfZb0NEji5deBEOk/kDVmDdnqbh+glLo
	 AiiXjLA3TcycRo6FDZVrH4SPtiiyJXNJX4DWL9VfphElf/orp/gU5Uxvt6rVuJopRIllE
	 eTkg9NREWwd2FKAUK+O/VXTAHM0S3b8Pl7ENrNxsSeYYkdNq7SFw72DBQ7BurxNPBn5oB
	 OwT5LLd3bXbuENFajN0sbrkZd2s8M/r9aADrabrN+rNeLz41nswpZFzUoAVqhysUb4Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cTOuTmX3;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34BE2606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cTOuTmX3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 93CF71F00A1B;
	Mon,  2 Nov 2026 19:11:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646673;
	bh=3q0iQg6twuS65syhRpiyxXa214b4tiOiHc1s8DxhziM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=cTOuTmX31nidun2Xq2HAgbpgiCq5AdUegF927nb3OfddxO1YF2jq9qmHD470oeI5g
	 x7id/wszhFnPSx9rpRDZZRmsibfTTxAnp+j0Fhm9p7OULFkTLjaxATl6KG7R+Rw979
	 mkbup5IBPUOD1bWc7YA2ED96DH3ezXj7TQYbowHwRMNUdnbFFG01r4bq2jTv8oysXn
	 Kjcg201wMRmNkeRgLwAabWKY9qJsq6Z6UJ5F+T3biMd0uIA+1ss8FLG05kSJnbv00j
	 aDN+PmW/RTkl3/DqJrZPqrlXp2l6WpCwV5JQuAg76As3+88vxDqYxT6Y7E+9o3Il8W
	 bfvlp78D8TI0A==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 03/11] NFSv4/flexfiles: cacheline align the per-stripe layoutstats
Date: Mon,  2 Nov 2026 14:11:01 -0500
Message-ID: <20261102191109.13470-4-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261102191109.13470-1-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

Moving the layoutstats lock into struct nfs4_ff_layout_ds_stripe stopped
stripes serialising on one spinlock, but it left them sharing cachelines
with each other.

The lock and the statistics it guards sat at the tail of a struct whose
sizeof() was 296 and whose alignof() was only 8, so in mirror->dss[]
stripe i began at i * 296.  296 mod 64 = 40, so every stripe started 40
bytes further into a line than the last and no stripe's lock was line
aligned.  Acquiring stripe i's lock therefore invalidated the line
holding stripe i+1's lock and counters.  A RAID0-style layout -- one
mirror, many stripes -- is exactly the case the per-stripe lock was
introduced for, so this false sharing ate into the win.

Align the first member of the guarded set.  That does two things: the
lock now starts on a line boundary, so the guarded set occupies lines of
its own and shares none with the read-mostly members above; and it raises
the struct's alignment to 64, which forces sizeof() up to a multiple of
64 and makes the array stride line aligned.  The stride is what actually
separates stripe i from stripe i+1.

Verified with pahole on flexfilelayout.o built with DWARF5.  The layout
is identical on x86_64, arm64 4K pages and arm64 64K pages -- cachelines
are 64 bytes on both architectures, so page size does not enter into it
-- and was taken with neither CONFIG_DEBUG_SPINLOCK nor
CONFIG_PROVE_LOCKING, both of which fatten spinlock_t and change it:

  /* --- cacheline 3 boundary (192 bytes) --- */
  spinlock_t                 lock __aligned(64);  /*   192     4 */
  /* XXX 4 bytes hole */
  struct nfs4_ff_layoutstat  read_stat;           /*   200    72 */
  struct nfs4_ff_layoutstat  write_stat;          /*   272    72 */
  ktime_t                    start_time;          /*   344     8 */
  /* size: 384, cachelines: 6 */
  } __attribute__((__aligned__(64)));

A read RPC now dirties two lines of its own stripe and a write three, and
neither disturbs a neighbouring stripe.  Later patches give each
direction a line of its own.

Cost is 296 -> 384 bytes per stripe, i.e. 2816 bytes for a 32 stripe
layout, which is negligible beside the rest of the per-file layout state.
384 is also a multiple of 128, so the stride holds for implementations
with a 128 byte coherency granule.

Note that the alignment attribute only orders the stripes relative to the
start of mirror->dss[], not that array's own base.  The base is aligned
too, under either allocator kvmalloc() may pick for it:

  - From the slab.  kmalloc() documents a size based alignment guarantee
    for power-of-two sizes only, but the smallest possible request is now
    384 bytes, and every kmalloc bucket at or above that is a power of
    two whose objects SLUB lays out at multiples of the object size from
    a page aligned slab, so the base is at least 512 byte aligned.  The
    exceptions, kmalloc-96 and kmalloc-192, are both smaller than one
    stripe and cannot be selected.

  - From vmalloc.  A stripe array wide enough to need a high order
    allocation is served by the vmalloc() fallback instead, which returns
    page aligned memory.

Either is comfortably more than the 64 bytes this needs.

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 8fa2d8851166a..f48860450cf28 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -14,6 +14,7 @@
 #define FF_FLAGS_NO_IO_THRU_MDS  2
 #define FF_FLAGS_NO_READ_IO      4
 
+#include <linux/cache.h>
 #include <linux/refcount.h>
 #include "../pnfs.h"
 
@@ -86,8 +87,17 @@ struct nfs4_ff_layout_ds_stripe {
 	const struct cred __rcu		*ro_cred;
 	const struct cred __rcu		*rw_cred;
 	struct nfs_file_localio		nfl;
-	/* Protects read_stat, write_stat and start_time below */
-	spinlock_t			lock;
+	/*
+	 * Protects read_stat, write_stat and start_time below.
+	 *
+	 * Cacheline aligned so that the layoutstats accounting done on
+	 * every I/O to this stripe does not share cachelines with the
+	 * read-mostly members above, nor with the neighbouring stripes
+	 * in mirror->dss[]: aligning the first member of the guarded
+	 * set also rounds sizeof() up to a multiple of the cacheline,
+	 * which is what makes the array stride line-aligned.
+	 */
+	spinlock_t			lock ____cacheline_aligned_in_smp;
 	struct nfs4_ff_layoutstat	read_stat;
 	struct nfs4_ff_layoutstat	write_stat;
 	ktime_t				start_time;
-- 
2.52.0


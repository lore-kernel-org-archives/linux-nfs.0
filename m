Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793646670;
	b=DdMXVxMXnHBUMbgHbdAZNVxrSU1dZobtZu3hfuFz5zmKNbt7/uOsD6CN6bj7YY5VpTYX
	 2CWeHYru0iotgDu33jxpg981j2uYI65B0MGPdd6MYiH7T3exy11AamOp9aRZ3LY9AOlh3
	 SJ5j09OoFVM0+nCg1vDS97rPUSORnWtel2x7JWTyhVJy51aZGtpNvhQvRCj5upRYLc3ag
	 JgfwRYXWq4Z3dFErImttk9vyxni35oASVnZiYuZibA9ET6ibyKCx+op7iI7kXWkZsMRge
	 t3R8SCRdgfBuGPDaCujdTZmF2Y+zDGud0HIHttBXr7wfofpVUfTWX/xP3A6wm5qTkBg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793646670;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=iMpfGYu7vzPaUDhbnJt2ry7XCm/uyqEFFdBBo0m94Ks=;
	b=IrBRgEGXBlLRMoyp3FRs/dKSaNDSx+a3XipNl6gqDzEMIA7bp+8Eqn8lFHp57yv6sdRE
	 7pInqTmkfWaSe99MvHt165KQpo6idAfTumOOk83UD5nN2T53aNZdxvqNeQoyAsnB0a2eD
	 tj1urdaRIdPChSOD2lhXrIIc9Brj1knrZ7IMrXuKsCTsyio0ziJJIfROH4gYJr03w57Tb
	 KN5GI4RY6GNTVgvowoPdlw9Gdh8s1CWAUbjYpB7ehJLcWnpjlcxSgVfmjgX1ITzAd74oo
	 06mn22sR8BiZMUjvfBHlU8Wl31U8CDf7L4yVedipQL2OQKdopnhcs32U4t/bDjWT3jg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="be5c/7hF";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95284606A326
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 19:11:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=be5c/7hF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F2A351F00A16;
	Mon,  2 Nov 2026 19:11:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793646670;
	bh=iMpfGYu7vzPaUDhbnJt2ry7XCm/uyqEFFdBBo0m94Ks=;
	h=From:To:Cc:Subject:Date;
	b=be5c/7hFRBfBXa2VZLFRFfakbLb2LqE6YQ/a5pyQW8gvgvwMj8+/kWx+sNjHFQPCl
	 zIOPoKVwZRdNpRYb5N0FRsQ6dbqd+H5BXM2HuHauQWqeLQDIvpAqF2sf2lMEkevTO4
	 XMUBv8RY/IGoEneTvlsYSQm/jbtC0VZe7Rlj6kUMidDs+SZtF8F8ealET14e/pR7lm
	 kfQeHM+Da/6+b9ciHDNW+TBC/TehWHew9msAVw+qtYQ4gV0oRMR+TbPRO8RXzvnezr
	 pv2DOVhcknj/ub2a4vkcucUY8pMpuxq+u8O+U2zgtQMPaov6/zd23wJhs1NmX9wZpG
	 lWlYcfWelTd0g==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH 00/11] NFSv4/flexfiles: scale layoutstats for striped layouts
Date: Mon,  2 Nov 2026 14:10:58 -0500
Message-ID: <20261102191109.13470-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
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

Hi,

Since striped flexfiles layouts were introduced, each stripe of a mirror
carries its own read_stat and write_stat, but the lock protecting them
stayed in the mirror.  For a RAID0-style layout (one mirror, many
stripes) that lock is effectively per-file: every DS RPC takes it twice,
once at prepare and once at completion, so striping multiplies RPC
parallelism without multiplying lock parallelism.

On a 64-core client reading one file from a 32-stripe layout with a
128KiB stripe unit (~36.7 GB/s, ~275k NFSv3 READ RPCs/s), perf reports
45% of all CPU in native_queued_spin_lock_slowpath, and 73% of the lock
contention events come from the two layoutstats paths.

This series removes that bottleneck and, along the way, fixes what the
server is told in LAYOUTSTATS for a striped mirror.

Patches 1-2 (Jonathan) move the layoutstats lock into the stripe, next
to the statistics it protects, and remove the now-unused mirror lock.

Patches 3-8 keep the per-stripe hot path to the stripe's own cachelines:
  3: cacheline align the per-stripe statistics so neighbouring stripes
     do not false-share
  4: make dss_info->start_time write-once (try_cmpxchg64), removing its
     dependence on any lock
  5: drop the redundant atomic from the busy timer
  6: pair the in-flight count with the layoutstats updates, under the
     same lock, with lockdep assertions
  7: derive ffil_ops_requested rather than storing it
  8: give each direction its own lock and cacheline, so an I/O dirties
     one line (the stripe shrinks from 384 to 320 bytes)

Patches 9-10 fix LAYOUTSTATS reporting for striped mirrors:
  9: drop NFS4_FF_MIRROR_STAT_AVAIL.  The per-mirror bit cost two atomic
     RMWs per RPC on the mirror's shared cacheline, and since the first
     stripe reported cleared it, a report carried only one
     ff_layoutupdate4 per mirror: always the lowest usable dss_id.
 10: rotate reporting across a mirror's stripes.  Callers cap a report
     at four entries; resume each mirror's scan where the previous
     report stopped, so every busy stripe is reported within
     ceil(busy_stripes / 4) report intervals instead of only the first
     four ever being reported.

Patch 11 takes the report decision (pointer chases into the mirror and
layout, ktime_to_ms(), the last_report_time cmpxchg) out of the critical
section, leaving the lock to cover two writes on one cacheline.

The wire encoding is unchanged; the values reported remain cumulative
since the layout was granted.

The series is based on Anna's linux-next (nfs-for-7.4-1).

Thanks,
Mike

Jonathan Flynn (2):
  NFSv4/flexfiles: move layoutstats accounting to a per-stripe lock
  NFSv4/flexfiles: drop the now-unused per-mirror lock

Mike Snitzer (9):
  NFSv4/flexfiles: cacheline align the per-stripe layoutstats
  NFSv4/flexfiles: make dss_info->start_time write-once
  NFSv4/flexfiles: drop the redundant atomic from the busy timer
  NFSv4/flexfiles: pair the in-flight count with the layoutstats updates
  NFSv4/flexfiles: derive ffil_ops_requested rather than storing it
  NFSv4/flexfiles: give each direction its own lock and cacheline
  NFSv4/flexfiles: drop NFS4_FF_MIRROR_STAT_AVAIL
  NFSv4/flexfiles: rotate LAYOUTSTATS reporting across a mirror's stripes
  NFSv4/flexfiles: take the report decision out of the critical section

 fs/nfs/flexfilelayout/flexfilelayout.c | 251 ++++++++++++++++---------
 fs/nfs/flexfilelayout/flexfilelayout.h |  74 ++++++--
 2 files changed, 218 insertions(+), 107 deletions(-)


base-commit: ef30b3efb7e8bae94d790a6503a595e1051323e7
-- 
2.52.0


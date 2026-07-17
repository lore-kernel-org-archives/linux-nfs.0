Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0E04364A8D
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 00:12:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784247156; cv=none; b=QHqSK1UsRvQSCDFQ7p2W8aao06FmJ1Tfo78SAuGHSsVcoVPiaIWtUnb1GerPU0IZhR/k5FwUue5RzpyCSDxhqGIc3p3dJWaIZl0qN+3zzWWT6esMjc9x6jDCZF6asR/4zHa8LtXe73if6ybUAXXdHDzuUcBJ9Iom12g8qkspmc0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784247156; c=relaxed/simple;
	bh=r/FrWBZWkVRxKCAJ/F8DveP5a9KO7IaTljlfKPVcDsM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ni1dAAfLmIQPnoGu74tXCREdnhSUwAQz1CjDcO0AglprvMKubFoa16qWNoIlIyx0/owhbsVElesybl+1bc3ZrVruCUM1yfbGMWh3CDJ9pEYuinNTAzDsxo6eNE86Tyl4WDhE6R5Q+3JwcTbWuxnK/Rt50Qxh7GgKSHtDP8QOTwQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UI1sPqiE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UI1sPqiE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 157B41F000E9;
	Fri, 17 Jul 2026 00:12:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784247154;
	bh=ZCn/VwpX8P4sIKjTBVnWkEhpSW3U60LXdwydxiUfFH4=;
	h=From:To:Cc:Subject:Date;
	b=UI1sPqiETH2X4Ja8PfghzbMwoF68c9B4CpHIwYexsIQCVd2agzi3CN0ktDTxT8YmX
	 y/FlNxUXycbufexiNc9cKzxhHEm9x2F9h7bUUacHMv52FpgIeEbJduxUm5rm8bNMCo
	 nbayu5d44bmWpgv7ovaspl977cqD9b5fMVEQdczfEGegl+iktcJmzIocjKASSKfxHv
	 89zimaV54zOIjsJyUXy8Rs3RoAlsfIXQBwbY3+VtALVbEiOML7cVkQ71qA2g/vf92F
	 0gNVi8bv88nYE2GPQ3sNJZGAW6BgxUUQL6h6ZnaaeKiEx53Dm0TzpSITF8SBYxrjat
	 aHoRnswvCqbtw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/5] Minor NFSD global DRC clean-ups
Date: Thu, 16 Jul 2026 20:12:27 -0400
Message-ID: <20260717001232.438792-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I'm working on a series of global DRC improvements. A few minor
clean-ups are ready for merge now.

Chuck Lever (5):
  NFSD: Fix off-by-one in DRC bucket pruning limit
  NFSD: Eliminate percpu counter contention in DRC memory accounting
  NFSD: Eliminate percpu counter contention in reply cache statistics
  NFSD: Eliminate percpu counter contention in IO byte accounting
  NFSD: Document reply_cache_stats ABI

 .../ABI/testing/procfs-nfsd-reply_cache_stats | 38 +++++++++
 fs/nfsd/nfscache.c                            |  2 +-
 fs/nfsd/stats.h                               | 78 ++++++++++++++++---
 3 files changed, 108 insertions(+), 10 deletions(-)
 create mode 100644 Documentation/ABI/testing/procfs-nfsd-reply_cache_stats

-- 
2.54.0


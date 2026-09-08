Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF56A5803BA;
	Tue,  8 Sep 2026 16:34:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885297; cv=none; b=ks3s+kKbKJzkq7On7lc+sCcxq+4UOSPZtTYGCRgDPQ5tqVRIArngDFZ+YP7UwLDT5DVH8ajEcbTkFFJcW8drbxUfJjtTMMQhyiav1Z56wD2uSdu36V6LQ4dK8kgdXUJfDpyYRT3K3M5jTxcUvMPXJhv2xw41oLhyCkOmtB/zi58=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885297; c=relaxed/simple;
	bh=tGu/gKn3bAhi5s7Tl/toqEb6jcrVVQoi6O83bRyx9S0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QKkazKSmWEqhn70VHDlwBpYejyeOw/SMVzFqa9SURBgayZTkCyvfqHoK5SbVT8FfmtmT33mT+g0isNIHRFzI4IBo9kUbYuxzrF5kmG2cF+j8dTBtbmncQISl50bHGDhZA/ba9DCS7ekTm6IOTt3gHcDN1EJPVseXeJFqEGdTVIA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ok/xEjSU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ok/xEjSU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A2A31F00A3D;
	Tue,  8 Sep 2026 16:34:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885295;
	bh=xsarEBQz83oy13kJ3SZ3R6K9bssRVn1ez842Rktmuhs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Ok/xEjSU+oGKWKcuwLYQrMo+akicF0poGqDBRhu7+W98NmRg0GKsZB/msEUKPb+Ym
	 N++/fOWKY7Da49+rAr+9EfGDaMR5p/pmfiRsPUfh59qma2ckfaIigMeIXhM28ub8MO
	 tt33tn/kbfkU1MAaODn8R8m9r9puAFY9Roy4xTXjN06zar+X8gcvqcyqEw2u4f0vPv
	 wQ8eCLjzMuz6mRB+fFEoDMv9TTiUxFWCRiNcKM1Er6pRivnvJm+rKC2tUsXxpSaoKk
	 qbNQXoww1ScF3wzYdchb8uH63qEfwLbXEG1aCwGRLytkzu/SySHYLTL7hWzlCfwBc5
	 2+6RV9dtanpIw==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	cel@kernel.org,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: [PATCH 0/4] block, nfsd: fixes for sub-sector bvec direct I/O
Date: Tue,  8 Sep 2026 12:34:40 -0400
Message-ID: <20260908163448.30841-6-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260908163448.30841-1-snitzer@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

While qualifying NFSD's NFSD_IO_DIRECT write path with byte-level data
verification, it was found that the ITER_BVEC payloads nfsd submits 
expose silent data corruption in two bio-based block drivers and
two defects in nfsd itself. Example problematic payloads is the first
fragment starts mid-page because the RPC header precedes it in the
receive buffer, and fragment lengths need not be sector multiples.
bio_iov_bvec_set() passes such an array to the queue as-is; nothing
below it validates per-bvec sector alignment.

Patches 1-2 fix silent corruption (write completes successfully, data
lands wrong) and are stable candidates:

- brd re-derives each segment's device position from
  bio->bi_iter.bi_sector, which bio_advance_iter_single() advances by
  whole sectors only, so a sub-sector segment length skews everything
  that follows.

- zram hardwires is_partial_io() to false on 4K-page kernels, sending
  sub-page bvecs down a whole-page path that ignores bv_offset/bv_len
  entirely, and has the same sector-cursor skew.

Both are verified with a synthetic-bio reproducer (stamped pattern,
write, read back, compare) across mid-page and page-aligned
geometries.

Patches 3-4 fix nfsd: the filecache never fetches DIO alignment
attributes on the supplied-file acquire branch, so every WRITE to a
file created via NFSv4 OPEN(CREATE) is refused direct I/O for the
file's cached lifetime; and nfsd's statx-based DIO gate is weaker than
bio_split_io_at()'s split-time checks, so an admitted iterator can
still be rejected by the block layer -- retry the segment buffered
instead of failing a valid WRITE with NFS4ERR_INVAL.

One open question for the iomap/block maintainers: should ITER_BVEC
direct I/O with sub-sector bvec boundaries be validated or bounced
centrally rather than trusted to every driver's iteration?  An audit
of in-tree bio-based drivers found the same bi_sector-derived position
pattern in dm-io, dm-log-writes, dm-writecache (pmem path) and
dm-integrity -- unreachable through nfsd today only because dm queues
advertise dma_alignment >= 511, which nfsd's alignment gate refuses.

Tested with the reproducer matrix on brd, zram and nvme-loop at 4K and
16K page size (aarch64) and 4K (x86_64), plus 30-connection NFS write
rigs comparing source against export byte-for-byte: clean with the
fixes, corrupting or erroring without them.

Mike Snitzer (3):
  brd: iterate the bio by byte position, not bi_sector
  zram: handle sub-page bvec segments without corrupting data
  nfsd: fall back to buffered I/O when a direct write gets -EINVAL

David Flynn (1):
  nfsd: fetch direct I/O alignment for files handed to the filecache

 drivers/block/brd.c           | 29 +++++++++++++++++++++++------
 drivers/block/zram/zram_drv.c | 36 +++++++++++++++++------------------
 fs/nfsd/filecache.c           |  4 ++--
 fs/nfsd/vfs.c                 | 29 +++++++++++++++++++++++++++++
 4 files changed, 77 insertions(+), 31 deletions(-)

--
2.52.0

Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793811709;
	b=s7t8BCJanEqFf9Lw97/83iMBGZJaI+GOQUarDgNJbAeoLxKCVgmmFQMOmoVHKyqZcCb5
	 eX7ER8DnQSjioJHTELkW5A9NHYuU0Zu4Fd96JZ/K8gA0/JmN7ye8kqQcpg5mwVgPwzFLb
	 T3+IKHrP9VQ4tGtc1hMG9SyhFgf6qY5Jz1KAoftTRNkapqbp/KF3I6u82K+vBycbt0gfe
	 pu8tNFcyOFv0mguBgtsWjSa2vZFQbL5NAs5nXzLWBxORLRjRJKY+wcx1hGpJFfEh8Cun6
	 u9vj0BNO3njgmbFCQctYkeYeA9zJngJtkD+z1n20U/v7V+fAl/aAWBlMVTRckIQpG/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793811709;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=jkCHVhZioJ1wdZN6npY2hfrvWb9kbC3wPalZmZ3BoVA=;
	b=Adk+mGQN6ig90XDs8DJpD5/EcU3QUN3IVLXwPlYhSS98hKy8o6U6ymS4k/Dxf+nbmZe5
	 woaYjvnULp1rLRLZJwOldJmLbD/npBjTvTiyXk436GBYyrYSXRbZYjgAHsMNUDS+YvV+i
	 Jfha+Dy9MQUaAgpz6NwBYKLbdpZA8bb/v/ci11YowkJtJsDKG+1LsxCBYkZ6v7Ez8IztV
	 caKETdIMXVEFsxVnQMoMC6vjtXEOgXEnL8y6ebehAwIWSwG+6DJQLVgeOpsQcCqKfmx2W
	 yLziDqgTdcIqJdG8gFX10q8snG3XqzSQmPd1K8//HKHqqalAR2v9CmQF6tGIgUzRoTA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IT2x62J6;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1563606A326;
	Wed,  4 Nov 2026 17:01:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IT2x62J6
Received: by smtp.kernel.org (Postfix) with ESMTPSA id ED6B91F000C1;
	Wed,  4 Nov 2026 17:01:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793811708;
	bh=jkCHVhZioJ1wdZN6npY2hfrvWb9kbC3wPalZmZ3BoVA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=IT2x62J6jn/yfd+OqmhV0T8VN/l364Oj0rtzzElfoSBg5AlI2P5CKcGHPitytOUdB
	 rCMPOzw6jrqFs2RRAsbUrEFz0z7dCmzAo7iAbPX7yMi76pnu0twc0lzcE00PeLaNU1
	 7MeoRZ0ppZpFPXYztbMrcPhjKkDVFz1bx3XsDbcjpguZ59obJbd3Bh5HNxVxh7wXJj
	 ixi0MMwXpoT534c0m/y5CKXBd64MLxm/fo6C8yso6Yih31nWU0nueRk4Gp9PCcknyW
	 IJK4aGSV8dvWYKe0JSt/gc6eY0wF30rE0OZrCl9YV5fP6+DeU7pkN+6UV6uqrUunc9
	 l+HHO6sjCrTxw==
Date: Wed, 4 Nov 2026 12:01:46 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH v10 7/7] NFSD: drop a shared boundary page only once both
 WRITEs have written it
Message-ID: <autk-osSQ8l2LKz1@kernel.org>
References: <20261103211754.35352-1-snitzer@kernel.org>
 <20261103211754.35352-8-snitzer@kernel.org>
 <20261104091543.GA31130@lst.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261104091543.GA31130@lst.de>

On Wed, Nov 04, 2026 at 10:15:43AM +0100, Christoph Hellwig wrote:
> Why does the write include an fsync?  Are these STABLE writes, and
> if yes, why?

Only when the client asks for it.  A WRITE with stable_how FILE_SYNC or
DATA_SYNC must be on stable storage before NFSD replies.  So NFSD runs
one vfs_fsync_range() over the whole WRITE after all of its segments.
An UNSTABLE WRITE has no fsync.  Its shared units are completed while
still dirty, and the writeback that cleans them drops them, whether the
flusher or the client's COMMIT starts it.

The Linux client sends an O_DIRECT write that fits in one WRITE as
FILE_SYNC (FLUSH_COND_STABLE in nfs_pgio_rpcsetup()).  That is the
common case for the workload below.

> Can you explain where this very odd number comes from.  Is that just a
> worst case?  Or for some reason actually relevant?

It is the transfer size of IO500's ior-hard: every rank writes
47008-byte records, interleaved with the other ranks, into one shared
file, with O_DIRECT.  It is meant as a hard case, and it is the
workload that showed the problem on our servers.  The same happens
with any record size that is not a multiple of the page size.  The
cover letter also has 6000-byte records.

> How does this compare to just not using DONTCACHE at all for unaligned
> tails (and maybe heads, if for some reason they I/O you care about
> reordered writes).

Jon measured that on four pNFS flexfiles data servers with ior-hard
from three clients.  In one run, cached heads and tails removed the
reads, 0.000 per record.  But the page cache on the four servers grew
by 622 GiB during a 318 s write phase.  In a later run of the same
workload with this series, it grew by 2.9 GiB, at 0.003 reads per
record.  Keeping the data out of the server's page cache is the point
of direct mode, so cached ends are not a fix for this case.  Using
buffered heads and tails are available (in cel/nfsd-testing): set the
NFSD debugfs knob /sys/kernel/debug/nfsd/direct_misaligned_dontcache
to N.

> And how does it compare to that plus manual
> sync_file_range calls to micro-manage the I/O?

Wasn't measured because sync_file_range() writes the folio back but
leaves it cached.  To get it out of the cache, NFSD would have to drop
it after writeback.  That is only safe once the neighbouring WRITE has
written its part of the folio.  Otherwise the neighbour reads it back
from disk, which is the problem in the first place. NFSD does not know
when that is without tracking the half-written folios of every file
itself.  An earlier version of NFSD kept one tail folio per open file
for the next sequential WRITE.  With interleaved writers the next
WRITE is rarely the neighbour, and it still read 0.81 blocks per
record.  The folio's uptodate state already records whether the
neighbour has written its part, and 5/7 uses that.

> In general I'm not in favour of so many core hacks for
> very nfsd-specific behavior.

Most of the series is not NFSD-specific.  1/7 to 5/7 fix RWF_DONTCACHE
itself, for any application.  The table in the cover letter is plain
pwritev2() on a local XFS file, with no NFSD.  It reads 0.97 blocks per
write at 831 MiB/s before 5/7, and 0.0005 at 2281 MiB/s after it.  2/7
also fixes a bug in v7.3 on its own.

Only 6/7 is for callers that sync once after writing several segments,
which is what NFSD does for a stable WRITE.  The NFS client's LOCALIO
path does the same.  Without 6/7, each stable WRITE wakes the
DONTCACHE writeback kick once per segment, 23,000 to 65,000 times a
run, for folios that its own fsync is about to write.

Thanks,
Mike

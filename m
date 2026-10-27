Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793115427;
	b=d0QdAxS76Bc/HkqgAsypgIWAYKA/5cTqVlgHYPGbz+/bYwhJqTM/3YlJp/d1Q5hvheYS
	 xm4DdJUqN887m2BVbpdOlQ8ux7zfvWT7z2fB/xaDv4RU60SK8XpMtCvZH2Ux+j05hOIhL
	 sz6miiuk068n5tB91BVWJjRSjUa6Ganhbr7nLaWyY98QJD0E90OrlzuAYxOnKcS+zg+mG
	 5eGOuoTn8unSKX56n6VWGRIeIjMA5hnah1dAasAcZK/JgXll3tSP+O97siuhcKKr92/sL
	 3nvB+Me/S40M/PgKdV7NL112v6+duQkWsN7unmtUvs+wC/Hl9ZTBr6V2LdiGRsSDfYA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793115427;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=92Q/t3i/yf5QKlLrQvvhU5XIPi5Hv5PZF11rRsSNhc8=;
	b=niweq5CeCgtlGwxTC3bIF956K+BeSx18xfVM3mfjPFi3+LJJfQi1pXIkEEYkQAGWIPwZ
	 +HzBKzCvza9xMkCNSy75n1rTqWzpK98lysH0GCoEh9FqXyaQOjtxuQT40mZBaj8Ppbhm8
	 kngPVqMOBTpjc72zl409uwmGfpr5oY73kV3O2Q/aQqPxvYFCcuMoAWlvudHOeiEJoJ3fn
	 QpcvPGTfgCt95/WJwB4RLm622lhriRu5vip/MVRJzqkjYbcm+94+UWRRE+elO4eEY3cD1
	 q/Va1S4E/IXNuF/HelnnvPmLVGNlub6u4Fk4Xi6nzTVucsaUHeQSst3DlG9GQ3WtABg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VDdjpUOt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D03F60A381D;
	Tue, 27 Oct 2026 15:37:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VDdjpUOt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CFC81F01417;
	Tue, 27 Oct 2026 15:37:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793115426;
	bh=92Q/t3i/yf5QKlLrQvvhU5XIPi5Hv5PZF11rRsSNhc8=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=VDdjpUOttVw+UDMKsX6SfZvW+4AeEAuz79UHRmb2D0Tr6A98yFSMdw010PGIbmMDD
	 nkdkgftqln5ZqLXxsvSlBhq6wYoUBQ1xNVjiJSHbWGW9CmegVgzPlAU2xQTO0lh5p4
	 TDVhZ9fTowvkecTr8r0vH048cj4V5TMptzCk6FEniXnIvrGpNLWRZUzGUB9y7rD1wx
	 eiIs7IG95UKZoHCmujYswgro+KdWke9w8v0TlJPygb9ReNPGWyY3zsGrQ2txcsuSM7
	 V3Cow8mOrEap48I7nOaVizOz99qCcG8Zh2C6jPekE3wrE5N4E7tep8Crbo3nC6h6ss
	 50YAS3MgjBenQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6F6F0F4006A;
	Tue, 27 Oct 2026 11:37:05 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 27 Oct 2026 11:37:05 -0400
X-ME-Sender: <xms:IcXgamKZ7Cwo0cO4yPJzsbKeJH0q8h6Deza_HEEdHBORkCMRxlXpiA>
    <xme:IcXgao8ucvBAKYvgEmr07A5uNDvo0uhOyGcK--XCtRdADVZnOU5eq57D6doUA83WH
    Hv-C16x4Ss9WrXjVpKdPUkbmMaWB-HwV0H-By_u_SZ4etaBgJYo5Lo2>
X-ME-Proxy-Cause: dmFkZTEiN13F17KZNcYQn0KpaQrc0EhDk+XKiDQJgU+uJboiU/uuWPy7dUNQDQwAIQwjRn
    mgQANYsin+L0bTP5DRE1L5OMNHtiZgR/kusJ027yBtcJwj54sU9asDJb++xhf0RuWXWYYC
    LfV7kqMcFmPvzSzSHxBUQRcAGr5P1lcJfPGnxFFEi2E4gIxbNzNOlw9Z7tnJLkrw/rc4Mk
    ZGaw+jvnzy7MVhiIhGOgImNdEnfMvo3DkSiIB+t8MGzGtbHifzUxdDTPiD/eW4Nva9/oDQ
    7rnnwOllVB4TkxM8pihg4YNHqwojCvYRJvA/LXnS71lSzFP1YFJNqIaZl9VwLZZvEE+sIQ
    EBehBdjSFYPFS3bYQWwacKHiw7x0Ks4anHmueo9r7o+TCLAdcicr1wFli+ed7ZkXzP3EHc
    5uNOsYDv2dfYKbGnaVSFNZtlX+fOWxfOy4fa8SN4BNaoxOqSOghLmb6v3S/mXy6LDXqBke
    IEWQyfR+tznpCJ4VpoN8CIVDKW14axG0ZV0O/ZngpV1HD7RSoCPL/Vf2QijxBMRjhWJBy3
    n7mam6dt/AR+TlWpOiV8VTpJPAITHNiFkwXEsqvLqCBnoh0/D4BdTbM4jhPP/DV2KhpdtG
    qhKSI4YWJqOOx3Hf+xh3Lwd+UGAGMJcW6kwihl1578/7bQq373gqIhU2NZ4w
X-ME-Proxy: <xmx:IcXgalay_xjdWFFFlOK68gTkUC_95JtL6x9SYKSOVoVYjZ0bNcyIFA>
    <xmx:IcXgap4VTtTuo_6kpw4aYBMdoFjKF4lzMft4_tMcuUpXumuNaWL4vw>
    <xmx:IcXgaqkbGRz2a8mSCI7mw79t1y_UxUU2C7sdpEKpyY-JSIulPrnvBQ>
    <xmx:IcXgapHqzVrn6Jd-1MNX1vTDwKYrx62B2ngJuOouo2dRS51kRinhbA>
    <xmx:IcXgajhtl9ZdWCVcDvj8Kygnp6SMTr9sj_r-Y7sLESoMBx_TOO_Fc7Lf>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C4568782738; Tue, 27 Oct 2026 11:37:04 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AzmA6W_5FSQB
Date: Tue, 27 Oct 2026 11:36:44 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, "Mike Snitzer" <snitzer@kernel.org>,
 "Matthew Wilcox (Oracle)" <willy@infradead.org>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Christoph Hellwig" <hch@lst.de>,
 "Jens Axboe" <axboe@kernel.dk>, "Jonathan Corbet" <corbet@lwn.net>
Message-Id: <70ef3172-9631-4e19-9b8e-4722427a5a83@app.fastmail.com>
In-Reply-To: <fc2ea8d6f2cd9ae83d38941f90386aac6638a497.camel@kernel.org>
References: <20261024221152.6965-1-snitzer@kernel.org>
 <fc2ea8d6f2cd9ae83d38941f90386aac6638a497.camel@kernel.org>
Subject: Re: [PATCH v9 0/6] mm, iomap, NFSD: stop uncached writes reading back shared
 pages
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Oct 27, 2026, at 10:31 AM, Jeff Layton wrote:
> On Sat, 2026-10-24 at 18:11 -0400, Mike Snitzer wrote:
>> Hi,
>> 
>> Please consider this v9 for the v7.5 development cycle, so that it can
>> go upstream in the v7.5 merge window.
>> 
>> An uncached (RWF_DONTCACHE) buffered write drops each page it writes
>> once that page is written back.  A page the write covers only partly is
>> shared with the neighbouring write.  Once the first of the two is
>> written back, the second reads the page back from disk before it writes
>> its part.  32 threads wrote interleaved records to one file on
>> XFS (emulated 4Kn NVMe, 4 KiB pages).  Before and after 4/6:
>> 
>>   record  pwritev2() flags          4 KiB device       MiB/s
>>   bytes                             reads per write
>>                                     before   after     before  after
>>   47008   RWF_DONTCACHE             0.97     0.0005    831     2281
>>   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
>>   6000    RWF_DONTCACHE             0.97     0.0001    121      488
>>   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206
>> 
>> What is left after is metadata.  49152-byte records cover only whole
>> pages, and they read 0.0005 per write either way.  The test program and
>> script that produced this table, and how to run them, are in:
>> https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/
>> 
>> 4/6 has the page cache keep such a page for the write that completes
>> it.  5/6 lets a writer that syncs its own write complete those pages
>> itself once the sync is done.  NFSD does that for a stable WRITE.  6/6
>> is the NFSD change that uses it.  2/6 reports the DONTCACHE dirty count
>> in the bdi debugfs stats.  3/6 adds folio_mark_dropbehind(), which 4/6
>> and 5/6 use.
>> 
>> 1/6 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
>> bdi_writeback"), in v7.3.  A cached lookup that clears the dropbehind
>> flag could uncount a folio that was never counted.  It could also leave
>> a folio counted with nothing to uncount it.  The patch applies to v7.3
>> as it is, if the mm side would rather take it alone.
>> 
>> v8 1/7 is not in this series.  As Chuck asked, I post it on its own.  It
>> is a revised version of 80728157d1bd ("NFSD: cut a misaligned
>> direct-mode WRITE at page boundaries") in cel/nfsd-testing.  This series
>> applies on cel/nfsd-testing at 6d13b7f74eec ("NFSD: Map every
>> NFS_ACLv2 reply status into aclstat2"), with or without that revision.
>> Each patch builds with W=1 with no warnings.
>> 
>> 1/6 to 5/6 are mm, with small iomap changes in 4/6 and 5/6.  They are
>> Cc'd to linux-mm and linux-fsdevel.  If the mm and iomap maintainers
>> are agreeable, their acks would let Chuck take the series through the
>> nfsd tree.  But whatever approach the maintainers prefer for this kind
>> of cross-subsystem merge is obviously fine.
>> 
>> Changes since v8, from two independent sashiko reviews of v8: the one
>> Jeff Layton relayed, and the one that sashiko-bot posted to linux-mm.
>> Some findings were in both.
>> - 1/6 and 3/6 (both reviews): a folio is counted in WB_DONTCACHE_DIRTY
>>   only when both PG_dirty and its dirty tag are set.  v8 tested the tag
>>   alone.  __folio_cancel_dirty() clears PG_dirty but leaves the tag, and
>>   so does writeback that stops at EOF after folio_clear_dirty_for_io().
>>   A folio that stays cached then keeps a stale tag.  1/6 uncounted such
>>   a folio twice, and 3/6 counted it and never uncounted it.
>> - 4/6, 5/6 and 6/6 (second review): with blocks smaller than the folio,
>>   iomap tracks uptodate per block.  The edge that a write completes is
>>   then not uptodate when the write finds it, so it was never marked and
>>   stayed cached until reclaim.  This happens with 4 KiB blocks on 16 or
>>   64 KiB pages.  The new folio_dontcache_edge_written() also accepts a
>>   folio whose blocks outside this write are uptodate.
>>   filemap_dontcache_edge_completes() takes the range that the write
>>   covers, and 6/6 passes it.
>> - 5/6 (second review): filemap_dontcache_edge_complete() now waits for
>>   writeback in flight, which could not drop the folio.  It also kicks
>>   DONTCACHE writeback when it marks a dirty folio.  The earlier kick
>>   came before the mark.  It drops a clean folio that is not mapped
>>   without a mark.  A mark that filemap_end_dropbehind() then cleared
>>   outside the i_pages lock could leave WB_DONTCACHE_DIRTY counted.
>> - 6/6 (both reviews): NFSD finds the edges that a buffered segment
>>   shares by the mapping's smallest folio, as iomap does, not by page.
>>   On 16 KiB blocks, a WRITE written as one buffered segment can have
>>   page-aligned ends inside a block.  Nothing completed those edges.
>>   NFSD also completes a segment's first edge only when the write
>>   reached the end of the segment's bytes in that unit (first review).
>> - 4/6 (first review): a paragraph on a limit.  4/6 marks the folio
>>   before iomap validates the iomap.  A stale iomap stopped by a fatal
>>   signal then leaves a mark on a folio that this write did not complete.
>>   This costs one read-back and no data.
>> - 2/6: unchanged.
>> 
>> Patches 1, 3, 4, 5 and 6 carry notes below the --- line.  The notes
>> give each question from the v8 reviews, and the code, lock or check
>> that answers it.  This includes the limits that the series keeps on
>> purpose.
>> 
>> Before posting, I ran a third review of v9 locally, with Sashiko's
>> review stages and the review prompts it uses.  It found no new
>> problems.
>> 
>> Measured for 6/6 on 16 KiB-block XFS over the loop device.  Its
>> dma_alignment is 511, so every TCP payload is memory-misaligned and
>> NFSD writes each WRITE as one buffered segment.  32 writers of 12288-byte
>> records, 1 GiB: v8 left all 32,736 pages of a 128 MiB file resident.
>> v9 leaves 948 of 262,080 pages (0.4%) and reads 0.0003 blocks per
>> record.  The v8 results hold.  In every run BdiDontcacheDirty was 0
>> after the final sync.  That includes runs that mix uncached writes,
>> cached writes and mmap stores on one file.  Every record verified.
>> 
>> I measured all of v9 again on 4 KiB pages, with XFS blocks of 1 KiB
>> and 2 KiB over the loop device.  These blocks are smaller than the page.
>> 32 writers wrote 47008-byte records, 1 GiB.  Uncached application writes
>> left 0 of 261,850 pages resident.  NFSD left 497 (1 KiB blocks) and 349
>> (2 KiB blocks).  LOCALIO left 854 and 949.  Every path read 0.0001
>> blocks per record.  A kernel without these fixes, on a 128 MiB run with
>> 1 KiB blocks, left about one page for every two records.  Uncached
>> writes through NFSD, cached writes and mmap stores ran together on one
>> file, with 4 KiB and 1 KiB blocks.  BdiDontcacheDirty was 0 after every
>> round, and every record verified.  I did not test kernels with 16 KiB
>> or 64 KiB pages.
>> 
>> v8: https://lore.kernel.org/linux-nfs/20261023024548.71123-1-snitzer@kernel.org/
>> v7: https://lore.kernel.org/linux-nfs/20261020220346.28020-1-snitzer@kernel.org/
>> v6: https://lore.kernel.org/linux-nfs/atbfEbgMU6UGkn2X@kernel.org/
>> v5: https://lore.kernel.org/linux-nfs/20261019150725.1507-1-snitzer@kernel.org/
>> v4: https://lore.kernel.org/linux-nfs/20261015233309.42999-1-snitzer@kernel.org/
>> v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kernel.org/
>> v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
>> v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/
>> 
>> Thanks,
>> Mike
>> 
>> Mike Snitzer (6):
>>   mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
>>   mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
>>   mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
>>   mm, iomap: keep a partly covered page until an uncached write completes it
>>   mm, iomap: let an uncached writer complete its shared pages itself
>>   NFSD: drop a shared boundary page only once both WRITEs have written it
>> 
>> 
>>  .../filesystems/nfs/nfsd-io-modes.rst         |  17 ++
>>  fs/iomap/buffered-io.c                        |  36 ++-
>>  fs/iomap/trace.h                              |   3 +-
>>  fs/nfsd/vfs.c                                 | 116 +++++++-
>>  include/linux/fs.h                            |   8 +-
>>  include/linux/iomap.h                         |   1 +
>>  include/linux/pagemap.h                       |  14 +
>>  mm/backing-dev.c                              |   6 +
>>  mm/filemap.c                                  | 265 +++++++++++++++++-
>>  9 files changed, 435 insertions(+), 31 deletions(-)
>> 
>> 
>> base-commit: 6d13b7f74eec16e08d5e7f772ee119432a14ef2c
>
> This all looks good to me at this point. This is a mixed mm and nfsd
> set though. How do you envision this being merged?
>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>

My recommendation was take all of this through the MM tree, since
the NFSD patch looks like the first consumer of the work, and it
depends on how the MM API is changed during review.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

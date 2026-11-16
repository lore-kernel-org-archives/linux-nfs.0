Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.135.223.131
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794826944;
	b=cF8ptl78+6jNVE3qrqm4bubWuBNG1U9iwzKBpnoOgm2StUSrUv12qvWJneZ6YTQiEc13
	 7HiKf3paeEFgWk436TtMLSienkcq410STogrrQwfTcClZCCAeD+JK+NMBB4VIHbNdWSZP
	 YFR5As8V/tJxrKtBswy6eAJ3PJOBKWDrgPiOBsmVvjl/thowK4Aqq5eNZ9m7CgQ5eFDki
	 t4ODlKxTnXjTwHswef34IzOt2RcpdQ6ymY72ZJHK3VFT6WFa0QYH0YFOFb8t/V+QOB6dK
	 12Nqgzrqfyw1opDTUHsBgO5z3znDntTa2uOfzlshL6UGwmFw9rDC4KX8/U5Pm3ruyvw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794826944;
	h=DMARC-Filter:Received:DKIM-Signature:DKIM-Signature:DKIM-Signature:
	 DKIM-Signature:Received:Received:Received:Date:From:To:Cc:Subject:
	 Message-ID:References:MIME-Version:Content-Type:Content-Disposition:
	 In-Reply-To:X-Spamd-Result:X-Spam-Score:X-Spam-Level:X-Spam-Flag;
	bh=zMrJA+gjZFjeo0ud1+bDTEk2lqHpB6cq2ulbdh6191o=;
	b=q0NchACfu5LBl/oo2/oFJ+qMVfFfMS6JjOqlnzfxefZFxJ5MJqEZyclifSSUdzsVqHnU
	 erpVOKVYP853GkiNGBdfVqzFQv5sb890ycYv7en+5Mm6g2/cg4RQAIuhImaJznr4Y4Ug7
	 TmflcC+vl94CjFdMvwYlemz17LIWxLmwzQnz3sML+NTVhGS+387SJt6Tvc+z2y3KjQaMn
	 jOj3/+0UJGpikFnCRYpd90eflpnVgJLMoEvlukIIxOvOZi2oxaxfbjXk+2DNlg+qHYLHW
	 Y9s6/lGz3xpFcs9D2UNM0dwTeps2+mxDWTBBzPauLuv5qcxDSiGetU3C+xcAAsNLFSg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=suse.cz;
	spf=pass smtp.mailfrom=suse.cz;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=m5xT4FxW;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=QITJlvhV;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=m5xT4FxW;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=QITJlvhV;
	arc=none smtp.remote-ip=195.135.223.131
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6921B606A31C;
	Mon, 16 Nov 2026 11:02:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6921B606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=m5xT4FxW;
	dkim=pass header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=QITJlvhV;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.a=rsa-sha256 header.s=susede2_rsa header.b=m5xT4FxW;
	dkim=neutral header.d=suse.cz header.i=@suse.cz header.a=ed25519-sha256 header.s=susede2_ed25519 header.b=QITJlvhV
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 9A98C1FD38;
	Mon, 16 Nov 2026 11:02:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826941; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=zMrJA+gjZFjeo0ud1+bDTEk2lqHpB6cq2ulbdh6191o=;
	b=m5xT4FxWfhs/zyAI8agAe7LoG6kv0PNhgm8FfIeYbvTPRTtint7AWkWG9HgUuSUhcMt3/K
	HxyfZRrNkInhARbOOiK4DykIpqUjBjMAwWxL2XQzor4MjcVbnDgPoORIOouh0h8zwauEQE
	3tlmZTNweSJPM80cbqK2X/wzBiz0kGI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826941;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=zMrJA+gjZFjeo0ud1+bDTEk2lqHpB6cq2ulbdh6191o=;
	b=QITJlvhVhkoDFdAS/Enz/tCFDnDccQ+1FlmiGUQ0L7nZ1+NYfKqgknnqaLI6mDhJ89eQJH
	YS2FmZ31zPzziODA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1794826941; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=zMrJA+gjZFjeo0ud1+bDTEk2lqHpB6cq2ulbdh6191o=;
	b=m5xT4FxWfhs/zyAI8agAe7LoG6kv0PNhgm8FfIeYbvTPRTtint7AWkWG9HgUuSUhcMt3/K
	HxyfZRrNkInhARbOOiK4DykIpqUjBjMAwWxL2XQzor4MjcVbnDgPoORIOouh0h8zwauEQE
	3tlmZTNweSJPM80cbqK2X/wzBiz0kGI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1794826941;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=zMrJA+gjZFjeo0ud1+bDTEk2lqHpB6cq2ulbdh6191o=;
	b=QITJlvhVhkoDFdAS/Enz/tCFDnDccQ+1FlmiGUQ0L7nZ1+NYfKqgknnqaLI6mDhJ89eQJH
	YS2FmZ31zPzziODA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6FEC713408;
	Mon, 16 Nov 2026 11:02:21 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 39+PCb3i+moaCwAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 16 Nov 2026 11:02:21 +0000
Received: by quack.suse.cz (Postfix, from userid 1000)
	id D0FBA24DB2; Mon, 16 Nov 2026 12:02:20 +0100 (CET)
Date: Mon, 16 Nov 2026 12:02:20 +0100
From: Jan Kara <jack@suse.cz>
To: Mike Snitzer <snitzer@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, 
	linux-mm@kvack.org, Christian Brauner <brauner@kernel.org>, 
	linux-fsdevel@vger.kernel.org, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v12 0/7] mm, iomap, NFSD: stop DONTCACHE writes reading
 back shared pages
Message-ID: <iushs6l3mjqkq65srej4gevaf2oeazy5j5miaipy6yxscetzjd@d4ti4qgbhman>
References: <20261112190911.84702-1-snitzer@kernel.org>
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
In-Reply-To: <20261112190911.84702-1-snitzer@kernel.org>
X-Spamd-Result: default: False [-12.80 / 50.00];
	SUSE_INTERNAL_BYPASS(-9.00)[];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FROM_HAS_DN(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	URIBL_BLOCKED(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo];
	RCVD_COUNT_THREE(0.00)[3];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCPT_COUNT_SEVEN(0.00)[9];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	RCVD_TLS_LAST(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo]
X-Spam-Score: -12.80
X-Spam-Level: 
X-Spam-Flag: NO

Hi!

On Thu 12-11-26 14:09:03, Mike Snitzer wrote:
> An RWF_DONTCACHE write is buffered IO: its data goes through the page
> cache, and writeback drops each folio once the folio is written back.
> A write that starts or ends inside a folio covers that folio only
> partially.  Usually another write covers the rest of the folio.  If
> writeback drops the folio before the other write writes its part, the
> other write must first read the folio back from disk.  32 threads
> writing interleaved records to one XFS file, 4 KiB pages, before and
> after 5/7:
> 
>   record  pwritev2() flags          4 KiB device       MiB/s
>   bytes                             reads per write
>                                     before   after     before  after
>   47008   RWF_DONTCACHE             0.97     0.0005    831     2281
>   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.0005    601     1227
>   6000    RWF_DONTCACHE             0.97     0.0001    121      488
>   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.0002     90      206
> 
> 47008 bytes is the transfer size of IO500's ior-hard, in which each
> rank writes interleaved records to one shared file.  Any record size
> that is not a multiple of the page size has the same problem.  6000
> bytes is a second example.

OK, I understand the problem but frankly I hate the complexity this
introduces. Patches 1-3 are good improvements, patch 4 is OK but 5 & 6 look
too complex for too niche usecase to me. I didn't really pay attention to
previous revisions of this patch set so I'm sorry if this was discussed but
can't we just make iomap for unaligned RWF_DONTCACHE write ask for
minimum-sized folios for the partial edges without FGP_DONTCACHE and
use FGP_DONTCACHE only for folios fully within write? That will also solve
the problem with the following write having to read again from the disk and
it will be much simpler. Sure the edge folios will not be dropped after IO
completion which may have smaller or larger effect (depending on the
overall write size) but I'd say that's the cost of userspace making life
hard for the kernel :-p

								Honza

> 
> The test program and script: https://lore.kernel.org/linux-nfs/atqJBS8MlYfeUU-t@kernel.org/
> 
> - 1/7 moves code into a helper, with no functional change.
> - 2/7 fixes 88d6f128d06d ("mm: track DONTCACHE dirty pages per
>   bdi_writeback"), in v7.3: WB_DONTCACHE_DIRTY could drift.
> - 3/7 reports WB_DONTCACHE_DIRTY in the bdi debugfs stats.
> - 4/7 adds folio_mark_dropbehind() for a folio that is already dirty.
> - 5/7 keeps a partially covered folio until the write that completes it.
> - 6/7 lets a writer that syncs its own write complete those folios
>   itself, after the sync.
> - 7/7 makes NFSD do that for the misaligned ends of a direct-mode WRITE.
> 
> Merging: Chuck suggested taking the series through the mm tree.  1/7 to
> 6/7 apply cleanly to each of these mm branches:
> 
>   mm-unstable  4318887a3efa ("fs/proc/task_mmu: fix lost maps entries above 2^63")
>   mm-new       daed51c91051 ("riscv: mm: fix concurrency in mark_new_valid_map()")
>   mm-stable    fa4ad798f6f6 ("Merge tag 'for-7.4-rc1-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/kdave/linux")
> 
> 7/7 needs the NFSD direct-mode changes that are in cel/nfsd-testing.
> The whole series applies to cel/nfsd-testing at ab036e3a0dd4 ("NFSD:
> Refuse a direct READ whose aligned range exceeds the reply pages"),
> where each patch builds with W=1 with no warnings.  So 7/7 could follow
> in the nfsd tree once the mm part is merged.
> 
> Changes since v11:
> - 4/7: folio_mark_dropbehind() leaves a mapped folio unmarked.  Through
>   its page table, a mapped folio can be dirtied without the folio lock,
>   and PG_dirty set before the folio is counted.  With a stale dirty tag,
>   folio_mark_dropbehind() then counted the folio in WB_DONTCACHE_DIRTY,
>   and the dirtier counted it again.  sashiko found this in its review of
>   v11 4/7 (https://lore.kernel.org/r/sashiko-outbox-210121@kernel.org).
>   The folio lock keeps an unmapped folio unmapped, so the window is
>   closed for every dirtier that does not use buffer heads.
>   filemap_end_dropbehind() does not drop a mapped folio either.
> - 6/7: filemap_dontcache_edge_complete() leaves a mapped folio alone,
>   dirty or clean, to match.
> - Jeff's Reviewed-by is dropped from 4/7, which now has a code change.
> - Testing: a KUnit test (not in this series) runs the interleaving from
>   sashiko's review step by step.  On an unmapped folio, the folio is
>   counted twice.  On a mapped folio, v12 leaves it unmarked and the
>   count is correct.  The v11 tests through NFSD and with RWF_DONTCACHE
>   give the same results with v12.
> - Rebased on the current cel/nfsd-testing.
> 
> v11: https://lore.kernel.org/linux-nfs/20261111015607.46338-1-snitzer@kernel.org/
> v10: https://lore.kernel.org/linux-nfs/20261103211754.35352-1-snitzer@kernel.org/
> v9: https://lore.kernel.org/linux-nfs/20261024221152.6965-1-snitzer@kernel.org/
> v8: https://lore.kernel.org/linux-nfs/20261023024548.71123-1-snitzer@kernel.org/
> v7: https://lore.kernel.org/linux-nfs/20261020220346.28020-1-snitzer@kernel.org/
> v6: https://lore.kernel.org/linux-nfs/atbfEbgMU6UGkn2X@kernel.org/
> v5: https://lore.kernel.org/linux-nfs/20261019150725.1507-1-snitzer@kernel.org/
> v4: https://lore.kernel.org/linux-nfs/20261015233309.42999-1-snitzer@kernel.org/
> v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kernel.org/
> v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kernel.org/
> v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kernel.org/
> 
> Thanks,
> Mike
> 
> Mike Snitzer (7):
>   mm: move clearing the dropbehind flag of a found folio into a helper
>   mm: take a folio off WB_DONTCACHE_DIRTY only if it was counted there
>   mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
>   mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
>   mm, iomap: keep a partially covered page until a DONTCACHE write completes it
>   mm, iomap: let a DONTCACHE writer complete its shared pages itself
>   NFSD: drop a shared boundary page only once both WRITEs have written it
> 
>  .../filesystems/nfs/nfsd-io-modes.rst         |  18 ++
>  fs/iomap/buffered-io.c                        |  30 ++-
>  fs/iomap/trace.h                              |   3 +-
>  fs/nfsd/vfs.c                                 | 107 ++++++++-
>  include/linux/fs.h                            |   5 +-
>  include/linux/iomap.h                         |   1 +
>  include/linux/pagemap.h                       |  12 +
>  mm/backing-dev.c                              |   6 +
>  mm/filemap.c                                  | 219 ++++++++++++++++--
>  9 files changed, 370 insertions(+), 31 deletions(-)
> 
> 
> base-commit: ab036e3a0dd410f762192f33d6244e7993b36f8d
> -- 
> 2.52.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

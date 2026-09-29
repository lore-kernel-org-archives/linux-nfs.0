Received: from mail-qk2-f41.google.com (mail-qk2-f41.google.com [74.125.230.233])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82F4B54A7FB
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 19:56:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.233
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790711818; cv=none; b=DX7x2Z/fWWtcnqntCC/sJP5VyJpq8wRRV5AysP9Is40OUNswqPmxNBRARg1V/S+bOlQLj9swRnIJtebq05WE+sCVZeElIjoaTmJB8K+w0IKV3Ft7I25WIO83qIQe6jpbhOhRwcGRUduSaT2j6jiaX9oEw/P0g2O9aXAel9we4SI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790711818; c=relaxed/simple;
	bh=Y0/h65BK/3Cr60RUPs5WgSC8Ax0CBmTat7p70+NFbks=;
	h=From:Date:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=aVf8hwLW/rOhtUH0F/KyVs5odG//HjRYtJoW2fIlA2U/vhG6XGPyIj6aEe3b5Pc0PPfnH3nf5qBPgLNWmdn5rY+pM5lv5LliCqIVG0EQyik8KMFpEDBC99ZToq65wICHV/R/iNYrkpLoaudEoRMkwZ9NUwcGLiCz8IQA8UCpXn8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=YNKrbGzO; arc=none smtp.client-ip=74.125.230.233
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YNKrbGzO"
Received: by mail-qk2-f41.google.com with SMTP id af79cd13be357-93c57d36d37so423132685a.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 12:56:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790711815; x=1791316615; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:date:from:sender:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=/w/1o6dWL1VfAv+XnbpVEvJyvsggxxz3k1B5xm75PHA=;
        b=YNKrbGzOF2hpakh6pBc+HMef1t8KTxAb9OnE+7kxeUmYKni9zEhz5AI1tmPlEvGm/P
         a5VOzcxUU6petEpjG0j7gyGkykSj85MR/lt7E5GubXZo34uiHKHxErHUQeiDWKu31ZFa
         +xDC3KIjDT0PFr5LucjN7EUygCI1U8K/r72dpkDXCRuCOW+bYeV0/y8+2YSoeWc3v6+f
         3GvDHpL1cSi2nuS2wfEFQC1wHbKZP6kb5sJFMqw2NAyyF/cBZ9GqsuYrDXfxand54fXp
         4IbGmcXzaEV5Xq0MTWDsv0ObXY568YlDDi9SAaDyu0ecxY8TuJ6OvjbXVfNuVWmOsCd2
         gViw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790711815; x=1791316615;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:date:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=/w/1o6dWL1VfAv+XnbpVEvJyvsggxxz3k1B5xm75PHA=;
        b=a/BBqj0OaVTv0VbEeFtlOGZoa/tjE6WQrWHDvtNKAoImzsZhVs/TeSTS8DCMa2D6wS
         JUoHlvj6GQsQ9F2bQ1yVOD3L3wz/7PtLkHMuJEkfuT5VBx6gqp5l6mv8w9+s9nxRfLv0
         dRC2pC2pb1qetOS7VO0iM7pEgt1aAl+vmeEEsnWOy50zga3eo71dn5Aiblhl3MNX15NQ
         BZCfJCYCBirc829iYn/cDRBx0z7FRsSdDDJ5bv0qx7YlsZC2YouTHthJLX9iEcxekHzu
         vO9KzWiJH/lo5i/pSgl8/+Kp/YDR4ALI0l3ZvipbTZQEzfeTJ/blWY2KksgGYuBD2+vV
         MHrg==
X-Forwarded-Encrypted: i=1; AKwUvBzRqj70VOZ5RZiL0OlSh3vU7IMygmpVFew/W1WKc2TM9rlvw5Pp9kyI3EP7jGUFdhT+aXd1lsZoXHk=@vger.kernel.org
X-Gm-Message-State: AFuF++mqyDZVNkplUdSzg1wDOq+qIg60tEzJeSBH11UsCc+y8DX+23LU
	j7EHSPN+RnD4xsS8L7kAhr2Im+6jxPgMK0qoqlnRNVYH/xKA+sg7y32LXuq2vPTctEYbf6Mdiwb
	AlagJ
X-Gm-Gg: AYBFou18265CVgABB95fl2m78xFKQsSmdR2Vh5NjkemflHGewzDJdXsQ3JwaNQFfiAT
	OBEYEC3peFlJZuI1DY3juti1Ntgd6+TrxWoKYNuId9G+PyDI17SvZUVsRkHMsIJYNnmafdGtutV
	Qpr1sivrnsusfDVFupExjJJiyGX4LA9Ggtfrfb/iYidmy3Qw0oMqqBVUayxkXcYJPUsvByRawhL
	MSa0k0AtlnFjx8z2kkGBjOMlH2INV/5kbYOV0T58UllKMrjUqXdfAo3ANG5NtpONtsT3S7zTJ6A
	uKOeu4JNOFLwUpU5yJstfddD4/eC4oXBvdsrFqncXwVzywIbidPmcWBZCAn+LQSufbLMWfYn946
	revDdgMidiYXkTSQiwiA0MlyMaDQ4dkjAD6XSKnFCNehlm8uGoYPXz8v0wYEFKCMb6lC8wmEyFS
	t532xOs2bGqg3FkYJ+uP413pzatfzHKLjHHceJ+SpyiKXJy29kP9YtknzKRNcDSkGFSvZUNtxrc
	7nQnsrBvrxNKyO5lnczxb2dSw2VsTiB7SpibQXWXn9dqFIuZ++YNWsIgiZadRO90jpnd6hn8g==
X-Received: by 2002:a05:620a:4541:b0:93b:d79f:d941 with SMTP id af79cd13be357-93c9fc965b9mr115799685a.54.1790711815041;
        Tue, 29 Sep 2026 12:56:55 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c9f4b912bsm48096685a.20.2026.09.29.12.56.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 12:56:54 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
Date: Tue, 29 Sep 2026 15:56:53 -0400
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS
 READ and WRITE
Message-ID: <arwYBaemyvLoG2sT@hammerspace.com>
References: <20260929173423.16149-1-snitzer@kernel.org>
 <20260929173423.16149-2-snitzer@kernel.org>
 <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>

On Tue, Sep 29, 2026 at 11:27:05AM -0700, Chuck Lever wrote:
> 
> On Tue, Sep 29, 2026, at 10:34 AM, Mike Snitzer wrote:
> > Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
> > much safer to avoid needless buffered vs direct contention if/when
> > only one of them has been configured to use NFSD_IO_DIRECT.
> >
> > Mixing direct and buffered I/O to the same file causes needless page
> > cache invalidation and writeback, so although io_cache_read and
> > io_cache_write remain separate interfaces, writing either one adjusts
> > the other so that READ and WRITE are never left on opposite sides of
> > the buffered/direct divide:
> 
> Jeff and I have been discussing making DIRECT the default for WRITEs and
> BUFFERED the default for READs. This patch takes us in the opposite
> direction.
> 
> Nothing here convinces me that mixing the modes is a bad thing to do.
> "Needless page cache invalidation" needs some demonstration, and it
> needs to show why the right thing to do is make it impossible to mix
> modes rather than explore the issue as one or more bugs that can be
> fixed. Or... why not let admins explore this for themselves? Where is
> the hazard and why does it need to be forbidden by the admin UI?

The basis for the interlock is that O_DIRECT mode is intended to avoid
bloating memory with page cache and the excess CPU burn of managing
the page cache.  Using read caching in conjunction with O_DIRECT
writes knee-caps the wins of O_DIRECT.  But sure, you can do it.. and
I suppose the freedom of choice (and enough rope to hang) is perfectly
fine. I can drop the interlock and send v2 after more time for review
of the other patches (but there were some real bugs fixed in the
interlock patch so will require some care to adjust).

direct_misaligned_dontcache=N shows the excessive 630 GiB page cache
bloat (across 4 servers) I've had to confront with a larger scale test
that really sticks its finger in this particular wound (as documented at
end of the "NFSD: keep boundary page of a split direct-mode WRITE
until both writers complete" patch):

    On a four-server pNFS flexfiles rig, three clients writing 47008-byte
    records for 240 s against 640 nfsd threads per server, compared with
    the same servers before this change: device reads fall from 0.014-0.015
    per record to 0.003, page-cache growth over the write phase falls from
    about 11 GiB to 2.9 GiB, and write throughput rises by 2.4% to 4.9%
    across NFSD_IO_DIRECT and both stable_how floors, with read throughput
    unchanged. Records of that size always take the split path, since their
    direct middle is at least 38818 bytes, so the figures are the split
    path alone; the whole-WRITE fallback needs records below about 12 KB to
    come into play. Keeping every boundary page cached instead, which a
    later commit makes possible with a direct_misaligned_dontcache=N
    debugfs knob, grows the page cache by about 630 GiB over the same
    runs.

The "11 GiB" is what's left resident in page cache _without_ the
"NFSD: keep boundary page of a split direct-mode WRITE until both
writers complete". _WITH_ that patch (to make more informed use of
DONTCACHE) it drops to the quoted 2.9 GiB while still benefitting from
RMW avoidance buffered IO makes possible -- pretty fantastic result.

> Later patches in the series assume DONTCACHE is the fallback for
> certain cases.

That's the existing default that current upstream code has.  But with
this patchset the fallback is buffered, with buffered DONTCACHE the
default unless debugfs direct_misaligned_dontcache=N configured.

It would be quite bad to remove DONTCACHE support because it actually
does offer pretty solid wins (especially for the workload I quoted
above).  If pure buffered IO used (direct_misaligned_dontcache=N)
WRITE performance suffers: "only" 31,297 MiB/s for O_DIRECT +
buffered, whereas with O_DIRECT + DONTCACHE, overall result were (more
runs needed to get stddev):
4 - FILE_SYNC floor   35,567 MiB/s
2 - NFSD_IO_DIRECT    35,302 MiB/s
3 - DATA_SYNC floor   36,163 MiB/s

> Jeff has measured substantial performance deficits for that mode,
> and maybe removing DONTCACHE would be a better direction to take.

But to be clear, I'm not referring to DONTCACHE only mode=1, I'm most
interested in hybrid of O_DIRECT+DONTCACHE (more on that at the end
below).

My series has been fully tested with Jeff's more recent DONTCACHE
commits in place:
 88d6f128d06d mm: track DONTCACHE dirty pages per bdi_writeback
 f3122ce09a51 mm: kick writeback flusher for IOCB_DONTCACHE with targeted dirty tracking

> The patch that reports the actual stability of a WRITE was dropped
> because it broke something (although I don't remember what).

Haven't seen any issues with it.  Been carrying it ever since you
posted it.

> As I recall, even a direct WRITE needs a subsequent COMMIT. Have you
> demonstrated that the client COMMIT is a latency problem or that
> the memory that is pinned on the client has a noticeable impact?
>
> We suspect that it might, but every time I've measured, avoiding
> COMMIT with NFSD has shown no impact on throughput, which is why
> NFSD doesn't already do this optimization.

Yes, in the header for "NFSD: let a direct-mode WRITE raise stable_how
and elide the client's COMMIT":

    What this removes is the COMMIT traffic, and it is worth most where a
    client's writes are carved into several WRITE RPCs, because each piece
    is then committed separately.  Measured on a pNFS flexfiles share where
    every write straddles two data servers, so every write becomes two WRITE
    RPCs and, under NFSD_IO_DIRECT, two COMMITs: the two modes do identical
    durability work, one fsync per COMMIT against one fsync per WRITE on
    identical WRITE counts, and the COMMIT RPCs alone cost NFSD_IO_DIRECT
    31% more server CPU and 42% more client CPU for the same bytes, about
    20 us of server CPU per COMMIT plus a client cost that grows with the
    range committed.  Where only one write in 22 is split the same effect
    is a couple of cores on each side and no resolvable throughput
    difference, and writes that fit a single RPC send no COMMIT in either
    mode.

> So even if these patches apply mechanically and benefit your workloads,
> it would be helpful if we could step back and understand what you are
> trying to achieve and how it should coordinate/align with where Jeff
> and I want to see this mechanism go. Can we start with that
> conversation?

OK, please review what I've provided further and we can then have a
more detailed discussion about anything you like.

Claude helped summarize what this series fixes:

What this advance is, precisely. It is not "NFSD uses DONTCACHE". It
is NFSD's direct write path - io_cache_write modes 2, 3 and 4, where
an aligned WRITE goes to the filesystem as O_DIRECT - with DONTCACHE
used only for the buffered fragments a misaligned WRITE cannot issue
directly. The page cache is bypassed for the bulk of the data and
bounded for the remainder. That distinction runs through everything
below, and it is exactly what separates this from io_cache_write=1,
which is plain buffered DONTCACHE with no direct I/O at all and does
not reach this code.

A misaligned WRITE in one of those direct modes is split into a
buffered prefix, an O_DIRECT middle and a buffered suffix. The
boundary pages are shared by exactly two WRITEs that may arrive in
either order, from different clients, at once. Marking both DONTCACHE
bounded the page cache but cost the second writer a read from disk
every time - 0.81 device reads per record on the rig, 585 GiB read
back during an 8.1 TiB write.

Thanks,
Mike

Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.146
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792795108;
	b=iwnmltmwE54QYLC5jat5yQkmNtrZ67W3b768TJG01IwXjuin10jSrgCrlgimlZcfajnN
	 qjMWdB+zjS690cnRZpqvNkt4TpmXNqzcXjPQEiZPHP6eULZl2VW2yT71auu9gho5i7c1n
	 +oY9jiVT3UMcLOgFCJpvejqndYdVdAF1x9KaUMFKHeX3acRx/14Xeme+4ntKLKqQrSwn0
	 KzEMla9JG90bHcGMZWPz0pOIE5v6FEKUN6/G9Nu/0Ki4Uouc3EfNTsOhtBeOgvz7a8Die
	 iDMdV6Bx9oTBQLIp92eFiS34au7eBs7f5v0vON44xlI+xc4K12J3M/DIYTIJfLJnv8w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792795108;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=CXpjL5aV+fL/tQYDIsd7gu8pYrT13G45saJG84Sqomw=;
	b=Ky8UuC7pvi1igLYdTkjQxmcnB65exd6yXCEcHP8tkF34m5iNnEKB9r6aix0Dp9TP+2la
	 kcWnfgUTK/RKXmWzMEnf4XhzBqsSAJso2U8rBG62Blz4tc916vmrUaXCGlp8e7z4JjWVJ
	 AQRmK4eHliTcjD8lFumZRHBGtLWJvqPe6NyTi1XRguLGb9Uw1XMq/0T51rrsbXQz9WkxL
	 2cUplZlXXZe06YwnE9tXU3UaFahS13YIbOLIxsrnKFVndYk/9vYui2Y+6BM66Uy/72GUz
	 H4O9SdrAHLqQxOy6IoSgqEnzWL6K3ASXt7ZzfGxUnGy8XOlClUC50dsJ6iQ4AypjSSQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=k9NO7nUw;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b="Y7J+9/EW";
	arc=none smtp.remote-ip=103.168.172.146
Received: from fout-a3-smtp.messagingengine.com (fout-a3-smtp.messagingengine.com [103.168.172.146])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61A64606A31E
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 22:38:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 61A64606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=k9NO7nUw;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=Y7J+9/EW
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.phl.internal (Postfix) with ESMTP id 89C1EEC018D
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 18:38:26 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Fri, 23 Oct 2026 18:38:26 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1792795106; x=1792881506; bh=CXpjL5aV+fL/tQYDIsd7gu8pYrT13G45saJ
	G84Sqomw=; b=k9NO7nUwus6pgom+xJ3Prj6B7WYKUU6iuNkvaMBD4fEtpk5/Tyl
	+nITaTlHB+oLEhndk/KHP8Dt6B/+XbLy1+qZfUa+hTkpV75NAHRK7ud14lokFSJM
	0ZHmL3XQSHT+LCp3031Ju1pFelvJOLUXWrC+zHGHwuYD/BiD34vMi2Sw1wwh9boy
	5Ar1R03kPEn+OXIFlRAM5WZ4xOSvYtksf/caK9sGPD+F9/kbbbBB0FATprhLYFD9
	KBEcSUPYE06e6i5S1Nh9Qm1Bcm0Ammz3hDNtDkqRURgMrGC8tGjbneeNpND65Fnq
	DBd5heCpHPzJNEeg+luBU85MGhSHySANDig==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1792795106; x=
	1792881506; bh=CXpjL5aV+fL/tQYDIsd7gu8pYrT13G45saJG84Sqomw=; b=Y
	7J+9/EWOXaB0LzEx5mgwKelbGgi89TUuSfSSKznxAuR7DNlDhCe+F10bXsHoTi6d
	S08Lvz+/9ihvDuCRl+DDVGVNGMhi06Q3KAI1qs0xFkchU1/C0CjH0HzcZwchFbu1
	DsV52aHkXYeRdcA22Pg8ThUxJIDtCFyXmNm6ri3l9q6PEHNSF1TSQpqac4ZYwoci
	irtZPU2zirm3pv3M4kc0+4Hfb3ML567EoKqYi2l6gEq4YJs7mLhH0x836hBT9BTv
	oJTxq6Q+b99kBFxsbVLzAYTJbXlqRaHaU0Odnb9Rcob2XW4tvWufp3Q+Fd6grqZo
	hUVPqef1AH2llpB3K7ZXQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1792795106; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:PYKnZQ93XuydqFrZ5JPgnkm4YzzdcKCcjeWmOakVnju1uoM
	vMNRtRaQjgtLFA6EfInj18ZcyJDySauC3Z5T1ZLXI6sl/Qkq4DGVYyXXdO+0GQ3r
	L/y4fax6zGtS2KO1XnscGanY08u+I015qHq27sudXsWZA//VTJo9t8ZPUcmiwf8b
	RqB9kHp2O2xtXOU58GZMvUrI/wmdfJBU9hN5qraiS99v4gNLhy+X7OVzEvnKovnQ
	YApcdD6h4bfmj0lDfcKJxW6woXFB0Sg1WwgDGRmFKdxgqZobGxUisfE/4/2eyy/e
	5CzCPyHtwB/8o8/f1B29GSYMgrsmZFJWKjiO05w==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:KmLnJKZDRE19PAX56rvC54Ee6o1ap2dCE9utRFVjjL0=:wEUenmc4EYB8ur+IAcaeJAPVN3w/PSx3oXhanP+XV3c=;
X-ME-Sender: <xms:4uHbagj4QnAUlrcQZct5Cbs--ItFzGvlkiKsie4pFfwxInLm0Bt54g>
    <xme:4uHbanRRM_H6eAsin1dYZv6--GGXkDplmBKmBCeJ1oPPik87i5SHq_3Sn86hPr3zp
    GX-0dPhYL3DcC53edx7vnatP3VvfdJR6glD8hGIQzQjWMyI3BY>
X-ME-Received: <xmr:4uHbahYqRnSzPGk0LwAw7gpA5LX39nDoszXFiZ36shL4DWZcscgJzDuCeNCz1U0oFqz9IlSeXablvRe39zUTSrCNtIQRhK4>
X-ME-Proxy-Cause: dmFkZTG3Q/70zTOldkKwQ/nRgy4pIRffckwi2d0zpsPIWfS8PNEp1RPAIJQ+x4vQcGat3g
    qzQdPStc3TCac79qZLXbXiD3sTtVOHHv5cqUO1Wd+MwnhD0WzDnwjLyE8D1QBMRZ7Q3PXG
    zjxO1rKtu2atByIb/LLvCdY896C8BgpqdgbIwmsyP3bfg8lLjtyy1K1KC97OCP8Li3II3v
    BfY9tHc/0LsAp61D4lhkbW0+R9rbMeDd+9etu8BTxzXXVbxKxJxRdiFACgx4/sL3n/EIde
    4TPcJjZ/Ri7DlwgnKPWVVOP8jqSk37nWVK5cfE0Q8ZpFFKxpP5+CKFxupBfedjqGeHqaAY
    Ps5NSPTyhLbgfZd84yro+dup3JiuMW6kKtCgerFIyzbKVHBAUOjUIldRsPIRmJ+igIp3fy
    PtR9hqheMmajfBBchViUWLWyviR6XtD2Hz7ijxcFALDL9qkqVZ2elQnrYfrlfJuoxrSOrF
    v7lw4XZmc9Ffv3wqSSftRZSUCu+Yc+9NmuFvzB/L1xaeKvuf4oUsHDrW/fV82GMN9ueRDN
    eue/iSTcuaqJzYD0iWtxDmiNH2GfKDxc/7yhPj8sw610ii4+5lilSf1/buThdElax9LfgJ
    Y4YkzjykyTuzKmRY9rGkBhvu/+2DS4HX4hgbv/i0lbwVSBR+weE8EP5l+Pag
X-ME-Proxy: <xmx:4uHbakSC3GKcUcsT3aQ3WTEn1GdBsYRvZNtVYa7VCKMjI_CTUEyuyg>
    <xmx:4uHbag-qZxOfqU5eNfQ8tYsyt_Je-LSBSer_6MgfIZuui0Hle2BJ2Q>
    <xmx:4uHbakhN8urUjjOdSgzTyxskPC0P0OxBqN_fSZIt-VK2GjoklUbdbg>
    <xmx:4uHbahbRSjFaFCYIoNzBQG6nNzukQO_PmNXmusvcsyERO649tkhe9A>
    <xmx:4uHbasFkA85Uc_YspYqqeG3u4x7oct4lPV_fPyRLidJNztOtYYmhHag0>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 23 Oct 2026 18:38:22 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Jan Kara" <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs: set NFS_FSDATA_BLOCKED before invalidating d_seq
In-reply-to: <20261023192215.1795577-1-jonathan.flynn@hammerspace.com>
References: <20261023015239.2163480-2-neilb@ownmail.net>
  <20261023192215.1795577-1-jonathan.flynn@hammerspace.com>
Date: Sat, 24 Oct 2026 09:38:18 +1100
Message-id: <179279509880.1157394.17104184170834248641@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 24 Oct 2026, Jonathan Flynn wrote:
> block_revalidate() calls write_seqcount_invalidate(&dentry->d_seq) and
> only then sets dentry->d_fsdata to NFS_FSDATA_BLOCKED.  Because ->d_seq
> is invalidated before NFS_FSDATA_BLOCKED is set, an RCU-walk open can
> get past an unlink that is in progress.
> 
> The barrier in write_seqcount_invalidate() is issued before the
> increment, so it orders only the stores made before the call.  An
> RCU-walk lookup that samples ->d_seq after the increment can still read
> the old ->d_fsdata, and so ->d_revalidate() accepts the dentry.  The
> walker then waits for ->d_lock in lockref_get_not_dead(), takes its
> reference, and passes the ->d_seq recheck in __legitimize_path(),
> because ->d_seq still holds the value the walker sampled.  By then
> nfs_unlink() has seen d_count() == 1 and sends the REMOVE instead of
> silly-renaming, so the open proceeds on a file the server is removing.
> 
> Set NFS_FSDATA_BLOCKED first, then call write_seqcount_invalidate().  A
> walker that samples the new ->d_seq then also sees NFS_FSDATA_BLOCKED
> and returns -ECHILD.  A walker that sampled the old ->d_seq fails the
> recheck and retries in ref-walk, which waits for the unlink to finish.
> __d_drop() follows the same order: unhash the dentry, then invalidate
> ->d_seq.
> 
> Also correct the comment in block_revalidate(): the ->d_seq recheck is
> in __legitimize_path() and try_to_unlazy_next(), not in
> legitimize_mnt().
> 
> Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> ---
> Neil, this answers Sashiko's second point on 1/9: v3 still calls
> write_seqcount_invalidate() before it sets NFS_FSDATA_BLOCKED.  This
> patch applies on top of v3; fold it into 1/9 if you prefer.
> 
> The window with the v3 order:
> 
>   CPU0: nfs_unlink(), ->d_lock held     CPU1: RCU-walk open, same name
>   d_count() == 1, no silly-rename
>   write_seqcount_invalidate(&d_seq)
>                                         __d_lookup_rcu() samples the
>                                           new ->d_seq
>                                         ->d_revalidate() reads ->d_fsdata,
>                                           not yet NFS_FSDATA_BLOCKED
>   d_fsdata = NFS_FSDATA_BLOCKED
>   spin_unlock(&dentry->d_lock)
>   REMOVE sent                           lockref_get_not_dead() takes a ref
>                                         read_seqcount_retry() passes
>                                         the open proceeds

Thanks. This diagram is really helpful.

I think I will move the d_fsdata = NFS_FSDATA_BLOCKED assignment before
the comment and maybe add a bit of explanation.

Thanks for helping me understand this problem.

NeilBrown


> 
> Your afs 1/5 also sets DCACHE_BLOCKED after write_seqcount_invalidate().
> 
>  fs/nfs/dir.c | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 53cd3adf3ffe..79331e0fa044 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1879,15 +1879,20 @@ static void block_revalidate(struct dentry *dentry)
>  	/* Any new reference that could lead to an open
>  	 * will either:
>  	 *  - take ->d_lock in lookup_open() -> d_lookup() or
> -	 *  - will check d_seq in legitimize_mnt()
> +	 *  - will check d_seq in __legitimize_path() or try_to_unlazy_next()
>  	 *
>  	 * Holding this lock and invalidating ->d_seq ensures we cannot
>  	 * race with __nfs_lookup_revalidate().
>  	 */
>  	lockdep_assert_held(&dentry->d_lock);
> -	write_seqcount_invalidate(&dentry->d_seq);
> -
>  	dentry->d_fsdata = NFS_FSDATA_BLOCKED;
> +
> +	/*
> +	 * Set NFS_FSDATA_BLOCKED before invalidating ->d_seq: the barrier in
> +	 * write_seqcount_invalidate() orders only earlier stores, so an
> +	 * RCU-walk that samples the new ->d_seq also sees NFS_FSDATA_BLOCKED.
> +	 */
> +	write_seqcount_invalidate(&dentry->d_seq);
>  }
>  
>  static void unblock_revalidate(struct dentry *dentry)
> -- 
> 2.43.0
> 
> 


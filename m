Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793892960;
	b=aKJbMsgxhbIaaCt1gpAl62+TyeRZuqnqmAAb+iFwysJaFBKTUFD4ens+7JfzDMk8CZph
	 pZ7q8nZV+6ToKqjAYpayqP3OlQ11SEt56cs9KdSLXfqVZsgdj96u140Ebia6TETc9Yo3r
	 6GFKbjJvZuv3+BQcGRb5uXbzlD+572f+A4FftIc2+w2nDitzGawSuf6lhG0XG8paZGqaf
	 VeZ+YGolHwj0j24GmEQ1QUJCNsSm93frhFcmVDilK99O+LhRI8FMEKIZ1uEMngN3fPNGK
	 kx/f3Fm3ABJ9gK98DiMtyHgjYo1DYWzsPiyfK6fUi65/7PErxCgpeIgatAdCfghrG5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793892960;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=oi/ZRG1ZfO2EPRXTzOK2jbFPdNS06WP2KYCV4856/0c=;
	b=Jc5x6kz8cHSLTgJFl8ddPpj3957ihkMd0VOTz6qCITX9Z5YBqo4dXaC5+7PlNrhA6R5Y
	 KO5am7JhhROq//iqkzxynl7B/skWePwSU6X7lHhcGOnluvObrF5NiGD0rmvIadjRxM4fZ
	 jxmy9GNKPT92/dHENMUakGIyydNmQIBCkayKtJc/i/6OkeriOfzCmpWABKaYfHx4bEkHe
	 IJeDZB+YQ2jaD7TIjCuZrvPSVNNXDMLI5UdMWKJ//rNqagU2xkXg7HJorsKFT3x1VfYZX
	 FiIMlP6AZzM0sndOFqRbe4EIUBI8HrDTFQSoC6EGnfcrTYUH3t5mzWKf0C5jGvjPrPQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JeY2sOBG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 588C7606A31B
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 15:36:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JeY2sOBG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C69C11F000C1;
	Thu,  5 Nov 2026 15:35:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793892960;
	bh=oi/ZRG1ZfO2EPRXTzOK2jbFPdNS06WP2KYCV4856/0c=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=JeY2sOBG6nnksYr80oF0Ih3rl822GpyBaeIOtFhPxUJboQsP1uXIbkvu9f94QXmsp
	 W62j37Zex3ZwyR7vxMgY40HOHwJqj01m95cavpTOOKkz1xJNLtcJKo1SnIkJgvUtUJ
	 1OFsz/Afcct/csBHwgKsIHWiH+tF1VjySjxrKFq77ljdSyn0zPx/3c4Ka1aCyVaY8h
	 GAlZCKNIMDyrnb6IjppQ6kes6W0wOOLALTB0YyWs2n8HMq7ZRMz9u11THCnCHumVCV
	 /qRzF7NRr573kM6B29QrqxsAh6bSSwk8A2N9jIt3rUPD3KY80IPZiRVQ1rBD8fVv7F
	 8iiUepC3g//aQ==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 2F8CEF4006D;
	Thu,  5 Nov 2026 10:35:59 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 10:35:59 -0500
X-ME-Sender: <xms:X6LsajpYmE-Z8FPT70bX6oER2QdRreEDE2d21YwZHDMz8lwKFL91xw>
    <xme:X6LsaoeAKEA0PJl_25WYuUO04RbzZPJXu2oGG1wQkDlli9UZzIVSbtHt41ES7Q86h
    OrYc56qwsaEofKRpY7MwySz7dPk8FjeLyuoIxARTkOmC9-ZgrXFeytf>
X-ME-Proxy-Cause: dmFkZTFsj7K80otAp6H7UgU6MWlm1U1wyz6jj55TRDslEdHHgkFqArwHCkA2Vtk3jYSNjk
    +X9W6THF/22Hk45Y2wZZpPLsskA3BAxw1mqT4H5ossHIJNwnX3rU+HmClj9d+R2SFlKaqa
    k8Q2qzgoydIOHYyWPOaoJn1pyNBsnA3lu/1+TNU/WZMlGaSI9BoH1inJP664o/ckdk7tGd
    84+illlJDr/20lrjzueZijNv1OM3fRXxFQTUOdIpzJqZWxijst3Dt9tyN4mB06m5cDpNPO
    Tu9qpchQtiZfSmHJzPqH5lCXi/SqUyOcJr44cepBw/5nlxs1eBQDGSxmqmIC85WM6Okmbv
    1twTNI5u9mpPRwwJeyDMhukfny7+HO4l+ZTLWI0re0uFCv4pNMubF7Ln5JeB2U05K6+Ezb
    bLtZD7E4LLamy984S10/GrtcK5li4Fw++7eTPUYzyyKSDRPvpXBnBtIjILVmP19lzu8HVD
    UFcE5ARCpct4zCEYeKRxGtDPFvKjAkyutfSYuzh8wIuQ35NRI2x12r1ti0UWumwtRu28Ij
    6+U+0a6NSomqZDiYJtyxWCbkKtT+mL+XOt3pGVuDPKL8+qfdUeDrVS889FOMgvKQ467sID
    uCa5AfUF5Ie0v0SesvIt2nB4rHnMDmQ3LmXonpg24sRLHCHnI9RTCbNr195g
X-ME-Proxy: <xmx:X6LsakTTWk8bWPk-fbjwQePsF-n5k8INyVVU6R-q83-qhO-URYkeEw>
    <xmx:X6LsavkZS_dxd3advk5DPb_V_I0R6GDMiCCs1sa2dv-Y-6jeTZMWMQ>
    <xmx:X6LsasT6HFFeS3pm8d6d0kx1c0CeOLkBg4HV6qUNUsbZv8R39x4wdA>
    <xmx:X6LsalMr6QUMPAv_gZLsvjWzZKwKIBp8NUUrWZpaoiHIwgte8Acd0g>
    <xmx:X6LsatUXo3NQ__Y8_hlR_uUnimPbFaDKfJqIIan_eLOtLrhaMjbqxGuk>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 12047B6006E; Thu,  5 Nov 2026 10:35:59 -0500 (EST)
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
X-ThreadId: AdpJwv4U0R6N
Date: Thu, 05 Nov 2026 10:34:56 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <5a9801cf-b4af-4a04-8ebd-86ab9b5160f5@app.fastmail.com>
In-Reply-To: <20261102191109.13470-4-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-4-snitzer@kernel.org>
Subject: Re: [PATCH 03/11] NFSv4/flexfiles: cacheline align the per-stripe layoutstats
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> Moving the layoutstats lock into struct nfs4_ff_layout_ds_stripe stopped
> stripes serialising on one spinlock, but it left them sharing cachelines
> with each other.
>
> The lock and the statistics it guards sat at the tail of a struct whose
> sizeof() was 296 and whose alignof() was only 8, so in mirror->dss[]
> stripe i began at i * 296.  296 mod 64 = 40, so every stripe started 40
> bytes further into a line than the last and no stripe's lock was line
> aligned.  Acquiring stripe i's lock therefore invalidated the line
> holding stripe i+1's lock and counters.  A RAID0-style layout -- one
> mirror, many stripes -- is exactly the case the per-stripe lock was
> introduced for, so this false sharing ate into the win.
>
> Align the first member of the guarded set.  That does two things: the
> lock now starts on a line boundary, so the guarded set occupies lines of
> its own and shares none with the read-mostly members above; and it raises
> the struct's alignment to 64, which forces sizeof() up to a multiple of
> 64 and makes the array stride line aligned.  The stride is what actually
> separates stripe i from stripe i+1.
>
> Verified with pahole on flexfilelayout.o built with DWARF5.  The layout
> is identical on x86_64, arm64 4K pages and arm64 64K pages -- cachelines
> are 64 bytes on both architectures, so page size does not enter into it
> -- and was taken with neither CONFIG_DEBUG_SPINLOCK nor
> CONFIG_PROVE_LOCKING, both of which fatten spinlock_t and change it:
>
>   /* --- cacheline 3 boundary (192 bytes) --- */
>   spinlock_t                 lock __aligned(64);  /*   192     4 */
>   /* XXX 4 bytes hole */
>   struct nfs4_ff_layoutstat  read_stat;           /*   200    72 */
>   struct nfs4_ff_layoutstat  write_stat;          /*   272    72 */
>   ktime_t                    start_time;          /*   344     8 */
>   /* size: 384, cachelines: 6 */
>   } __attribute__((__aligned__(64)));
>
> A read RPC now dirties two lines of its own stripe and a write three, and
> neither disturbs a neighbouring stripe.  Later patches give each
> direction a line of its own.
>
> Cost is 296 -> 384 bytes per stripe, i.e. 2816 bytes for a 32 stripe
> layout, which is negligible beside the rest of the per-file layout state.
> 384 is also a multiple of 128, so the stride holds for implementations
> with a 128 byte coherency granule.
>
> Note that the alignment attribute only orders the stripes relative to the
> start of mirror->dss[], not that array's own base.  The base is aligned
> too, under either allocator kvmalloc() may pick for it:
>
>   - From the slab.  kmalloc() documents a size based alignment guarantee
>     for power-of-two sizes only, but the smallest possible request is now
>     384 bytes, and every kmalloc bucket at or above that is a power of
>     two whose objects SLUB lays out at multiples of the object size from
>     a page aligned slab, so the base is at least 512 byte aligned.  The
>     exceptions, kmalloc-96 and kmalloc-192, are both smaller than one
>     stripe and cannot be selected.
>
>   - From vmalloc.  A stripe array wide enough to need a high order
>     allocation is served by the vmalloc() fallback instead, which returns
>     page aligned memory.
>
> Either is comfortably more than the 64 bytes this needs.

This commit message is very wordy, and can probably be edited down.

>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.h | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index 8fa2d8851166a..f48860450cf28 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -14,6 +14,7 @@
>  #define FF_FLAGS_NO_IO_THRU_MDS  2
>  #define FF_FLAGS_NO_READ_IO      4
> 
> +#include <linux/cache.h>
>  #include <linux/refcount.h>
>  #include "../pnfs.h"
> 
> @@ -86,8 +87,17 @@ struct nfs4_ff_layout_ds_stripe {
>  	const struct cred __rcu		*ro_cred;
>  	const struct cred __rcu		*rw_cred;
>  	struct nfs_file_localio		nfl;
> -	/* Protects read_stat, write_stat and start_time below */
> -	spinlock_t			lock;
> +	/*
> +	 * Protects read_stat, write_stat and start_time below.
> +	 *
> +	 * Cacheline aligned so that the layoutstats accounting done on
> +	 * every I/O to this stripe does not share cachelines with the
> +	 * read-mostly members above, nor with the neighbouring stripes
> +	 * in mirror->dss[]: aligning the first member of the guarded
> +	 * set also rounds sizeof() up to a multiple of the cacheline,
> +	 * which is what makes the array stride line-aligned.

Let's leave the original comment alone, since most of this information
is  duplicated in the commit message and can be easily found with
`git blame`.

> +	 */
> +	spinlock_t			lock ____cacheline_aligned_in_smp;

Making this cacheline aligned seems like a good idea!

Anna

>  	struct nfs4_ff_layoutstat	read_stat;
>  	struct nfs4_ff_layoutstat	write_stat;
>  	ktime_t				start_time;
> -- 
> 2.52.0

Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793897197;
	b=Um6M0NrXGLM+Yv3CoP2RTS1DFUdLxXxDUXKyWhkfBONwTbtzsu3I190Fm0ZrYdMRT1YS
	 oiBCds4gzSMx7GrWBFZk88m6lRNv7NBdocSF6AcAhSIFO2CvNrI9XKbg6Kg34nVdXbyFA
	 EUU81ZJf9NI0jtMfnQMnIra2+vHX0aQboFFqHyJKEtVurcqFps3RO5AJHBGCwvLsNyjvT
	 1osf3wRQBU8yrozV3v4NdJNKrwpPJTPkN7DpqZNZQhey/npCDn7T/+niRqbkIx04hC4N8
	 noCE2WTS/u7EdmC47zVhaA54Nb4OETRUGvgm2Shs/DDHHi/EaYRi9ctGCHLtTP8Li+w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793897197;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=Vnu/MCp6L56jyQp0juyIgaSbc5SFbDUx13qwhmGLlSY=;
	b=dsesz1IZGbcmsjCbMmRuzHFtouBL0n6Rhh45fIKlD3wbjRoYkf3txE66in4KHu3k2saE
	 ZxNUFfnclVzDpo5KJdykMR5a5reHgboC0As0+TPFGkcju9rxnGplUq+eMRWsj9LtoWeNW
	 fApTBLHmp5m+9nuaDGsZlbVyTry64DVr5gYqvtYKZh30o/02Aib5MmR1K5iEHZAGncaDa
	 AJuOFs9QuYS19AgGcpbPOJweHRZYSH9/ccINbe6hQ2vYZy3RZ7WxAP393FuOVctq8+iq5
	 v82P4UppBJusfFInkbAnN4R9mJjbiHvhpTlrmP8cBGBJiP2hv8ZGrG5jgbTTONcCp/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cfGyuZdY;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55A9D606A329
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 16:46:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cfGyuZdY
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B590B1F0093A;
	Thu,  5 Nov 2026 16:46:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793897197;
	bh=Vnu/MCp6L56jyQp0juyIgaSbc5SFbDUx13qwhmGLlSY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=cfGyuZdYY5NiA/vdZQVJsY7e/f8gEzebgESv8dZGxtcM9eZh6LcMgy2KMr07m92wv
	 Z/BO7NHp/LuRMZM/7ao8x6N5pmPi7oo/6PuaEzT5R5SxaNCopii9hH9M6EIGcbBo88
	 jvrNE2mxrtxOwvO2LbXVDlofjAO1byS28EcQ6vYh+8xhVus1vj1z2aj4a3EfIxqGsU
	 PWwAw5fI70Hga9KK81RzmZRk6JT6/ZEoXdovb5mGT47dlUAPOUAPgHUWLAstBFsyST
	 oJwwrJLvZW/q2N/gbfT2qhG7Z3CBrpqYKgZU6tzHJNx9CFpBelQRy5k0vt6jJN5qpr
	 5twJaRmIjfDgw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 23D02F40066;
	Thu,  5 Nov 2026 11:46:36 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 11:46:36 -0500
X-ME-Sender: <xms:7LLsao8FO5UfaimuAFZ-OnAyvwQ1c2s0_l7bbsuWVeVL62a2BfqUQg>
    <xme:7LLsarirgo52DCEoLbBiFwahYFEDQnZLGsqhD1az3CyOoQ7803LSzozReanCyAU5F
    Gf-neY6RTWpXIQxFwItRZdTs6THc1z1B1spfLaxS0dKnRpa_oxFumd-jQ>
X-ME-Proxy-Cause: dmFkZTFO3/JGAaoV7Nr42ScRvOnwwgVQEOnT65c9bTbGntup8JPIwaBmMTNVAELhA6xeok
    xgLXQEkcz5/6VEOpHkzF1+yTIl9dUY62WlW5bHK035vB7SXaib1swJtp12XWt2suYSolsp
    8odw3jbz7ymBcAVr8eu4qF103or+DdcpBFK5DhM0VUa9N7M/1nX7YZizA4LoQHechzdMUh
    kEDTHReA92LnKM8QQ244wTp7UrU342AkiMnM9SIsW2Awh6wvNZ2OSzdxI8S7ViMBwMZfYU
    b/NVYRAEM0q8zZQYB5kVkqLw8IcHKgja/EGQ3faw8P2infTS2jkqmVMzdtVwNNNtM/V4DE
    KwEhGTZ6T+jMCho2Z3RRvpHBzkiqWjVKdu4zWa46Wss3tCk3q+lUrymX0YDWMuDR+URT77
    K0XKtPrNf6NjuXUuDeZEmISo8nf0Vel8dvlwyMr+CRSmeosWNjvwKIWEMrU1b6prcNtZHr
    Ct7gwf+IxJ6my6x77CHx4EDzK6puciSvoVLRBTd9jPU5Sxi5LBL42dIFbYn+cgqsihnh+D
    n3Os/4MiStGNaIqo68Y1FkTpGDVNMf4cwAn2e1Of0Juge1gONX/LTyqjrnv+BCupmQG6zq
    GZgslWNd3a3LIYAJnPIE5fDsgWqH3HINTZpBfOmQtW5ocE9gk9yhur+qKy4g
X-ME-Proxy: <xmx:7LLsasnruPrnj8CF6YmqrYHSp6Tbk_iX7tHv6WRwkhfNoNtZnztWYg>
    <xmx:7LLsapoI_2gRSv0gy_17eFQIVF93dqn6o427KAizi_9UqT9ovnj79g>
    <xmx:7LLsalE7iv1hao6DGEyq3jS2ec4CPqhPAARAGKSvV3idSKthvSku9w>
    <xmx:7LLsalxVaGD-ZI449f5gy8GQl8nKX8ro_8VGCfoElCntz-SyuVf2LQ>
    <xmx:7LLsaqoT2MmJ2WmWQzrJ6QB8LigJrej5eR6VljAW6e2gI2U3ZK3VvDDV>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0B951B6006E; Thu,  5 Nov 2026 11:46:36 -0500 (EST)
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
X-ThreadId: AOWqPum3d1Qg
Date: Thu, 05 Nov 2026 11:46:14 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <dd737694-14b2-458a-90d2-a8e702f8e859@app.fastmail.com>
In-Reply-To: <20261102191109.13470-6-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-6-snitzer@kernel.org>
Subject: Re: [PATCH 05/11] NFSv4/flexfiles: drop the redundant atomic from the busy
 timer
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> nfs4_ff_busy_timer::n_ops is an atomic_t, but every access to it is
> already serialised by the stripe lock:

Honestly, the commit message doesn't need to say much more than this
sentence. The rest of the message basically repeats the concept using
more words.

>
>   nfs4_ff_start_busy_timer() has one caller, nfs4_ff_layoutstat_start_io(),
>   reached only from ff_layout_{read,write}_record_layoutstats_start()
>   with dss[dss_id].lock held.
>
>   nfs4_ff_end_busy_timer() has one caller,
>   nfs4_ff_layout_stat_io_update_completed(), reached only from
>   ff_layout_{read,write}_record_layoutstats_done() with the same lock
>   held.
>
> The two reporting paths, ff_layout_mirror_prepare_stats() and
> ff_layout_encode_ff_layoutupdate(), take the stripe lock too and do not
> touch n_ops at all.  There is no lockless reader.
>
> So the atomic_inc_return()/atomic_dec_return() are locked read-modify-
> writes on a line the CPU already owns exclusively -- pure serialisation
                                                            ^^^^^^^^^^^^^
Interesting that there's some UK spellings sneaking into your text. I
noticed "neighbour" in an earlier patch, too.

Thanks,
Anna

> overhead, paid twice per DS RPC on the hottest path in this file, at the
> 275k-450k RPC/s the per-stripe lock work was measured at.
>
> Make n_ops a plain int and document the locking on the struct.  Its size
> is unchanged, so the stripe layout is unaffected.  The underflow check is
> preserved.
>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 6 ++----
>  fs/nfs/flexfilelayout/flexfilelayout.h | 6 +++++-
>  2 files changed, 7 insertions(+), 5 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 7c328f2ec900d..6a474fa7b0446 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -711,9 +711,8 @@ static void
>  nfs4_ff_start_busy_timer(struct nfs4_ff_busy_timer *timer, ktime_t now)
>  {
>  	/* first IO request? */
> -	if (atomic_inc_return(&timer->n_ops) == 1) {
> +	if (++timer->n_ops == 1)
>  		timer->start_time = now;
> -	}
>  }
> 
>  static ktime_t
> @@ -721,8 +720,7 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer 
> *timer, ktime_t now)
>  {
>  	ktime_t start;
> 
> -	if (atomic_dec_return(&timer->n_ops) < 0)
> -		WARN_ON_ONCE(1);
> +	WARN_ON_ONCE(--timer->n_ops < 0);
> 
>  	start = timer->start_time;
>  	timer->start_time = now;
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index 658940979883a..d97001abc0d22 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -64,9 +64,13 @@ struct nfs4_ff_io_stat {
>  	ktime_t				aggregate_completion_time;
>  };
> 
> +/*
> + * Both members are serialised by the enclosing stripe's
> + * nfs4_ff_layout_ds_stripe::lock; see nfs4_ff_{start,end}_busy_timer().
> + */
>  struct nfs4_ff_busy_timer {
>  	ktime_t start_time;
> -	atomic_t n_ops;
> +	int n_ops;
>  };
> 
>  struct nfs4_ff_layoutstat {
> -- 
> 2.52.0

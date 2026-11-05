Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793901683;
	b=CPoAw4snH6UjwXXkGpyPl5Q5KraZsfErPL1Pq5rZwxAv3yI4CCkZSQpuZKu0g/aa44vX
	 sOSgjJrsmhc6AQE/yfshKm4VbKDkEvbo6D3QGmf7JsiOkhyiU15JCh6+5LVecZE/R4wM1
	 alj9Gu370NHR4AaM5FTCQ9NX73daNw3nf+46Ydnc8AZx5ZK3yKGE9EMUK7u43PwgAKsJd
	 kOkdMJpvTlhhIQSoYd6q2fx51uTMKST45SwXwRrbREtRdNSzQYzoOcGK9XMGSA4AKiCvL
	 OSvwl4die0BM9bVh+ybppY3imIWFly7g7D8iaVDS2mRBmixjg9nZJMlRU7xzWF5w6uA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793901683;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=ASmShQokumGxc3MJ9wrQQLmYoPdK2iE1KW6OF8t7UrY=;
	b=2k9crvr0DlRBPATEgZM1eRuqiWouk2kJ+bdcC4ps/MGAiyBg346Y62xm+g7JCq0F4xi6
	 UysCBOQHf2pGv6lchUQQUwBZxm+e1RGxCVBxKCOJPVYypg7+rodJH8UabMpehW5tASWzb
	 YPlgLTEIU/z8QRusj8Ez2c+m657Wfhj0ddNEY3qK3MuAmCQELAkyT/A5jEdc2I/If54Q6
	 UV8+FKKxgEurqKu854pNrby43XVhCvwqti2O1DnCrQ9EjanG6GaIAhAwPbj/Ek6ig0rrD
	 i+Yhk7rnf3mx0uElrfYg+kk36icJy8wfCzGVFAwFB7vqOG0me95eNDy6tecMpk2uTCw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G4IHdvmu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F7B3606A31B
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 18:01:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G4IHdvmu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5FEAE1F00919;
	Thu,  5 Nov 2026 18:01:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793901682;
	bh=ASmShQokumGxc3MJ9wrQQLmYoPdK2iE1KW6OF8t7UrY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=G4IHdvmuxDtXTkUCieHRTtRovSODCe1uPyoTLtc8kV32r7mD2b5N6xp1k+dJmM3H0
	 m6YuMDHXnKaZoqqE9rVG6fDPO8uSbH0SwrlesqhI/dLUA6SUIouo6l50+8G5I8nf1v
	 ERfDKgIVmD3AKko2AQwqgE5ll/PfmD23aXhKrUP8XdK7ftQ5g4yeXtMIRxQg49LKn0
	 mnjqXbY15Nsiib+kW5m3aWfDAyVysPx8EnW5uW3vLDxnK88gfwthblclyC7Uw85juL
	 fhPyATlb0yelVlRYEHbKtXAHDuyBJo5wdrsl8LjUn6qZQ710ZqdnnRU1sfrVTC1dWH
	 i0/aL8X9s/QeA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id A856EF40069;
	Thu,  5 Nov 2026 13:01:21 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 05 Nov 2026 13:01:21 -0500
X-ME-Sender: <xms:ccTsajEqLXmOq9H1-Hn-Q43wXdhddIwzeCxdiF1_-OORH2_FBaglsg>
    <xme:ccTsarLQ3WoHbqliFtFhSQSwD26VcGhpx_Xc3dN2ojA39lYqHj-eFiUyomniFim9q
    3KWqbQClwaqQZsdeIOoKXaXKIq04psr8HoKNcY2_6469WHFFieojXA8>
X-ME-Proxy-Cause: dmFkZTFt95Ivq7PehjkOJ4Gl6JM/zBiDC+7flefJUwESFbBGmMMmTrzvPPqhMznytqoB76
    sY8tGCasxUCQU7f1gu+E8ZtOYBnwcaDUmM6FQ34owpB4jo6fpMnV7kl6gK3ilg0KObV3Hq
    fFNLchawFgPAzuOa83fqi7LIYuh8+DXvbr7guptevpOkPPVm7SWq8VPCt7pWc6QSuL+kHn
    oFL6h4gXT2fKKV8gedxlVxlmpKFH0UTM+xWfZXxtM6zD0YEBSjBk92Mq8pLZTDztj2rm5O
    zCXeYUA9e7DhWTyfm8R8YPB1Afx/5mv/Yli9oygD1sixZm5uUdG+FQRMOxFpz09zZ8BWes
    HWxOLAnC5mPH1WoxJUSEjE8ZQmSn114Bu8gAA8JwHvyqJJ5PmyjPrJeONT9PqpoQWup2EA
    qi+E0MvMerW+nLAW98JJAcIRODp0VE6vxini6mMLVFqfthYSeoVsycrWkGUC2BmdWz+/A2
    e6QpVIuYNpe5z7Do5L3sKu64r7BxQx+WcMR/Pb/r4/yciN1+s2+2oMk352+ZCApxxEO/2K
    WA2HmWTDM8ydFYXwcEybvu/eZEGJYVIivkFJMLk8RJ0fXFvHmVGlo/QaQsxgR/49JPhs8H
    voQHBwOa04N0TcG/5sow3zsDPeo+ATK/hHjr5h7bQ3vX3T48xBzcsE6riIhQ
X-ME-Proxy: <xmx:ccTsaktTnCbfckqNEXNMoGeDJuwzMhgBz0WkOJZuh0eEDE-5O8gBYA>
    <xmx:ccTsavTmqI-Am9yioA3pfTSd2dV6yuaILHma-IEbykf9CxIQ3QCoEg>
    <xmx:ccTsaqPDmhjScRUa7zjJA0laHvgVHGsaGe2BRymGbmZjAbG3gOJvFw>
    <xmx:ccTsakYMhIhiDYie1VwdbVf30im3MxyZJnGknmwsl5uHmVpn-zze5g>
    <xmx:ccTsakwxs0-b5nX2wHkZKvvmKJmsztJNyS-HJphmj0NKIKIoKajr1LbR>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8E202B6006E; Thu,  5 Nov 2026 13:01:21 -0500 (EST)
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
X-ThreadId: Azlk8exdQmDB
Date: Thu, 05 Nov 2026 13:01:01 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org,
 "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Message-Id: <c730c4c7-84be-4a28-bd8e-ea03edff09e7@app.fastmail.com>
In-Reply-To: <20261102191109.13470-8-snitzer@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-8-snitzer@kernel.org>
Subject: Re: [PATCH 07/11] NFSv4/flexfiles: derive ffil_ops_requested rather than
 storing it
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Mike,

On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> From: Mike Snitzer <snitzer@hammerspace.com>
>
> nfs4_ff_io_stat::ops_requested carries no information that the stripe
> does not already hold.  An op is in flight from the moment it is counted
> as requested until it is counted as completed, and the previous patch
> put both halves of that accounting in one place each, so
>
> 	ops_requested == ops_completed + ops_in_flight
>
> holds at all times under the lock.
>
> Drop the field and compute the value at encode time.  It had exactly one
> producer and one consumer, the LAYOUTSTATS encoder, so nothing else
> needs to change and the wire format is untouched -- ffil_ops_requested
> is still a uint64, and nfs4_ff_ops_requested() returns __u64.
> ff_layout_encode_io_latency() now takes the whole nfs4_ff_layoutstat,
> since the in-flight count lives beside the statistics rather than in
> them.

Let's cut the above paragraph.

>
> This takes 8 bytes off each direction's statistics, which is what lets
> each direction fit in a cacheline of its own; see the next patch.
>
> Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> ---
>  fs/nfs/flexfilelayout/flexfilelayout.c | 12 +++++-------
>  fs/nfs/flexfilelayout/flexfilelayout.h | 19 ++++++++++++++++++-
>  2 files changed, 23 insertions(+), 8 deletions(-)
>
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index bfe8288a14a08..846544977cf30 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -764,7 +764,6 @@ nfs4_ff_layoutstat_start_io(struct 
> nfs4_ff_layout_ds_stripe *dss_info,
>  	lockdep_assert_held(&dss_info->lock);
> 
>  	nfs4_ff_start_busy_timer(&layoutstat->busy_timer, now);
> -	layoutstat->io_stat.ops_requested++;
>  	layoutstat->io_stat.bytes_requested += requested;
> 
>  	nfs4_ff_layoutstat_set_start_time(dss_info, now);
> @@ -3066,12 +3065,13 @@ ff_layout_encode_nfstime(struct xdr_stream *xdr,
> 
>  static void
>  ff_layout_encode_io_latency(struct xdr_stream *xdr,
> -			    struct nfs4_ff_io_stat *stat)
> +			    const struct nfs4_ff_layoutstat *layoutstat)
>  {
> +	const struct nfs4_ff_io_stat *stat = &layoutstat->io_stat;
>  	__be32 *p;
> 
>  	p = xdr_reserve_space(xdr, 5 * 8);
> -	p = xdr_encode_hyper(p, stat->ops_requested);
> +	p = xdr_encode_hyper(p, nfs4_ff_ops_requested(layoutstat));
>  	p = xdr_encode_hyper(p, stat->bytes_requested);
>  	p = xdr_encode_hyper(p, stat->ops_completed);
>  	p = xdr_encode_hyper(p, stat->bytes_completed);
> @@ -3101,11 +3101,9 @@ ff_layout_encode_ff_layoutupdate(struct 
> xdr_stream *xdr,
>  	xdr_encode_opaque(p, fh->data, fh->size);
>  	/* ff_io_latency4 read */
>  	spin_lock(&dss_info->lock);
> -	ff_layout_encode_io_latency(xdr,
> -				    &dss_info->read_stat.io_stat);
> +	ff_layout_encode_io_latency(xdr, &dss_info->read_stat);
>  	/* ff_io_latency4 write */
> -	ff_layout_encode_io_latency(xdr,
> -				    &dss_info->write_stat.io_stat);
> +	ff_layout_encode_io_latency(xdr, &dss_info->write_stat);
>  	spin_unlock(&dss_info->lock);
>  	/* nfstime4 */
>  	ff_layout_encode_nfstime(xdr,
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h 
> b/fs/nfs/flexfilelayout/flexfilelayout.h
> index b0653a652d3b8..23f665fef4985 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.h
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.h
> @@ -55,7 +55,6 @@ struct nfs4_ff_layout_ds_err {
>  };
> 
>  struct nfs4_ff_io_stat {
> -	__u64				ops_requested;
>  	__u64				bytes_requested;
>  	__u64				ops_completed;
>  	__u64				bytes_completed;
> @@ -78,6 +77,24 @@ struct nfs4_ff_layoutstat {
>  	struct nfs4_ff_busy_timer busy_timer;
>  };
> 
> +/*
> + * ffil_ops_requested is not stored.  An op is in flight from the moment it is
> + * counted as requested until it is counted as completed, so
> + *
> + *	ops_requested == ops_completed + ops_in_flight
> + *
> + * holds by construction; see nfs4_ff_layoutstat_start_io() and
> + * nfs4_ff_layoutstat_end_io(), which maintain both halves together.
> + *
> + * Caller must hold the lock guarding this nfs4_ff_layoutstat.

This comment could be cut down too, and leave the one note about
holding the lock.

Otherwise, this is a nice cleanup!

Thanks,
Anna

> + */
> +static inline __u64
> +nfs4_ff_ops_requested(const struct nfs4_ff_layoutstat *layoutstat)
> +{
> +	return layoutstat->io_stat.ops_completed +
> +	       layoutstat->busy_timer.ops_in_flight;
> +}
> +
>  struct nfs4_ff_layout_mirror;
> 
>  struct nfs4_ff_layout_ds_stripe {
> -- 
> 2.52.0

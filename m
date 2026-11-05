Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793914059;
	b=fglcfkUB5xifSpZJoYdI9pslZzfgZIqP1KSP1XisXxsyUrsua4XB6w7eIVc8vtey2hv3
	 N/nNIvz9gdTdoVTurLcPu5317qDd9OAn9HnCMCtlQGllJYBQXA0ueAIxW9lldJqCW2WNA
	 88GG9wbrkunnTVv34wuiyxmqNJE6GVeuSWIfRXZOiusfftMFni83j+Nn4zuq/fwf+1l3G
	 B4W+YV6W31jEMu7PNQIAPugcBhF4feMMazwt+asBUvMoP4BNe03PEq9t/eFMbS1CWegMg
	 IeFTZXp6UIMJ2VP198wzxSHVy5esX1LVCxSfPMXXkxptTtVEs/DgvutiscEusOe081A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793914059;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=/43GDL06nu28877nsn6GPnInacjA21UTWPyT4M3fu28=;
	b=Xlp3a+7namNgW72kbJ6DH/Sw8XEX30RGo9vRrwexwxJ/mqHMNamKjk8F9g2rcg7tDp0Q
	 Ojkw60ZMQiL/6Qq6T3lbYbTnHboE67jDVMtDCGPFZm1th9jRGrt5zZh1CeOnVjPh9YVNu
	 K3UxyIZonvqDDi4MKfICZ0r2wEu0lxryovrZQHO0PpAJ8e8GbSgM/Pq1ku2tdhXppBSZt
	 ynHlCML+Nh4HsD1cBLrkaspJ1IALgFLNUVQ3/Ej83GgFXLCM6L89dkaIvyMLeG5aRoocO
	 ESFwa3zSKTDe4UVYWqH7Mx8maP72kwafNVtwyipH9fMayBcCToZfs94jOKQ9ulkKY8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=okewdbaA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8492D606A32D
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 21:27:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=okewdbaA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D022E1F0089F;
	Thu,  5 Nov 2026 21:27:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793914059;
	bh=/43GDL06nu28877nsn6GPnInacjA21UTWPyT4M3fu28=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=okewdbaAuCzg9M7h++x2ftnfBI/GWS/oc7Kp65zWaXCH8n0g90fc7/J4ec2xPiXG6
	 3vGGuVC0fAe4UYoZZgiX3h1NVN7SmUmHMhfdLLUKlL/ZCYQFJFoWURf0lfAHrK4n70
	 Q/x9u6OMp74Gn+0MnAlYs8evKz8aZODXI6tmztLF4dZJKmeG4Q7y9GKCb5Cglj6BXO
	 Ro+8VvMuzSJikChPSiz0d0jda8yVPfwVqplpEmHv2uCn1zlnw3f/RydnX67K2FQVZ7
	 R/+GGsCS1Rxk8xWc9D8YjU7uEbiyOcztdalF8aHt0H/bviqRAgM1Wgr47Hdl5hkTlj
	 PiK3gqU59Jbaw==
Date: Thu, 5 Nov 2026 16:27:38 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: Re: [PATCH 04/11] NFSv4/flexfiles: make dss_info->start_time
 write-once
Message-ID: <auz0yhZstrpx2O4l@kernel.org>
References: <20261102191109.13470-1-snitzer@kernel.org>
 <20261102191109.13470-5-snitzer@kernel.org>
 <2e7ab5bd-11dc-4b02-827f-7a4983f755c0@app.fastmail.com>
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
In-Reply-To: <2e7ab5bd-11dc-4b02-827f-7a4983f755c0@app.fastmail.com>

On Thu, Nov 05, 2026 at 11:14:10AM -0500, Anna Schumaker wrote:
> Hi MIke,
> 
> On Mon, Nov 2, 2026, at 2:11 PM, Mike Snitzer wrote:
> > From: Mike Snitzer <snitzer@hammerspace.com>
> >
> > start_time was written under the stripe lock in
> > nfs4_ff_layoutstat_start_io() and read outside it in
> > ff_layout_encode_ff_layoutupdate().  Pre-existing -- mirror->lock had the
> > same shape -- and benign, since it is a single naturally aligned 8 byte
> > value, but it is an unannotated race either way.
> 
> We can probably drop this last sentence.
> 
> >
> > The lock is the wrong tool for it.  ffl_duration is measured from this
> > stripe's first I/O, so the field is written once and read-only for the
> > rest of the stripe's life.  Say that instead: publish it with
> 
> This portion needs editing too. My brain tripped over "Say that instead"
> while reading.
> 
> > try_cmpxchg64() and let the first I/O win, and read it with READ_ONCE().
> > Only the first I/O to a stripe pays the read-modify-write; every one
> > after it short circuits on the READ_ONCE().
> 
> This sentence is just rewording the previous sentence.

Sorry, I will review all commit headers and code comments.
 
> >
> > ffl->last_report_time two lines away is already published this way, so
> > the pattern is not new to this file.
> >
> > This also stops start_time depending on there being exactly one lock per
> > stripe, which a later patch changes.
> >
> > Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
> > ---
> >  fs/nfs/flexfilelayout/flexfilelayout.c | 21 ++++++++++++++++++---
> >  fs/nfs/flexfilelayout/flexfilelayout.h |  3 ++-
> >  2 files changed, 20 insertions(+), 4 deletions(-)
> >
> > diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c 
> > b/fs/nfs/flexfilelayout/flexfilelayout.c
> > index 7fc1369df8439..7c328f2ec900d 100644
> > --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> > +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> > @@ -729,6 +729,22 @@ nfs4_ff_end_busy_timer(struct nfs4_ff_busy_timer 
> > *timer, ktime_t now)
> >  	return ktime_sub(now, start);
> >  }
> > 
> > +/*
> > + * ffl_duration is measured from this stripe's first I/O, so 
> > start_time is
> > + * written once and read-only for the rest of the stripe's life.  
> > Publish it
> > + * with a cmpxchg and let the first I/O win, rather than depending on 
> > a lock
> > + * that every reader would then have to take.
> > + */
> > +static void
> > +nfs4_ff_layoutstat_set_start_time(struct nfs4_ff_layout_ds_stripe 
> > *dss_info,
> > +				  ktime_t now)
> > +{
> > +	ktime_t unset = 0;
> > +
> > +	if (!READ_ONCE(dss_info->start_time))
> > +		try_cmpxchg64(&dss_info->start_time, &unset, now);
> 
> I have the same atomic64_try_cmpxchg() question as in patch 1 here.

Right, I noted that in my reply to patch 1.  I don't think its
something to be overly concerned about.  Given the use of ktime_t
(s64) it really is the more appropriate interface AFAICT.

Happy to take instruction from others on this though!

Thanks,
Mike

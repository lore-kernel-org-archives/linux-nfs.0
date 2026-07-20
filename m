Received: from mail-pl1-f173.google.com (mail-pl1-f173.google.com [209.85.214.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9784E42A7B8
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 14:24:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557498; cv=none; b=F0Gd8nUJhqKPT9X/WXISCO83/JPslihaOkhX/JJjZylyZFnyA/mIeaIjVi1Rcn5+PcvbjAiXIMHRsRsuaJ3ngaXDCD8xcGKS4xAecyRVha3srdPN2AYnecz4eszXaPFtV/mZgpqkuS8L93gfYeEMJFEiFMi14R/ONH3h0Uzy+5k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557498; c=relaxed/simple;
	bh=5YOz07pqrRzHc/y5gK+zPeW+ZinkUbIdk5AyTHFzBQQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fTrhHKG7JG46wX+AFBYjN2FkcOlQDWA5CFkarGnnlUaKyZIq3kdGIjOqcWcSwyqwlcXAkt8CqQzo3GStnVih8quE6KnTWeihikLwn7RNT+66UpExZzcEPCiuxz4nUz4SBBF3TI8itXYALfg9k26Oey8KeNXD8OtCAd2bHhrpqZg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=eyYrC7qL; arc=none smtp.client-ip=209.85.214.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="eyYrC7qL"
Received: by mail-pl1-f173.google.com with SMTP id d9443c01a7336-2ccdf36f63dso360685ad.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 07:24:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784557496; x=1785162296; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=8cwKQpI83P5FqESUgzNcjIOqIVaxCRz594tRNYraCzw=;
        b=eyYrC7qLGTAnFMKsv6ZcinzzifSSJUnqW8Llm7a114KjX2qM2U0pMVj4iDKzW/FC0L
         HmyLwDcFzzFhuqCts1v3b/T6+4QJaYwAEjVSlD25eAZjW/I9ZzbUfiuzPnvmWgMcpHuA
         7EV2ZKMoV1EV5hQiW1egHYlI5Y6fn9gaMJq1ECzvQeRT/DOA7JDIkap3HUcdWJow/dVy
         m1rn8k6ocpYkVzrScuTibx9W/0HpjX76Uo7PCjTRd/e38pVeIdAWN9J+pHHjxVI0YytQ
         40/0sHBM1XtVF4n01B7nQpMdPHNEIpYfbCoiJYGsBZRk7tEbFaxwjrYK29+6PB9iJqx4
         3EsA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784557496; x=1785162296;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8cwKQpI83P5FqESUgzNcjIOqIVaxCRz594tRNYraCzw=;
        b=mCcO/19zKr66fw7MFjc2lfjhsJYlgK7zUK1RBTUaKUpuRtZBFYQ7McwYGIpNOaLBey
         ldIKk8NSBRJIxq7bIs7TlkCrofr4cS0mlIj1EvcBZ318fPmHZH3RTtC58NObXM4HLzUN
         GBzaaVNGyrfw9uJvc4JUFRNBwq8td3omvd6CWPqBIjuW5LGeqchJ08QpLkFoOhfe14do
         AOrnYiwD723V4Px2Wx95MlJ9NqBB4kyvfrC7fNxyAUIygXakkRL5dIN5HmCvDre26hdJ
         SVQBjRU8dVGC2BgXHw1IX70cluueFlOBQbG34aaPi6WLCa8ziXXZM0HLJNSZhESZJoU1
         3R/Q==
X-Forwarded-Encrypted: i=1; AHgh+Rqy9ak6O44v2Hv1PUdk1fMnXM+nXClwAC3P7USXpnP/eg7iYzVSnJJsdkdgwVljRXa4LFc3Gj3WjPo=@vger.kernel.org
X-Gm-Message-State: AOJu0Yzk7b9bbDuzZii54kGOcg0QIQiG4OE1+OEF1BXv86Tb6qbbCdo4
	ycfp9mxBOC6jN6UKOYs4zbm66xT9CGX1g/DigB1aKZale3oeLsvMR6o1RBVkoGkT7g==
X-Gm-Gg: AR+sD11PlAvNcR1QezPiNUOxyjYCYlesl92/QGFEueWfPYGQhZ53A03IcCenRI5OA9C
	6TP3WtTO6CEWtKjCtd3yJTiRosuGuzBpFJwvupUIPLyEc32EmNc8z9myzmfNrh8Em9TKqmEQ+A1
	J6zlc4o/WGVbWAhFeR7H0TqiThwJCUytVoB7JHL0385R60Wwl0DqA9pDId15h/tDcQXocGztchu
	IhOVtvzdmmjlR5GlsGnIZd16p3EDa3neIX6vS6Yk3jvVlK+52fv0QEu2A2n9fLfdW7QpQ4uqPSN
	Pg3SNRbIFBC54I/JYyUIYaOyQqawAdx9Ey7Orwh+SK6BRp8Fj61fY/CZJIPvvDoyfRQ5Tkl5jCp
	Y58f4kWZS7azQOzlIUR5YIlNpBY13a6VifNbt2r5Od3DJOSzLNgVA02xZtvxiqJb9BAL4Eneg8l
	D0wxNjXt+o/0mop4KZ9fmiD3w0/Vx4LyKybSsZEzWj2EUBNew=
X-Received: by 2002:a17:902:ecd2:b0:2ca:bf8e:360b with SMTP id d9443c01a7336-2cf7b52947fmr768815ad.9.1784557495303;
        Mon, 20 Jul 2026 07:24:55 -0700 (PDT)
Received: from google.com (10.129.124.34.bc.googleusercontent.com. [34.124.129.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2cf34743105sm58050985ad.69.2026.07.20.07.24.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 07:24:54 -0700 (PDT)
Date: Mon, 20 Jul 2026 14:24:49 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 3/5] nfs: Introduce nfs_release_request_list helper
Message-ID: <al4vsf9ELpS9-4ed@google.com>
References: <20260715143540.3597616-1-praan@google.com>
 <20260715143540.3597616-4-praan@google.com>
 <20260720091505.GC24298@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260720091505.GC24298@lst.de>

On Mon, Jul 20, 2026 at 11:15:05AM +0200, Christoph Hellwig wrote:
> On Wed, Jul 15, 2026 at 02:35:38PM +0000, Pranjal Shrivastava wrote:
> > Introduce a centralized helper, nfs_release_request_list, to handle
> > the bulk release of nfs_page requests from a list.
> > 
> > This serves as a preparatory step for two upcoming improvements:
> > 
> >    1. Pin-Aware Cleanup: As we migrate to iov_iter_extract_* API,
> >       requests will hold pins (GUP) instead of standard references. The
> >       helper ensures that the correct unpinning logic gets applied
> >       consistently across all requests in a list.
> > 
> >    2. Folio Support: In subsequent patches where nfs_page structures
> >       will cover multi-page folios, this helper provides a clean
> >       infrastructure to unlock these larger units of I/O in bulk during
> >       completion, similat to the pattern in bio_release_pages.
> > 
> > Additionally, refactor nfs_read_sync_pgio_error() to utilize this new
> > helper.
> > 

[...]

> > +/*
> > + * nfs_release_request_list - Release a list of NFS read/write requests
> > + * @head: list of requests to release
> > + *
> > + * Removes each request from the list and drops it's refcount.
> > + */
> > +void nfs_release_request_list(struct list_head *head)
> > +{
> > +	struct nfs_page *req;
> > +
> > +	while (!list_empty(head)) {
> > +		req = nfs_list_entry(head->next);
> 
> req could/should be local here.  Or you switch to list_first_or_null,
> which some folks prefer.
> 

Ack. Made it local

> > +extern void nfs_release_request(struct nfs_page *req);
> > +extern void nfs_release_request_list(struct list_head *head);
> 
> Please drop the superflous externs for new code.
> 

Ack. Dropping the externs.

Thanks,
Praan

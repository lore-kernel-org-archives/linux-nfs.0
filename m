Received: from mail-pl1-f169.google.com (mail-pl1-f169.google.com [209.85.214.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4FBB442DA50
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 15:03:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784559824; cv=none; b=oDwlxkNBUumshtIsfuG05m8SYLnQGCy89/WvkItJuyHgkc4jhbjPWoxXFG60/berjshpBj5uS9lZzJuyIBTCV2xkHvlHLXWbpgbGu4aYSoyuBK0YYv2lwXz0qD4dhGCsgpAEOrU8XFfI5Y7VU03/cEQeaOXvCgBydX+ooJGqQOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784559824; c=relaxed/simple;
	bh=kHyVi1X3653L6/E5eJCh0+Evt8DBGh0gAuSqsbK/2lM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=EtICNczwrTCA/mggqya0PXnDFzxiMOBA2SidAY1mB3DaOlko3YsZst9aLmZurnTgh4VrP1ndrJzNK+cj1ky/GkGsir/R8RYz0AU//tVSdFst6gvUFfnl4yOtuco16lDYCAvgroYrtHpi+zj1i9fq1LXVH+ppUQf6IjA9dEKPj8k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=vBkAKj9u; arc=none smtp.client-ip=209.85.214.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vBkAKj9u"
Received: by mail-pl1-f169.google.com with SMTP id d9443c01a7336-2ccdf36f63dso369065ad.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 08:03:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784559823; x=1785164623; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=CoUBDaPFGXQM1OhLmt0HKzfSrSapevvomHz56sEIB6c=;
        b=vBkAKj9uc97Me0T5IuGYQLGDvd6DAhvyfWojJI0ER2sJ9ut7nI2wWOrc+ryURpszos
         zaGod0RXx18PIDyS27B6z9OdW4x4EoQldGVwcSxFPpgWWuWg3dEmvdgB3Ki9iw6Nc4t8
         6z9gDCUpinNU/Kcl2h3gvqY9xzvRIsHHtAxuWI6BCJejnHL3KdU1qpXp3h2huju4y+/T
         Z8ikJDz+0k3Vmhy1txNoMcXnhNm0JvQQaTyAxDUmYePxNuPkW1csm1pN15FtFD4PxIyv
         v+AmB+fnOG9Dtn9LtxMwgqy0kiMEUsz8lYFZ9GgIUa8JNFMfWAJS+o+DRNU20mKUswDd
         05jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784559823; x=1785164623;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=CoUBDaPFGXQM1OhLmt0HKzfSrSapevvomHz56sEIB6c=;
        b=JcYVWyy+fvXXsCP9S0mtKSo/IHxsf2CJGcvRlvCcwvS8JwjR/JfGuLiyRGQWn/zfIO
         vT7taGw7+xIXKTcBnFJ5PKIKVuAIHlpGxDH04MM7j8FQzEoGDmJ9QRcL1tXnLgV3H9RZ
         x4Y3RhjPqqlz/EVbvY2UjmfrmELpOTkrb+YIXyHYybxNHeluf3WaYX/SVXKWo96b7aFe
         61YLIpH/zNEniANqpsQK/2AK0mnilu8KooHuIpQ7iTRMKTTiiIfgdgShOiGaLj9Yhkmw
         T4XXrJ10rzVyvAbzMieYjcenqa0TrH6+R/YSMxJ8jCXFumdMJcLNUlMlYj+Rt4uUGs/o
         cGjg==
X-Forwarded-Encrypted: i=1; AHgh+Rq2heAJg4Ya5ZOdLuOkXVUTtrzPKcz3P/7U2VXiTZTMYA1gxBchgZD5Ie/MAmopuP+vCz184JubKXE=@vger.kernel.org
X-Gm-Message-State: AOJu0YwDfRDlcyRKiTf4hiqUQVM+gLHRLA9nVNNqr2K0uDIN8Uxjo4Gz
	JXpxNa4UjUOZB9ptqtYeJ21gqXcmGVPnz231mFVcsv+1pxooD2ChIuBEPARbkJlUzw==
X-Gm-Gg: AR+sD13anODGyFn6yB6kmC1qVk8P0/7Lxe+Z825M4WjLoV74QnOnVs7HZHNNNjJpqkL
	HiyHZXfCfzdacbHL++wIjbAzRFsx1L0gkAs5qA4A446sPBU3Z99JnlAO5I61XuF6I9MDWL3Ex/d
	d8hCP9mDTf2H1+yslyQIgyiKZuLs6RPPW+rl8RujZOvhdkU7ynbHnb2Aomq5MuQlg9qYET94Zla
	t7iMsGzV/tpRDGQD8LGBgl/7dicz6fi9Q+ilG6N5AfUuq5rMFEHPazZyRiUtejo8pyAmRCVjPj3
	PfcaMgA7QSvu8HGoPh2SdzvqZU3MMPpCft/S8ebEAw7KIZszVxndBv3NMV/xekdp4xu2nvQ/DQb
	zESRkRpkCawHqHhLhWPAz7HJ5gKZKIaRe85urziolu0x5YIgLQ+rl2yIcpCCw8DTEcM0VTcwdr9
	Dv/bo2ZkX8rZvQYKNrf/sBFo4yfx1ZrlWKNdSd
X-Received: by 2002:a17:903:41ce:b0:2b7:b03d:9dce with SMTP id d9443c01a7336-2cf7b68e33amr1005485ad.18.1784559822071;
        Mon, 20 Jul 2026 08:03:42 -0700 (PDT)
Received: from google.com (10.129.124.34.bc.googleusercontent.com. [34.124.129.10])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-84c2adfdfd0sm5823209b3a.25.2026.07.20.08.03.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 08:03:41 -0700 (PDT)
Date: Mon, 20 Jul 2026 15:03:35 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Shivaji Kant <shivajikant@google.com>
Cc: Christoph Hellwig <hch@lst.de>, Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3 3/5] nfs: Introduce nfs_release_request_list helper
Message-ID: <al44x6w0rr7yd8J3@google.com>
References: <20260715143540.3597616-1-praan@google.com>
 <20260715143540.3597616-4-praan@google.com>
 <20260720091505.GC24298@lst.de>
 <CAMEhMp=eHz105-t+pDLbX+6uWOPAGHWfkjd4PqTdeXmXf0tPGw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMEhMp=eHz105-t+pDLbX+6uWOPAGHWfkjd4PqTdeXmXf0tPGw@mail.gmail.com>

On Mon, Jul 20, 2026 at 03:28:09PM +0530, Shivaji Kant wrote:
> On Mon, Jul 20, 2026 at 2:45 PM Christoph Hellwig <hch@lst.de> wrote:
> >
> > On Wed, Jul 15, 2026 at 02:35:38PM +0000, Pranjal Shrivastava wrote:
> > > Introduce a centralized helper, nfs_release_request_list, to handle
> > > the bulk release of nfs_page requests from a list.
> > >
> > > This serves as a preparatory step for two upcoming improvements:
> > >
> > >    1. Pin-Aware Cleanup: As we migrate to iov_iter_extract_* API,
> > >       requests will hold pins (GUP) instead of standard references. The
> > >       helper ensures that the correct unpinning logic gets applied
> > >       consistently across all requests in a list.
> > >
> > >    2. Folio Support: In subsequent patches where nfs_page structures
> > >       will cover multi-page folios, this helper provides a clean
> > >       infrastructure to unlock these larger units of I/O in bulk during
> > >       completion, similat to the pattern in bio_release_pages.
> 
> nit: similar -> similar
> 

Ack. Fixing it,

> > > +/*
> > > + * nfs_release_request_list - Release a list of NFS read/write requests
> > > + * @head: list of requests to release
> > > + *
> > > + * Removes each request from the list and drops it's refcount.
> > > + */
> > > +void nfs_release_request_list(struct list_head *head)
> > > +{
> > > +     struct nfs_page *req;
> > > +
> > > +     while (!list_empty(head)) {
> > > +             req = nfs_list_entry(head->next);
> >
> > req could/should be local here.  Or you switch to list_first_or_null,
> > which some folks prefer.
> >
> > > +extern void nfs_release_request(struct nfs_page *req);
> > > +extern void nfs_release_request_list(struct list_head *head);
> >
> > Please drop the superflous externs for new code.
> >
> 
> Small nit + fix christoph's comment,
> else looks ok
> 
> Reviewed-by: Shivaji Kant <shivajikant@google.com>

Thanks,
Praan

Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.214.176
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793101488;
	b=CpAWABZD9BTHJQUqyhciRtU16h7jArspOFjTFHxq4ELzOZktEm0PFoUHBOyyJjSEAc6r
	 UgZ0CxS4jVoR+Uy2smAxGfUb4/xAL2Z9n3darLceccOOeYbII/77XEmbbPZ4/ZAOzouos
	 7b7MJb77b5raDVZxJEqOo/KcylW8NnbHehYG8Fjv/pIHoOzzlAKREXn06zymlf0+N3HF8
	 F7xDGVKgx9GT8kkHb+0HmH8/34pNiMT2jPNPqKfmBZU9SwzfLV5p+GvOWzjsqE4Mnxkkx
	 OvTmxN+wFOx/FAeL0kXxub35wO9QB3UtBV+9cIKcZileLOx/txQ5Z6zGw7baGVEQJMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793101488;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To;
	bh=VL6Rob804TfrBVBHD9ZWTKZw10w75nWGhTvtW+uNe1c=;
	b=kvRYj8XQDDNtSHSVflL8iMikegaQxzPsTslJt3HK4ePC659IrIqFQ02xTZeMMIlTKbfp
	 c8MdH6DGjpJd+tIeLtdwJHZIICj5YiE9z1inE5cfOowQpe0PAkUQiWgscYEAobTyL+NGK
	 ZN75NU0SejAKZ+hAz3MDmK7RRVHgyKbDmkScffJNUDnIvvrDD/NUnCaRk17ZXLZMbcfya
	 RDrWeQ0uKmk+XCvnGwIdLJkvF7jXyICs0Y1Tg0DRGO2fq03Pw3asUjOCkVamRtITx5zlS
	 MVSXchkls3yImKD7oWep7YiVPR5eL7C5/LbRRfUsoxJiUPC6ynn8x2GyG542Z9+3bJg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20251104 header.b=fyGObDqD;
	arc=none smtp.remote-ip=209.85.214.176
Received: from mail-pl1-f176.google.com (mail-pl1-f176.google.com [209.85.214.176])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AD52606A33F
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 11:44:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7AD52606A33F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20251104 header.b=fyGObDqD
Received: by mail-pl1-f176.google.com with SMTP id d9443c01a7336-2ea7f9c11e6so52115ad.0
        for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 04:44:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1793101488; x=1793706288; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=VL6Rob804TfrBVBHD9ZWTKZw10w75nWGhTvtW+uNe1c=;
        b=fyGObDqDbLqO/Eg6fI773LOjM0osLi6Bf3QOYY3PB8zZPWTCT3m3C7PrvvKAZAvuFx
         Bsafyb2OrH1UKet4PrlwS+h5K1Rdrgsr+3km9DG2Eygs1Voj7O5h4HIReUl35jqOlOB4
         81VJ7tQ37uwIMAUzxjvF82OF7mdPnk839sQuVziduDBQ2/M27numqFJLivmGUU9egkoQ
         jB3jJdujr8nUrrveC1MgTVz5J7rB0EvQ0NiLQGZ3ordXbIcRdlH+HzAXEhzayq8M2ozQ
         2c9ibvJdhOioz++BbcbQ2TVg0a79wE6bszyEdGB+2vmCgbP+HYIxQuOFxyAk0L3/nvUJ
         /azQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793101488; x=1793706288;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=VL6Rob804TfrBVBHD9ZWTKZw10w75nWGhTvtW+uNe1c=;
        b=DaUnbBMS/zJYzfT4Eva4AjSoYsJmTGr/X23EYs4YuXdTyTx8ya5GhjzrVd9I41j72e
         cSTYi85vujuxpbSpOznI3dbd5e9ZY1Vgrb8+1P98vPJ4HMBq2FE+jHoVUCP5aRVN7iA8
         mVZFmDnm8EJZHB9x6h7f4R0r/Hn3Ji91ctWigLR8ooVSzsnh5aUe68JEtrm85cYbrYez
         ie+FmhDfY2EPYOX7yL2IgN+hKh/RxZEgtDVHHZrO5RNZCPalzM+ar7EtpRV8OQ4JLZHw
         IgCVDATCJSHJb/2y73vgFQ1+M5OZiNgH2qiI6SpJTzbrz8JGU/syPKiP7bVGFY7Za1+i
         E+bw==
X-Forwarded-Encrypted: i=1; AKwUvBx8pdsJ9yvDAoUdRsFUeEb9wzLnwkrmYvCqu1jNAPwgdtmZnyuv3su9MLqM7wVQjfLNfI3a7opJRcM=@vger.kernel.org
X-Gm-Message-State: AFq9FYJ6gMzhHVquozzuPLEp8B4c6azfaCrukJ8n+YL6QoXSucOBJYem
	suKpSQHR5FI7/SnxFXJNGiOB/lonsSHhD2yzcHtDmdsisEXAgrOWHK87AZCJAEVZ8g==
X-Gm-Gg: AYBFou0iwF+rVRbsk78UGSsqaNmjhf2k8BYUejK9QN6R9ZBWOVvNFYCaV2OIy+wVeA2
	KIYOLjRigR1SymfM+eszpleQ/92xv6FdfE2iu5RMCilq0h7OOP660nCIe8dutQw2TieZApIZkIq
	UpzCslVrNyq3DhbmJMMPOJmFRWewPaKr27wfvA80J/UlmoMY10tHPWIL+W4ciTmHO2b3L7BTpaQ
	qHBfT+BS9LDjxUeaYM3eJk+/wH02dm+OPDAjICUsmX4kgW57dYM/aHe33g7Zj5FMF1Fqsj52+BD
	tYlZzH95Q0BLDxwT8d7UsJ+/maMHiCoETgoFVZE2pfd7NfiNGxlphqdn5f0A0o3Yh220a8WGpxz
	cHHrf7gESIjTqdoqzqevFhrL8TZCDWFEFetyYjPE9xU6gCoDLPzcZhnHZzsFFg5QBxHQ+c1XgNw
	/p7q3fgWpFoOxCB1YdppRUdIm71hHZS/18uWsr5lig0XG556QNpHtyuaKYYCPJsMEFJkkeUDJ0d
	kaXVz9fUGBm2CW4edivyJql/c0pxfUHFVD8bEdbZwhPOYMHYGHlkO+bon5Ww6l6z11kqTwLEq/J
	Un68yOIRHidPKx4IPA==
X-Received: by 2002:a17:903:32d2:b0:2c9:d89f:fd98 with SMTP id d9443c01a7336-2eae52ae155mr4517745ad.1.1793101487114;
        Tue, 27 Oct 2026 04:44:47 -0700 (PDT)
Received: from google.com (105.211.142.34.bc.googleusercontent.com. [34.142.211.105])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-cd8ccc90d74sm2571152a12.20.2026.10.27.04.44.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 27 Oct 2026 04:44:46 -0700 (PDT)
Date: Tue, 27 Oct 2026 11:44:39 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Leon Romanovsky <leon@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>, linux-nfs@vger.kernel.org,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org, Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>,
	Tom Talpey <tom@talpey.com>,
	Unnati Sachan <unnatisachan@google.com>
Subject: Re: [RFC PATCH v1 5/8] nfs: tag READ/WRITE RPCs carrying P2PDMA pages
Message-ID: <auCOp5jphqwPX2BQ@google.com>
References: <20261006233248.705086-1-praan@google.com>
 <20261006233248.705086-6-praan@google.com>
 <20261012071020.GH27033@unreal>
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
In-Reply-To: <20261012071020.GH27033@unreal>

On Mon, Oct 12, 2026 at 10:10:20AM +0300, Leon Romanovsky wrote:
> On Tue, Oct 06, 2026 at 11:32:45PM +0000, Pranjal Shrivastava wrote:
> > A transport must know when an RPC's payload pages are P2PDMA memory,
> > so it can move them by DMA or refuse the RPC.
> > 
> > Check each page as nfs_generic_pgio() builds the page array, and
> > record the result in nfs_pgio_args. The READ and WRITE encoders of
> > every NFS version then set XDRBUF_P2PDMA on the buffer holding the
> > payload.
> > 
> > Additionally, avoid using READ_PLUS when the pages are P2PDMA memory.
> > 
> > Signed-off-by: Pranjal Shrivastava <praan@google.com>
> > ---
> >  fs/nfs/nfs2xdr.c        | 4 ++++
> >  fs/nfs/nfs3xdr.c        | 4 ++++
> >  fs/nfs/nfs4proc.c       | 3 +++
> >  fs/nfs/nfs4xdr.c        | 4 ++++
> >  fs/nfs/pagelist.c       | 2 ++
> >  include/linux/nfs_xdr.h | 1 +
> >  6 files changed, 18 insertions(+)
> 
> <...>
> 
> > +++ b/fs/nfs/pagelist.c
> > @@ -970,6 +970,8 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
> >  				if (pageused > pagecount)
> >  					goto full;
> >  				*pages++ = last_page = page;
> > +				if (is_pci_p2pdma_page(page))
> > +					hdr->args.p2pdma = true;
> 
> Should we allow wider use of is_pci_p2pdma_page()? Does NFS require
> `struct page`?
>

Hi Leon,

Yes. NFS O_DIRECT is page based today, and the Direct I/O series [1]
just moved it from get_page() references to FOLL_PIN pins through
iov_iter_extract_pages(), which is what DMA into user pages requires.

This series lets P2PDMA pages through the existing path, and
is_pci_p2pdma_page() is how NFS tells which RPCs carry them, the same
way the block layer does for bios.

I'm aware of Pavel's dma-buf I/O work [2], which Jens has queued for
7.4. The hook is a file operation, but the only implementation so far
is the raw block device on NVMe, where the block driver owns the
dma-buf mapping. It's also exposed through io_uring registered
buffers, while this series serves plain O_DIRECT on user buffers.

Since NFS isn't block based & its I/O goes via SUNRPC to the transport,
taking a dma-buf map instead of pages would mean reworking the NFS I/O
path end to end, which is a large + separate effort that I'm happy
to look into after this series.

Thanks,
Praan

[1] https://lore.kernel.org/all/20260814143255.861084-1-praan@google.com/
[2] https://lore.kernel.org/all/cover.1791975048.git.asml.silence@gmail.com/

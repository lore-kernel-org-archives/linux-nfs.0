Received: from mail-pl1-f170.google.com (mail-pl1-f170.google.com [209.85.214.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FC323B38A9
	for <linux-nfs@vger.kernel.org>; Thu,  9 Jul 2026 06:19:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783577960; cv=none; b=hRme9LGBnSRZJags+53sPur08j52RnyPLL/h/nOGvqHOJCSTcLx0D36CpYDmyMulJORjHdYpP4TKs/IbAjedc2aFdz2y69o7oWsxhndCMim5C7VWq7unWQfVem4QCgzWTic9SDiWqGcmpQfZ3k5cYyeZnP5AbCCURBwArwBUzHw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783577960; c=relaxed/simple;
	bh=ZGwIsrqjg3x5F2mnz6g66MzYCqQwBZkm250mDjNhtGo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WQgM3/maGHIyJMvvWs4SA6odnWEOgY8Ee3vKKrmQ6WeHrAE2+v/lwpAJyfongWCK4SrOnexbADP9C3GYGGGpsIQqr1MWjZbxIhjjANU4MQnugUFuissUtNCW1CytGkJoS3QVRj++QOHxO2opvzVhZPqk6xyJIsV8lyUnVUC64a0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=AXMn+ukf; arc=none smtp.client-ip=209.85.214.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="AXMn+ukf"
Received: by mail-pl1-f170.google.com with SMTP id d9443c01a7336-2cab97c86bdso48625ad.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2026 23:19:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1783577959; x=1784182759; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=sVwokARvELpibyxJ1Yufay2/9dNo2BXnunlPaasxpXQ=;
        b=AXMn+ukffNCxA4rzCPiRdVjePE1UP0iq+wvZ0tcM+0konhgXOIuZRvLmCjtUr/ViTN
         Z0yVhZDgwQzHmuGzYhbyduNckl8ZS48MF40zQ2Utb9/xlEJhvEBHz8ni3OQAivuYO6xL
         BPOHqB60K2CZ41hE0sB+r0hBTPiefaCpkPDFNn+NQQrS39fYmnMrzHGjff8pZjxzwtKr
         NgXP19a82/xxTkcO8My8V1PossmrgC0BW9i2gWTMm8iu34WGDuTOvONUI6OGc03VYDIr
         rKnrL6CPdcj5+klPy/eD+2Dr1hnEXS1P/DrYRg10mahOODF+Fur1p2rdtkrSDyRfE+sp
         SZ2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1783577959; x=1784182759;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=sVwokARvELpibyxJ1Yufay2/9dNo2BXnunlPaasxpXQ=;
        b=isHWDgVQ0KN3BSndiFXHN10J18wNFtA+iuE2UZBU/CZTrhxiVUXqXtkMhglVzfyQf0
         4d3gE0VXwbYZ9Lh/IimYZhmTV4mZcfaLEZQVnRw9UrPJ8/Aa2y9y+Nhxi66sZm2WOUm4
         7GVCRrwkl5rZvAw5sQImY+rLXfxSY5U3szgRUyWEi4g5ByrV0vdw/t9lmvt0XhCWMD0g
         XlvRcPorZGhIRKWCWw/rTDgYJo01SoHUfzyzsGZnNEpA9a3aGPJWnO+8Y3LjqbaJuLwT
         r+HKV8G76fzHNycRlgCnNeDad5zPFE7DwopBB8RCqemmNGS6Kj2N/GilyzWcnsmZi87N
         6xug==
X-Forwarded-Encrypted: i=1; AHgh+RrGqBBuoSL6f7IjGoqfrlrrdtQFaOxKEAIKh+Nhr7CzBOrA1n90bzE/ue5lBtnE15D3VvcxKq+GRAg=@vger.kernel.org
X-Gm-Message-State: AOJu0YzFZjpdU2nKRn5hCcpjZvTxuqLowwSdGBqR4T3ALVtG4oVrsC2H
	zcJwmJUwmok6BWGMUqXefwKlPQbrAotP839jXkjFZ0ZQXdd0eMO7o1wyIvm2AiSSVA==
X-Gm-Gg: AfdE7ckuqrJkTqjuWf4L9syuvuayO2XAbLSzGq78nkA+s8ioRh2Gt1PBq62bgjv/F+0
	LX5iNr88GAMj2kNT3F+9OYgk7ecFR4PvCLfBitKNbKmAkbIReOEHrGBCRG2BI1iE/hvjPMqAaTl
	gLcvMXv7Vfj8u0SVX6B8jsUS2fTYIHUVNL6fExrg32zBzMVr0hjw+mxPj35fZM5fz3WKIq3Cjtt
	X/y2rTfZi4dlIiLBnuz4vThgTFijD5FhDVNwVmzHmLPzlBXcwic3e6WInshFQ4E2dIZJjejR/7k
	lEMYhIpL1qjaymWc0ZIAvRqU5fnbvRZuG9e0RrP0lrp8/NO5AfawWX8ifGGVafKysPTAioxtoD5
	PE1rEzU3Bp7g1+IsiKmhZbbkfAU8oCaojM7NSVpLQL3ugZtOB1ByNqYvbiQjMDEoDsLy+0qR/A8
	Cq1CO4vq7Y9gmNtm2xpSmHEOnL+t+J0HcKpHz5xkavob2aHEg=
X-Received: by 2002:a17:903:3d10:b0:2ca:ed25:9c2f with SMTP id d9443c01a7336-2cd57365bfbmr1755705ad.16.1783577958430;
        Wed, 08 Jul 2026 23:19:18 -0700 (PDT)
Received: from google.com (10.129.124.34.bc.googleusercontent.com. [34.124.129.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-38a5574ca88sm593811a91.7.2026.07.08.23.19.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Jul 2026 23:19:17 -0700 (PDT)
Date: Thu, 9 Jul 2026 06:19:12 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>,
	Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, Anna Schumaker <anna@kernel.org>,
	Shivaji Kant <shivajikant@google.com>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 6/7] nfs: Optimize direct I/O to use folios for
 requests
Message-ID: <ak89YF6BS-iYf_e_@google.com>
References: <7ee3bcfdd6126c93cbb1c219bf601182b95c10d9.camel@kernel.org>
 <ajGGpDvzZdkGtSbN@google.com>
 <ajP8ZTTLYkICFTO_@infradead.org>
 <ajQ21kH1ZVajS2Y7@casper.infradead.org>
 <aj4iiD5C_yyLeb3U@infradead.org>
 <akevQfFVteCOD6LM@google.com>
 <akfAgy52s_Gch2KG@infradead.org>
 <akzsO_vmYX_7Umjd@google.com>
 <ak4A6IEmWNi27I2d@infradead.org>
 <ak44z-X-SKKhkBkg@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ak44z-X-SKKhkBkg@google.com>

On Wed, Jul 08, 2026 at 11:47:27AM +0000, Pranjal Shrivastava wrote:
> On Wed, Jul 08, 2026 at 12:48:56AM -0700, Christoph Hellwig wrote:
> > On Tue, Jul 07, 2026 at 12:08:27PM +0000, Pranjal Shrivastava wrote:
> > > Ack. I see! Thanks!
> > > 
> > > Regarding the page_folio impasse, how do you suggest we proceed? Should
> > > I expose and use get_contig_folio_len() from bvec? Or should I move the
> > > NFS helper into the iov_iter lib? (or both).
> > 
> > Sounds like the best way forward for now.
> 
> Ack. I'll reuse get_contig_folio len and move the nfs extractor to
> iov_iter for v3.
> 

On a second thought, I guess I'd try taking a stab at writing
iov_iter_extract_folios and handle the vmalloc / slab cases for kvecs. 
I believe that would be the right way to go, unless I'm missing
something obvious? Can I take a stab at it in the next version?

Thanks,
Praan

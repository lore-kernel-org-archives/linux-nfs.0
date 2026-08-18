Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 666CF382374
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 23:13:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787094784; cv=none; b=iKe12XxqFR0Zidvk6hKAkstFo1ikw9UCIH33CE1pWu7jA0mJVrUD6dLODx6USL54Tfg/snBIx5b9ek8qm18HcbnVGaAu2uMjXi+vtCCIgF7IVlot9kPyIF+SkS2OOfkTbbCs8gkJ7zUqzVhZ1q1kvvILxAHv9zppIW1bkK45Oi0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787094784; c=relaxed/simple;
	bh=BDiZlLn8yUL0AzMbSy744NQt1DJWi5GQp0INu5IQ1nA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Wi5/p95T3/ZW138zSLnKULBRNXx/Gg66tBR95MygakMgdlLrHzzGM7BB97WwcbEA3XW9g967DeLTQkvrKXTzdlKt9+irUjrzzTh0S2IdGsdeSmPDkYYD2shN3PKPaE7GUzLdl3x8PzsaDfw0b0ONxroFKHg2/YQC7m5TJNO9IG4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=hzwWDv2p; arc=none smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="hzwWDv2p"
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-4921eed3fa2so4136945e9.0
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 16:13:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787094780; x=1787699580; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=DQXxaPCZrLuCK5ASFGi0NLQ4bTPXAiPZ09vFv9q88/c=;
        b=hzwWDv2p9X38SKTFyUQvtB5VFvmYDzzMD3tpJUp6hXMZTCivN0eEHKfmxV/tkoWxl/
         orG9Wn5ltzsiazs8tkdmdhINLUyLIZYlmH8jqY2vnoTRtWCMeDxqzuxCoEVT5p1HE/kE
         WbPSl04CGnWR9KoeAx4nikCOOigGxZZkzoAvYh5YKrRloWuebS8NG1bw2zdfU0CcxM3q
         4AvKwRrMCgS0neAvbcU7Mce+KCY4qLbTDsGRzquF4RYR0O4KtsEhBSaf5g3meK67FCQ9
         Vwy5lLPxE4Ey5Di6HwA8X2FkojTHjSNZp1hRRGEcYXOg/frE0EqfX82CL9CL4xhhWvtW
         N1pw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787094780; x=1787699580;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=DQXxaPCZrLuCK5ASFGi0NLQ4bTPXAiPZ09vFv9q88/c=;
        b=osZiVF+/IWJjSDYpVgZchQCH7GRmXYRxEkRIX9CKgr8r+yKdruECBS7nxwx1KmBbCq
         8CKWoqxheEgnplXbCmwIYFMx8ahX+qd98sV3BjuMswp9pYF3NXYJxqziUfqTrYz/0EDx
         2VJYMMHnqEtVMYrVtMEgWsDyefxbLfepYwCybe/11GGeFmzC1kTwgUBEafEMuMuUclMR
         xClzp39illt/4SiTuBoQBz1frrKuofbvL0Yv+BndSGC3mXgG6YvzEC/hVT0W3tX1djIf
         QVxg1Ajlsv0NULvFmrXj6v9H1QA/xDQwTUcp58n61ev4HxRYG5BEx6/SivZhjz/XjVNI
         dmcw==
X-Forwarded-Encrypted: i=1; AHgh+Rp5uDu1g6vK3ti38Zz1Rnhr+I6JGpN6zTIavigDAzMvG2F8wm4hi9aAyqIx4IoTSSwC1O3N0m/BFVs=@vger.kernel.org
X-Gm-Message-State: AOJu0YyQCLOWVlmb+2dBH/kr19CCqahgarZDDEtZw/OiYgQY+UqclIKQ
	vDwaffKCde2vdXmQWa5FqUSZ3x+YRFDzBTQeOHFnjYRfx5exqLMFkUTFOPa07wSmqQ==
X-Gm-Gg: AR+sD12hiBwjIv9ntoGawGxekOQ9fMC434lQmQm6w7UpvGN/rCKx1/xDq69nZPQXf+E
	958qdYChHHGXykDk/7+hwanGY/tSxLwWy1ljpvmxieiyelNib+voSU+f4nTFQaHe7OF9ST5dSMN
	lVclvvDRWAGMBA9piMlKppwF/rDn9ZTj816EwP9gXHR36adQxNvnmyjdUnJ4KsFV8TpX0WCE9PY
	7AblLv6rTIY7JyqRJZB+VxHVz+ZqWywlDRHNbS0x2Q3HUkmEoACFkft2De505drKx9mJqduykkF
	6lbOj0qPdPbvKaVRPKyfk5iLCk9uDpWdhg/ikEkEGUJ5CzQJxTWhlWb+487wVL6iAeM7237ymXj
	UAF3VteAaSyZH+EpaTL35aCUE/z00j2x/X4CAKsAqXF5sXaGoBdxx9ABzq6mQXSmaEmv2XWEkBp
	Q1Ge629KufWZQoAsD8S1DKrDD7Gb6fRwZ6u5x7VRDx
X-Received: by 2002:a05:600c:6748:b0:497:fecd:5b00 with SMTP id 5b1f17b1804b1-499aa1d0670mr7992845e9.9.1787094780484;
        Tue, 18 Aug 2026 16:13:00 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482b1450acdsm731812f8f.9.2026.08.18.16.12.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 16:12:59 -0700 (PDT)
Date: Wed, 19 Aug 2026 04:12:55 +0500
From: Ameer Hamza <ameer.hamza@truenas.com>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, alexander.motin@truenas.com, caleb.stjohn@truenas.com
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not
 zero-copy
Message-ID: <aoTmC-jhOLD6F4gY@hamza-PC>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
 <20260817210811.3984663-2-ameer.hamza@truenas.com>
 <2ed0ee16-c20e-44bd-9e7a-f5b71764f14f@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ed0ee16-c20e-44bd-9e7a-f5b71764f14f@app.fastmail.com>

On Tue, Aug 18, 2026 at 09:55:56AM -0400, Chuck Lever wrote:
> Hi Ameer -
> 
> First off, thanks for posting the full series to provide good
> context for your problem statement. Contention in the page
> allocator is vexing, and is a problem we've been chasing for
> years.
> 
> There is a lot to unpack. I'm going to focus on patch 1/2 and
> set 2/2 aside for the moment. I promise we will come back to it.

[ ... ]

> So what I'd like you to do is provide a backportable fix that applies
> before your series to address the fsnotify and atime accounting issues.
> I'm not convinced that stable will want the bulk of the 1/2 changes as
> you have them here.
> 
> I don't expect this work will be a heavy lift, but let me know if it
> turns into one.

Thanks, both issues were real. Fixes posted:

  https://lore.kernel.org/linux-nfs/20260818225715.572140-1-ameer.hamza@truenas.com/
  https://lore.kernel.org/linux-nfs/20260818225715.572140-2-ameer.hamza@truenas.com/

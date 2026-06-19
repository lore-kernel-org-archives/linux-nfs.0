Received: from mail-pl1-f176.google.com (mail-pl1-f176.google.com [209.85.214.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 877593803D2
	for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 11:50:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781869821; cv=none; b=EultXn+N+qFFds3n0zSGSpmRUb9VibA2B/mI8FPnijNIuSER4WuU/WvsIHvaRPCb3U0tenDgBCoRhAvBzkPQJrpd9lMlCV+K2k1qMlQJy24SgLOXtxSNwQn0Hnv+d7C1Ow/SZuMCUIiiI5MK1SMObvbYnC/l0A2hYulhVyWF5Ms=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781869821; c=relaxed/simple;
	bh=CGgYKgZQvNQ+VGIt4WFVSP/rCPlZ/Tdt8Cwy+BWzBg0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FU5fUkBLb0SWnbiXAmX7dP6XFVQMffho5u8WFoKV135dG3/SL3STvvpTr2F4vafOm8mGFM3ZniLZ9UPIw7/1wgDpYbOpCQb87nj25Zs9AnSoxwdW8bQXa7mLppZhAbwETgNOTrdEgFD+0KOtCNIoZLuMnc4y0OqqzQGe4Fo2Z9I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=ZoRiHdPN; arc=none smtp.client-ip=209.85.214.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZoRiHdPN"
Received: by mail-pl1-f176.google.com with SMTP id d9443c01a7336-2c6b7bd4e8dso45175ad.0
        for <linux-nfs@vger.kernel.org>; Fri, 19 Jun 2026 04:50:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1781869820; x=1782474620; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Wi5/IAnFRvmM2957wAfYHVgEEe7a4uv0m6a3wgn8qvM=;
        b=ZoRiHdPNY8JpUnuoeDAaujnqInk/fBPxRm1T0AcdZ/pbVWqjKdsX0KiUaZzklKmrKv
         REwkmguRLBKqBJPJD69QM7ib/pX55jVJPi9EIs6d7XbVS2O3wz8nybx4TGvqENn2wbMP
         sDtsZLF55iAb5HwxhzQsNOqlyacijEGrcYbp6lsLEXECUfDhysbWKPnBaIJQeCvV6ej4
         N883oeyJGAIGV3fdgDO4FdnnU9crgGYfmLQlm3RI9OywyMy0YakCylg3hFTgLybxDZKG
         OTZi/YgxE+YvcZUGQftGpT3ezSaTre6BABXy2117QaSUNbhDF2PJjedE+j20g4h/082e
         hvVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1781869820; x=1782474620;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Wi5/IAnFRvmM2957wAfYHVgEEe7a4uv0m6a3wgn8qvM=;
        b=e1HDG8F/FrDh85EQEWqS0w7FiGRhCUgjMptL0O+xx/76dy5/F3jCibTHjClRybTYRA
         eb/BeEE/ECiIE77rtuAR7fZTCnZmCFMSAGjBVqHufXCJRLM3xHOhgS2yUboCaeBcup0Q
         WVE2CNejWR9vhknRYmShxfSFJpt9Go+eRm7K+9b1YSysocSIGtHVBemHag/ooov830EF
         j6dXRS9UM61VyKsWt/Kfc3i5JFWBFHADmEggHZV3ADirr9rgrvdaVWcPMiVeQ7yJrAhV
         nMUGHHgyKfJSmYyNmO0Aft9U8hSwQb0mPBN20nOEVMRuPMsobgX6HO8oVTtKV/YYMtaV
         NzdA==
X-Forwarded-Encrypted: i=1; AFNElJ+jND3LxWwNjFX9SMQfujlzvAoJzwUj1J26IaOZI/cxwRfd4XTDFLXlCfD3tAAtkSgNYuX7XnGzvYM=@vger.kernel.org
X-Gm-Message-State: AOJu0YzxZN9UWLoAJd8057nMegbfreUEtkArr41mZ4mkQCgAmzd8nKfb
	mIA1W8U13yqNL6JWq39l/KGA0RBl0+1Qnd1AqS9ySOSFUcPiWc+weVfTO1TJuPtj1A==
X-Gm-Gg: AfdE7cnID/YbxsHA/tL3pGRnJ2u17Lv7WlWvX3XM4obq+k5AnH6baZ45ATjiwZwOdBV
	m7UW8YTLzfgOcdLCXCSNWvDGKG7PbIPspyXjY8E/F8iWB4+V1I0h+I3FYBQ4zw3QQNvaVGfaHhC
	AjuU1ogh/AhWv/gMVCz4Zma2O6BAe6cr3bPWtOtbcHsMM49bgt5DzGNI1oyJktBhRrlCI14q1hi
	6DupSXfL4zkTB3xeFAlrMV2s0+MBrQa2vg2J8zaiGf3AECLPF6hGG2sxJZPm8eqlcC2J4sipVQJ
	DM3AarXhpN9Dw6bJxLEHnjQYXASwP3DExf3frw2wQV+XU8EMVx2g/f/3a2Ar+O3dNw5UyjPr/3E
	IiGC3QLCWaAUYy4nLv0N9009/7IEx71WRVYT/TfROFnW+ZvVbdtKi24c9DBEAOlrlpnx/AnJVKM
	g9OYQcGGBaoEqdNmHekigjTpihzEn3Bpl3vQJHCOzrU9Ls4IZ1Sg==
X-Received: by 2002:a17:903:2442:b0:2c0:defb:557e with SMTP id d9443c01a7336-2c71ecbfb3dmr1319455ad.1.1781869819247;
        Fri, 19 Jun 2026 04:50:19 -0700 (PDT)
Received: from google.com (199.255.142.34.bc.googleusercontent.com. [34.142.255.199])
        by smtp.gmail.com with ESMTPSA id 41be03b00d2f7-c8a8544e2afsm2211920a12.12.2026.06.19.04.50.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 19 Jun 2026 04:50:18 -0700 (PDT)
Date: Fri, 19 Jun 2026 11:50:13 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Hellwig <hch@infradead.org>,
	Shivaji Kant <shivajikant@google.com>, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 0/7] nfs: Modernize Direct I/O path
Message-ID: <ajUs9RVduacffGN4@google.com>
References: <20260616134000.2733403-1-praan@google.com>
 <e9000012-ac58-4520-826d-b5734439ab0e@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9000012-ac58-4520-826d-b5734439ab0e@app.fastmail.com>

On Thu, Jun 18, 2026 at 09:46:56AM -0400, Chuck Lever wrote:
> Hi Pranjal -
> 
> On Tue, Jun 16, 2026, at 9:39 AM, Pranjal Shrivastava wrote:
> > Modernize the NFS Direct I/O path as a preparatory step to enable PCI
> > Peer-to-Peer DMA (P2PDMA) support. Following feedback on the initial
> > RFC [1], the modernization and architectural changes are split into
> > this standalone series.
> 
> Good idea! Following is a review process note:
> 
> Please add linux-rdma@vger.kernel.org and linux-pci@vger.kernel.org
> when reposting this series for review. The latter is suggested by
> the MAINTAINERS file; you might know of an even more relevant set of
> reviewers to include.
> 

Ack. Apologies for missing these out, I just ran get_maintainers on the
current (part 1) patches and CC'd. I'll include the lists and relevant
people in the next version.

> -- 
> Chuck Lever

Thanks,
Praan

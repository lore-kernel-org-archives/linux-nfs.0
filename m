Received: from mail-pl1-f169.google.com (mail-pl1-f169.google.com [209.85.214.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EECB3F54C8
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 14:05:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784556314; cv=none; b=SBZzoN1jgUQZvKKpUACOdN5wG8nj9fM7KC17TMNC9Y+bBvfaeMFHvfV4PM8oY1edZIMIoWOhNBv4WDKrcPwsghw86zIU/ZoJQLiyChf9fXRMRAH6vrBh4I9eFLQ+T7OUEHCq+TTRByfsV3EKcZlL+3xoHe3ClwKxBg+LXw8Cv3Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784556314; c=relaxed/simple;
	bh=5lqSyj7tegrikuu13pbql1e3DTA3C1pNxBfrevtfQD8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Evz5oY+9i4nrxOv8V9xnsDUtbnquGsg0KmB7THf9knlubIziXHYwc1EeVha238Hz3enGECmPS4MZK1iOa9RoJ8I7NbhKN7cV6rA1Sj0aA7yD2GYnuYFxvRHfpqIZY7kyy1CGOH+VHqNN2bFZsRax44ocA1jW1C/I7adi3fCOTvM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=Fti/DOtQ; arc=none smtp.client-ip=209.85.214.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Fti/DOtQ"
Received: by mail-pl1-f169.google.com with SMTP id d9443c01a7336-2cab97c86bdso375125ad.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 07:05:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784556310; x=1785161110; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=cTPuSS0UxTjwfoyNlzWlVXcUbvD3zoNXQvEQx6uuRws=;
        b=Fti/DOtQ8rpwxt2rJKDRwGTAjLhvzJEbSzRx7i4eIueKrYMqbMp6U4PVdKSWy8sKOL
         jTvIzkO+AjGpU1w1ui04DdyB/gnFsTcT9/5vljaVoUyt8nVQCTJJHGavU54wp7hGnkMY
         48s7DJ+e+RL5cQTdyL2orSDr/tlxdTYr9gNRf4THKZj+D4W8o7/0IqBdYDdd39e045WL
         +a6roMfTvJlUYm33ZLVPXxdM/y699QTsoYFwsPONq+9AU3IR9sKyILODNDAdpHVkKgOo
         zneBU/5d8cQaWtEMUdx1wZSnyKj8s0jlmsvDPNBDskWJEbkKclS0z2NENERoNtodyo8E
         MEAw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784556310; x=1785161110;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cTPuSS0UxTjwfoyNlzWlVXcUbvD3zoNXQvEQx6uuRws=;
        b=OADmQ1gasKeQjQzIlesusoyR99KjmG+Pwo9cqnpsUSysm8T62KyrgqHQeQ65kEEit9
         qPA3aJuDwmz4gXOTvEZ0GGS/J0rVp35zeO/WSMdsxxWsuGXu/DJs5PjoGvxk/d/2pBnj
         FqJb+5R7IAdjzpw2EAh41WjJd8WOc+fwKtqka2daTDrm/9ljtNBRIKz4rt94hQqwsxsV
         jtAnYIz+4o8YpSC0/8uSsvAuZ9pShceFGnJ89LpPrmfisZnSl0JShYwj9GNIOeDEjW5Y
         8wV0dvz54y6zirtQMjQGK6zui+gKvO/+ThfZ2EauYqYJ2CA+oP5fy22mkTKTrDLYs5GR
         6IAw==
X-Forwarded-Encrypted: i=1; AHgh+RpT3xndgFJdRJKQChTC86++kh0lGHaBHHgbEub1ADg33HJd0XndFZyopJqdQE0BsIiizwSo0w+szJw=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx0OXJma9txoH0ySKSHM5nCQ3fwVWhuMtpCc/pqcmuPGskQ5NP3
	jQendEPCm8hzIgMal5rbVSfs4FkATqzVNoEW5jVPzP7rYcO+4gX6yhYuRk52SRlgpQ==
X-Gm-Gg: AR+sD104aMrY/6KA4sgDsK8K+xqT8hLRK0ShxVZjuAGwEAY2JD2OQtwXo4IpAcR5XiP
	hyWhA0wCQurwdM7K78RgkQcLbg5c8llrsrFgZtDjeBQ0xszElPW8Z+TNmzY63ePe/eqOHZkOeJa
	v6sGnnhS3cbLGAWI8QJS0fPKg1OXeBVBhBuHyjhEX51Uozm8teXf33ViDR1JfWkof0OXHveg6BN
	Z3p2MPedPpOtqwGEMSUKXfb2qpTDKsr7ugoazuil8PzzRxShMdNLkv9+F+tejz8Ud1GwlHkornN
	5st4ycD8yhtbA0B+24PGekD1FiMXzAgHf77dhRJAbTJxJg+IkkyfaK9o8TifdqznMWtd/WnTvTR
	pg+pEVEkCUnAmDmmebCv6ay+e/AOEdiNGc7pBFbfYucqfdqJh4KMqGo1D134AgqZrMkH/yi4lBn
	oZd9L7cNy3C8dAB5u6vEfPXVRYEsOUf5pRueHR
X-Received: by 2002:a17:902:e78e:b0:2ca:e513:17a6 with SMTP id d9443c01a7336-2cf7b69889bmr556035ad.15.1784556309833;
        Mon, 20 Jul 2026 07:05:09 -0700 (PDT)
Received: from google.com (10.129.124.34.bc.googleusercontent.com. [34.124.129.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-38e4aff1cd3sm5960679a91.6.2026.07.20.07.05.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 20 Jul 2026 07:05:09 -0700 (PDT)
Date: Mon, 20 Jul 2026 14:05:03 +0000
From: Pranjal Shrivastava <praan@google.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
	Logan Gunthorpe <logang@deltatee.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, linux-pci@vger.kernel.org,
	linux-rdma@vger.kernel.org, Shivaji Kant <shivajikant@google.com>
Subject: Re: [PATCH v3 2/5] nfs: Track number of pinned pages in nfs_page
Message-ID: <al4rD6fdQe36rzEV@google.com>
References: <20260715143540.3597616-1-praan@google.com>
 <20260715143540.3597616-3-praan@google.com>
 <20260720091401.GB24298@lst.de>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260720091401.GB24298@lst.de>

On Mon, Jul 20, 2026 at 11:14:01AM +0200, Christoph Hellwig wrote:
> Nit: capitalization of the patch subjects is inconsistent.  You probably
> one to stick to one version or another.

Ack. I'll stay with the lower-case convention as it seems to be common
in the other commits. I'll fix that in the v4.

> 
> Otherwise this looks good to me.
> 

Thanks!
Praan

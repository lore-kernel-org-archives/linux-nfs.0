Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 50924199E89
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 11:24:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787916279; cv=none; b=Qd6AwgETQSHOOsQe4jMqLOiXQd7UVQ97CeNasJdjiLVO84lEoX/7YIWFbqOXZ7ga26txHdiUjOKTNUDpEuSO/aylCyioVKjAMuKiEqkQT6/nv4zSn0rwiDVgJGiYsN9Ge2fvtD1Y9BrdY1PkJ4pG81kYyUKb7UECp4U0OIgN138=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787916279; c=relaxed/simple;
	bh=5oHcRuhCGL0OYCae8aoKaZLaG/pEOakAnQt+ruXqLos=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=mBEythoJh4wTI3yW6AcVbj4EvQuPRtExET2S0xWy42nCAw2u7R8kM+G5fAYlRgzVQKDoG5Ff+iKk3upR384xPtSKdj253jd6+D50WoYOgZaRJi6F1VzxUK0IGmPcEai824wkvFdY7SP27qdU7tZdl5cRgfneQjVjAR1Zje2aQFQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=DhQodndX; arc=none smtp.client-ip=209.85.210.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DhQodndX"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-7f4f53975e6so740800a34.3
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 04:24:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787916277; x=1788521077; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=KBFxxTo0WJItWcptpVbkyRNZ+ds9M3fpqqLeVQRj4xg=;
        b=DhQodndXig/k40kc1PqqOjl6iaJoBJmORReglsojymOrnSli/BTCyOiGsFBXkc67wy
         u4NYG54CnYqrFddDNyEl8jXHGP7XTHRoS78IrXj+Kt66gYLPIdy5OF2HNGP5zIT93IFD
         goBVEZq5H7jADGLo43Jqp2d+TJK+sqGcskiheatpIizHpNvCI6c4aWYbMHHT9Fr4OUcl
         3tS7gFvguxCX+qV6OzV7JpDZ5eDAOomSHM+4YsBU4wbPqShCbVEk1vCvh7DZ4O6OBq5+
         5ENERwu1M2T+3JLWXQBCHnvHkB/5Y6rRkmrnPTcovZGHtBUCrRit+X+KWQGNl/GobRXi
         8qbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787916277; x=1788521077;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=KBFxxTo0WJItWcptpVbkyRNZ+ds9M3fpqqLeVQRj4xg=;
        b=GbX+yge02nHnS5X1jpuTrpAowO4tahce1RcsBexWIwvJcI5KD4wAX2OMCrpA33Ull6
         Fto3ZCLwql9ru+dp4hMOqKQJOxz+FYEk3czU76RY6IBByajHuuyxZF9Tr7fuJEcJVh7I
         k1YvYgMowrDXTP4kqkj5cjkK9cNy4nbzZQNsXN8frV7JSpFUK00qJs0WXS3VHwlwpCWi
         xOQ6CKP2DYKIEg7laZ4BJmuSO1Dd8pZMP3a62qb9XmFmUO+BGErptNKo7LilqFOoeA4y
         VwMH9dgaMY/dzs05k8N0kbDt+bVsK2s/tdCf7txvxUEa9dRPXhLC097uqJtSMjOmL7hF
         t4ig==
X-Forwarded-Encrypted: i=1; AHgh+RqB0J1qq3qSAXmlh7v8IoK76JJ31hCQSfS6sbFTWM3yMfUUFyJU6CCXo5v6NlR046tdUhz8jur13gQ=@vger.kernel.org
X-Gm-Message-State: AFuF++mwh9bjq50ciuMN5NZ18iKZUEx6A24xWHdfyuWFDxrdF4rLCrjY
	iWYNQk5L7CkoVrEpc+U9bvHvVkvJOQKC0ZHqxMXSkUfiTG1I2mQQGblGgVfhmwozjic=
X-Gm-Gg: AR+sD12Uk3vPt8YNLKO/tEwfFAFTDMH0pBcLthUXIqVAKSYkHCNQkig7Y+oPaK0XxEZ
	OyyLwxF2sVWZ4jcjBnGhGCPZjtB0wutt5R7yJw6ut4ZRTLEAuNjDJAvFzVHLMJ50tTYa0qN9FBW
	c/RQJCS1lEScJ2DQ51ywSeo4nuOF/ALtPT7jQR31Ty11ZD8YlPF/VAN00Y+lduxZ7iddxY+wAeP
	kxP75vK7VJOu5suZZO9oRZd8V+RNyTzt3p2mNUj0J4zReI6cribyHLbPphotT3+pMDwt2jFY/c9
	/nkrpT4UTDrV5pwhf3El39QC8mdjt3BjI5BfvJElxhxKSWCV7/s3+lmGa5ahs/gzYoaC5jzzOOX
	wEiOJB53GRklrJYI1ZizRQ4Gr5Jg3ZJ6UqHDI5cZhR2gJB/eX7+2UQzLXNsK2AWVptIlU6zKlHB
	B177TU7QrlcJywsrMxT+p2D//mP0kheVPuEnUYAxrrR7hnmLRYKsLR9EhiiGjgAjDdYEh29G+yu
	4yUQQFb332puyE9Q7I=
X-Received: by 2002:a05:6830:6f88:b0:7f4:d8f4:8b2d with SMTP id 46e09a7af769-7f4f25596cdmr8210751a34.15.1787916277101;
        Fri, 28 Aug 2026 04:24:37 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f4fa96d29esm1082758a34.17.2026.08.28.04.24.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 28 Aug 2026 04:24:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org,
 Jonathan Curley <jcurley@purestorage.com>, Mike Snitzer <snitzer@kernel.org>,
 Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v2 01/23] NFSv4/flexfiles: reject a stripe_unit that does
 not fit 32 bits
Date: Fri, 28 Aug 2026 07:24:35 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <7C602108-0528-4B48-B10B-BC9110475F00@hammerspace.com>
In-Reply-To: <59de74d2-e2bf-457d-a0cc-b3dfedc5b8c8@app.fastmail.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
 <09f50acb9f481b3a9c3716e8f70b9b3dbe81888c.1787327939.git.bcodding@hammerspace.com>
 <59de74d2-e2bf-457d-a0cc-b3dfedc5b8c8@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 27 Aug 2026, at 15:25, Anna Schumaker wrote:

> Hi Ben,
>
> On Fri, Aug 21, 2026, at 12:29 PM, Benjamin Coddington wrote:
>> ff_layout_alloc_lseg() decodes stripe_unit as the 64-bit value the
>> protocol defines, but every consumer treats it as a u32:
>> nfs4_ff_layout_calc_dss_id() divides by it with do_div(), which casts
>> the divisor, and ff_layout_pg_test() copies it into a u32 first.  A
>> value that does not fit is silently truncated, so the client stripes on
>> a unit the server did not specify -- or divides by zero, if the low 32
>> bits happen to be clear.
>
> I've been thinking on this. What would it take to update the users
> of stripe_unit that you mention above to treat it as a u64 instead of
> a u32? The calls to do_div() could be replaced with div64_u64() for
> example. It just feels a little more robust to me than artificially
> limiting ourselves to a 32-bit value.
>
> Thoughts?

I agree it would be better that way, storage is already u64.  I don't think
the division cost is a big deal.  I'll make that change for v3.

Ben

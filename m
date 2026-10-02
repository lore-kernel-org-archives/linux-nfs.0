Received: from mail-oa2-f34.google.com (mail-oa2-f34.google.com [74.125.231.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 823434FB9CD
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 17:20:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.98
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790961620; cv=none; b=lppc7bNruq/JTr/Yuz7tTJcr/VlQUbzyshrgKIYqVZxr8DfKfE1+H/Qs9lJSxLX1GqwtJtvP9BwdGpDb4Ha/5br/1SlPTgSjviiZ8lBNd9+QUqk92JxdkUoaOMfyIICOicP8XcLadw9y+XI76qQ/C7o4ZBiNQfx6E9/laQXRoNI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790961620; c=relaxed/simple;
	bh=/CVYYYTwv6YCYfeTxhIuIBDoGb0sszG8rZP0LVR3GxU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=sA/N+1+CJwVgcZ6rhql8ePC/Kw4wC83YtSKME3HckeO4Cjr3KA63gH1wcd6szBbas6Ikp+opnA+ydy5aS1D5UULXf3nbDmY+NMiBaMfEgRPff5I6cxZ6duYy3vaD8NbACyleaOxKb8Ak+Jgl3mz9kRnFDIOieLJWvUyHGbVvl8Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=oZO9Xe1v; arc=none smtp.client-ip=74.125.231.98
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="oZO9Xe1v"
Received: by mail-oa2-f34.google.com with SMTP id 586e51a60fabf-499c0f06935so123458fac.3
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 10:20:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790961612; x=1791566412; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MxEQLT41xgX3acWDz/lwIF1K7bYIpk4TXD94hJ3kwko=;
        b=oZO9Xe1vUrxbzVE8IqBuhwApML99swSUpr6sEdlwE3Z+7sgUQSkZR8z0XrvN0Laue7
         0NfWrHFE0K7dodTP+m5Qqv889PA6w37DCpusapDvMJziY4SJiDmF7SAfuc4pBiG2xDsg
         8F9fNPYu1atShhePetIYsVcmaPZ4GA8IGznQs0L55Nuk3Hh11P2ZRYrLNYa/f+VkHdiU
         iOqqw7/S2o3C3bDm3GOwfoCVZOg3LwEh9XEQ8fc8fvYhF2edueZhuJ+zmtunkafr0OXW
         u7zMIgSbSeZBCy9fScSkfNgvLhF0QCGn/5ZHeURn3TmWaqkbR/HfwGTlZIT/yCmrl6mq
         9GTg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790961612; x=1791566412;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=MxEQLT41xgX3acWDz/lwIF1K7bYIpk4TXD94hJ3kwko=;
        b=ODEWkXhol/haN9QbhP4e2eaJvRPvHZ1wEz5/4rYJS3QkIMhkEp6Yne0FZD+80rpc3v
         I9qqr4Ts43FdQkzAe5CISHQW4cMRa6hTzJIZofSFfhHPX60mlvKDm/xQcGJRIl+qNkEr
         Yfs/w5HNyJtEO5kfPym9bBNKaQPNPEJmDIMWmidh6WIaa+AmhmwFe1/5vVXLlFYFihax
         yBAryXbKAkZK/8/gJJ74KPrYu5MOAWwU8D89xh7uM1wCfJFvMM23XeBdJx5r/O/h/6Fe
         2gZRl9cIbmO7ne0jtL/hKK2qFZ8MIsOAtbtpdVixbLPJ2nzbs2ENYrxCr8JI7QphlReX
         U9HA==
X-Forwarded-Encrypted: i=1; AKwUvBzoGO1/76CDb9N4Fmc7my9EiyhOtt/yLMm208zQlUmxWz912rSphD713SFXdW+EVlEwmlKalRfOW9g=@vger.kernel.org
X-Gm-Message-State: AFq9FYI5+FmXd+RXHjwDgzzJ6IPWLuQGdHEfnDi2MMRs9dMe/y1Qvb+C
	/kY2pe6nTujzvu0DiKCOR3jsQSKAGm83QYOR23uoVpSAD9Iv9TRMS90VtuAXoY3eJ/ISCGf7WNT
	IFmqk
X-Gm-Gg: AYBFou0DqZgrRJw7u+q12+4qod+pDuH44lbRbvsTQSqXoJ3k3pMZoSCMpnYbtBm6FKJ
	Z8ZRPyMJOCG0/NwCcvW6JeUtkVzuB17YSGdeCmoaER79674KcSAvuxVwPxWnEhPrBXYjK8MP/03
	xKMJuJMUUcnDKCEqB0eIaHNnIUn3HNCgwd5snwBQPlsiK5QDrezAVzABa3kv8vydC/tpgNBRlL9
	zC+IW4VFamzgRnUKVCfUbR64tDeXTHdf1Un7YESQgMlyFmBo8cgRX4b2IdagVITnoxhLBWISzQB
	KgDai0dh0vy1E+JTd9IZ4vFgeNfXxGmooEj/XVjHaCPR9vW4nF8JrVqEvvZo9XUO/i+QsC6RjHg
	CurM1KtP87ozG4ie55dLLYNa4yu4w3c9UP6u/+HE2tRcZFNe6hR/j6VjY4kopc0PuH1Pl3Gzzui
	6HPFhcLMpkDj/BDBOQQSKShWfnzeOCtcV36uoD7GsMXTVjW8X1HDkGNz1KWa7XMs+X//ZLagya/
	JrBbT05HANhGsGyyQ==
X-Received: by 2002:a05:6871:e498:b0:49d:e4ee:659e with SMTP id 586e51a60fabf-49e15e0ecc1mr2570248fac.30.1790961611835;
        Fri, 02 Oct 2026 10:20:11 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-49e16f00b5asm2631997fac.14.2026.10.02.10.20.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 10:20:11 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: wake a thread after re-queueing transports in
 svc_clean_up_xprts()
Date: Fri, 02 Oct 2026 13:20:09 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <6613E805-C877-4E42-82C5-D2214C596B50@hammerspace.com>
In-Reply-To: <2588e487-1126-4592-819c-b025e4ab346e@slotpi15m67>
References: <5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com>
 <2588e487-1126-4592-819c-b025e4ab346e@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 2 Oct 2026, at 13:06, Chuck Lever wrote:

> Hey Ben -
>
>> -		if (q)
>> -			lwq_enqueue_batch(q, &pool->sp_xprts);
>> +		if (q && lwq_enqueue_batch(q, &pool->sp_xprts))
>> +			svc_pool_wake_idle_thread(pool);
>
> I'd rather the wake not depend on the return value:
>
> 		if (q) {
> 			lwq_enqueue_batch(q, &pool->sp_xprts);
> 			svc_pool_wake_idle_thread(pool);
> 		}
>
> svc_xprt_enqueue() ignores what lwq_enqueue() returns and wakes a
> thread every time. The conditional form is correct only if a "queue
> was not empty" answer means some other thread is already on its way
> to the batch, and a reader has to work that out from the lwq and
> svc_recv() internals.
>
> This path runs once per pass of a namespace shutdown, and a wake that
> finds nothing to do costs one trip through svc_thread_should_sleep().
> The unconditional wake needs no such argument, and it matches the
> other enqueue site.
>
> One nit in the description: nfsd's svc_serv is per-net, so every
> transport it drains belongs to the namespace going away and nothing
> is left to put back. The sentence about the 5 second timeout reads as
> if nfsd were exposed with a bound. Let's drop nfsd from it and name
> only lockd and the NFSv4 callback service.

Roger, I'll send a v2 after the weekend.  Thanks for the look.

Ben

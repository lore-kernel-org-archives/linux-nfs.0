Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794591529;
	b=EykpqOMp4Ou3L6HAGtnrq8fKTZJWorYshbWaOdSgvSpGVf2CT9bdTluArRXHOCgOI8FV
	 uNo8dGgzx5zGWZCpPhaBuY+ZbCsly9hz0btuM8UOoAhPmxqInU6A85B8IWg3qYgYDol6n
	 MP0jJR/Wsp1BiaMkY4iMzkTy3k/ASzvbXb3H9n5OXrfOwHfXKlCYXQRBIqrlQN4SJ2bOU
	 Zh6kMab2ddh/0VXU2/C5mirP4B6CGXsPyPus6RlqYDf8VjYx4AXPoOrcduLxRVBwdS+uU
	 AoVYkhM6OvTYvISdYVkIhbMXYdEDKvmfUF9WZzRi3noBhoJM+bU67yj61nhg8M4uZVA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794591529;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=jKPak6ySdgfiRhnn9y+CvF9Y23VULkjN8DQBAypE1mw=;
	b=tr5N4qF3HQZ++NoslGkkuP1CZ9faZYuCE11xnW+NXensftoghzN21SHnMwJyizI5LKJS
	 p9p5UhVxg4J7EJPKmTMHlVo1amO+Q9O+TvCwGJXkukYZetkDCk3qw4tFI4wk2zJXYnBg6
	 jR2dp6uHauulDyqiy8lIox3fzeB54SdbpZiNHeSUiePrX+Iv6rOmzRn4vCYGf4OhZQPjU
	 2G/MOzzmoKQSoINnc09H4+nglin2VSnIDAlVE13WvlI75KvU0DPHHddA1QVs7k5WtPSUG
	 h/3G8UVvtDUE+BrCojU6xscfFYasOEVycYcwaYP4l2Nat4zsKFfQNPYo9HzC6CDWa6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HNEoo4zk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCD91606D4B1
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 17:38:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HNEoo4zk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 895FF1F000C7;
	Fri, 13 Nov 2026 17:38:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794591529;
	bh=jKPak6ySdgfiRhnn9y+CvF9Y23VULkjN8DQBAypE1mw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=HNEoo4zk7KRuye5FrEMmre9DUChBVCcsUybr+SDgdHAt0bqLj1+EhaVGNB3w+XnWO
	 gYwdRiwNbeIDlpQmRf2lFXYWNXXwOwWIvo/jFRzs4Jav28oBQI1ri/hC9ruTVH1bhH
	 DaIkuKKwXoq2V2J24PtEV0FWNEFBWjYT50PzxZ+nKPpdf4UpGjYGs6wShBnZLmzvCO
	 qTVBmGCh/KFg8tz6EHrkkH5tsJmzW800WBMcWJTNZLkcM6BAb0PW2uoij5rvLeMwFj
	 XvN5H38I+qpkiZB1lP8fcwRVytshNeimhoRmDBDh9FvYx37QGs+QQHmroYSzgPA3VP
	 jSAB85NTdgV3g==
Date: Fri, 13 Nov 2026 12:38:48 -0500
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Anna Schumaker <anna.schumaker@oracle.com>,
	Trond Myklebust <trondmy@kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Make rpciod and xprtiod visible in sysfs
Message-ID: <avdLKA6kYX_vFk4m@kernel.org>
References: <20261113001611.90519-1-snitzer@kernel.org>
 <20261113001611.90519-2-snitzer@kernel.org>
 <67be1870-8488-45f1-84e3-b047a75fa406@app.fastmail.com>
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
In-Reply-To: <67be1870-8488-45f1-84e3-b047a75fa406@app.fastmail.com>

On Fri, Nov 13, 2026 at 09:18:36AM -0500, Chuck Lever wrote:
> 
> 
> On Thu, Nov 12, 2026, at 7:16 PM, Mike Snitzer wrote:
> > rpciod and xprtiod are unbound workqueues.  An async task's work is
> > queued to the affinity pod of the CPU that queues it, but an unbound
> > workqueue's affinity is not strict by default, so the scheduler is free
> > to run the worker on any CPU the workqueue allows.  On a two-node NFS
> > client whose writers are pinned to the node local to their NIC, with
> > the workqueues' affinity scope set to numa, 1.5% to 2.4% of the skbs
> > sent on each port were still handed to the driver from the other
> > node's CPUs: 97% of them from rpciod running rpc_async_schedule(), the
> > rest from xprtiod.
> >
> > Neither workqueue can be made strict today, because neither is created
> > with WQ_SYSFS and so neither has affinity_scope, affinity_strict or
> > cpumask under /sys/devices/virtual/workqueue/.  Add WQ_SYSFS to both.
> > Nothing changes until an administrator writes those attributes.
> >
> > With affinity_strict set to 1 on both, the same client sent nothing
> > from the other node and spent about 1.7 fewer CPUs at the same
> > throughput.
> >
> > Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> > ---
> >  net/sunrpc/sched.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > index 016f16ca57799..83e2974a44d9f 100644
> > --- a/net/sunrpc/sched.c
> > +++ b/net/sunrpc/sched.c
> > @@ -1278,11 +1278,11 @@ static int rpciod_start(void)
> >  	/*
> >  	 * Create the rpciod thread and wait for it to start.
> >  	 */
> > -	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
> > +	wq = alloc_workqueue("rpciod", WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
> >  	if (!wq)
> >  		goto out_failed;
> >  	rpciod_workqueue = wq;
> > -	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM, 0);
> > +	wq = alloc_workqueue("xprtiod", WQ_UNBOUND | WQ_MEM_RECLAIM | WQ_SYSFS, 0);
> >  	if (!wq)
> >  		goto free_rpciod;
> >  	xprtiod_workqueue = wq;
> > -- 
> > 2.52.0
> 
> I already posted a patch for this back in September:
> 
> https://lore.kernel.org/linux-nfs/20260915-performance-v3-3-ae26d460bfd3@kernel.org/

Nice

> Did it get rejected?

Maybe it was overlooked, Anna?

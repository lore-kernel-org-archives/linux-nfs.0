Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1874339875;
	Tue,  8 Sep 2026 18:06:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788890779; cv=none; b=BiqvbLnmMIi1azVejcBe4zpxETtBcHTxw5f2cl7+8pAaWY2Bmvuxvh6UWpLnx8yvggTA5El+rb7tw3k3CgYPmeit7N64LHmnE+nXAAW9qtUOW448tFbow/jfwsm4AKJkaA+Q8F6P5gi/f9OCgPWYnZqOExiCA7joFGcAdpQoRIw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788890779; c=relaxed/simple;
	bh=oMHnSBValUXrWdbaZhr8pFXut/Al85Sd2viiZ5Jf4Ws=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=VQ0EuGP5+/qhGKl5MIu8siUrzUvv/7wLUVy4Y6Z+uhHqDccdD2ZGsulfiWExy2t1pT5h3yJlEZ5oISE6yYMtsOoXiBzkPN6INR6TmnNws9ZdGQz9I/Sue0w+8Z7jWNB4OsOqKpRVFyr9g7W+CzcJYYUAqwMR+AL8+qWekRAjIYs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JN9PFfl2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JN9PFfl2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 541021F00A3A;
	Tue,  8 Sep 2026 18:06:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788890778;
	bh=PrjTINeDnb6STqPpRMwQ3/DyMvFIKnQZaiXQIKUq5bM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=JN9PFfl2DyUKA7gMLaCyaGomQjnv7wLJZMHFcciTDkIV8xW7/AYzapjGyRm7pmH9i
	 +4ESDp6w4IWl1Ev2TLQ5YoNP8LjTx9yBDaHENZ75DTx+AMVia/GCKZBP64E5qG+Uqw
	 hpJLAxLITjSctkgSEDAy2rSGF7eXhiJCaqsq4k/rsYoeANgApc0yQwSG1s6YHd0j8Y
	 0B57yclgWzAIU/Yywux8PHNnVWaG5Zo94yWobDenX+Hvux+LGKsG5/43qiIe6dZqup
	 xGIQJ5E1c+QBRCF67vQfk3VBHm8sJMjxpRAG42bP3R3qEUTjJ0FxcbpJ2m/NyYgEKm
	 EZXYKPAonlrlA==
Date: Tue, 8 Sep 2026 14:06:17 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	"linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
	dm-devel@lists.linux.dev, Jens Axboe <axboe@kernel.dk>,
	Jeff Layton <jlayton@kernel.org>, david.flynn@hammerspace.com
Subject: Re: [PATCH 0/4] block, nfsd: fixes for sub-sector bvec direct I/O
Message-ID: <aqBOmZ1zTyU7Y_q-@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
 <aqA5qgfUTbNi0nHJ@kernel.org>
 <f6a9430a-93b2-445b-9cb3-a6a41ae5445e@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6a9430a-93b2-445b-9cb3-a6a41ae5445e@app.fastmail.com>

On Tue, Sep 08, 2026 at 01:48:14PM -0400, Chuck Lever wrote:
> 
> 
> On Tue, Sep 8, 2026, at 12:36 PM, Mike Snitzer wrote:
> > Apologies for the git-send-email misfire.. still not sure what
> > happened, but will sort it out for future.
> 
> 3/4 looks sensible, and can go in now. 4/4 might need some
> adjustment. Assuming, of course, there is no functional or
> mechanical dependency on having 1/2 and 2/2 in the tree
> first.

Right, 3/4 and 4/4 don't have dependency on 1/2 or 2/2.

Thanks,
Mike

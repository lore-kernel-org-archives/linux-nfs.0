Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F72F27BF93;
	Mon, 24 Aug 2026 04:57:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787547476; cv=none; b=jlfCeX5WJpWVDb5ukIlnfWDg2D1TCrItvOiHRVBtIKYYpAoRZzRuuLFFmUcvXbmKaO6iuErmzIc47xGJrUUy+imH/CTRrcjyjdY8z/XHLuhaxY/YSNjkYfCd3PD5qNA5+XPFeVxPq+KnyLsDQ8yqLcCg9N/J0o3Ww4DYE1lyTIY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787547476; c=relaxed/simple;
	bh=NyXRpwdg6yBfVIQOJaMZCcBk4YphL1lGutrtTFJsqTU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MWbxglVFeiNJcz2tIxMtI6+FO3nJ0Ve4vbYR7HYq5p8WzNOYi+COYklaI5pXELvgMzybOinFS9aJQD87lWJDifTmyU/XWENS7TIcgnPb6oDWwTMqUnboyaCE/kpOPV9DcIVBBgIUNtqC8aI3ZKhgijAV0qXjCN6fE3lkpqUcq2A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=pFpaGsYR; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="pFpaGsYR"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description;
	bh=245p8zrhWKrhjJkSRaqb+oya1mI88yA4bBnC6uq7Br4=; b=pFpaGsYRjmLVq8mzH0rMqhbBhL
	CGxBtzs9tVUuyLNZGxWdeB4owetFfjY1Y4+wJ1uru2A8UpU+2Zf7VmU9/X7nj5WtBFMVUntQ667bE
	sCPP9SyGotFKIuJ4JdF3Dtpiw8RJ0Zy3GKGlS4fAC2c5kb820H7W5bnTPyVRymMuWrKHFuEJINc7R
	630R1bWL1wpNHeLR2ymoyw2U1b+JF9KyUd/Vj/OA9DTGvhiRRt600+Adhes9PObwx5BB6lx1bQrJ3
	Zztxma1b4WQxCFNJAX+LjvvGPVrTy3nqtWolPSObOIJSkdbJoMCt5K82SkBRXQHizgsG9e3foU6Ao
	R+B6QsDQ==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wyMki-0000000FvI1-2f6O;
	Mon, 24 Aug 2026 04:57:44 +0000
Date: Sun, 23 Aug 2026 21:57:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, Christoph Hellwig <hch@infradead.org>,
	Ameer Hamza <ameer.hamza@truenas.com>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Christian Brauner <brauner@kernel.org>
Subject: Re: [PATCH 1/2] NFSD: Fix duplicate fsnotify access events for
 iterator READs
Message-ID: <aovPSDE_IGKggzyN@infradead.org>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
 <aoVHBkmPNSRakbYW@infradead.org>
 <9ad95194-983d-427d-9a07-c9eb0891d1a0@app.fastmail.com>
 <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Sat, Aug 22, 2026 at 12:21:12PM +0200, Amir Goldstein wrote:
> (1) In this series
> https://lore.kernel.org/linux-fsdevel/20231122122715.2561213-1-amir73il@gmail.com/
> we intentionally moved the permission hook outside
> of the splice iterators because we wanted to avoid calling them
> with freeze protection held and also there were some duplicate calls
> for this work.

This got me into a little rathole of looking into the other
do_splice_direct_actor callers.  And I still don't understand why
taking file_start_write outside the main splice machinery is fine
for splice_file_range callers, but not for do_splice_direct callers,
and what consideration exists for potential new callers.
(and yes, the naming does not help)

> (2) emitting many READ events from an iterator instead of one event for
> the user's READ request is more noisy and serves no purpose to users.
> In most cases (but not always) those events could be merged, but at the
> cost of futile CPU cycles.

Yes.

> >From a quick inspection of the code, it looks like:
> - fsnotify_access() is missing in vfs_splice_read()

Yes.  Then again I don't really understand vfs_splice_read, it basically
just forward ->splice_read.  I guess for backing_file this is
expected and matches what do_backing_file_read_iter does. for
code it looks weird as the context doesn't change at all.

> - the naming convention for splice_ do_splice_ vfs_splice_ is a horror

The entire cascade of do_*, *actor* and the whole structure of the
splіce code is horrible unfortunately.  Part of that is due to the
mess of inflicting a fake pipe for the fastpath callers that don't
need it, but paet of it is just self-inflicted bad naming.

> - we could make the low level splice_direct_to_actor() static and possibly
>   rename it to splice_direct_to_actor_sd() or something
> - we could export vfs_splice_direct_to_actor() for nfsd which wraps
>   splice_direct_to_actor() with permission hook and fsnotify_access

The latter is the right thing to do.


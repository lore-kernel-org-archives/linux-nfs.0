Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792582053;
	b=yWKZbucWsXWBqzVgiGXLv6EHdxahQtfG+rqVMaopgH9V/RB366F17jVdefsSg5sm7aGj
	 Kn980JtHFFaA5dt0drQqUAxe2H4KWhhFbxr3DbGXPoCZGAmf5ZmkVzhlyDKuSvHSwBx/8
	 /JAOHN+XD2pwa6pHmIz5J+977eruQaDrrRby9m0Q9urQtre+YNLOWDIN9yyrV0tJ00604
	 UvG1YmzR6+pnVXIFAuf5TITInjjvFMG/QzQAXTCGYbmSJ1nO93nIds8wnGaZal6JMqj+R
	 a/XOvmBp843hBtZkbFWaFHcLNjsO5GtBjzh+2lm/Cw6QyIYkBmoxioCR0VTNCUXJ7gw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792582053;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=fBh1//KrJPIC1GBh5Da5r8teHIOPwJ0CfmsZgU7OU0E=;
	b=QuuzsnJzrVZeKWjmFEq73bRCUkZj6eIqQTR78l3tWhW92l4pTDvxyDKLq71V4LDpI1ls
	 q7FQNoA9fE1eiF103C+CSA7KKNTlYAycFFF/9YYEx73VcF93vJuQo9j8K6j2wr/QUhIpo
	 SGquYzXVq+vtvfKnwC6FF1HqXiJ6wrwU5a6Vvrg6VhC+YO72ziSlTTlPT9FR7z2QsVHGd
	 ou0e88LtDEAEIH+zyNVPioV+0TM4H8Qj7UqWpuRnKx9qQzjpF8Qk0UEgXuvXr5dBnF1eH
	 dI+WzkmspfSeO8emrl4waZrfxEguHuifPJVPuLUNT8PyjGeP4idnH3dK/ywmx/UDMLg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nGCAZI8I;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6416F606A31B;
	Wed, 21 Oct 2026 11:27:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nGCAZI8I
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BE4D1F000C4;
	Wed, 21 Oct 2026 11:27:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792582053;
	bh=fBh1//KrJPIC1GBh5Da5r8teHIOPwJ0CfmsZgU7OU0E=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=nGCAZI8IaZJu1nbhAXcORthb1tdTtEPo77zJlZkRTaJ9pcKs4zRmECVz8e5qVG5kz
	 3+ar5djVGZJF/SiAHSBHJKrC3DIOOto727sfsQx+Nr+wJZnTeLB5fQFQT7euDOCVyU
	 bZMTO14XVLQjzXIcH8XQVgbWklJ6IDrNBjgpaCBPZYfh6AWTpENEOt+QCM+VPUoFNt
	 cb7kuvALJQdel6xt4EnKyBU1p3JuM61UKFEfaNsDxSDenbzFWh2DKP5KJJEY33CsNY
	 aqExV4MHuEUamYopcS8PzwBbPHDAGw6PUSlHf4cKJIfyG/D01lsjtiesu6sh72d8V/
	 62enOfocXv/sA==
Date: Wed, 21 Oct 2026 13:27:28 +0200
From: Christian Brauner <brauner@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] nfs preparing for locking changes.
Message-ID: <20261021-hochzeit-stuben-widrige-609e75b40a2d@brauner>
References: <20260926001011.401824-1-neilb@ownmail.net>
 <20261021-hinbekommen-angedacht-bahnanlagen-d832186d3a71@brauner>
 <179257850450.1724252.1685434539612383422@noble.neil.brown.name>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <179257850450.1724252.1685434539612383422@noble.neil.brown.name>

On Wed, Oct 21, 2026 at 09:28:24PM +1100, NeilBrown wrote:
> On Wed, 21 Oct 2026, Christian Brauner wrote:
> > On Sat, Sep 26, 2026 at 10:01:17AM +1000, NeilBrown wrote:
> > > I am working on changes to directory locking.  The medium term goal is
> > > to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
> > > can be run unlocked, and consequently cannot be called when ->i_rwsem is
> > > held.
> > > 
> > > The requires:
> > >  1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
> > >     this in a few places. New interfaces d_alloc_trylock() and d_duplicate()
> > >     are now available and can be used instead.
> > > 
> > >  2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
> > >     unlocked d_alloc_parallel() would then be able to create a new
> > >     dentry with the same name.  In particular d_rehash() must be phased
> > >     out as it won't be safe.  Various techiniques are used to avoid the
> > >     need for d_drop(), particularly that d_splice_alias() is now able to
> > >     splice a hashed alias.
> > > 
> > > Further, the first two patches here fixes bugs that I found while
> > > developing and reviewing these changes.
> > > 
> > > The patches depend on patches recently added to the vfs tree.  I would
> > > prefer these land in that tree too with an Acked-by or similar from NFS
> > > maintainers.
> > 
> > I'm happy to take them. I just need an Ack from the nfs people.
> > 
> 
> You have an Ack from Anna for v2.
> 
> https://lore.kernel.org/all/68919e69-d97b-47a4-8695-8021f24f119c@app.fastmail.com/

Thanks! Catching up with mail after conferences and vacation.
Note that Sashiko reports a couple of high severity bugs on this
patchset.

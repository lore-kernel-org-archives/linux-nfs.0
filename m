Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792576100;
	b=468LJaB52nN9CsxnAn20uRkb9pM9VHGez7jAr45JlsSQ1IUhSqng8LQgASUdbVJ2hVEp
	 /DQ+lOLJbpO1q29DTD1htWp8x3iYQMeConv6xIKaV+5gasnbMqjCzGET5ViLjzgq0Rx6C
	 YQnG9xdvvA+Bsm1zof0GR4eg6YFoUrERm0FxBgL/7qMxTEZdv/JZwPtxuvb9mdeSUhmHH
	 zrkj7+g6cnuX4t4mr4tnxit1X9Mn2aknIapMKzcAEj6y9gByaSzy01X3LN3p8GTKF0q7Z
	 91Zz3A9hdtUHoo7QJGr7J022DRFpiEUEX17uLTk+Y6E/hEV/yiSZ9JVqDP2CZBIc9bg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792576100;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=Fj+HUip53YXsOg5vnwsnEZmcalPlvXrw1U0Nd+vz7KE=;
	b=ch5Q7D1kaLKv/W0ydW6lZQDEfilK7voYSOLj+5wLKe1XN0pqCwLK5hvV+ONsaTkByRNx
	 xXS3BbFKBvKbDHqn/UrGFLcI8qF5JMv//2KGgIMJZNaVFhiRGHRHdwZfZnLcxXg6+2z4t
	 8cvjusMX8mV3FECmMrdSKm2gNSpTfMiLOgAlpHZ6c0PbwaFFzTO7Rl5UZsg4qEztzyrnk
	 6KhZF+ruxvL7TWa/Xi956q5z60Bn8pmCsHmBj8MieTDvlufwAodiwL7Taez7r+8O0xOs8
	 m/M1+DqlEPN7WmfgTOtovkPxJ5OFPassZg3a7QaOAlNBCX/DkpEii7+B0qM2CKDQXTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=awMLHxOH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15AF3606A31B;
	Wed, 21 Oct 2026 09:48:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=awMLHxOH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69F2D1F000C9;
	Wed, 21 Oct 2026 09:48:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792576099;
	bh=Fj+HUip53YXsOg5vnwsnEZmcalPlvXrw1U0Nd+vz7KE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=awMLHxOHrJeMes3T4yxiy/Z0WKV9Yy3S6Azgv/MaKu3VbJ3N84EtM3S4tMRZfEXfw
	 nJt7ureZSBEFkXcwaRMvUE0EtAfH9WVSENyLDaMWPsqZD5fcd4NoDb8EqsGRXZTS8X
	 VeUBrfKiwW7s4DfK18jo6XFZqyhHXtBC7aXqmcm2ckNV/zzt5oL+e+12h0DNo2J26S
	 85PUg/Ec18Xig4cCc1gomj4HKLDM2wNYYAm/XQxFSax+UBuWltv5EAHN6/HdnSLkLS
	 k/kxmTk3WZOV11V+f3Z7wFx1CqPdWVqE19PerkSp59gAMFfzH3x6dfonRBvWrYwxqk
	 bBEh6TeoNKyvw==
Date: Wed, 21 Oct 2026 11:48:14 +0200
From: Christian Brauner <brauner@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] nfs preparing for locking changes.
Message-ID: <20261021-hinbekommen-angedacht-bahnanlagen-d832186d3a71@brauner>
References: <20260926001011.401824-1-neilb@ownmail.net>
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
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>

On Sat, Sep 26, 2026 at 10:01:17AM +1000, NeilBrown wrote:
> I am working on changes to directory locking.  The medium term goal is
> to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
> can be run unlocked, and consequently cannot be called when ->i_rwsem is
> held.
> 
> The requires:
>  1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
>     this in a few places. New interfaces d_alloc_trylock() and d_duplicate()
>     are now available and can be used instead.
> 
>  2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
>     unlocked d_alloc_parallel() would then be able to create a new
>     dentry with the same name.  In particular d_rehash() must be phased
>     out as it won't be safe.  Various techiniques are used to avoid the
>     need for d_drop(), particularly that d_splice_alias() is now able to
>     splice a hashed alias.
> 
> Further, the first two patches here fixes bugs that I found while
> developing and reviewing these changes.
> 
> The patches depend on patches recently added to the vfs tree.  I would
> prefer these land in that tree too with an Acked-by or similar from NFS
> maintainers.

I'm happy to take them. I just need an Ack from the nfs people.

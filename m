Received: from fhigh-b6-smtp.messagingengine.com (fhigh-b6-smtp.messagingengine.com [202.12.124.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D0F2046C82B;
	Wed, 30 Sep 2026 21:17:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790803060; cv=none; b=SsRQDEuxAE4WI9qvaq3v2p3RlOz9lZMh5uqEDWKnJskAJm0kH1qjmwqTNttrnHhLA/bInT43O63+DjbE6mbwkST7XhiGJYfxu6m4Ymd/49pMZMLZciKNaZprZWcwqRmJCEgyXSrFWkDNjw3sm7XrArVJ8x0taVVhd2iMd+NVudQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790803060; c=relaxed/simple;
	bh=LVOHumrHyHT+mIYjVPW8zGx23DcqwKbyKcv+g1tjnI8=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=oC0EzgMSWFvqTF+r3gDJbNNvjWiUyM8RLxfzo1koBRbfadBaUbcbbzGf+K9wfs3FHbjZ8L9ep5oRE6F93MLBLRz51AssW0RBWwxwYFfHCjEGUDw3ked8giBc3UtUdeZK8o1OEWwQ0HpxQzR/72VSJ4WT4RGauidTMuaGUwJa+f8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gUXA9zxv; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Ai357FG4; arc=none smtp.client-ip=202.12.124.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gUXA9zxv";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Ai357FG4"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id E86EF7A007A;
	Wed, 30 Sep 2026 17:17:37 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Wed, 30 Sep 2026 17:17:38 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790803057; x=1790889457; bh=V9E6+Jyih2ZQ40BcJgsbHBwin3o99HCpRGz
	ELXlzetw=; b=gUXA9zxvCl88E7U9H1ELAKFIiEoq9DUwy0ZF+tqx5FrgnG9hwXK
	4iD5ixq0DgEybMVSd1c9tJQPi7kbv+JQV/JYjpLZI1Do9UAuqRCtKpd7In4c1pFt
	rXs3F64y/1jKu/t0XreWnbOiW0skqywzptfwoDtXtQPm2ruq8GnYJzVPsjGpo0aH
	+IO0RcJXgmPEYNkm7fmuYmgxhrBALOvZEhZA4ibYIIsKPZ1OETgah1K35fBWoy/w
	jNFSbZLZilemLVVYxy6r0XEr28gityms96SdSAMWSBW42T7FTv31VWLaf4OJL8ck
	a9z7ZxSlz4gQ4s7LGzxvfWZDXNg+9S0pnPA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790803057; x=
	1790889457; bh=V9E6+Jyih2ZQ40BcJgsbHBwin3o99HCpRGzELXlzetw=; b=A
	i357FG4Jnav2tyizPLAibOuTXTqLmY2V4SpW6nx8o2zO1RiXUV3kDXFBLJqw+/bc
	e3wtKm2p+2V3ydT0roECUJGjyx5awjAIJ6zgvvlfk0XLQ8WNEr0QXBX3PKTodIeP
	1ROZlKQnqWaPxc6SXB00RUGfZbtZGYuwsoKQEgI4ccFK7tA0sU+abraW4M8KHni3
	u8wKNdnE77iSPqtMUYCnzRj3bmz8yTPm8q82DwocT1LVD6q2shLtfMfero22IGqp
	vQsmCHG1EID6146n9HGOAKtHCqOHgMlJJ2ePEfyfnC2Al3GYhpDLbluzsd98JBJD
	KxNDdsZYKaunW3AB9oXHg==
X-ME-Sender: <xms:cXy9avRQCNJb0LtMdn_GyXsh_g4_xuM6v08LfuG3ThBIVO5c5l8w0g>
    <xme:cXy9avA1roG_u07nEMZE7ZxzzAtkzRCCOu8b8WnqiUi23ufEVUSRte6XBhtGfs5En
    aoap34I_6pJQF1n0JwMx8tSYBWJ4a4bVxylnecBzwen79rYtIM>
X-ME-Received: <xmr:cXy9auLaMIxwZuRdK7VEWra6UA_xz9Z_GwGU2cm7kF07hlJ0uIHZ3Vo8bH2i01MtCSLeYS_I0CocLj9_9gsb6Nu7uCot5Nk>
X-ME-Proxy-Cause: dmFkZTEiP7eojnwJIrVLqcVTGL46onno6ZtSQqEedKDBUHsPo/W4h3ztg05trwBtbbPtpz
    hO9vqks2n/NfgmVUC38eSh2fEAYv+kUiNi1jrR3di4Yf9S0nlAOV0eSosUQgDnM9G6KpvR
    ow+NP8ygfvWV+J2za5klwIvKjB9uu5bh07eDMNphduRQ0kUsM1cXIYwWXYyjK6CmbgZ+QM
    zL8YEAH/t0zC0lFDwZeo/Isjuens0kdSIWL/jv2kgHqs6bkdryiKUnB+0l/6Dt5GpVZFp+
    ZQsH9oYPU+I2EO3+H19UwQ4/PoKrZVePofPFMErsnlXPzeLzdczP6ijEdAxGgu6kagyEgF
    ylupx+2sygvNZVSFzRZbJSpjppFukSc5Ki6msbZUqddrJQhj2ENrOIro0309iXSDRyTYyd
    x6G7m+I/dWaVaM2CVi4HaeBO0jb8j0VGE86qSj5uKYHg0SVOCxL331tvF6ySDejSEK2jS9
    +xy0bLa4k3iT1X3aZc97Fx6oqn1XSnHZzRlZOeKhj0PPqlQ5j4xFzsDD+it7LA0i+DyYcJ
    NWJUUT/Pg+OQmexUCdf3h6M2hATsOCXBvlZU28ctTocATHxcR6P7xFpg/J8Mr66CxF70Ad
    qc+1di1mSRPYXtYLRvautb5cfiFwMqzXQ0k0YisC+27dWdyaKMXvRuNqsaxQ
X-ME-Proxy: <xmx:cXy9aiARsVC8nEVO2A71lPuR8oMhJwYQoUFSvw7Ntg7WEoZAU33hYA>
    <xmx:cXy9arslEsof58jfBeNgPHlkqIq1t2MmuMMNdJbuZl8rXAK9Y_e8Kw>
    <xmx:cXy9aoR9NQcQZpPFkLFGYxOueQtnnSz2OmUEPm20ojwyTaEgPO1Onw>
    <xmx:cXy9aqJCjBajqa5wLsmWxoc-4mUuD0j5BCuOZsGOF39n1LvK2RYanw>
    <xmx:cXy9ai27OD0UI_I883TC49iYqPI7vaYFBJ9LZMLiP9VhxXLhqtoe1Zir>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 30 Sep 2026 17:17:34 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "John Stoffel" <john@stoffel.org>
Cc: "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Jan Kara" <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 3/9] nfs: remove d_drop()/d_alloc_parallel() from
 nfs_atomic_open()
In-reply-to: <27325.7525.26178.516077@quad.stoffel.home>
References: <20260929022547.1428036-1-neilb@ownmail.net>
  <20260929022547.1428036-4-neilb@ownmail.net>
  <27325.7525.26178.516077@quad.stoffel.home>
Date: Thu, 01 Oct 2026 07:17:32 +1000
Message-id: <179080305245.37859.18267888595495397553@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 01 Oct 2026, John Stoffel wrote:
> >>>>> "NeilBrown" == NeilBrown  <neilb@ownmail.net> writes:
> 
> > From: NeilBrown <neil@brown.name>
> > It is important that two non-create NFS "open"s of a negative dentry
> > don't race.  They both have only a shared lock on i_rwsem and so could
> > run concurrently, but they might both try to call d_splice_alias() at
> > the same time which is confusing at best.
> 
> > nfs_atomic_open() currently avoids this by discarding the negative
> > dentry and creating a new one using d_alloc_parallel().  Only one thread
> > can successfully get the d_in_lookup() dentry, the other will wait for
> > the first to finish, and can use the result of that first lookup.
> 
> This paragraph is confusing, and I'm not sure which thread can use the
> result of the first lookup from this description.  

Unfortunately it isn't clear to me what it is that isn't clear to you
:-)

When O_CREAT is not requested, calls to ->atomic_open are protected only
by a shared lock on the parent so if the dcache contains a negative
dentry for a given name then two ->atomic_open calls on that name can
happen concurrently.  That can be a problem as they both might try to
instantiate the dentry with an inode, and the second to do that will
trigger a BUG.

This is fixed by discarding (d_drop()) the dentry and using
d_alloc_parallel() to allocate a new dentry.  d_alloc_parallel()
effects a lock.  Only one thread will get an in_lookup dentry.  The
other will block until the dentry has been instantiated, and will then
be given the non-in_lookup dentry.

The current code does all this in nfs_atomic_open().  The new code does
the d_drop and the d_alloc_parallel() in VFS code were I can manage the
locking rules more easily.

I thought that is what I said above - though more briefly of course.  If
you can point me more precisely to what is not clear in the original, I
can try to improve it.

Thanks,
NeilBrown


Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1DB8D3D5227;
	Tue, 28 Apr 2026 14:22:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777386147; cv=none; b=nWirvew7GheVj9XoKjVX9pVDmdE1wG7E4STvUFXRsVUdpb9OFgNPMgmf2X+q2UTu9RsTJbccaZcYPcIbqngNZQZVWE0HeqVizT7hJzc2JiYDhMu+GrpNQqW14Rnqu96v/i8fvo3BDww+KrdY8SXh5IfUZ4fw1/q+NHjkAMkwX50=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777386147; c=relaxed/simple;
	bh=sl1fqLImGDcEEKCBCo2L/+ljN9uGeACIGU4eqA8valA=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=ap74bTGjQsdg8Xe3g1V/JqBv/gKYb4yjtlVB10JWVnImhhTJWvTVshrXlTWxZzgdwG5BKGztYizRTcA87+HRFf+BCDlYa2BvIrhkLn/MzPXafJU8/xCp/C2Hu4un2L1QD4NkhKMEbb1/vODQ+kAVFQwKQqW+X9zcPciZHgBOUPU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=mSJdFBE9; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="mSJdFBE9"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=r9Hup9E3/oT6Fka4DsUaI6wjWjOX8izftWYyjO/QbNY=; b=mSJdFBE9ahFIrl6ZrqyL0VQTJt
	+HNrR+hnMC33kG0BDUrznpRNac4VLuKJ4jBHg2SWoV9cChvQQl5dmfCyFqK9qtSzedBDKT4jEQlWi
	Pf/+80uv80xoyV2dE/1vYukGEoqB9DB3AqC2ei2nZGmQy3exf4KpbFfDjeAWjHS85acg/PkNuMWoP
	uNfpusC6O6ynrKoCsGE1Z/Ic2pARN5i0Kej0bgHBaaYAWRro38zzoLmh0ql9x+ffpAYW111RKEZZ4
	RTdyWhnPEfIuHZV79U8goabOKFh/l4OeYbTWJieXjFbf/S2ahgR4l7OZpfeZM8vMX/uKNOh3k/emv
	ihXe8tFA==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wHjKT-000000011sv-3ldP;
	Tue, 28 Apr 2026 14:22:27 +0000
Date: Tue, 28 Apr 2026 15:22:25 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: NeilBrown <neil@brown.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Amir Goldstein <amir73il@gmail.com>, Jeremy Kerr <jk@ozlabs.org>,
	Ard Biesheuvel <ardb@kernel.org>, linux-efi@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 04/19] VFS: use wait_var_event for waiting in
 d_alloc_parallel()
Message-ID: <20260428142225.GX3518998@ZenIV>
References: <20260427040517.828226-1-neilb@ownmail.net>
 <20260427040517.828226-5-neilb@ownmail.net>
 <20260428033738.GV3518998@ZenIV>
 <177737511992.1474915.1952404144121931523@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <177737511992.1474915.1952404144121931523@noble.neil.brown.name>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Tue, Apr 28, 2026 at 09:18:39PM +1000, NeilBrown wrote:
> > d_must_wait() conditional, though - ->d_flags and ->d_lock are in different
> > cachelines and there's no need to dirty both every time we are called.
> > IOW, have d_must_wait() do this:
> > 	if (!d_in_lookup(dentry))
> > 		return false;
> > 	if (!(dentry->d_flags & DCACHE_LOCK_WAITER))
> > 		dentry->d_flags |= DCACHE_LOCK_WAITER;
> > 	return true;
> 
> The only time that DCACHE_LOCK_WAITER will already be set is when there
> are two (or more) waiters as well as the thread they are waiting on.
> That means three (or more) threads all accessing the same name at the
> same time.  How often does that happen?  Is the micro-optimisation worth
> the small increase in code size?

Depends upon the load, obviously - a bunch of threads hitting the same
pathname at the same time... not impossible.

More to the point, why not set DCACHE_LOCK_WAITER as soon as we grab ->d_lock
there?  Then waiting becomes simply "wait until !d_in_lookup()".  Sure, we
might end up setting DCACHE_LOCK_WAITER on a dentry that has just dropped
DCACHE_PAR_LOOKUP - who cares?

While we are at it, do we need to drop it when we clear PAR_LOOKUP?  Because
if we do not, the whole "what do we return from __d_lookup_unhash()" thing
disappears - we simply pass the dentry to end_dir_add() and have it check
->d_flags & DCACHE_LOCK_WAITER to decide whether to bother with wakeup.

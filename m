Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DB453655C5;
	Wed,  3 Jun 2026 19:02:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780513350; cv=none; b=BeP6fHIMaRkimBmox8V0lWCZ9BWlfQulwSR3wOpfgS/Agb4RYcPtmKnRVQcQAtKfKIgI1u+q7UQTjPlvqAhyZK9gxOxo/K9e6howNw+CwPbVbgzhHODbBGTrDk0SR4MWsTEpxoG97rSEVRh3nMxypsesYbr/mPAl7nYHCcE/ybY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780513350; c=relaxed/simple;
	bh=HPApwlQDrWbolSphIH6jYlGyQXHHjK8fwuBm8moe07M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=SBevPq0ARZm5vjQFRp4IfWpArLHi5dZ6buAuliHXxVfanFDa//I7tHXPa0xKdhLazr0/L/21L3qAMrA5BgjaKhV6mf3kPN9NpyrhTtKZwLRXV32Z+FwJGAHH55zGfSquAaad6Gq81d4gAfP0WviDdBSWt2cjNzJUJELlPERN2ok=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=MTU06pwv; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="MTU06pwv"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:
	Content-Transfer-Encoding:Content-Type:MIME-Version:References:Message-ID:
	Subject:Cc:To:From:Date:Reply-To:Content-ID:Content-Description;
	bh=Dx5V5pnYItNCZyfVfK3O6R3GKLUSz5A1jQjn4R0ZC6E=; b=MTU06pwvdUEbHNL7eu08leeXy8
	3RCh27NYYtONEyxb+v+ypGWOrKpgTVHUJtt/yGH3hYxqBxJA/GzAci1tDwFPvlzTkrUaul77ogQ8y
	JNBGcRObgcFwQ8HQiy3E6ERXT/c4v4j3LnKmLqjJxSsEb6fU0yYAaFknSFfpInKSdtOPDfD6D1jNJ
	EejdL2yVScWRqf/qKDF+p3GURuIxjmEV/iVRH0lId/OtfdhBkGVZ+2UR0BCDOjMl/fgyZAalhOKmS
	Ppx6xW5HSA43228dKZZTM9VM3SxtvPpu4i3ImXe9Vt7qVkR8ZCh2lW7bbuhZIBi3HkkrtLdpy4+MP
	0O10GbTg==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.2 #2 (Red Hat Linux))
	id 1wUqrB-0000000FEt3-3TmH;
	Wed, 03 Jun 2026 19:02:25 +0000
Date: Wed, 3 Jun 2026 20:02:25 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Jann Horn <jannh@google.com>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] fhandle: fix UAF due to unlocked ->mnt_ns read in
 may_decode_fh()
Message-ID: <20260603190225.GB2636677@ZenIV>
References: <20260603-vfs-fhandle-uaf-fix-v1-1-ff64ee367e4d@google.com>
 <20260603181523.GW2636677@ZenIV>
 <20260603182454.GX2636677@ZenIV>
 <CAG48ez0Jte3UE8wn9Ljs3o2uVDFB24Zbp9zBdaj+D5c4R0+TSQ@mail.gmail.com>
 <20260603185324.GA2636677@ZenIV>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260603185324.GA2636677@ZenIV>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Wed, Jun 03, 2026 at 07:53:24PM +0100, Al Viro wrote:
> On Wed, Jun 03, 2026 at 08:46:07PM +0200, Jann Horn wrote:
> > On Wed, Jun 3, 2026 at 8:24 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
> > > On Wed, Jun 03, 2026 at 07:15:23PM +0100, Al Viro wrote:
> > > > On Wed, Jun 03, 2026 at 07:38:06PM +0200, Jann Horn wrote:
> > > >
> > > > > Fix it by taking rcu_read_lock() around the mount::mnt_ns access, like
> > > > > in __prepend_path().
> > > >
> > > > > +   /*
> > > > > +    * Containing namespace.
> > > > > +    * Normally protected by namespace_sem, but there are also lockless
> > > > > +    * readers (which must use RCU to guard against the namespace being
> > > > > +    * freed).
> > > > > +    */
> > > > > +   struct mnt_namespace *mnt_ns;
> > > >
> > > > Umm...  It's somewhat subtle - at the very least you need to explain why
> > > > there will be an RCU delay between umount_tree() clearing that and
> > > > having the sucker freed.
> > >
> > > Something along the lines of "removals from namespace are serialized on
> > > namespace_sem and guaranteed to happen no later than the active
> > > refcount on namespace reaches zero; freeing of namespace happens only
> > > after the passive refcount hitting zero and there's an RCU delay between
> > > dropping the last active ref and dropping the passive one that had been
> > > implicitly held by the fact of having actives", perhaps?  Only in
> > > more readable form than that, please...
> > 
> > Hm, like this?
> > 
> > Containing namespace (active).
> 
> Umm...  That's actually "active or has _just_ dropped the last active
> reference and didn't get around to scheduling decrement of passive refcount
> yet", unfortunately.
> 
> Hell knows - "active or deactivating", perhaps?

Note that "active" in such context is easy to mistake for "active reference",
which it definitely isn't - it does not contribute to active refcount.
Mounts within a namespace do not pin it - it's the other way round; they
are guaranteed to stay live until they leave the sucker.  Anything that
hasn't left by the time the active refcount of namespace drops to zero
will get pushed out (and killed off unless there are other references to
any such mounts)

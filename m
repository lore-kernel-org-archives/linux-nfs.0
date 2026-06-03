Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD19C3F1664;
	Wed,  3 Jun 2026 18:41:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780512118; cv=none; b=C55ZH8G6g9BRbTTOAKaJlQ/f2urzpoLHmbuC+xOJ6rpGCgfc6ig2KoR0kprjNEbcdLOhFRGNOu80B3NJ189e1ZBlSG7p0SxX+yQwXMMcsyKIGRUAL5azNw/5oE7nt5WgydJQ2c7JeUQ4ZhpBuVBcfOCbIasTSMiAuGe3F/+MtP4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780512118; c=relaxed/simple;
	bh=uJED0teoIdjVhdoNgWriK1mxOQP+XK7luDMQuvfLecs=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=WEGini6n0CIIi/pMFU9A2zQIOTcne+JIxofw47fkiiwLl/ywIhhM9fF1zhxDBNNaElzmLVAMjK+BVMh+c0KlyBw/tB0W7l397NRlZTNltHH5BpGhZZJXRB/iEAi4fGjtNHJJku6Z6cVhAZE6QXA6IAISOSkSZ23V2XfiQ/A5+d0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=g5s9s+4u; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="g5s9s+4u"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:
	Content-Transfer-Encoding:Content-Type:MIME-Version:References:Message-ID:
	Subject:Cc:To:From:Date:Reply-To:Content-ID:Content-Description;
	bh=ag1oM71DILNUVfABJCnS6ACf7quiWWEKEO5WFYOcjBA=; b=g5s9s+4u6kFwhjlO1F0PVvjyoT
	hCxCSfwCNR8U6sui3Gbf4sWTq2w4acinV0tHGPgQfM5La8H4svnHjwlAW9wlGqTPLftLgoPs7L6Oq
	Oxb1YJB9FzAm8TMSYOKd+1DSLXAvVrR8dT1rFY2P6vJhReIjsg1HvkcfbJC9r4GIW58z2+5Hil2en
	ZyhCA2xEX6+6SSOc9iX04vewpIaGJnEgIkmMFrm/Ajn2O/jTiEA2RnTxpO6I2KDHhQZcJWr04hNVC
	jHgdKhGQeSXJjxF6XLKZuqg9BJuJS2ov9itqaEtsRmzInZJcp9dXXqwry/encQuiR6MB0OswSkbDa
	O9CptaZA==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.2 #2 (Red Hat Linux))
	id 1wUqXH-0000000F9zw-3eq6;
	Wed, 03 Jun 2026 18:41:51 +0000
Date: Wed, 3 Jun 2026 19:41:51 +0100
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
Message-ID: <20260603184151.GY2636677@ZenIV>
References: <20260603-vfs-fhandle-uaf-fix-v1-1-ff64ee367e4d@google.com>
 <20260603181523.GW2636677@ZenIV>
 <CAG48ez1DGQ8MbFWWi+n0Br84cBF_wSrNgPqd+NSxAcbAK7WR7g@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAG48ez1DGQ8MbFWWi+n0Br84cBF_wSrNgPqd+NSxAcbAK7WR7g@mail.gmail.com>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Wed, Jun 03, 2026 at 08:23:44PM +0200, Jann Horn wrote:
> On Wed, Jun 3, 2026 at 8:15 PM Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Wed, Jun 03, 2026 at 07:38:06PM +0200, Jann Horn wrote:
> > > Fix it by taking rcu_read_lock() around the mount::mnt_ns access, like
> > > in __prepend_path().
> >
> > > +     /*
> > > +      * Containing namespace.
> > > +      * Normally protected by namespace_sem, but there are also lockless
> > > +      * readers (which must use RCU to guard against the namespace being
> > > +      * freed).
> > > +      */
> > > +     struct mnt_namespace *mnt_ns;
> >
> > Umm...  It's somewhat subtle - at the very least you need to explain why
> > there will be an RCU delay between umount_tree() clearing that and
> > having the sucker freed.
> 
> I guess I could write something like this instead, to make it clear
> that this basically follows normal RCU rules, except that this code
> isn't actually using RCU markings and accessors?
> 
> "This is like an __rcu pointer which is protected by RCU and
> namespace_sem; however, because most accesses happen under
> namespace_sem, it is not marked as __rcu, and RCU access is done with
> READ_ONCE()."
> 
> Or we could put __rcu on this pointer, and annotate all the locked
> accesses with rcu_dereference_protected(...,
> lockdep_is_held(&namespace_lock)), but I guess you'd probably prefer
> to not do that?

Not the point...  What I'm talking about is the reason why RCU access
to ->mnt_ns is valid in the first place - prompt freeing of namespace
instances *is* possible; we do have a guaranteed RCU delay between
zeroing ->mnt_ns and having the instance it pointed to freed, but it's
not instantly obvious where to look for it.

Basically, the store that cleared ->mnt_ns has been done in namespace_sem
scope and that scope is either no later than the scope in put_mnt_ns()
that has dropped the active refcount of ns to zero.  At the beginning
of that scope in put_mnt_ns() we are guaranteed to have the passive
refcount positive.  Dropping the passive reference happens after an
rcu delay started in later in the same namespace_sem scope and namespace
is not freed until the passive refcount reaches zero.

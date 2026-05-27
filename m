Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B572E30DD2A;
	Wed, 27 May 2026 08:50:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779871852; cv=none; b=CPfOeJSvDV3rHO2SG9r/YkT6jjBoVHV8VsrRrPil+epLvsgQnJRAFSJkEfcwWNArudBbZgGE5UtAAByspoS9chQyto/olof+me29//mBNBaz/iJUC9U/Y65JQIoGo4rDbZkX8azsqnS4C51fIvcmopCjNObdYSucNVkky+B2OhA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779871852; c=relaxed/simple;
	bh=Pos1LKDGnxjII6zvTEyXjuDDOkcVRQtqhKZywYNQGSo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=TNJ/uGIS/OYubOFJ++o7mA2ZI4c/KAePvpFIgS5y9g40wz3wr7nNbRZ1PKP2aS+8IELkmldALwltmyIb0FLiCjaYmaQoRF4O3KGhVWViryHXHkAhNMo0ix8Uy665s/Z/1i2XWqyGkn+n3RBq4Ipmh5C9JxX7IxvMjJ5Pdi1ZRAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b=K+Lei1i2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="K+Lei1i2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8ABA61F000E9;
	Wed, 27 May 2026 08:50:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linuxfoundation.org;
	s=korg; t=1779871851;
	bh=wP+eaBcEtoPp/7xKAXoJ6JjcJom+Mzp3XCjO/gK0Apo=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=K+Lei1i2RUOAYTYZkiOXopxCLHTDTPRpVpJstm6pInlnJQ9qHLOOfWasbnBLkZMM4
	 vXrvnSHqTkxkPy32XlFCSWRCO+yFrXKUrdY4aMgE9d85RXMYr3h2xH3T4VcqEIKQUO
	 gQ/YspVihJ62O1jZUNYdLwkGVyeyuVL/8FBWqxI8=
Date: Wed, 27 May 2026 10:49:58 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Calum Mackay <calum.mackay@oracle.com>,
	Christian Brauner <brauner@kernel.org>,
	linux-fsdevel@vger.kernel.org, Miklos Szeredi <mszeredi@redhat.com>,
	linux-mm@kvack.org,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 1/3] tmpfs: simplify constructing "security.foo" xattr
 names
Message-ID: <2026052722-garlic-worry-03b2@gregkh>
References: <177945382308.2991556.1256192774754909984.b4-ty@b4>
 <5386153f-9112-4971-98fc-de90d7aae2c6@oracle.com>
 <CAJfpegu3PawBxwOPEO-+at-B9zRTJOzY+z4qeV7xOwOQb3Fr7w@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJfpegu3PawBxwOPEO-+at-B9zRTJOzY+z4qeV7xOwOQb3Fr7w@mail.gmail.com>

On Tue, May 26, 2026 at 10:46:12AM +0200, Miklos Szeredi wrote:
> [Cc: Greg KH]
> 
> On Mon, 25 May 2026 at 05:59, Calum Mackay <calum.mackay@oracle.com> wrote:
> >
> > hi Christian, Miklos,
> >
> > https://lore.kernel.org/all/177945382308.2991556.1256192774754909984.b4-ty@b4/
> >
> > > Date: Fri, 22 May 2026 14:43:43 +0200> On Tue, 19 May 2026 10:13:21 +0200, Miklos Szeredi wrote:
> > >> tmpfs: simplify constructing "security.foo" xattr names
> > >
> > > Thanks, this looks great!
> > >
> > > ---
> > >
> > > Applied to the vfs-7.2.misc branch of the vfs/vfs.git tree.
> > > Patches in the vfs-7.2.misc branch should appear in linux-next soon.
> > >
> > > Please report any outstanding bugs that were missed during review in a
> > > new review to the original patch series allowing us to drop it.
> > >
> > > It's encouraged to provide Acked-bys and Reviewed-bys even though the
> > > patch has now been applied. If possible patch trailers will be updated.
> > >
> > > Note that commit hashes shown below are subject to change due to rebase,
> > > trailer updates or similar. If in doubt, please check the listed branch.
> > >
> > > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
> > > branch: vfs-7.2.misc
> > >
> > > [1/3] tmpfs: simplify constructing "security.foo" xattr names
> > >       https://git.kernel.org/vfs/vfs/c/aba5853b137b
> > > [2/3] simple_xattr: change interface to pass struct simple_xattrs **
> > >       https://git.kernel.org/vfs/vfs/c/1cd9d2387c05
> > > [3/3] simpe_xattr: use per-sb cache
> > >       https://git.kernel.org/vfs/vfs/c/12e9e3cd03b5
> >
> >
> > I have been doing some testing of Chuck's nfsd-testing tree, which
> > includes some vfs changes.
> >
> > The test systems are reliably crashing, in what looks like it might
> > possibly be something related to these three patches.
> 
> Calum, thanks for the report.
> 
> Relevant part of call trace is:
> 
> kernfs_new_node
>   __kernfs_new_node
>     security_kernfs_init_security
>       selinux_kernfs_init_security
>         kernfs_xattr_set
>           kernfs_root
> 
> Since __parent is assigned after security_kernfs_init_security() gets
> called, kernfs_root() will return NULL.
> 
> Greg, any idea about dealing with this?

Don't call this so early?  :)

I really don't know, sorry.

greg k-h

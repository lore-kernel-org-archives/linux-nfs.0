Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7DB043DEDA
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 07:52:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790149944; cv=none; b=HfiHswKgzHv4Gi0wC7jwShcHZw912nuKq5YP5vX6Rkc8XyhzpXDsXpLqU1Hh1MoL8DwvDeT+GRvv80w6ICYKrrlCZ265BdbCPdQyo7FZ7eoSRoAAGZbbkx4oi1HgoTqr7FzdFXUpmWXOyQPlQEzGF7Udke8nlNkr/Z9mrOaqX34=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790149944; c=relaxed/simple;
	bh=Fnyr6rVRPoJFxW0Z4pPZSrWsGB1tzbeFsCl+jZOkZ2w=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=aNNGqL5lbfXXKFjKq2LGTLoPPiXqesH/yFibjB/oQGLqksLnddMFs2KgcVUSohCXXK4WtoFkXvLlEM11wPKz7d6YGWaVdTPi0F8f7/WYTmfkmo4jxTzb5G+ikaCDfnRM5R86pmKVqiWqxr4blDuF7t9ml6mbWvpyoFqlyfJEjZU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cw3eLWqz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cw3eLWqz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F2D81F008A4
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 07:52:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790149943;
	bh=1X1/H46wtOUFhCSfHDgaDbvfS/kcoAzk1WxGfPpPlb0=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=cw3eLWqzvQ6o9N8t0qWwBmIxlEDYNV8GtvSjMVPu6lEN0j9d8iq6s8AmwLKcQg7wd
	 p7ayO5WKGZZ+rg4XxSLLwAJ2wo3fBPQluYeZUM2IlX+ZCJtrdDcUozDGj+n/ICHzHJ
	 3eN3VC1YlZHZmMyokfXYKzqh7vpbaFdQnwTdFJH9k599dPjgrauHnrckBVQH0Km/f7
	 aRxSj9RvNBh6bxyyJdqn8jIy9RcCV5kW8Mixj+iDWGTq+ZFAXHFFvlp0FXIJqQSvVf
	 5ZE+EVKan1yDZefR92QtfK01/t6+t475ByaN8Z+SA7Q43WmlJ97o3c/8QtUhkrzyLg
	 B48evJUkQiBtQ==
Received: by mail-ej2-f12.google.com with SMTP id a640c23a62f3a-c254f70553dso91127466b.0
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 00:52:23 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AKwUvByiuvZpYqQ862dBL/u3oABUOTeq+Iv2kok5qLVEoZOPv4HOnj5HaI3hJt6usIzeSTkFPyV3iWPQjlQ=@vger.kernel.org
X-Gm-Message-State: AFuF++lqVpAbjJkJh7X6+3JNLHAvimLIYRjSarh8c7haY8LEct9SKmDk
	983Xml1eC3Rh/DG5fARMVdX7/Ej550YGwdhGqh8KhPtGkNrJzA/Jnc3uoK3ECI5cVCRDxPpiZVf
	2zupcE/WwoDMUpH42N7pcDZ2PSN+PD3c=
X-Received: by 2002:a17:906:4fc5:b0:c25:1b4f:6d95 with SMTP id
 a640c23a62f3a-c2aadc9904amr135862666b.6.1790149941479; Wed, 23 Sep 2026
 00:52:21 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260919022441.3305170-1-neilb@ownmail.net> <20260919022441.3305170-6-neilb@ownmail.net>
 <CAKYAXd9W3O=Dsavu4=XUp+3SyFWOL3Bs7fbzg0YBFpwk4-TCAA@mail.gmail.com> <179014624846.37859.16894598335961934458@noble.neil.brown.name>
In-Reply-To: <179014624846.37859.16894598335961934458@noble.neil.brown.name>
From: Namjae Jeon <linkinjeon@kernel.org>
Date: Wed, 23 Sep 2026 16:52:08 +0900
X-Gmail-Original-Message-ID: <CAKYAXd8_cmVMyD8y4U5+-y3PZta2Mi5KQJX-7XRA88fuEsrX_Q@mail.gmail.com>
X-Gm-Features: AclHuK9GtQXgBccXjDjr02skxzNXUfjo8-6MgvjMV6m7PQmHZG-x4TCWIsJDAUI
Message-ID: <CAKYAXd8_cmVMyD8y4U5+-y3PZta2Mi5KQJX-7XRA88fuEsrX_Q@mail.gmail.com>
Subject: Re: [PATCH v2 05/14] cifs: allow -EISDIR precedence over -EFTYPE in __cifs_do_create()
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jori Koolstra <jkoolstra@xs4all.nl>, 
	Mateusz Guzik <mjguzik@gmail.com>, Dorjoy Chowdhury <dorjoychy111@gmail.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	Paulo Alcantara <pc@manguebit.org>, linux-cifs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 23, 2026 at 3:51=E2=80=AFPM NeilBrown <neilb@ownmail.net> wrote=
:
>
> On Wed, 23 Sep 2026, Namjae Jeon wrote:
> > On Sat, Sep 19, 2026 at 11:25=E2=80=AFAM NeilBrown <neilb@ownmail.net> =
wrote:
> > >
> > > From: NeilBrown <neil@brown.name>
> > >
> > > If atomic_open is given __O_REGULAR, we now would prefer -EISDIR
> > > if a directory was found.  So move the S_ISDIR() tests earlier.
> > >
> > > Also don't return -EFTYPE for S_ISLNK() - that should get -ELOOP and =
only
> > > if O_NOFOLLOW.
> > Simply exempting symlinks from the __O_REGULAR check in cifs is not
> > sufficient. Once this check allows the symlink through,
> > cifs_atomic_open() still calls finish_open() on it, setting
> > FMODE_OPENED. open_last_lookups() then skips symlink traversal, so
> > do_open() returns -EFTYPE before may_open() can return -ELOOP. This
> > path also reaches cifs_new_fileinfo(), which pins the symlink dentry
> > with dget(). The symlink's file operations do not provide CIFS's
> > .release handler, so the failed open does not call cifs_close() to
> > release that reference.
> >
> >
>
> Thanks for looking at this.  I think I can see what you mean.
>
> If __cifs_do_open() chooses not to call cifs_posix_open(), if that call
> succeeds without providing an inode, then we could end up at
> cifs_get_inode_info_unix() or cifs_get_inode_info() and if that returns
> a symlink inode, this will be returned to cifs_atomic_open() which will
> try to open it (finish_open()).
> This is a pre-existing problem - is that right?  If an O_CREAT open
> which doesn't have __O_REGULAR happens to find a symlink, then it will
> already try to open it.
Yes, I agree this is a pre-existing problem.

>
> Presumably after calling cifs_do_create(), cifs_atomic_open() should
> check if the inode is something that it can open.  If not it should call
> finish_no_open().  Does it need to call server->ops->close() too?
> Can I leave you to clean that up?  My goal here wasn't to fix
> everything, but to improve the documentation and change some the details
> of what errors are created by __O_REGULAR.
If the server-side handle is still open, it needs to be closed before
calling finish_no_open().
I=E2=80=99ll take a look at it.
Thanks!

Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43876394496;
	Sat, 19 Sep 2026 01:59:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789783144; cv=none; b=Q+U7XK7S8+GTHNUfMAEfv9c8Vwg4F1zF+eW0cS/kLrM0oO36qAgDeeraDT5b3FTyXLV/+a+O98jlgOdrV9TTarklKGWG4CgZScclk1VNyPLKMvsTe93aOc3GgCy8CI/EkwI21BTLf2+ugIXlPldxU0ol+qHJ6S1UXEoSsRjzCfQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789783144; c=relaxed/simple;
	bh=Vd0Nq0t19M2YgeBBDprTT9iaP7BrVuOAuA3eDx+q/Rc=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=OJ/sfp+hC/SFD/uQ0QJ6rcVTg32Li5tzYvcC/cDk9qo1qoerQvFR0jx1qxfHeqM/qfDypBYfy46COzBarIlqBz3XqCjPrp6gUA4OzHt+S+3tkIOvDLNg7EqAgl0XnzJT9GzJUBzH+Ga57JSOEd8k2UJ4WKwNN5uz6eDJCCU8zMg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=e/Crfu9x; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=hxtJnL29; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="e/Crfu9x";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="hxtJnL29"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfout.stl.internal (Postfix) with ESMTP id A5AD91D00104;
	Fri, 18 Sep 2026 21:58:59 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Fri, 18 Sep 2026 21:58:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789783139; x=1789869539; bh=nh/C4Q5BiOdNTmfqGZnkHCJ3NXU++0bpGH5
	Fc/yEaCw=; b=e/Crfu9xFJH3DGXlXaJf7kxVqMtBHeNtAIYHY80hxwWkQ1PAi7d
	cmOu7J6TF6FAnVoMjZ7l3VtaSo7eu1rePEVdSGwVJ48QgBkm7FS80GabB5r+HySG
	cr9rslHUVAaRqp3kQMYh0sDm2f3UgZpMATbLjhmmZwS6MCOdO1JpL4yi+CkX3Djk
	OW/JCCxDn3UjOQCFzBm3J9TXl0znRo8XvVPBJtPzoI4IFEXpObUaWqsFvWBKwJiX
	hYsQ18sR8n+pO7dqKikKmUUNuJHCLHjqGn0T/vb1HKc1hskvWoB2Y9WdeE/b2adZ
	w7zuQLyQBYPNRtZqmdfengCxTyDbGs4pszA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789783139; x=
	1789869539; bh=nh/C4Q5BiOdNTmfqGZnkHCJ3NXU++0bpGH5Fc/yEaCw=; b=h
	xtJnL29rd8MegqIHK+Bww6hugcnWmKauvdiv2MEwSQyGmN2fuyLV3JGKe8gG2RGa
	YYV7nlfg35h2fZG8/f1b+ZgLz7ZpFNmysTMoO6NVYKN7SGfHLXL0SSsE9ddKk26v
	SaFZNLik+e8+8wbOHkStbUK/kcY/FuImOw37EUA0i+OqTd3OX2LCNz+FjatNnWcR
	W+SnR9NpLxwBlT/LlaZPx2MNizAZBnI2vMYeljpoAiAsUZkKcZottwl+w6WS0j2k
	JzpKgh9eMMv9qi6PepFXWqEEltsf7PEc4oHYBCitHuaj11vPaXHSoNrijj8xNYQM
	WtG8dv7Ri+SZNaWTHcJRA==
X-ME-Sender: <xms:Y-ytalY-zW7zvjB6t4v8sfjnP9eS3k0pmZZq4xU8u5x-FFu714ZDyA>
    <xme:Y-ytarfJFS08frCVGIJ-r-pqPixImaUpJx5r8gLYXPHeS3WXu8575mXj7qe-Jx1YO
    IbItx-aQEzbqfH3CDsy795t83TE3litHrXs0MBWTELsigCkXLI>
X-ME-Received: <xmr:Y-ytauIKwv9Fdxtuo2AukY-_NPrLR640rO2cQkU2sibob80YW3HKeIgf_bCgeYDUo8obGPYircbVAw1-GVX9f-60ff9SsIc>
X-ME-Proxy-Cause: dmFkZTE6QpaXc9yL6AgFKDlkYKF7YCqmm6eIFjQLv/9/Bcjfmgfipz2uUqgaA7IG2xhyxY
    4Yo5/Z6GoTitUvnjJu1Y9ugn5RG1oiZBFSEMiZXcsGg1+U4BNKcDyrRhgPJZJrS3+9Qn8y
    xCY+ZzJyoRRAh/FMV6baelt0EpFENJYWAdhWXiL28Y5KyoFQDwm0EVdopnX6KUdX7SMOcx
    h1OlqpVqTjh4lYSY/zcstp/InDIeejZ1PIsFdUez0ajhtHvkcq9qEjtIOtZ39HIK33Rc7W
    a97Y6Eqw2U7A4RdAen9qqErcyKDkJPrVJYlIjZY+032BS4GvLwWY9kxQjCrbgc9NOT3Lan
    JdJXk/G6TywAA76eIXa7KuC/p6CgyLnsTMbG4oM79JaPU10CtG5oHkS/cXVEZVEPeNQpK9
    mtbCXt6aNH+z5kUBKCDPsiJQUxXwQubwThy8sRA9BIzsWRZkJsPap5q3hP/+onq/Gj3kn6
    KeS5mf5dO35ZE8GPPXnpZ7aXDgfbAp5OuqEwL0TcUV3Si/xiZF6rvyYP4OMN/M6jdQA2Tc
    xhZF7vQjDJWE6L3AXm9VVdVAmHuBdhcixnQb1ux7uWOPHjhtNwp0SVkJqaeZAJi5eBMN/i
    ZGersgbtztoTY6wt3bCME42XsrEXB0QGdFK98rD+lWAXm9bhy7xsnTU/LGeg
X-ME-Proxy: <xmx:Y-ytagLMprT-YSlH4qw5awR1SlnGUFIVfSHjkMk40o-ZmF4JogxfcA>
    <xmx:Y-ytalU3ZbxT5fe9LegaTgzxsyr7_oXkiojLpGo_DezSxdGMZ0rJzw>
    <xmx:Y-ytahnr4r-zPV0qWKI8rsj07bom4iuPr7KFtf6D5qKXU_FkV1chnA>
    <xmx:Y-ytajngpX4bqSy5sOr3NF_0C--yDTa33DNiysYRNWgiM6knGEK2Bw>
    <xmx:Y-ytan-r5zHm9QyCLJBpvlsvenkuQ4LxBE7lIJG4sKW9VAIpSu7u2_l6>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 21:58:56 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jori Koolstra" <jkoolstra@xs4all.nl>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
In-reply-to: <2052084198.1190749.1789567317791@kpc.webmail.kpnmail.nl>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-5-neilb@ownmail.net>
  <aqlXZ7Gunepk_4uV@lt-jori.localdomain>
  <178950702008.207413.8966334050259525793@noble.neil.brown.name>
  <2052084198.1190749.1789567317791@kpc.webmail.kpnmail.nl>
Date: Sat, 19 Sep 2026 11:58:52 +1000
Message-id: <178978313273.207413.10091995194620648480@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 17 Sep 2026, Jori Koolstra wrote:
> > Op 15-09-2026 23:17 CEST schreef NeilBrown <neilb@ownmail.net>:
> >=20
> > =20
> > On Wed, 16 Sep 2026, Jori Koolstra wrote:
> > > On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> > > > From: NeilBrown <neil@brown.name>
> > > >=20
> > > > The caller - nfsd - needs to know the type of object found when a
> > > > non-regular file was found to exist.  This is most easily done
> > > > by passing back the dentry.
> > > >=20
> > > > So change calling pattern so that the path (now called "path") contai=
ns
> > > > the parent dentry on entry and the child dentry on exit.
> > > > vfs_lookup_open() will dput() the parent and caller must dput() the
> > > > child.
> > > >=20
> > > > If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> > > > use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> > > > dentry to the dcache we return %NULL in %path->dentry.
> > > >=20
> > > > Signed-off-by: NeilBrown <neil@brown.name>
> > > > ---
> > > >  fs/namei.c | 31 ++++++++++++++++++++++---------
> > > >  1 file changed, 22 insertions(+), 9 deletions(-)
> > > >=20
> > > > diff --git a/fs/namei.c b/fs/namei.c
> > > > index 0c787363b101..30ccc0c2f02f 100644
> > > > --- a/fs/namei.c
> > > > +++ b/fs/namei.c
> > > > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameid=
ata *nd, struct file *file,
> > > > =20
> > > >  /**
> > > >   * vfs_lookup_open - open and possibly create a regular file
> > > > - * @parent: directory to contain file
> > > > + * @path: directory to contain file
> > > >   * @last: final component of file name
> > > >   * @open_flag: O_flags
> > > >   * @mode: initial permissions for file
> > > > @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct namei=
data *nd, struct file *file,
> > > >   * If the fs object found is not a regular file then -EFTYPE is
> > > >   * returned.
> > > >   *
> > > > + * @path is updated to contain the dentry that was found if possible.
> > > > + * In particular, if -EFTYPE is returned, then @path.dentry will be =
the
> > > > + * object that is not a regular file, or %NULL.
> > > > + * Consequently the caller must be prepared for @path.dentry to be
> > > > + * dput(), an it must dput() whatever is in @path.dentry after the c=
all.
> > > > + *
> > > >   * Returns: the opened struct file, or an error.
> > > >   */
> > > > -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > > > +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
> > > >  			     int open_flag, umode_t mode)
> > > >  {
> > > >  	struct file *file __free(fput) =3D NULL;
> > > > @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *paren=
t, struct qstr *last,
> > > >  	mode |=3D S_IFREG;
> > > >  	open_flag |=3D __O_REGULAR;
> > > > =20
> > > > -	error =3D lookup_noperm_common(last, parent->dentry);
> > > > +	error =3D lookup_noperm_common(last, path->dentry);
> > > >  	if (error)
> > > >  		return ERR_PTR(error);
> > > > =20
> > > > @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *paren=
t, struct qstr *last,
> > > >  	if (IS_ERR(file))
> > > >  		return file;
> > > > =20
> > > > -	nd.path =3D *parent;
> > > > +	nd.path =3D *path;
> > > >  	nd.last =3D *last;
> > > >  	nd.flags =3D LOOKUP_OPEN;
> > > >  	if (open_flag & O_CREAT) {
> > > > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *pare=
nt, struct qstr *last,
> > > >  	op.mode =3D mode;
> > > >  	dentry =3D lookup_open(&nd, file, &op);
> > > > =20
> > > > -	if (IS_ERR(dentry))
> > > > +	if (IS_ERR(dentry)) {
> > > > +		if (dentry =3D=3D -EFTYPE) {
> > > > +			/* Try to determine what was found */
> > > > +			struct dentry *child =3D d_lookup(path->dentry, &nd.last);
> > > > +			dput(path->dentry);
> > > > +			path->dentry =3D child;
> > > > +			WARN_ON_ONCE(child && d_is_reg(child));
> > > > +		}
> > > >  		return ERR_CAST(dentry);
> > > > -
> > > > +	}
> > > > +	dput(path->dentry);
> > > > +	path->dentry =3D dentry;
> > > >  	if (d_really_is_negative(dentry)) {
> > > >  		error =3D -ENOENT;
> > > >  	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL))=
 {
> > > > @@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *pare=
nt, struct qstr *last,
> > > >  	} else if (!d_is_reg(dentry)) {
> > > >  		error =3D -EFTYPE;
> > > >  	} else if (!(file->f_mode & FMODE_OPENED)) {
> > > > -		nd.path.dentry =3D dentry;
> > > > -		error =3D vfs_open(&nd.path, file);
> > > > +		error =3D vfs_open(path, file);
> > > >  	}
> > > > -	dput(dentry);
> > > > =20
> > > >  	if (error)
> > > >  		return ERR_PTR(error);
> > > > --=20
> > > > 2.50.0.107.gf914562f5916.dirty
> > > >=20
> > >=20
> > > OK, so if I understand the problem correctly: the current implementation
> > > does not work for the purposes of NFS because ->atomic_open() may return
> > > EFTYPE on O_REGULAR and then you still don't know what that found dentry
> > > was.
> > >=20
> > > An arugument with such specific calling conventions feels kinda yucky
> > > and easier to get wrong. Why not an out enum arg that specifies the
> > > found dentry type? Seems at least a bit cleaner. What do you think?
> >=20
> > I'm alternating between an out dentry arg separate from path, and
> > reliably returning one of -EISDIR, -ELOOP, and -EFTYPE.  Those are
> > all well defined error codes that are used for exactly this sort of
> > thing.
>=20
> It's only internal callers anyway, so I would take the leeway with some
> errno proliferation. Seems fine to me, especially since NFS needs exactly
> this info.
>=20
> > My current thought is to modify ->atomic_open to respond to __O_REGULAR
> > either by calling finish_no_open() so the caller can inspect the dentry
> > directly, or to return one of those three errors as appropriate.
> > VFS code can map them all to -EFTYPE for syscalls, and nfsd can use the
> > raw error code.
>=20
> Personally, I like this last idea the most. Still, I wish there was a more
> general way to signal XYZ problem happened during function call without any
> worrying about collisions on the very limited errno space. I understand that
> you can decouple the local error codes returned by not directly forwarding
> any errnos from called functions, but this is often impracticable or at
> least requires an ugly errno translate.
>=20
> Interested on perspectives from kernel veterans here what is wisdom, I've r=
an
> into this myself too.

I'm not aware of any patterns that are used in the kernel to address this
issue.  I don't think it comes up all that much, and people create
ad hoc solution that work for their case.

Sometimes this is a positive value returned in place of a negative
errno, though that doesn't work with ERR_PTR().

It might be useful to have a MAX_USED_ERRNO so that any number between
that and MAX_ERRNO can be re-purposed locally, and some automatic
conversion to EINVAL or similar could happen at syscall-return.

I think that mostly people manage with the error codes we have, and put
up with occasional overloading.

NeilBrown

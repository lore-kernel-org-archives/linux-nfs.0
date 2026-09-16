Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.183])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A16624A3F2A
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 14:02:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.183
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789567330; cv=none; b=CqqFaLTIQ/aT8Z1Rnx1THLZ35/tprpSyg0e7f3cBHbRVXyZDME2r5eLgRilHi8wp/muSJUZVOyKpUzWJzKG0yWyVj9qlgSMIXnY3KH3F4IOnDuUVo2xgMFQKeiy2SNs5mog83tkDT90S7aS69xzM/z7VR72n9j9+WqpPfz2Howk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789567330; c=relaxed/simple;
	bh=b2xft+OKM2lLyQoaD18uV1GzD7Aiiqrxm6TJCdgd2P8=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=gZp0J3sbT3XP5D4LzdOdUESBvtL1IuQi5FZdPiTcoTiKbLDPo2n4Y9qoIUNpQAL+MoIwDRGXx8sTzaBuYED4xOrSBvk8jyejfjyfxdGQigBH3aiYBGhsuwJLa7ECpVdr36Odme8WlKzTmXCweS+lnDuxgwm1BK3Mw/3zVZL9Q9Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=njiP/rxj; arc=none smtp.client-ip=195.121.94.183
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="njiP/rxj"
X-KPN-MessageId: 2e5aacfe-b1d7-11f1-8f57-005056992ed3
Received: from mta.kpnmail.nl (unknown [10.31.161.189])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id 2e5aacfe-b1d7-11f1-8f57-005056992ed3;
	Wed, 16 Sep 2026 16:01:57 +0200 (CEST)
Received: from mtaoutbound.kpnmail.nl (unknown [10.128.135.189])
	by mta.kpnmail.nl (Halon) with ESMTP
	id 2e59d1aa-b1d7-11f1-a07b-0050569981f5;
	Wed, 16 Sep 2026 16:01:57 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:subject:message-id:to:from:date;
	bh=KNPF855LWyArwiBTo/NsLgkSqeHprkbCNAzYgmKihk4=;
	b=njiP/rxjV4DV8RpS3k0wfi1drWVXVrMQZqKAwjkS7nlJVvwr/zp2Gt3YFLc2kcCwkA10+PxHM40e6
	 uXtdPQG0PcgaczR0WPPdlCzscxyHxKjuittwRKn6cT0L7bG/hOy3Ce3vZmwKpjWxHSqoDyuKI3Daw8
	 TudRJkg1N+LGETgFZg5SqYJbp2ju6zm1yXRGvOXJWcTaVW0Zjd6byWJ8evWA0o+MgtX2/2PQUU8IR+
	 r5j1meM2ICepAFKYbhlMNdG0ViW73oW27uECOinzByDQbCiXMIch4wWDDxYEyBiHdpn+teodSrx4Ec
	 5abbuftLBdfOpvjy/f6Xs9rZQoR5i5Q==
X-KPN-MID: 33|C9zVEll4OUbKdsU5tNMIxsF3gEx17Vmw5PRawJ5JCL7AUMeW9ifqCtdXsNM3HFB
 6tTtNH1dUxlb77I1rfKLM/97GQWY73zLQfL/FaT+W9Ck=
X-CMASSUN: 33|WSRBIeDpSsFYrliGnJ5yNIoq6U1lWyF+Pja11w6edSIvBSHUwA4F3WLUCJrWz3g
 XLED+gCp3/aeJUBgdLfmGxQ==
X-KPN-VerifiedSender: Yes
Received: from cpxoxapps-mh02 (cpxoxapps-mh02.personalcloud.so.kpn.org [10.128.135.208])
	by mtaoutbound.kpnmail.nl (Halon) with ESMTPSA
	id 2e4af220-b1d7-11f1-8edc-00505699eff2;
	Wed, 16 Sep 2026 16:01:57 +0200 (CEST)
Date: Wed, 16 Sep 2026 16:01:57 +0200 (CEST)
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>, NeilBrown <neilb@ownmail.net>,
	Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Message-ID: <2052084198.1190749.1789567317791@kpc.webmail.kpnmail.nl>
In-Reply-To: <178950702008.207413.8966334050259525793@noble.neil.brown.name>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-5-neilb@ownmail.net>
 <aqlXZ7Gunepk_4uV@lt-jori.localdomain>
 <178950702008.207413.8966334050259525793@noble.neil.brown.name>
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found
 dentry in path.dentry.
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Priority: 3
Importance: Normal


> Op 15-09-2026 23:17 CEST schreef NeilBrown <neilb@ownmail.net>:
> 
>  
> On Wed, 16 Sep 2026, Jori Koolstra wrote:
> > On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> > > From: NeilBrown <neil@brown.name>
> > > 
> > > The caller - nfsd - needs to know the type of object found when a
> > > non-regular file was found to exist.  This is most easily done
> > > by passing back the dentry.
> > > 
> > > So change calling pattern so that the path (now called "path") contains
> > > the parent dentry on entry and the child dentry on exit.
> > > vfs_lookup_open() will dput() the parent and caller must dput() the
> > > child.
> > > 
> > > If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> > > use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> > > dentry to the dcache we return %NULL in %path->dentry.
> > > 
> > > Signed-off-by: NeilBrown <neil@brown.name>
> > > ---
> > >  fs/namei.c | 31 ++++++++++++++++++++++---------
> > >  1 file changed, 22 insertions(+), 9 deletions(-)
> > > 
> > > diff --git a/fs/namei.c b/fs/namei.c
> > > index 0c787363b101..30ccc0c2f02f 100644
> > > --- a/fs/namei.c
> > > +++ b/fs/namei.c
> > > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
> > >  
> > >  /**
> > >   * vfs_lookup_open - open and possibly create a regular file
> > > - * @parent: directory to contain file
> > > + * @path: directory to contain file
> > >   * @last: final component of file name
> > >   * @open_flag: O_flags
> > >   * @mode: initial permissions for file
> > > @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
> > >   * If the fs object found is not a regular file then -EFTYPE is
> > >   * returned.
> > >   *
> > > + * @path is updated to contain the dentry that was found if possible.
> > > + * In particular, if -EFTYPE is returned, then @path.dentry will be the
> > > + * object that is not a regular file, or %NULL.
> > > + * Consequently the caller must be prepared for @path.dentry to be
> > > + * dput(), an it must dput() whatever is in @path.dentry after the call.
> > > + *
> > >   * Returns: the opened struct file, or an error.
> > >   */
> > > -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > > +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
> > >  			     int open_flag, umode_t mode)
> > >  {
> > >  	struct file *file __free(fput) = NULL;
> > > @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > >  	mode |= S_IFREG;
> > >  	open_flag |= __O_REGULAR;
> > >  
> > > -	error = lookup_noperm_common(last, parent->dentry);
> > > +	error = lookup_noperm_common(last, path->dentry);
> > >  	if (error)
> > >  		return ERR_PTR(error);
> > >  
> > > @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > >  	if (IS_ERR(file))
> > >  		return file;
> > >  
> > > -	nd.path = *parent;
> > > +	nd.path = *path;
> > >  	nd.last = *last;
> > >  	nd.flags = LOOKUP_OPEN;
> > >  	if (open_flag & O_CREAT) {
> > > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > >  	op.mode = mode;
> > >  	dentry = lookup_open(&nd, file, &op);
> > >  
> > > -	if (IS_ERR(dentry))
> > > +	if (IS_ERR(dentry)) {
> > > +		if (dentry == -EFTYPE) {
> > > +			/* Try to determine what was found */
> > > +			struct dentry *child = d_lookup(path->dentry, &nd.last);
> > > +			dput(path->dentry);
> > > +			path->dentry = child;
> > > +			WARN_ON_ONCE(child && d_is_reg(child));
> > > +		}
> > >  		return ERR_CAST(dentry);
> > > -
> > > +	}
> > > +	dput(path->dentry);
> > > +	path->dentry = dentry;
> > >  	if (d_really_is_negative(dentry)) {
> > >  		error = -ENOENT;
> > >  	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
> > > @@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > >  	} else if (!d_is_reg(dentry)) {
> > >  		error = -EFTYPE;
> > >  	} else if (!(file->f_mode & FMODE_OPENED)) {
> > > -		nd.path.dentry = dentry;
> > > -		error = vfs_open(&nd.path, file);
> > > +		error = vfs_open(path, file);
> > >  	}
> > > -	dput(dentry);
> > >  
> > >  	if (error)
> > >  		return ERR_PTR(error);
> > > -- 
> > > 2.50.0.107.gf914562f5916.dirty
> > > 
> > 
> > OK, so if I understand the problem correctly: the current implementation
> > does not work for the purposes of NFS because ->atomic_open() may return
> > EFTYPE on O_REGULAR and then you still don't know what that found dentry
> > was.
> > 
> > An arugument with such specific calling conventions feels kinda yucky
> > and easier to get wrong. Why not an out enum arg that specifies the
> > found dentry type? Seems at least a bit cleaner. What do you think?
> 
> I'm alternating between an out dentry arg separate from path, and
> reliably returning one of -EISDIR, -ELOOP, and -EFTYPE.  Those are
> all well defined error codes that are used for exactly this sort of
> thing.

It's only internal callers anyway, so I would take the leeway with some
errno proliferation. Seems fine to me, especially since NFS needs exactly
this info.

> My current thought is to modify ->atomic_open to respond to __O_REGULAR
> either by calling finish_no_open() so the caller can inspect the dentry
> directly, or to return one of those three errors as appropriate.
> VFS code can map them all to -EFTYPE for syscalls, and nfsd can use the
> raw error code.

Personally, I like this last idea the most. Still, I wish there was a more
general way to signal XYZ problem happened during function call without any
worrying about collisions on the very limited errno space. I understand that
you can decouple the local error codes returned by not directly forwarding
any errnos from called functions, but this is often impracticable or at
least requires an ugly errno translate.

Interested on perspectives from kernel veterans here what is wisdom, I've ran
into this myself too.

Jori. 

> 
> Thanks,
> NeilBrown

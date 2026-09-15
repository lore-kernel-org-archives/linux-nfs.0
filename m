Received: from fhigh-a4-smtp.messagingengine.com (fhigh-a4-smtp.messagingengine.com [103.168.172.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46EE63DA7D4;
	Tue, 15 Sep 2026 21:17:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789507029; cv=none; b=qMcfzwqvPnbWAypXSd+7cfbcVBW1SBSPtaXEWerYutMgN1AgUcbb/d0TwqMbzB+739SH78DNLSqxIlxZBH7dqRrtOiZj2ELPb8DfDjPiSRYFWBkxjrMajzDL+2FwKCYabUDOtEYXyyt0rgKHiEiE5OE+If635PpRosthJ/xg2kk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789507029; c=relaxed/simple;
	bh=0g4gXQEvKdHxiViCowhei/H+khkBU4QmyUPqnuM/JNQ=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=gs/HBaY5Ax2NcIMMeBTwA1glJHHP3IBD7oeivc7AyC7HoXCc4eETR0ivQhiOQbmcFb4xC57B7UmRwnjGH1B8x9vixXyFsqByTNc4Y+aNN4VRY2XjLHoc1QEqAZKkInvDWTYqSG4R/Ji0SC04mfa6CYz24uyi4Cgo+upyLkmV6eI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=WmKH2gO3; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=mTfO0XF6; arc=none smtp.client-ip=103.168.172.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="WmKH2gO3";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="mTfO0XF6"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id DD4501400AEB;
	Tue, 15 Sep 2026 17:17:04 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Tue, 15 Sep 2026 17:17:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789507024; x=1789593424; bh=4jID6SAQvoOTU1AMYQdxuvWUhUOZWHs1zWs
	XunLTtSM=; b=WmKH2gO3TGKMm6f2aecREptt0v99IpvSqjzNdSoKR4wxMqYg8ja
	Do99Bu9X8/A7LOAN8EdFjTs7MUSSzCD7XfzQrIWcCLFI+5ff7z8AggHHK7Z9bzk7
	R+wgvml4A9ln4lm5s8wvFtFORM3BeI9OyJ2kfYGJslo5kqgW3FjiCa6YVa7EjQRo
	xQGUET787IVywOeHolmUSIw/pc0MHfSNT+msPFueYLFpXHlcbfEWd+GpjFpFtQss
	ElF2TSQbwlvoXPQdqqHkmK/miI25sxUAW7OwcenyTI9Ova7EsWmvx0LPDdPlJ3pT
	ykojbcRaEY14tqN7kwlEWp8EyMbwjVO2Idg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789507024; x=
	1789593424; bh=4jID6SAQvoOTU1AMYQdxuvWUhUOZWHs1zWsXunLTtSM=; b=m
	TfO0XF6+wpKA8I+aNc2a2J9QSgSyHNdc5iButtGSGw9d6Kkmnx2CS4/leyHTpnNL
	PEp04UsAhVqCi/ONErivIrMH5MPa5V+FsFodia208mDzO3iaMk1wB2l7j9Ui0dKL
	kHH0139SZu0804s7/ffmF8W3MUbbG0K33FhudEyB+I6LF4KeDfNTa+U6V82EF8Se
	7ioyQKBAt3kxY0mXMnuN9Bx0ClpPbYheWXLX4hjePAizcRnUKG4QycYODPypWazA
	uEceFeNBP8QPxqDL7PoQ5hHFwD5VTFgmKuIPbLAUbf9ALkSrqQlgai32Ex2yw1S7
	GpHZRRjvjA7T3lS2P05hg==
X-ME-Sender: <xms:0LWpalvUk0dqZxTOSsk2sSlm8izigUWRwT4Ai9ZxpRZirQP4mNnTDg>
    <xme:0LWpatgnCIf7iYBYMGEWTx11HLz47OEnSi5I9te3xUXvdu8PEgjnYNuqJotBmDP5D
    BE4cm-hX43Q_H2Y9Dn4t58i7sVOhY0_lMxSrUf80gmBwqTy>
X-ME-Received: <xmr:0LWpau_E8XBisM0jbD66cAcZuFwK5UQpXHrsa1jl3VN7u4CSjeTrvxmX_c-TS3NKDK4EcQbOJdjZXkENJnf1bJmaV2EAaoI>
X-ME-Proxy-Cause: dmFkZTGvo87HSMuekebDIz9xxt4tQl/hJrrk9DVjX/jr3iimbJWFYT3pUOsTqTwukVNqPE
    oYy1nMOcJ+nuwR76eaXNjtddCBQHjskptVgeENn6NIp5UQ2jUuo1HyHAXRgZovLUTIj2P1
    +jrd/h00i98mfyWbMzPM/5FpCvuOczKFPEDBhc5lBCXFzrXU71t9RGiKeaMpwOMyw2q2ok
    9+Sb56pjb7GC9AUkCZZwhDU/6IMNHrbpZpxYUNdKQfH/lVeNGzjwnAcR71zS+7cYT0INTM
    PAHN/1cARaoEhn1i1NfwPMqYOxXaJFhsEi+cxBUyitjNcCZJL7fRgjsOILj986JD3RLSYP
    DxCI+Yk8HbKiBP3SgRm3NqKTea3AuJJHWy6bNZBA0Hh2zcKBfuBoHBN5IclUhQCigZpqSX
    Jc8eADgEm2pXG+EFcfvWmeBdE2xBzXI8zw95WxO/bD3J4z1IFgLBdd71q0TOtW1bBoO9Zw
    1ZSvbAkTB8+IgEXgXvq68TJFOsdR3w7SzAQpaF5961aOrojIG0shMqS7sNMjVeOnsdM0oF
    Z4zHzLDX3v1zUhqf+71KC2FvCGK47OkIigG0ZF01bfqjjxUwqCUCrhXgswSKnMCoZP3EHM
    Nckk6As/74Mu8pxTTPcI2EboOR+ehE0yiMpHTjidlKQEpISs5SR7Ji0tcaEA
X-ME-Proxy: <xmx:0LWpaouxHJFkUdTnV4elui3o8Hi_QSQy1NbNoE7hTdM9h4IhsEpyjw>
    <xmx:0LWpaqoIHe91497B4RW2umFlAbt8IkBL4z7dVvR4tilqrxfVEBht7A>
    <xmx:0LWpakpqlS6EJBKix5Qo3HWVA7_uEkcpHbBmm57xTfOQjkBqWnS0UA>
    <xmx:0LWpahYOGL6LKFcRvYP-PDliNJab_T_qA2SD3H2Hl4a3DOqmxhEWwA>
    <xmx:0LWparW1J8n2j0ZtVpPmPxl5pReudVjVn2vl5l6GgLlaSg8g98PjEUD1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 15 Sep 2026 17:17:02 -0400 (EDT)
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
In-reply-to: <aqlXZ7Gunepk_4uV@lt-jori.localdomain>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-5-neilb@ownmail.net>
  <aqlXZ7Gunepk_4uV@lt-jori.localdomain>
Date: Wed, 16 Sep 2026 07:17:00 +1000
Message-id: <178950702008.207413.8966334050259525793@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 16 Sep 2026, Jori Koolstra wrote:
> On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >=20
> > The caller - nfsd - needs to know the type of object found when a
> > non-regular file was found to exist.  This is most easily done
> > by passing back the dentry.
> >=20
> > So change calling pattern so that the path (now called "path") contains
> > the parent dentry on entry and the child dentry on exit.
> > vfs_lookup_open() will dput() the parent and caller must dput() the
> > child.
> >=20
> > If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> > use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> > dentry to the dcache we return %NULL in %path->dentry.
> >=20
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/namei.c | 31 ++++++++++++++++++++++---------
> >  1 file changed, 22 insertions(+), 9 deletions(-)
> >=20
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 0c787363b101..30ccc0c2f02f 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata =
*nd, struct file *file,
> > =20
> >  /**
> >   * vfs_lookup_open - open and possibly create a regular file
> > - * @parent: directory to contain file
> > + * @path: directory to contain file
> >   * @last: final component of file name
> >   * @open_flag: O_flags
> >   * @mode: initial permissions for file
> > @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata=
 *nd, struct file *file,
> >   * If the fs object found is not a regular file then -EFTYPE is
> >   * returned.
> >   *
> > + * @path is updated to contain the dentry that was found if possible.
> > + * In particular, if -EFTYPE is returned, then @path.dentry will be the
> > + * object that is not a regular file, or %NULL.
> > + * Consequently the caller must be prepared for @path.dentry to be
> > + * dput(), an it must dput() whatever is in @path.dentry after the call.
> > + *
> >   * Returns: the opened struct file, or an error.
> >   */
> > -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
> >  			     int open_flag, umode_t mode)
> >  {
> >  	struct file *file __free(fput) =3D NULL;
> > @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *parent, s=
truct qstr *last,
> >  	mode |=3D S_IFREG;
> >  	open_flag |=3D __O_REGULAR;
> > =20
> > -	error =3D lookup_noperm_common(last, parent->dentry);
> > +	error =3D lookup_noperm_common(last, path->dentry);
> >  	if (error)
> >  		return ERR_PTR(error);
> > =20
> > @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *parent, s=
truct qstr *last,
> >  	if (IS_ERR(file))
> >  		return file;
> > =20
> > -	nd.path =3D *parent;
> > +	nd.path =3D *path;
> >  	nd.last =3D *last;
> >  	nd.flags =3D LOOKUP_OPEN;
> >  	if (open_flag & O_CREAT) {
> > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, =
struct qstr *last,
> >  	op.mode =3D mode;
> >  	dentry =3D lookup_open(&nd, file, &op);
> > =20
> > -	if (IS_ERR(dentry))
> > +	if (IS_ERR(dentry)) {
> > +		if (dentry =3D=3D -EFTYPE) {
> > +			/* Try to determine what was found */
> > +			struct dentry *child =3D d_lookup(path->dentry, &nd.last);
> > +			dput(path->dentry);
> > +			path->dentry =3D child;
> > +			WARN_ON_ONCE(child && d_is_reg(child));
> > +		}
> >  		return ERR_CAST(dentry);
> > -
> > +	}
> > +	dput(path->dentry);
> > +	path->dentry =3D dentry;
> >  	if (d_really_is_negative(dentry)) {
> >  		error =3D -ENOENT;
> >  	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
> > @@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *parent, =
struct qstr *last,
> >  	} else if (!d_is_reg(dentry)) {
> >  		error =3D -EFTYPE;
> >  	} else if (!(file->f_mode & FMODE_OPENED)) {
> > -		nd.path.dentry =3D dentry;
> > -		error =3D vfs_open(&nd.path, file);
> > +		error =3D vfs_open(path, file);
> >  	}
> > -	dput(dentry);
> > =20
> >  	if (error)
> >  		return ERR_PTR(error);
> > --=20
> > 2.50.0.107.gf914562f5916.dirty
> >=20
>=20
> OK, so if I understand the problem correctly: the current implementation
> does not work for the purposes of NFS because ->atomic_open() may return
> EFTYPE on O_REGULAR and then you still don't know what that found dentry
> was.
>=20
> An arugument with such specific calling conventions feels kinda yucky
> and easier to get wrong. Why not an out enum arg that specifies the
> found dentry type? Seems at least a bit cleaner. What do you think?

I'm alternating between an out dentry arg separate from path, and
reliably returning one of -EISDIR, -ELOOP, and -EFTYPE.  Those are
all well defined error codes that are used for exactly this sort of
thing.
My current thought is to modify ->atomic_open to respond to __O_REGULAR
either by calling finish_no_open() so the caller can inspect the dentry
directly, or to return one of those three errors as appropriate.
VFS code can map them all to -EFTYPE for syscalls, and nfsd can use the
raw error code.

Thanks,
NeilBrown

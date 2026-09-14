Received: from fhigh-b6-smtp.messagingengine.com (fhigh-b6-smtp.messagingengine.com [202.12.124.157])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07A5C423E99;
	Mon, 14 Sep 2026 22:00:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.157
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789423220; cv=none; b=o1UkGrcDXDWeDknYQWkGzYoDKIWNBXhhmDmZLQrfXzzZF/7ggwCv45Xm64fnnfJy5NHX9izH3+nDugQReq6PMfjJGot5lIIGe99yiEYQCQ8WUnU1/0QA5y7hF+2RRqGZLU9gEyO6F3mmTZ0f/cGyEU7nie8O6TiY28PydX06XoI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789423220; c=relaxed/simple;
	bh=U7Po3XIGmD5WnXqODiveJImEONA04vUf7bVEZasXpzg=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=MzCY/gQ0vgoK1Wr/3n4FRyl2ZU0jitFN/RkLee9GHLeHwv9EGiQPzeQGGRLIGcn+eysu0EdFtDiIcMVfCTI4FLbpArgv18e9soHbKpO+3JfDKtI8h4faTeqktcCl2TazHnoVyxNfypiKu3/CHIhMHG4H1GfP7OWVFt0yEOjGQbk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ncIxh6Y/; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=GgGqNKrV; arc=none smtp.client-ip=202.12.124.157
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ncIxh6Y/";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GgGqNKrV"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfhigh.stl.internal (Postfix) with ESMTP id E93D67A0126;
	Mon, 14 Sep 2026 18:00:16 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Mon, 14 Sep 2026 18:00:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789423216; x=1789509616; bh=+/O8cbNK7AneUbK5Khhf+8X4M22FDfN6jAN
	vhHXMEtg=; b=ncIxh6Y/mmjJ9anGMcT1UxYIdtFQGIsJNQatei7dj+EM2PVW16r
	46mWcEGw7E3wnG5yR6Dahu+lCD3Nz9txkr7BEgBW9NWvkJl2WChb72SzjrwMJuNO
	ugYj9Q0aAC6qvA/ROjzMuPBRARuWG4ceQ6iqNTngEZT2uH2eqHy8M0YiuNtKvUGC
	jGOsAdayUPX7MyxGUrpiV6LCgDFtYY5JmoUfp2qJ9HNu/K0590+peVQs+iy4rVKS
	FfsIl6obmilAcFo4MuRLx9FkUrxI6KoEhjj2RdWDQWVkpV86xSF9Ralsgtb9DgM6
	KgIadJE0uYBePe+dX+SX8GTjL4ORMMiJIWg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789423216; x=
	1789509616; bh=+/O8cbNK7AneUbK5Khhf+8X4M22FDfN6jANvhHXMEtg=; b=G
	gGqNKrVZzNaXTzvwvnm3tVqF2fvyNOWpPyJ/+TqfL8HIhr2LLj2LFGVUOF1j3v3x
	jeBxDTYYD+Dp6W/qvPrueadnjjkY0HnwPD/PiaXRPZbnOcZ8Q84SoC2ah1aLPECt
	x5TSCpKrCNF4zMKLJn+yOgtome8M8joDPUoAlVYwHEJ2klmbcQtV85XLAasQ6aeL
	LHWB0GaY014vWljdJcB1F7Xw/GWYB61/JyBcsGZra5s5qeyYfIc+Ok3TcmWZsK6M
	tUrjGewtUtjESGFk+PYtSxJ5jQKaJGHnYdj242wnuaUpOG8mXQVVKgrwlv6nXCnV
	Rpb1XbU4GruhrY3+uV8zw==
X-ME-Sender: <xms:cG6oanKKjFzyiAdXYDIubUldEqX011r_nrmU6C_Ff50R8OyebEPivA>
    <xme:cG6oaqNZurdu8qrdnAKEQfe8KQN2CLlowJ-Veewmw8SiLmFkk3L3888saYNcMCHxq
    1xO6hsN6gFINvIO5Aif3N9md_2G5PQIC8JJtbkTiSbm4-bNH5A>
X-ME-Received: <xmr:cG6oal5asTbQQN8pvrXiD4n_YO3GekLci1QMVAV1u5urtIef7PIbzCTi2V5_gEsiEg>
X-ME-Proxy-Cause: dmFkZTF5ra8BkwsnAzYDhslg7HdOA3tTnHthlvzeQuHExsImqvTgVv9/gOouS2+xoVvdKO
    57spt1qyTccCTZKBGZ9pvgYVm/2Glg2TAz4q8IZKT1a23BO2k+CmuposyGjfGrQvBy/3hd
    Iegl71s4i6f0albXieII/mcSxTgFyjCN7SOtUIBwUrB7kMtxQPCekkSGiyj8pYVyx6hg/V
    cuwWE/Q7cWa1HMUsb08ugZ8LxP7GvsF4Y2U1Uu9FNYtYLSltKTMwTNvJwmqtcctipl8d5l
    GB/HwcKc6t/GvHxd/1btSPE1eh2zDDO/MeYB8JvQjuAmyTAnS2sTtiYlK+c7VRuRdfr0E9
    2CYQE7cVESGl4tdozHHslg5xJz82EWVsJLXEn9vmgG/oCi0VIpeIu3NALl8HsFvgslV8/U
    7zNiGGrpH1BiFLIeCNaTMF+u+HmA+21S10OHgSFXykYyJLgHL5mLOwJSNyLOIWC0OR2vlx
    GqOR3dpRk1tEL4ypaZiDKYAfF0tDGibwVSjIZvng7jK6p25m/N32VgZGsUf1wZtUAne+TQ
    vPph0EFrY8vtmHM3//9bUDMDYdth9XhBp61NmKiEBbOj0A85tERRP0ci1wD6cU2oUHz8XO
    05Al2oRDH2WqkPWv83J0YE2heYgWQQKOa+FzWCMnl6PSborzPmdo1DFishuQ
X-ME-Proxy: <xmx:cG6oas4LRehjSseb6Jy7U1tR7nOe4bN9pLcrOEFydhJlRuRgEDt3bw>
    <xmx:cG6oajGpJ5yTa4OPozs4559vu1pIf-vQEcv5xS5ESLTYoy3lxLdisQ>
    <xmx:cG6oasUNyXbCOyKTmJnVBPFQlSZK7Rowu34ZhlD0bk7tnz7Wr_BYdg>
    <xmx:cG6oanUrWUCMR2IGHnoifGJ4427Ik8-D20S4fxFlybU4O5NlxsqJDw>
    <xmx:cG6oaptJyjQ2qsrfWu0eDCzTagaUTPv8JSOyTFB7bM7UIypF-C5aBlmd>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 14 Sep 2026 18:00:13 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Mateusz Guzik" <mjguzik@gmail.com>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
In-reply-to:
 <CAGudoHG59N0Fen0-Wh+yz+OMA_HcX+Bu-dx+7J0QnypyK_b3ZQ@mail.gmail.com>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-5-neilb@ownmail.net>
  <2mr6afww7r67o2hjblafhdwqffg3zicsqjkddnquunfaalolpd@yq54r5nlqftm>
  <178933378203.207413.6142548185484898062@noble.neil.brown.name>
  <CAGudoHG59N0Fen0-Wh+yz+OMA_HcX+Bu-dx+7J0QnypyK_b3ZQ@mail.gmail.com>
Date: Tue, 15 Sep 2026 08:00:10 +1000
Message-id: <178942321010.207413.739445924462882192@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 15 Sep 2026, Mateusz Guzik wrote:
> On Sun, Sep 13, 2026 at 11:09=E2=80=AFPM NeilBrown <neilb@ownmail.net> wrot=
e:
> >
> > On Mon, 14 Sep 2026, Mateusz Guzik wrote:
> > > On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> > > > From: NeilBrown <neil@brown.name>
> > > >
> > > > The caller - nfsd - needs to know the type of object found when a
> > > > non-regular file was found to exist.  This is most easily done
> > > > by passing back the dentry.
> > > >
> > > > So change calling pattern so that the path (now called "path") contai=
ns
> > > > the parent dentry on entry and the child dentry on exit.
> > > > vfs_lookup_open() will dput() the parent and caller must dput() the
> > > > child.
> > > >
> > > > If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> > > > use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> > > > dentry to the dcache we return %NULL in %path->dentry.
> > > >
> > > > Signed-off-by: NeilBrown <neil@brown.name>
> > > > ---
> > > >  fs/namei.c | 31 ++++++++++++++++++++++---------
> > > >  1 file changed, 22 insertions(+), 9 deletions(-)
> > > >
> > > > diff --git a/fs/namei.c b/fs/namei.c
> > > > index 0c787363b101..30ccc0c2f02f 100644
> > > > --- a/fs/namei.c
> > > > +++ b/fs/namei.c
> > > > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameid=
ata *nd, struct file *file,
> > > >
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
> > > >                          int open_flag, umode_t mode)
> > > >  {
> > > >     struct file *file __free(fput) =3D NULL;
> > > > @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *paren=
t, struct qstr *last,
> > > >     mode |=3D S_IFREG;
> > > >     open_flag |=3D __O_REGULAR;
> > > >
> > > > -   error =3D lookup_noperm_common(last, parent->dentry);
> > > > +   error =3D lookup_noperm_common(last, path->dentry);
> > > >     if (error)
> > > >             return ERR_PTR(error);
> > > >
> > > > @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *paren=
t, struct qstr *last,
> > > >     if (IS_ERR(file))
> > > >             return file;
> > > >
> > > > -   nd.path =3D *parent;
> > > > +   nd.path =3D *path;
> > > >     nd.last =3D *last;
> > > >     nd.flags =3D LOOKUP_OPEN;
> > > >     if (open_flag & O_CREAT) {
> > > > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *pare=
nt, struct qstr *last,
> > > >     op.mode =3D mode;
> > > >     dentry =3D lookup_open(&nd, file, &op);
> > > >
> > > > -   if (IS_ERR(dentry))
> > > > +   if (IS_ERR(dentry)) {
> > > > +           if (dentry =3D=3D -EFTYPE) {
> > > > +                   /* Try to determine what was found */
> > > > +                   struct dentry *child =3D d_lookup(path->dentry, &=
nd.last);
> > > > +                   dput(path->dentry);
> > > > +                   path->dentry =3D child;
> > > > +                   WARN_ON_ONCE(child && d_is_reg(child));
> > > > +           }
> > >
> > > Does anything prevent the child from flipping over to regular?
> >
> > Yes.  An inode is never allow to changes its type.
> > And while you hold a reference on a positive dentry, the inode is that
> > dentry is not allowed to change (a negative dentry may become positive,
> > but a positive dentry must keep the same inode).
> >
>=20
> Let me restate: what prevents the repeated lookup from finding a
> different dentry, which also happens to be regular?
>=20
> I don't see any locks held here to prevent it, so AFAICS in the time
> window between lookup_open() and d_lookup() someone else could have
> for example unlinked the target and linked something else.

Sorry for misunderstanding - Chuck reported that problem too.
I think I have a solution involving a small change in the ->atomic_open
contract.=20

>=20
> But that's a side remark, the real criticism was later in the e-mail
> and it is present in the quotation below.

Sorry I missed that :-(

>=20
> > > I would say this is the wrong approach to the API. The path dentry
> > > switching is a massive hack and should be avoidable. So happens I was
> > > working on cleaning up the overall handling and you convinced me to post
> > > the patchset early, see:

"massive hack" is in the eye of the beholder.  Updating a path->dentry
while walking down a path component is a common pattern in in namei.c.


> > >
> > > https://lore.kernel.org/linux-fsdevel/20260913144918.1606123-1-mjguzik@=
gmail.com/
> > >
> > > On top of that the routine as is has avoidable refcount traffic and it
> > > seems you are adding to it. Instead it can switch to vfs_open_consume.

That argument is somewhat less "in the eye of the beholder".

> > >
> > > On cursory reading of the nfs patch, the following should do the trick =
instead: split the
> > > helper into 2 parts (say vfs_open_lookup + vfs_open_lookup_finish, mayb=
e add
> > > vfs_open_lookup_abort should the caller decide to not go through with
> > > the open).
> > >
> > > Then in nfsd you could have something like this:
> > > struct vfs_open_lookup_arg v;
> > >
> > > vfs_open_lookup(&v, parent_path, ....);
> > > [ child dentry is in v->path->dentry, do arbitrary work with it]
> > > if (ok)
> > >       file =3D vfs_open_lookup_finish(&v);
> > > else
> > >       vfs_open_lookup_abort(&v);
> > >
> > > The new struct would hide 'struct file' and whatever else
> > > vfs_open_lookup might want to allocate first.
> > >
> >
>=20

Thanks for the suggestion.  I'll consider it and the patch set you
mentioned above.

Thanks,
NeilBrown

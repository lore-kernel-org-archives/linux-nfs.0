Received: from mail-ej1-f50.google.com (mail-ej1-f50.google.com [209.85.218.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EFF5F3A9615
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 20:59:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789419571; cv=pass; b=Ojl0RqbTd52+A0DBo7vPU+VMNOsdANpFOb7sR5XYZVx+k2RmKcsI5mJTlC3Gz4B+ENCMMTBeqxMnVkLMQ7DdmiNXHsCPGEDfDOQCNTnhfe9YfrzKMOlpo6fdzM/BEPfrzfZdzUm1mSNFFncuGtkGXw+3mw4DIPhhQmFtZl7rSq0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789419571; c=relaxed/simple;
	bh=j7u3CVocYfNSz6ykANmlSKsGM16yN6Y/4fPWJSUINcg=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=XZ0DLNLEjy+3OpSHeOZKz55JnjKs8vfSzfAEwlpO8mIXCR6KGNv8QUYe+BFlC47iPzv8dAH/BlujcUDzyExJCsLjUiWidNx33XN2b8ey61Jp7F9MxE76jUA+lUeswuTTYQIPlA4dKFyob9D/JCAN21CS4G00rhWKUgcNcybzJJ4=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=nVIWYqIF; arc=pass smtp.client-ip=209.85.218.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nVIWYqIF"
Received: by mail-ej1-f50.google.com with SMTP id a640c23a62f3a-c1670dad7a8so673651266b.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:59:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789419568; cv=none;
        d=google.com; s=arc-20260327;
        b=W5sWCmXvCOXdavOOZ5jW1kQWTXotH0prAfOr/Vbc05OCpj3kuyduw2tmlARD9JJI4+
         3sPAYwPnk9uxerQ1cpHKSHFFNmFdHcXroj722GqjjUrz6JIZP4KCugftM9s5klMQDYJz
         LnWIUD7hokMMx/snWa7yi5AeLF7dDXNhwpgK4rYhUqTSg8xBkIPFbUQqefq9Ejh3wj+9
         JrSoRF6YchXMcEvU7SgFuXt3QHJfieM2tQViwhkyuh7q3i4HVUeKFFrt5Z/bHtr04ciP
         ec9eEgOqcboW+LYwr/6akLMMJs+gMj5Mea5sIh5a3r8eOwH2c8Nm9LwzyxisC0P3YQly
         dpMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=7LSg5RdUyrJ+d+U0WBwd0ySTQ6Z5VZa5bGOIanx2lvk=;
        fh=xghaZyxNGwvx+jy4/bEQHfG8edGUljwg/3IibTQpjKE=;
        b=OjBBHJ3a6jae4prYSVT0Obiv2WP6fhijs+mPd86QU5WozKdT27rNvgOr7riVynXXUB
         m0PHyF1ZqLrH7fiUI1z6U27Y5xP/DrKuri+xSzPnOABCME0wrfYxfSmPauJ2X8YyWH+I
         kbTW1lZm4Q5QdiYcPoyGNECzu8jQa89BVxXZ1AVfpr24vzzqXdcMRpsoJAoAYr83UXHM
         hrfcyJzedtCpWSGZ7O41N/XLMZ1jTHVeOysbZRK3bGw83vn6hmENb4dxebiAhodaeNzC
         vn9VgAnWcBF9Li3VmVbQGhX315Tp6ldPF5TKYAlpCj1S45E9GRGszymkm1SYxI7ExHum
         EkQg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789419568; x=1790024368; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=7LSg5RdUyrJ+d+U0WBwd0ySTQ6Z5VZa5bGOIanx2lvk=;
        b=nVIWYqIFnX26CKQeY6NMWP+RgaIiLlJnjeRRgDQtOEm+YfIFWWnDM0+XpuyT/LmW9S
         I/HrVOtJCqPrir1zKI7OqJsgA5uezQKJxx1xhu1iQB3WLLdzs6sPvt7T9ACMWjo0ee5H
         xXKwfnnlUdQykcsMCOOQ7ADoB+LsjFJdQTdw4FS/W1VsS4YNf2Vm4IAEtCC7fuSRkgTe
         YjQ/yzELwEpxn2QsxPJTvSLFNe02uXQS+AwO9mTpDYaXyeJx09q4kirlx6gwJqTr2heH
         mxj4fREfaQTKkkVFcKKDV+pGlh4Ef/a06XtnYQ2q/u5LHoU85DUwBOiH6Yn5N7LfKL2x
         hpXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789419568; x=1790024368;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=7LSg5RdUyrJ+d+U0WBwd0ySTQ6Z5VZa5bGOIanx2lvk=;
        b=B+AadAeFjoMyxCnCWrTjFxS9xRIVYtNpWGeUtfaQ0cegQrWEvm2t6+HLDyFxcLL49M
         1J+S2TOXurLdKyAXsS3dbM5jNxce9sdT2qLS2OsJzJF9TcoooeYfcPwi8gXmRPsGmXDf
         8okunF2crtOKJwR8Wkr3dubSDN/+5zgUlpV3VA469tDJ1NVwSem16vLy4z/F0RuOPHN6
         0115fSoTJPXgiAjSR9UxAAuZ4VQcntexpMTw0zpjmwLoYoGWMvo53Tp77SF6QUjLyCKR
         NQV0VnkNSb3A9/PnrKk6GZZhoFwXXpRgyHoYdRvLt4CY18Im8GpNNivZ6lULwiq0F9r1
         Lv7g==
X-Forwarded-Encrypted: i=1; AKwUvByplZophqkqQIFa26qoacHu/X2VUh8Tqa96vU0M/TkXQPRCGPNPWaPffbtkIC4KRj1SzkQXgj/mlZM=@vger.kernel.org
X-Gm-Message-State: AFuF++mPLX9bOsOh0pKHaXcBUm/5VGqvkOlnJM18teuPR+oM5jDoYLY5
	DDJoZjX/qBFjeGB/kn3IggBkF+d9EIjSTUQvkDFk63tl7uPmipByOoQiw7JLnaPlWnTww7PZv1W
	zNMarAvEEdrthAZFZT2QXn/w3SBWWHB8=
X-Gm-Gg: AYBFou3PY+O9tDnxpRPAIYV7zpQc+EHpIWLFmGf5FkWix2v1EG6AROJnrCT8F0L6Yfy
	d5zVMQf/gqymnG3gFj3B/XiqogPNb2spSb5+fXIBAZVMgbMDvf96/7NLaxSKkq3V4VSa5HtmMoy
	S35LP465prq6G40ij5gy1W7rWEpFVbjntOuVOIe45JhmO1D6brOxxlzIaBeRHOUp/3oq8GnMa2e
	6HDHSsXlr4XgRSVBbxJkqTCrxkbLyk2vt9FZUZHKvXnQDnkZo1auKifb6Fhq5qguICH1EStIXik
	aLfVRFhFNCIxzH4z55WEThwugOQOFSlu4YRfarUBNOI3Jxv3CZe9wJMrWIMuYtNAQ8kvyxI9r1R
	5UJ189sPU
X-Received: by 2002:a17:907:930d:b0:c27:420b:7c82 with SMTP id
 a640c23a62f3a-c29b876e022mr286157366b.48.1789419567915; Mon, 14 Sep 2026
 13:59:27 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260910002934.192979-1-neilb@ownmail.net> <20260910002934.192979-5-neilb@ownmail.net>
 <2mr6afww7r67o2hjblafhdwqffg3zicsqjkddnquunfaalolpd@yq54r5nlqftm> <178933378203.207413.6142548185484898062@noble.neil.brown.name>
In-Reply-To: <178933378203.207413.6142548185484898062@noble.neil.brown.name>
From: Mateusz Guzik <mjguzik@gmail.com>
Date: Mon, 14 Sep 2026 22:59:14 +0200
X-Gm-Features: AcwNN1Vo9_WgDFAN78Ox2ZEC0TlJ_qNc6EDOHH1iRPNXfhxDrKnXqyUtshK7RNI
Message-ID: <CAGudoHG59N0Fen0-Wh+yz+OMA_HcX+Bu-dx+7J0QnypyK_b3ZQ@mail.gmail.com>
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 13, 2026 at 11:09=E2=80=AFPM NeilBrown <neilb@ownmail.net> wrot=
e:
>
> On Mon, 14 Sep 2026, Mateusz Guzik wrote:
> > On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> > > From: NeilBrown <neil@brown.name>
> > >
> > > The caller - nfsd - needs to know the type of object found when a
> > > non-regular file was found to exist.  This is most easily done
> > > by passing back the dentry.
> > >
> > > So change calling pattern so that the path (now called "path") contai=
ns
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
> > > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameid=
ata *nd, struct file *file,
> > >
> > >  /**
> > >   * vfs_lookup_open - open and possibly create a regular file
> > > - * @parent: directory to contain file
> > > + * @path: directory to contain file
> > >   * @last: final component of file name
> > >   * @open_flag: O_flags
> > >   * @mode: initial permissions for file
> > > @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct namei=
data *nd, struct file *file,
> > >   * If the fs object found is not a regular file then -EFTYPE is
> > >   * returned.
> > >   *
> > > + * @path is updated to contain the dentry that was found if possible=
.
> > > + * In particular, if -EFTYPE is returned, then @path.dentry will be =
the
> > > + * object that is not a regular file, or %NULL.
> > > + * Consequently the caller must be prepared for @path.dentry to be
> > > + * dput(), an it must dput() whatever is in @path.dentry after the c=
all.
> > > + *
> > >   * Returns: the opened struct file, or an error.
> > >   */
> > > -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > > +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
> > >                          int open_flag, umode_t mode)
> > >  {
> > >     struct file *file __free(fput) =3D NULL;
> > > @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *paren=
t, struct qstr *last,
> > >     mode |=3D S_IFREG;
> > >     open_flag |=3D __O_REGULAR;
> > >
> > > -   error =3D lookup_noperm_common(last, parent->dentry);
> > > +   error =3D lookup_noperm_common(last, path->dentry);
> > >     if (error)
> > >             return ERR_PTR(error);
> > >
> > > @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *paren=
t, struct qstr *last,
> > >     if (IS_ERR(file))
> > >             return file;
> > >
> > > -   nd.path =3D *parent;
> > > +   nd.path =3D *path;
> > >     nd.last =3D *last;
> > >     nd.flags =3D LOOKUP_OPEN;
> > >     if (open_flag & O_CREAT) {
> > > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *pare=
nt, struct qstr *last,
> > >     op.mode =3D mode;
> > >     dentry =3D lookup_open(&nd, file, &op);
> > >
> > > -   if (IS_ERR(dentry))
> > > +   if (IS_ERR(dentry)) {
> > > +           if (dentry =3D=3D -EFTYPE) {
> > > +                   /* Try to determine what was found */
> > > +                   struct dentry *child =3D d_lookup(path->dentry, &=
nd.last);
> > > +                   dput(path->dentry);
> > > +                   path->dentry =3D child;
> > > +                   WARN_ON_ONCE(child && d_is_reg(child));
> > > +           }
> >
> > Does anything prevent the child from flipping over to regular?
>
> Yes.  An inode is never allow to changes its type.
> And while you hold a reference on a positive dentry, the inode is that
> dentry is not allowed to change (a negative dentry may become positive,
> but a positive dentry must keep the same inode).
>

Let me restate: what prevents the repeated lookup from finding a
different dentry, which also happens to be regular?

I don't see any locks held here to prevent it, so AFAICS in the time
window between lookup_open() and d_lookup() someone else could have
for example unlinked the target and linked something else.

But that's a side remark, the real criticism was later in the e-mail
and it is present in the quotation below.

> > I would say this is the wrong approach to the API. The path dentry
> > switching is a massive hack and should be avoidable. So happens I was
> > working on cleaning up the overall handling and you convinced me to pos=
t
> > the patchset early, see:
> >
> > https://lore.kernel.org/linux-fsdevel/20260913144918.1606123-1-mjguzik@=
gmail.com/
> >
> > On top of that the routine as is has avoidable refcount traffic and it
> > seems you are adding to it. Instead it can switch to vfs_open_consume.
> >
> > On cursory reading of the nfs patch, the following should do the trick =
instead: split the
> > helper into 2 parts (say vfs_open_lookup + vfs_open_lookup_finish, mayb=
e add
> > vfs_open_lookup_abort should the caller decide to not go through with
> > the open).
> >
> > Then in nfsd you could have something like this:
> > struct vfs_open_lookup_arg v;
> >
> > vfs_open_lookup(&v, parent_path, ....);
> > [ child dentry is in v->path->dentry, do arbitrary work with it]
> > if (ok)
> >       file =3D vfs_open_lookup_finish(&v);
> > else
> >       vfs_open_lookup_abort(&v);
> >
> > The new struct would hide 'struct file' and whatever else
> > vfs_open_lookup might want to allocate first.
> >
>

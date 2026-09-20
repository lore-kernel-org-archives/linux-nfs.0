Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C0A64367B8B
	for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 16:32:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=170.10.129.124
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789921940; cv=pass; b=aP+SK67K/dONIuF1IIqjrR1BMbhC7ik/7bRFsmGGPfEoxLm/aeV0lcr5gylTgwyd+kcfnjkpYq15g8Sh0ZHJ8zG+VULNVvJBk1Tl40clz2n3jJkQoUsNLzLqIKd3DR9cm9iYGcY96rPGwrEpECOvUhSWSkwk2C8pQY3drn7Po/k=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789921940; c=relaxed/simple;
	bh=+4YERuX/Tm4BEarMicY7oOWvS+xS/CmiXnLfQ+itnn8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=J/Azl0pfymwso8O4Wx2JlKbaSFtoljI2r0dO9P4wLb4CR8p0BtFNO2JFAmQhBet9UX36CxkiK/F3dWh/5nWS3xupDnmJR774fgok9hNxse8iu2JvoE96ayNMH6vdt1qlv1KBft1wo90rSd5qfk3IBASDR2UPIN8OmyQlbaoFNNs=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=NE+s2rF9; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=O2Zrr29N; arc=pass smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="NE+s2rF9";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="O2Zrr29N"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789921934;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6ElUqtRQzGRczK+6qtQzmlt/OBYAjwvyq42r0CytLLM=;
	b=NE+s2rF9rmHr7RWbmayfgzY6aMLiVodPbc77lnIvK+GiQDyryLQ/wrygrOum698e6IUG9T
	2EI6PmA97MB99dMuHzzEWZigEUmMKzgDerBu+E2UTx2qyw4fdkfyygTZQ8kqJm/vgrcxpf
	5E/sehzlNwTqljoW1/imgtpQf8q9pEY=
Received: from mail-yx1-f71.google.com (mail-yx1-f71.google.com
 [74.125.224.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-403-ZW0t-oUrNLacErNd7hfw9g-1; Sun, 20 Sep 2026 12:32:12 -0400
X-MC-Unique: ZW0t-oUrNLacErNd7hfw9g-1
X-Mimecast-MFC-AGG-ID: ZW0t-oUrNLacErNd7hfw9g_1789921932
Received: by mail-yx1-f71.google.com with SMTP id 956f58d0204a3-66c70fa2ba4so2341145d50.2
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2026 09:32:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789921932; cv=none;
        d=google.com; s=arc-20260327;
        b=h1QkT6YMT25uPRYj0I3B3Hvzgz3ghhYafki2fxuZyaTUXdXpuH7oaf2MI5jgmQTTVZ
         Sxhw04T8XU4nfXDHaFAlAscph85TINEqA8C73ozgzqqWiVzFB1aPfcbjpIblNn3loH4S
         lYm5arMQ6HX0XBXLMve+MB9/POlI+Br8eISsfv256qLAf7XYONgbabBkt2uKn1jUygP8
         Rnq7RYFzbQoXkHIyaB7HviG7Ac4gkqqf2TVi665jT9WyxXNtSMhLUXvwQY9FMZW0Pszg
         dv59of+8fKXPosJO1a7X6GWR8kk5CL4OBk3FjT6tUsttIU7ApaXN8QkOVoVQASCemiEX
         2vqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=6ElUqtRQzGRczK+6qtQzmlt/OBYAjwvyq42r0CytLLM=;
        fh=g9iLeQQtzCXAmxc8ygrzFZI7DU6D+EtVzRuHPcmcf/E=;
        b=Bv+3iy5V+f8wLm1LyelXBQZjPUaMWbCSr1Ju87DijDTbBZiQaOocALqxsVzcPHHi4j
         8q9IwcrR8t+pBe7xJpvHevIiJGJy/qteOrvMicdtWiAsdSiom+h9kULMPsB9Z1x/786R
         bNkpVHC81xSuXm4gJfxsoq7VY2M2nwH1oEG2MXDqB69q4ckRm/pY5DyMjnh46xMMhj8C
         hal3Q451Z+IgahTmxPj9Dijm1ZVmc8FpFcWB+ewUctDkAxAw2M+62OHzvbO0WvaK1RqE
         dGbbVLE6/omBnLmb1jCknwN6GwES8wGSzwmRSlPz8S8mcOZPeqw/Peue2QgDJWa6K8OB
         gA3g==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1789921932; x=1790526732; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6ElUqtRQzGRczK+6qtQzmlt/OBYAjwvyq42r0CytLLM=;
        b=O2Zrr29NPOW53WilSxjiGi5+GUNvcBVvdOoqH73SkdEdUiROaNcUr/Dadgv5HRQK5S
         5SohqF3YNLsUhWrHOtO3hDALjesXlygri5dK03KUhIieVN3sd/R9gCZqM285mVAkkhSO
         +eCemdvwbh99xjp00OjVgcow4v3enfWfjUWx3UPKM7+p9xcABOtqk9+quAtR6yiQevRE
         Pp9/kavNr2iMDdp8J2+ssCMO+kFuzKCkCXRvpHRP1Bb80K7ygFIvx1ywjX2h1ZZ6Kvd+
         K0KmEy87O5P2mJ9RdpedP4huuujk4F2y/CyHDRTDF5v8GBCOGDpjxyjqYIsYaBPnBFSH
         YbrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789921932; x=1790526732;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6ElUqtRQzGRczK+6qtQzmlt/OBYAjwvyq42r0CytLLM=;
        b=UpYU1mznEKqdFy0Oxbxhhr/2KYRr8MJzIhkT2TxBi0kpPtWlmPWHAFTMUcaIeZRVha
         w4bzANKCSKYXC8LfO2Kcm+o1HVuK59Ahvv71hlAqL4qrWWiAWJbYIpt7wmPkCDoR4wwM
         Nk8XQCccsMrRMyLJmBkqG2CuS/OYlMVefEuov/Ks2nJ9UD7QcIXuckRjTO0BjILdaNtE
         QwMqM5K7c3/Zv+dx4BZNo9aa6Y2Uqv6wdUDcxwZLwkVFk5f3PWadl3FHgttcHvW3qjnm
         I8fqP2Wqe0i9p0bE0d+6nqw3kO/B1LEJeA2qynfWXt8zyfnn6U9Zlj0aet/uc8p42YgH
         BtBQ==
X-Forwarded-Encrypted: i=1; AKwUvBylKGmo3YItWRrWxwsTYilRINTutSIsFqaVv4NcWvOtHgeIt+XPlO4vPM4myq4GdaXiT+CeHLK0QZo=@vger.kernel.org
X-Gm-Message-State: AFuF++mX7UQPubv7mDZ9EGP1gXNP8HqpK7E9BzY/4pT4rE0N8CVA5CmX
	BEq7RiGoezacgu3d5qEr4c6wdmD8RztFuteoWS7Xo+8ZQxqqCr5iGdNfSMdOw7nGJuhHg5Uq1yU
	fmaVrqoI0zPUk7oxSV4ZHF00VZLdpaXgmsQML+AmjmDybQ8o5paJsXZ2UcO53hxcUtsqvGHwaQk
	oZ2DIXIqixcoOeQcz4qh0owaOW+s6HLlRNmFmZ
X-Gm-Gg: AYBFou2rdrZAZxyYq0sPGfkBag7ffwUR6s0Vq5BpvgW1hSNklcRt1SHXvPol6+FXNvJ
	KHq3sr93GPkrVoFClYFRl3dJnKDNHGU8Uosicio7LOo1nUHkjn6JZm9A+CjVmjgVgyZWdIn/Xq8
	qX0kzCpY0aHGiOGTWg9g5BfdO97GzfZc8tR3HBQ2Ux/Bq/DQNHbURwoJ6Dy4obVSvFYvJC4ghfM
	SN2oHb+dQtehTxa5BG7PJNliT5LNpyJUTiJo6w5GfuNUg==
X-Received: by 2002:a05:690e:1348:b0:671:50b8:aee4 with SMTP id 956f58d0204a3-6717fdf7f42mr2684435d50.77.1789921931926;
        Sun, 20 Sep 2026 09:32:11 -0700 (PDT)
X-Received: by 2002:a05:690e:1348:b0:671:50b8:aee4 with SMTP id
 956f58d0204a3-6717fdf7f42mr2684413d50.77.1789921931459; Sun, 20 Sep 2026
 09:32:11 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260919022441.3305170-1-neilb@ownmail.net> <20260919022441.3305170-4-neilb@ownmail.net>
 <CAHc6FU4M59nodfn+NCDsr81Wdmvd1Ubw712FF56ekVWfe1+Nuw@mail.gmail.com> <178985655280.37859.6894749467886035489@noble.neil.brown.name>
In-Reply-To: <178985655280.37859.6894749467886035489@noble.neil.brown.name>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Sun, 20 Sep 2026 18:31:59 +0200
X-Gm-Features: AcwNN1WDWK2kuJ9juQym02aIIB-Y-9YWAPGC_3VkH8hMthBmOzCWtJtaHEAolhI
Message-ID: <CAHc6FU4cD3fb13LE1-HOEnOoUNVdW1N3e892r7rFE9HJfztvhg@mail.gmail.com>
Subject: Re: [PATCH v2 03/14] gfs2: simplify atomic_open handling.
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, Jori Koolstra <jkoolstra@xs4all.nl>, 
	Mateusz Guzik <mjguzik@gmail.com>, Dorjoy Chowdhury <dorjoychy111@gmail.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, gfs2@lists.linux.dev, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org, 
	Paulo Alcantara <pc@manguebit.org>, Namjae Jeon <linkinjeon@kernel.org>, linux-cifs@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 20, 2026 at 12:22=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrot=
e:
> On Sun, 20 Sep 2026, Andreas Gruenbacher wrote:
> > Neil,
> >
> > On Sat, Sep 19, 2026 at 4:31=E2=80=AFAM NeilBrown <neilb@ownmail.net> w=
rote:
> > > From: NeilBrown <neil@brown.name>
> > >
> > > gfs2 incorrectly returns -EFTYPE for any non-regular when __O_REGULAR=
 is
> > > in force.  A symlink might not be an error, and nfsd needs to know if=
 a
> > > directory was found.
> > >
> > > Neither this check, or the following check for a directory is needed.
> > > Both cases are handled correctly by instantiating the dentry and pass=
ing
> > > it to finish_no_open() - the caller will interpret the type.
> > >
> > > Signed-off-by: NeilBrown <neil@brown.name>
> > > ---
> > >  fs/gfs2/inode.c | 17 ++++-------------
> > >  1 file changed, 4 insertions(+), 13 deletions(-)
> > >
> > > diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
> > > index f361876c5583..7aa92bb31cf4 100644
> > > --- a/fs/gfs2/inode.c
> > > +++ b/fs/gfs2/inode.c
> > > @@ -738,19 +738,10 @@ static int gfs2_create_inode(struct inode *dir,=
 struct dentry *dentry,
> > >         inode =3D gfs2_dir_search(dir, &dentry->d_name, !S_ISREG(mode=
) || excl);
> > >         error =3D PTR_ERR(inode);
> > >         if (!IS_ERR(inode)) {
> > > -               if (file && (file->f_flags & __O_REGULAR) &&
> > > -                   !S_ISREG(inode->i_mode)) {
> > > -                       iput(inode);
> > > -                       inode =3D NULL;
> > > -                       error =3D -EFTYPE;
> > > -                       goto fail_gunlock;
> > > -               }
> > > -               if (S_ISDIR(inode->i_mode)) {
> > > -                       iput(inode);
> > > -                       inode =3D NULL;
> > > -                       error =3D -EISDIR;
> > > -                       goto fail_gunlock;
> > > -               }
> >
> > as you note below, when the inode exists but it isn't a regular file,
> > we won't even get here (gfs2_dir_search() will have returned
> > ERR_PTR(-EEXIST)). So the above two if statements are dead code, which
> > contradicts the patch description. Could you please fix that?
>
> There are two different modes here: the "mode" that was requested and
> the "inode->i_mode" that was found.
> This branch will only be taken if "mode" is "S_IFREG", but the inode
> that is found could be anything.

Ah right, we could be looking for a regular inode non-exclusively and
get back any inode type.

> >
> > > +               /*
> > > +                * This can only happen if "S_ISREG(mode) && !excl" s=
o "file"
> > > +                * cannot be NULL.
> > > +                */
> >
> > Is that comment useful without removing the below NULL check for file?
>
> Fair point.  I'll remove the NULL check.
>
> I'd feel more comfortable if gfs2_symlink(), gfs2_mkdir(), and
> gfs2_mknod() all passed "1" (or "true") for the "excl" arg.
> Then it would be even more obvious that we don't need to test
> for NULL, as all callers that pass a NULL file, pass a true excl.
> (you could remove the "!S_ISREG(mode) ||" which would make the code
> look cleaner).
>
> But that is beyond the scope of this patch.

Yes, makes sense. I'll happily clean that up.

In fact, could just remove the two if statements in this patch queue?
We can then clean up the rest on gfs2 for-next without causing a merge
conflict.

Feel free to send a cleanup, or let me know if I should write that.

> hmm... you could even pass "!file || excl" to gfs2_dir_search() to make
> it impossible to use file if it were NULL :-)

Right.

Thanks,
Andreas


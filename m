Received: from fout-b4-smtp.messagingengine.com (fout-b4-smtp.messagingengine.com [202.12.124.147])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF0BE40BCB8;
	Tue, 22 Sep 2026 21:17:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.147
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790111843; cv=none; b=k1ITHlQ2zl4KHrtPji2klllgwCWNvdcF6nAWk7/FvgfMVjICKXboITFPAirGbNwP3FPJdEDfrrmvPvUwroFOb7Cfe75laWrMT7jjdXgzQ9rkTI5SF4FAFwmqbCwsEbW85vXrrdDTBIg0bHSpQEmTcOjjhgcGrd19BofJ647KedY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790111843; c=relaxed/simple;
	bh=pu3vMDlMomiPSoJNSyMb2SwHHzd7dOj2/34pD71ks+I=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=P3inwx+iSkBz3vrrlfQKZL2slwmiLN58d+g5CWCQQe3bowBnhruophoxH+69+St7MXG0W4q5HbyEQxI9vnh1BXFGnVMW1lDa+IOOsoXoMpJiQlU22UxctlgDvH5qsHipQv2q3L1AJGmuCWU6XnbjPAEfkg1yWDOYVFMxvVZGUT8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=e2vdmKoI; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=vNUDHWHE; arc=none smtp.client-ip=202.12.124.147
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="e2vdmKoI";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="vNUDHWHE"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfout.stl.internal (Postfix) with ESMTP id 2B99B1D000E5;
	Tue, 22 Sep 2026 17:16:59 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Tue, 22 Sep 2026 17:16:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790111819; x=1790198219; bh=7Hw9YNz2h/EeChhYu1wFGNtUB8DDFUueuj6
	D+5FuZ4M=; b=e2vdmKoI2UfuzfwbATc6bU8Ld8MbjvDVv+dw1vclRzmToyAKVBR
	2KY7gh/xXZFSNQyHusw3FmUhZ+NP248DlI2HoV9Kc3jz3aT7J2Itctk+H2gHHccZ
	Tme2taRtXaqOOPRlRXeNWhPSAqbTtFRntgAOctQyGKgwVKmEjSBmMcYXXlg+3qy2
	cBaqaBDXWGg9KXolDhjyJiXbNJs0RjIRDnihDAbLI3QKAO71ws7ULvqgcC57BWDG
	p5G52yy8Da5qYyXToP9PggNL5GFSvpC649mfAYzE97qM02wAHevvLv9T5CQVNSGU
	lRjqTmgCHkOoxopHPCCNCrOoPoVWI1YBTbQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790111819; x=
	1790198219; bh=7Hw9YNz2h/EeChhYu1wFGNtUB8DDFUueuj6D+5FuZ4M=; b=v
	NUDHWHEu+JUdbP25sSYbFco+D4SF1RJ+3rbflZxNEsCXgylpxbYnterUI6AdC1ra
	fhYGg1pLKHUHt0Qf//QojF/4rv3+5FAwrUVpQlOmmID3eC7jZgugYMdxBKZczb9l
	oUGoH+TGQO8kEXBSPPvFiA/6TrMfBbT2mlRBkP8mkPMjamGZ3DbOS29EYv/vpmG2
	CQ7UFBHtzaDTGO9Y4/SR8z/EW1bw0GEFl3s89RMKcsqeCw+S8CfcVHllcX/+cBNy
	qJ3kq4TM8ZHcsFwjmAQlbPU0rM2H5EvoFcK/IWJvh03yDJhWp9kMUMjdnXhw55wN
	D1bg3qrBNvXvSNMe6T7JA==
X-ME-Sender: <xms:SvCyarGU77S3CAci5EoxCcgJjAG3oxIuQTIrk7A3CxyefH-H5WFl_Q>
    <xme:SvCyaosJ1KSY__-MsAFHEhVJIAVTK4sdN9J3HBfZIDN5dRtr4YgENCXfKa9U4a8e4
    2vq3qZDxcifMSEhVbwAxGHXSZJxCFXSHS-3TofNkZghmFQt46G7>
X-ME-Received: <xmr:SvCyauT_uIOl53YkO5W9ekgR6HfJW_DOCcFp6jm-v3oVqRzro8heL7dJ99q9LRFNEYinkD1W5xDs1XGuzhh1me4HnIbq8b8>
X-ME-Proxy-Cause: dmFkZTElOiHXUzQGTU4YDPoCB8evvf7R2NnkuH6G4Ttb62lBDPQ+5SKt9LMehyrWNIuN22
    JEWmjZ9Kpu7u1ILeez51FgSB/iiQ3gHbBkOaNQQJ3E26OK4aQXPIfAM2dYEjcA+xZyrDXg
    NaV5Q7Z1fqvDnO1h1p+B5NytNVf68qZQq0OYnaN0OXNRsADrWFXUW1+fR27wiMi3FCP64K
    bp/eUvYZ4BCztLOPyOFirW9uE0JzfO26umPEGPozKQpDcGsU7IZlwWudXLNb8ITj5KtKx0
    G0rwPGf6UyCCZ1s3hz4uGmk5rQmBVwOpEnqcJjKXOoLQaN5daF2zjioFEor8zvHWI6t5dn
    YmOkUjaYIBz7BhGqtnpXq1RSvvlEJGxKrl4apispFbK80NYlNPii1grc6U16LGpNtiUAet
    j+M/VSzcGoVA62DIxxpPbBE+KYRvbAjZ9gzFiAEOrg/XRTXm+CAZezUkft1lrAgbh733H+
    RrAichRODbywM3j6XaSbu9tadULJzjN8c646FncJujbTh1jzo6k5ac/2LJIm12nCR00rme
    aXJlK1J/2H+9uuzldWcmmtumojHMeTvqnFN9PGXers+vd2B8XgG0M2HblYmchink4B9ys6
    r0ZLD3Yog4n98fPtSAMuW/e1CqG3mCu0ubQswatB870R/VpcvwwqVNJ6k0iA
X-ME-Proxy: <xmx:SvCyalF9rYdrWgS07MDqydeFfGN4KkzMa5s3I8_0f2bZ82pLVhz6eA>
    <xmx:SvCyagcmUAMsaBwwH_YqvD86Upmr5H9OtKGkfHx-8UFIUsP9vxjpeg>
    <xmx:SvCyassiejY67mQidkvJIIzCM0PeLzOex2euip1IikcnHXOyPk8v6A>
    <xmx:SvCyaufPjFCK5Ck1EwclVnNxTU0gevtMrVL8VZ0Nu3grnvVy05LG2A>
    <xmx:S_Cyah5o4y2QeE_-adwKCQP1aZc9aQtuPuKXaXRvHYXLP1yuJyetLzpW>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 22 Sep 2026 17:16:52 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Andreas Gruenbacher" <agruenba@redhat.com>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, "Jori Koolstra" <jkoolstra@xs4all.nl>,
 "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 gfs2@lists.linux.dev, "Ilya Dryomov" <idryomov@gmail.com>,
 "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 03/14] gfs2: simplify atomic_open handling.
In-reply-to:
 <CAHc6FU4cD3fb13LE1-HOEnOoUNVdW1N3e892r7rFE9HJfztvhg@mail.gmail.com>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-4-neilb@ownmail.net>
  <CAHc6FU4M59nodfn+NCDsr81Wdmvd1Ubw712FF56ekVWfe1+Nuw@mail.gmail.com>
  <178985655280.37859.6894749467886035489@noble.neil.brown.name>
  <CAHc6FU4cD3fb13LE1-HOEnOoUNVdW1N3e892r7rFE9HJfztvhg@mail.gmail.com>
Date: Wed, 23 Sep 2026 07:16:50 +1000
Message-id: <179011181059.37859.15377924679358209081@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 21 Sep 2026, Andreas Gruenbacher wrote:
> On Sun, Sep 20, 2026 at 12:22=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrot=
e:
> > On Sun, 20 Sep 2026, Andreas Gruenbacher wrote:
> > > Neil,
> > >
> > > On Sat, Sep 19, 2026 at 4:31=E2=80=AFAM NeilBrown <neilb@ownmail.net> w=
rote:
> > > > From: NeilBrown <neil@brown.name>
> > > >
> > > > gfs2 incorrectly returns -EFTYPE for any non-regular when __O_REGULAR=
 is
> > > > in force.  A symlink might not be an error, and nfsd needs to know if=
 a
> > > > directory was found.
> > > >
> > > > Neither this check, or the following check for a directory is needed.
> > > > Both cases are handled correctly by instantiating the dentry and pass=
ing
> > > > it to finish_no_open() - the caller will interpret the type.
> > > >
> > > > Signed-off-by: NeilBrown <neil@brown.name>
> > > > ---
> > > >  fs/gfs2/inode.c | 17 ++++-------------
> > > >  1 file changed, 4 insertions(+), 13 deletions(-)
> > > >
> > > > diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
> > > > index f361876c5583..7aa92bb31cf4 100644
> > > > --- a/fs/gfs2/inode.c
> > > > +++ b/fs/gfs2/inode.c
> > > > @@ -738,19 +738,10 @@ static int gfs2_create_inode(struct inode *dir,=
 struct dentry *dentry,
> > > >         inode =3D gfs2_dir_search(dir, &dentry->d_name, !S_ISREG(mode=
) || excl);
> > > >         error =3D PTR_ERR(inode);
> > > >         if (!IS_ERR(inode)) {
> > > > -               if (file && (file->f_flags & __O_REGULAR) &&
> > > > -                   !S_ISREG(inode->i_mode)) {
> > > > -                       iput(inode);
> > > > -                       inode =3D NULL;
> > > > -                       error =3D -EFTYPE;
> > > > -                       goto fail_gunlock;
> > > > -               }
> > > > -               if (S_ISDIR(inode->i_mode)) {
> > > > -                       iput(inode);
> > > > -                       inode =3D NULL;
> > > > -                       error =3D -EISDIR;
> > > > -                       goto fail_gunlock;
> > > > -               }
> > >
> > > as you note below, when the inode exists but it isn't a regular file,
> > > we won't even get here (gfs2_dir_search() will have returned
> > > ERR_PTR(-EEXIST)). So the above two if statements are dead code, which
> > > contradicts the patch description. Could you please fix that?
> >
> > There are two different modes here: the "mode" that was requested and
> > the "inode->i_mode" that was found.
> > This branch will only be taken if "mode" is "S_IFREG", but the inode
> > that is found could be anything.
>=20
> Ah right, we could be looking for a regular inode non-exclusively and
> get back any inode type.
>=20
> > >
> > > > +               /*
> > > > +                * This can only happen if "S_ISREG(mode) && !excl" s=
o "file"
> > > > +                * cannot be NULL.
> > > > +                */
> > >
> > > Is that comment useful without removing the below NULL check for file?
> >
> > Fair point.  I'll remove the NULL check.
> >
> > I'd feel more comfortable if gfs2_symlink(), gfs2_mkdir(), and
> > gfs2_mknod() all passed "1" (or "true") for the "excl" arg.
> > Then it would be even more obvious that we don't need to test
> > for NULL, as all callers that pass a NULL file, pass a true excl.
> > (you could remove the "!S_ISREG(mode) ||" which would make the code
> > look cleaner).
> >
> > But that is beyond the scope of this patch.
>=20
> Yes, makes sense. I'll happily clean that up.
>=20
> In fact, could just remove the two if statements in this patch queue?
> We can then clean up the rest on gfs2 for-next without causing a merge
> conflict.

I've changed the comment to not mention the !S_ISREG() || excl condition
directly so it can be changed without confusion.  Instead it now says:

		/*
		 * Above gfs2_dir_search() can only return an inode when
		 * called from gfs2_so file cannot be NULL.
		 */

It shouldn't conflict with your patch.
I'll repost shortly.

Thanks,
NeilBrown


>=20
> Feel free to send a cleanup, or let me know if I should write that.
>=20
> > hmm... you could even pass "!file || excl" to gfs2_dir_search() to make
> > it impossible to use file if it were NULL :-)
>=20
> Right.
>=20
> Thanks,
> Andreas
>=20
>=20


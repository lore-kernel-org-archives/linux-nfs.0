Received: from fout-a8-smtp.messagingengine.com (fout-a8-smtp.messagingengine.com [103.168.172.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9010038424C;
	Sat, 19 Sep 2026 22:22:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789856566; cv=none; b=BHFxR1JDn1ZvvhKfrbv6MW2fEUKfO/w24qjtQYbz76UndtrYZXAzk3NjmRvI5J0QQq0v5TsBWuclQ8rLofHtvqZ5c+WUG/jfJ1M83vNGC2ODpelEOwHAC8Fnu273eE5xeYI/tMLmCu+HBFRUEZ5nNq2u29qCSpGNMBzPf8Di5Oo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789856566; c=relaxed/simple;
	bh=FlgSJJtFUdWJ8tRsXp/CedR63jrFahGNk3apx+VitJ4=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=cqioiWGGwVP7TwfHAOH7YPAvIxWBlePpLdV8PpQ+oMjg6+Y5tqY2m/+MBB8EDvL3QUj0w5csdg39TVxUML75UZAIdGwgpkRBUZzfXazeHesiPtH1kRWBjndszvpPzQQ8OBMXQAqpSeGjlmJTZ902Gmlrf8790s+waVb7J3iMs/A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=mt/4rTLw; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=LhDfVUXe; arc=none smtp.client-ip=103.168.172.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="mt/4rTLw";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="LhDfVUXe"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfout.phl.internal (Postfix) with ESMTP id B15A8EC009C;
	Sat, 19 Sep 2026 18:22:42 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Sat, 19 Sep 2026 18:22:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789856562; x=1789942962; bh=+IpOH+u2KvI1sbyiO9548M7mDnShKIV0iIv
	0cIo3Jbw=; b=mt/4rTLweXd+rVWfkWBFNqKUqlicTNnElFiLwacXkWaGEdzPOUt
	qRHp/TKZze67YKMxduWCd2onlf4t/pP9mG4sZzc6wLu087ARsEb18St/pMYbuk7o
	RNH+/J9XqElUnJMOi3rt6gs4iT0ees4NqDcnkPpp3QjJGuwLtWSLuKPJXV77mwlf
	9pihN9+ZH6D+J3LS3xkA+/jGcUjYvyzbnqUceeQsrZEsQY8HK+Z3OSP2yBJsIr9I
	rFsKh25L02FxHpkgtKrUxMlKpELiUlv0BFMKK4lvwGyAt9bBURkWRz6d1T/Keuqc
	F2SSzocBpFCcPMSPBQyEqnIfUChY4nRBVIQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789856562; x=
	1789942962; bh=+IpOH+u2KvI1sbyiO9548M7mDnShKIV0iIv0cIo3Jbw=; b=L
	hDfVUXeDVzEl545n6MmXRhqQSa9B5hJexcv3ZXeUOAJXNCkfdRkSRLqs1aa5nGZj
	CQpvOqMiZGrPvI9SMMGnpHICLBCSCOgXz9LUaCP4pvJkh4VthpzFh4COcTmqK9f7
	rF0jJs20RSbG7IMqkMOD/NT4bv7yM8cDyNNk6J9sy1ZGvOo8y34GDas6DGTrycQw
	i232bnN+FFJ2pK464ClsotyEtdEZWYP/w6X0TNCYTIuWkEDp8GcwNfToF/RYTi9Z
	zC6dyLz5aa7d4lJ5PTrMQXb1EkiWm8un1K5f/Cpsa0fR+xBqJ+aPxabXbR9uVpSB
	Udhez9xB/K5TLcXq1xvow==
X-ME-Sender: <xms:MguvahMo-B0L6PK2wgNlDaHacZvTwS-1gmGTiGyJs1nelC_59_RCBQ>
    <xme:MguvalTT_79Q2XLSsoz_vsTfOWZu0WdKbrWPwNZLDReMBTZWwHLuC1hX3N_g8akOl
    Qxs9DJlB8PkP2dtlePNWHPwj2neRUUsQssW7GVYuxc0CWN-Gg>
X-ME-Received: <xmr:Mguvak53adxEN3gfbXgd7q84Za-0u2c35DPod7YC340Fwmk1U2lKEHrQ0KOB0VLyF1a4XBTxqUnkdpKPMULwYiSZJCaInxs>
X-ME-Proxy-Cause: dmFkZTG1ofuJaJgESZYFIlGTak6lbeLZAYklKyn2ZaR+Jn1B6UL27Or9BJmC/6otW4XwrV
    BbRl4MSqMUEo+ZAkzxR/zd+D8JVHb9xfDX2TNgXMXJW+dDdY2f2oip3FLijoM6pUj94/5u
    aCkAw7uGD/d5TtxOzCP60gZmin6b/AwNMOOV/tEfU9DJSnk3aqLwtcPRXvX1yDr7Xp0II6
    SrsZkX/iBwgTVoieoqKQwpgWOBz31GXJDJGObvAZ18irb5h0PDGAAsI6HF38dzKmnI55A1
    St0hvpEyDESYGSfDGQ6z0dNhF5MUgARgMwdLI8+Ygm0PYVXp7sDLzZmMJgXsIb2jX/tkMT
    +Dy1weYqGwzv3p0c96nktbwqNFCCDXAvV0bcwnjv/Po8fMfcFdq1BfGgqdukzAtBDESbrL
    FGEOTLqdbd5YWNQxq8t8L7EvfYVbGI7Ory8y1POHxP5vaQWzWTb0dMPS+X2CtthyLejXHW
    SU1xmqBdsdTGEP2nCIqIM2CTPJZVrXHJbXUOPSlSvEdE/Vm7C4ETX/dsHGWSC4yhQOl2R8
    f6Hwe/PPG+PWAtLt/dAVCh5PDjt0p98Klj+lDyOHlU1eGJUnRX093BcSs/53iL7vrUnKsz
    /+MamiiY6S0Jx3zxZIczlI4buLkZgWt8ZKTue0fOamDtbArDcotp88b6JeWA
X-ME-Proxy: <xmx:MguvagaIu-QHgkvBBZpGkMXsHF2-dAIsdG9IBxS--TZhiQNH3HsrfQ>
    <xmx:Mguvagbsu79kku_NfiOZj8r3qhySUDtUblceZwcjkFbfb0K-Y82Nrg>
    <xmx:Mguvar2pBV4NC4F_N0NPcbfOBwOA0Aa45inVERStbBzkqj_Wd45QBg>
    <xmx:MguvagZX41P2kFT6-jQh4Jogt12zegxWAHDe71Hwe0nKqup9XHn6dA>
    <xmx:Mguval108GJxhL7aUhMPtkTNMbRrKesAIRdO2Rjlw60E1JzIt4dBBDPc>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sat,
 19 Sep 2026 18:22:36 -0400 (EDT)
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
 <CAHc6FU4M59nodfn+NCDsr81Wdmvd1Ubw712FF56ekVWfe1+Nuw@mail.gmail.com>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-4-neilb@ownmail.net>
  <CAHc6FU4M59nodfn+NCDsr81Wdmvd1Ubw712FF56ekVWfe1+Nuw@mail.gmail.com>
Date: Sun, 20 Sep 2026 08:22:32 +1000
Message-id: <178985655280.37859.6894749467886035489@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sun, 20 Sep 2026, Andreas Gruenbacher wrote:
> Neil,
>=20
> On Sat, Sep 19, 2026 at 4:31=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrote:
> > From: NeilBrown <neil@brown.name>
> >
> > gfs2 incorrectly returns -EFTYPE for any non-regular when __O_REGULAR is
> > in force.  A symlink might not be an error, and nfsd needs to know if a
> > directory was found.
> >
> > Neither this check, or the following check for a directory is needed.
> > Both cases are handled correctly by instantiating the dentry and passing
> > it to finish_no_open() - the caller will interpret the type.
> >
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/gfs2/inode.c | 17 ++++-------------
> >  1 file changed, 4 insertions(+), 13 deletions(-)
> >
> > diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
> > index f361876c5583..7aa92bb31cf4 100644
> > --- a/fs/gfs2/inode.c
> > +++ b/fs/gfs2/inode.c
> > @@ -738,19 +738,10 @@ static int gfs2_create_inode(struct inode *dir, str=
uct dentry *dentry,
> >         inode =3D gfs2_dir_search(dir, &dentry->d_name, !S_ISREG(mode) ||=
 excl);
> >         error =3D PTR_ERR(inode);
> >         if (!IS_ERR(inode)) {
> > -               if (file && (file->f_flags & __O_REGULAR) &&
> > -                   !S_ISREG(inode->i_mode)) {
> > -                       iput(inode);
> > -                       inode =3D NULL;
> > -                       error =3D -EFTYPE;
> > -                       goto fail_gunlock;
> > -               }
> > -               if (S_ISDIR(inode->i_mode)) {
> > -                       iput(inode);
> > -                       inode =3D NULL;
> > -                       error =3D -EISDIR;
> > -                       goto fail_gunlock;
> > -               }
>=20
> as you note below, when the inode exists but it isn't a regular file,
> we won't even get here (gfs2_dir_search() will have returned
> ERR_PTR(-EEXIST)). So the above two if statements are dead code, which
> contradicts the patch description. Could you please fix that?

There are two different modes here: the "mode" that was requested and
the "inode->i_mode" that was found.
This branch will only be taken if "mode" is "S_IFREG", but the inode
that is found could be anything.

>=20
> > +               /*
> > +                * This can only happen if "S_ISREG(mode) && !excl" so "f=
ile"
> > +                * cannot be NULL.
> > +                */
>=20
> Is that comment useful without removing the below NULL check for file?

Fair point.  I'll remove the NULL check.

I'd feel more comfortable if gfs2_symlink(), gfs2_mkdir(), and
gfs2_mknod() all passed "1" (or "true") for the "excl" arg.
Then it would be even more obvious that we don't need to test
for NULL, as all callers that pass a NULL file, pass a true excl.
(you could remove the "!S_ISREG(mode) ||" which would make the code
look cleaner).
But that is beyond the scope of this patch.

hmm... you could even pass "!file || excl" to gfs2_dir_search() to make
it impossible to use file if it were NULL :-)

Thanks,
NeilBrown

>=20
> >                 d_instantiate(dentry, inode);
> >                 error =3D 0;
> >                 if (file) {
> > --
> > 2.50.0.107.gf914562f5916.dirty
> >
>=20
> Thanks,
> Andreas
>=20
>=20


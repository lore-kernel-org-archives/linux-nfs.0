From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: include/linux/nfs/nfsfh.h declares a symbol
Date: Mon, 13 Oct 2003 11:21:38 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031013092138.GA16056@wohnheim.fh-wedel.de>
References: <20031001121811.GE31698@wohnheim.fh-wedel.de> <16266.11661.91185.167555@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16266.11661.91185.167555@notabene.cse.unsw.edu.au>
List-ID: <nfs.lists.sourceforge.net>

On Mon, 13 October 2003 14:43:57 +1000, Neil Brown wrote:
> On Wednesday October 1, joern@wohnheim.fh-wedel.de wrote:
> > Neil, the function SVCFH_fmt uses a static variable to sprintf into=
=2E
> > Looks like this variable is declared locally for every .c file
> > including nfsfh.h, which is quite a few.
> >=20
> > You could remove the static, but that would increase the stack usag=
e,
> > which might be a problem too.  The buffer could be reduced to 64
> > chars, to reduce that problem.  kmalloc()ing it seems a bit expensi=
ve,
> > but might be an option, too.
>=20
> Thanks.  I think it is best to simply make SVCFH_fmt a real function
> instead of inline, as below.
>=20
> NeilBrown
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Move SVCFH_fmt from being 'inline' to being 'extern'.
>=20
> This way, the "static char buf" is defined only once instead
> of once per file.

Patch looks good.  Thanks!

J=F6rn

--=20
To recognize individual spam features you have to try to get into the
mind of the spammer, and frankly I want to spend as little time inside
the minds of spammers as possible.
-- Paul Graham

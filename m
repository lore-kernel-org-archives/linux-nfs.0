From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] bug in read_buf
Date: Wed, 21 Apr 2010 18:36:05 -0400
Message-ID: <20100421223605.GC23480@fieldses.org>
References: <19405.3732.562014.510508@notabene.brown> <20100420165152.GD28826@fieldses.org> <g2k89c397151004201224wb35ae389g961523bbef23f452@mail.gmail.com> <20100420193944.GB31901@fieldses.org> <20100421223527.GB23480@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36763 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752641Ab0DUWgG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Apr 2010 18:36:06 -0400
In-Reply-To: <20100421223527.GB23480@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 21, 2010 at 06:35:27PM -0400, J. Bruce Fields wrote:
> On Tue, Apr 20, 2010 at 03:39:44PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 20, 2010 at 03:24:59PM -0400, William A. (Andy) Adamson=
 wrote:
> > > On Tue, Apr 20, 2010 at 12:51 PM, J. Bruce Fields <bfields@fields=
es.org> wrote:
> > > > On Tue, Apr 20, 2010 at 12:16:52PM +1000, Neil Brown wrote:
> > > >>
> > > >> Surely this can never have worked... which implies that the co=
de has
> > > >> never been used?
> > > >>
> > > >> When read_buf is called to move over to the next page in the p=
agelist
> > > >> of an NFSv4 request, it sets argp->end to essentially a random
> > > >> number, certainly not an address within the page which argp->p=
 now
> > > >> points to. =C2=A0So subsequent calls to READ_BUF will think th=
ere is much
> > > >> more than a page of spare space (the cast to u32 ensures an un=
signed
> > > >> comparison) so we can expect to fall off the end of the second
> > > >> page.
> > > >
> > > > Yipes, thanks.
> > > >
> > > >> I guess we never ever receive requests with any operation star=
ting
> > > >> beyond the first page!
> > > >
> > > > putfh-write-getattr, for example, is common enough. =C2=A0The w=
rite decoding
> > > > should leave arg->end set correctly. =C2=A0But there are two re=
ad_buf()'s in
> > > > decode_getattr(), and I can't see why we don't hit this bug on =
a write
> > > > that leaves that final getattr exactly straddling a page bounda=
ry.
> > >=20
> > > The write data is dumped into the rq_vec which has non-contiguous
> > > pages. So the xdr_buf head only holds the putfh result, the short
> > > write response header (v4 stateid, offset, how, length, etc), and=
 then
> > > the getattr. so there is plenty of space.
> >=20
> > This is the server-side write-decoding, so you could see:
> >=20
> >=20
> > 	rpc header | putfh | write ... data ... | getattr
> > 						     ^
> > 						     |
> > 						page boundary here
>=20
> Hm, I guess even when argp->end is wrong, argp->p is always set to
> something sane; so on the next READ_BUF(), when you hit the
>=20
> 	nbytes <=3D (u32)((char *)argp->end - (char *)argp->p
>=20
> case, you do
>=20
> 	p =3D argp->p;
> 	argp->p +=3D XDR_QUADLEN(nbytes);
>=20
> and p is something reasonable.  "end" stays wrong, but that won't be =
a
> problem until you run past the end of the *next* page, which it would
> take a very unusual compound to do.

(Nevertheless: applied, for 2.6.34 and stable.)

--b.

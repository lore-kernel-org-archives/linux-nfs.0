From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] bug in read_buf
Date: Tue, 20 Apr 2010 15:39:44 -0400
Message-ID: <20100420193944.GB31901@fieldses.org>
References: <19405.3732.562014.510508@notabene.brown> <20100420165152.GD28826@fieldses.org> <g2k89c397151004201224wb35ae389g961523bbef23f452@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754264Ab0DTTjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 15:39:46 -0400
In-Reply-To: <g2k89c397151004201224wb35ae389g961523bbef23f452-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 20, 2010 at 03:24:59PM -0400, William A. (Andy) Adamson wro=
te:
> On Tue, Apr 20, 2010 at 12:51 PM, J. Bruce Fields <bfields@fieldses.o=
rg> wrote:
> > On Tue, Apr 20, 2010 at 12:16:52PM +1000, Neil Brown wrote:
> >>
> >> Surely this can never have worked... which implies that the code h=
as
> >> never been used?
> >>
> >> When read_buf is called to move over to the next page in the pagel=
ist
> >> of an NFSv4 request, it sets argp->end to essentially a random
> >> number, certainly not an address within the page which argp->p now
> >> points to. =C2=A0So subsequent calls to READ_BUF will think there =
is much
> >> more than a page of spare space (the cast to u32 ensures an unsign=
ed
> >> comparison) so we can expect to fall off the end of the second
> >> page.
> >
> > Yipes, thanks.
> >
> >> I guess we never ever receive requests with any operation starting
> >> beyond the first page!
> >
> > putfh-write-getattr, for example, is common enough. =C2=A0The write=
 decoding
> > should leave arg->end set correctly. =C2=A0But there are two read_b=
uf()'s in
> > decode_getattr(), and I can't see why we don't hit this bug on a wr=
ite
> > that leaves that final getattr exactly straddling a page boundary.
>=20
> The write data is dumped into the rq_vec which has non-contiguous
> pages. So the xdr_buf head only holds the putfh result, the short
> write response header (v4 stateid, offset, how, length, etc), and the=
n
> the getattr. so there is plenty of space.

This is the server-side write-decoding, so you could see:


	rpc header | putfh | write ... data ... | getattr
						     ^
						     |
						page boundary here

--b.

>=20
> -->Andy
>=20
> >
> > --b.
> >
> >> [[
> >> I found this while looking at why fsstress over NFS over RDMA caus=
ed
> >> a bad memory dereference in READ32, suggesting that 'p' had a bad
> >> value. =C2=A0However it was ffff8801299188f0, which is not an "I'v=
e fallen
> >> off the end of the page" sort of value. =C2=A0So I think it must b=
e a
> >> different bug :-( =C2=A0It is as if the page is being unmapped und=
erneath
> >> us...
> >> ]]
> >> NeilBrown
> >>
> >>
> >>
> >>
> >> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> >> index e170317..34ccf81 100644
> >> --- a/fs/nfsd/nfs4xdr.c
> >> +++ b/fs/nfsd/nfs4xdr.c
> >> @@ -161,10 +161,10 @@ static __be32 *read_buf(struct nfsd4_compoun=
dargs *argp, u32 nbytes)
> >> =C2=A0 =C2=A0 =C2=A0 argp->p =3D page_address(argp->pagelist[0]);
> >> =C2=A0 =C2=A0 =C2=A0 argp->pagelist++;
> >> =C2=A0 =C2=A0 =C2=A0 if (argp->pagelen < PAGE_SIZE) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D p + (arg=
p->pagelen>>2);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D argp->p =
+ (argp->pagelen>>2);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->pagelen =3D=
 0;
> >> =C2=A0 =C2=A0 =C2=A0 } else {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D p + (PAG=
E_SIZE>>2);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D argp->p =
+ (PAGE_SIZE>>2);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->pagelen -=3D=
 PAGE_SIZE;
> >> =C2=A0 =C2=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 memcpy(((char*)p)+avail, argp->p, (nbytes - a=
vail));
> >> @@ -1426,10 +1426,10 @@ nfsd4_decode_compound(struct nfsd4_compoun=
dargs *argp)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 argp->p =3D page_address(argp->pagelist[0]);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 argp->pagelist++;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (argp->pagelen < PAGE_SIZE) {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D p + (argp->pagelen>>2);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D argp->p + (argp->pagelen>=
>2);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->pagelen =3D 0;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 } else {
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D p + (PAGE_SIZE>>2);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->end =3D argp->p + (PAGE_SIZE>>2);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 argp->pagelen -=3D PAGE_SIZE;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 }
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >>
> >>
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.=
html
> >

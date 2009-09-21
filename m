From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 2/2] nfsd41: add RPC header size to fore channel
	negotiation
Date: Mon, 21 Sep 2009 17:20:15 -0400
Message-ID: <20090921212015.GN12827@fieldses.org>
References: <1252709575-3426-1-git-send-email-andros@netapp.com> <1252709575-3426-2-git-send-email-andros@netapp.com> <1252709575-3426-3-git-send-email-andros@netapp.com> <20090914190315.GD1658@fieldses.org> <89c397150909180947w69b0139dx732100109e2793b0@mail.gmail.com> <20090918211253.GE26222@fieldses.org> <89c397150909210529q5b119d9dmff958dfe2d859635@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37545 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbZIUVUK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Sep 2009 17:20:10 -0400
In-Reply-To: <89c397150909210529q5b119d9dmff958dfe2d859635-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 21, 2009 at 08:29:30AM -0400, William A. (Andy) Adamson wro=
te:
> On Fri, Sep 18, 2009 at 5:12 PM, J. Bruce Fields <bfields-uC3wQj2KruMpug/h7KTFAQ@public.gmane.org=
g> wrote:
> > On Fri, Sep 18, 2009 at 12:47:57PM -0400, William A. (Andy) Adamson=
 wrote:
> >> On Mon, Sep 14, 2009 at 3:03 PM, J. Bruce Fields <bfields@fieldses=
=2Eorg> wrote:
> >> > On Fri, Sep 11, 2009 at 06:52:55PM -0400, andros@netapp.com wrot=
e:
> >> >> From: Andy Adamson <andros@netapp.com>
> >> >>
> >> >> Both the max request and the max response size include the RPC =
header with
> >> >> credential (request only) =C2=A0and verifier as well as the pay=
load.
> >> >>
> >> >> The RPCSEC_GSS credential and verifier are the largest. Kerbero=
s is the only
> >> >> supported GSS security mechansim, so the Kerberos GSS credentia=
l and verifier
> >> >> sizes are used.
> >> >
> >> > Rather than trying to estimate this is might be simplest just to=
 use
> >> > what the server's using to allocate memory: RPCSVC_MAXPAGES. =C2=
=A0No, that
> >> > also takes into account space for the reply. =C2=A0You could do
> >> >
> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0PAGE_SIZE * (1 + (RPCSVC_MAXPAYLOAD+P=
AGE_SIZE-1)/PAGE_SIZE)
> >> >
> >> > Actually, by design the server's real limit is actually on the s=
um of
> >> > the request and the reply sizes.
> >>
> >> I think the actual limit is svc_max_payload rounded up to a multip=
le
> >> of PAGE_SIZE plus PAGE_SIZE. which is a lot smaller than the sum o=
f
> >> the request and reply sizes. See below.
> >
> > Right. =C2=A0 I think you're agreeing with me?
>=20
> yes!
>=20
> >
> >> Note that svc_max_payload is what is returned in nfs4_encode_fattr=
 for
> >> MAXREAD and for MAXWRITE. These attributes use svc_max_payload in =
the
> >> same way this patch does - the maximum data size not including rpc
> >> headers.
> >>
> >> I don't think the server wants is to advertise a MAXREAD/WRITE tha=
t it
> >> can't supply because the fore channel maxrequest/maxresponse is to=
o
> >> small, so some additional space needs to be added to svc_max_paylo=
ad
> >> for the fore channel.
> >
> > Yes.
>=20
> For the additional space, shall we use what this patch calculates or
> some other metric?

I guess something like roundup(serv->sv_max_payload + PAGE_SIZE,
PAGE_SIZE) is the best we can do for now.

> >> > What happens if we get a request such that both the request and =
reply
> >> > are under our advertised limits, but the sum is too much? =C2=A0=
Can we just
> >> > declare that no client will be that weird and that we shouldn't =
have to
> >> > worry about it?
> >>
> >> I think the server already has this problem. In svc_init_buffer wh=
ich
> >> sets up the pages for a server thread request/response handling, i=
t
> >> uses sv_max_mesg / PAGE_SIZE + 1 with the comment
> >>
> >> "extra page as we hold both request and reply. We assume one is at
> >> most one page"
> >>
> >> where
> >> sv_max_mesg =3D roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZ=
E).
> >
> > Right. =C2=A0The difference is that now it looks to me like we're a=
ctually
> > going to start promising that we support the large request + large
> > response case, when actually we don't.
>=20
> OK - I see your point. With MAXREAD or MAXWRITE we only promise eithe=
r
> a large request or a large response per compound, not a large request
> and a large response in a single compound, e.g. a read and a write in
> the same compound.
>=20
> >
> > I guess the problem's unlikely to arise, so maybe it's not worth fi=
xing.
> > But it's annoying to have yet another undocumented restriction on t=
he
> > compounds we'll accept.
>=20
> I wonder what other servers are doing.

Yeah.  For now I guess we should ignore this.  (If you wanted to, in th=
e
same patch, add a note about this problem to the end of
Documentation/filesystems/nfs41-server.txt, that would be good.)

--b.

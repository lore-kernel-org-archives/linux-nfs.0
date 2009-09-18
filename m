From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 2/2] nfsd41: add RPC header size to fore channel
	negotiation
Date: Fri, 18 Sep 2009 17:12:53 -0400
Message-ID: <20090918211253.GE26222@fieldses.org>
References: <1252709575-3426-1-git-send-email-andros@netapp.com> <1252709575-3426-2-git-send-email-andros@netapp.com> <1252709575-3426-3-git-send-email-andros@netapp.com> <20090914190315.GD1658@fieldses.org> <89c397150909180947w69b0139dx732100109e2793b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42854 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbZIRVMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Sep 2009 17:12:50 -0400
In-Reply-To: <89c397150909180947w69b0139dx732100109e2793b0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 18, 2009 at 12:47:57PM -0400, William A. (Andy) Adamson wro=
te:
> On Mon, Sep 14, 2009 at 3:03 PM, J. Bruce Fields <bfields-uC3wQj2KruMpug/h7KTFAQ@public.gmane.org=
g> wrote:
> > On Fri, Sep 11, 2009 at 06:52:55PM -0400, andros@netapp.com wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> Both the max request and the max response size include the RPC hea=
der with
> >> credential (request only) =C2=A0and verifier as well as the payloa=
d.
> >>
> >> The RPCSEC_GSS credential and verifier are the largest. Kerberos i=
s the only
> >> supported GSS security mechansim, so the Kerberos GSS credential a=
nd verifier
> >> sizes are used.
> >
> > Rather than trying to estimate this is might be simplest just to us=
e
> > what the server's using to allocate memory: RPCSVC_MAXPAGES. =C2=A0=
No, that
> > also takes into account space for the reply. =C2=A0You could do
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0PAGE_SIZE * (1 + (RPCSVC_MAXPAYLOAD+PAGE=
_SIZE-1)/PAGE_SIZE)
> >
> > Actually, by design the server's real limit is actually on the sum =
of
> > the request and the reply sizes.
>=20
> I think the actual limit is svc_max_payload rounded up to a multiple
> of PAGE_SIZE plus PAGE_SIZE. which is a lot smaller than the sum of
> the request and reply sizes. See below.

Right.   I think you're agreeing with me?

> Note that svc_max_payload is what is returned in nfs4_encode_fattr fo=
r
> MAXREAD and for MAXWRITE. These attributes use svc_max_payload in the
> same way this patch does - the maximum data size not including rpc
> headers.
>=20
> I don't think the server wants is to advertise a MAXREAD/WRITE that i=
t
> can't supply because the fore channel maxrequest/maxresponse is too
> small, so some additional space needs to be added to svc_max_payload
> for the fore channel.

Yes.

> > What happens if we get a request such that both the request and rep=
ly
> > are under our advertised limits, but the sum is too much? =C2=A0Can=
 we just
> > declare that no client will be that weird and that we shouldn't hav=
e to
> > worry about it?
>=20
> I think the server already has this problem. In svc_init_buffer which
> sets up the pages for a server thread request/response handling, it
> uses sv_max_mesg / PAGE_SIZE + 1 with the comment
>=20
> "extra page as we hold both request and reply. We assume one is at
> most one page"
>=20
> where
> sv_max_mesg =3D roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE).

Right.  The difference is that now it looks to me like we're actually
going to start promising that we support the large request + large
response case, when actually we don't.

I guess the problem's unlikely to arise, so maybe it's not worth fixing=
=2E
But it's annoying to have yet another undocumented restriction on the
compounds we'll accept.

--b.

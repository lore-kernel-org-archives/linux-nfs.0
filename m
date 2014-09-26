Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54542 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753225AbaIZCZh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2014 22:25:37 -0400
Date: Fri, 26 Sep 2014 12:25:27 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Add missing support for
 RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
Message-ID: <20140926122527.19ee6931@notabene.brown>
In-Reply-To: <CAHQdGtRrpRxDi5FFjNhvptVnh+nqEyAREQA_6eSoExoW9_CsfA@mail.gmail.com>
References: <1411613479-8803-1-git-send-email-trond.myklebust@primarydata.com>
	<20140926111005.3124f859@notabene.brown>
	<CAHQdGtRrpRxDi5FFjNhvptVnh+nqEyAREQA_6eSoExoW9_CsfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/KtK70r9Fou7uRLcjPuG9Y.9"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/KtK70r9Fou7uRLcjPuG9Y.9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 25 Sep 2014 21:23:35 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Thu, Sep 25, 2014 at 9:10 PM, NeilBrown <neilb@suse.de> wrote:
> > On Wed, 24 Sep 2014 22:51:19 -0400 Trond Myklebust
> > <trond.myklebust@primarydata.com> wrote:
> >
> >> The flag RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT was intended introduced in
> >> order to allow NFSv4 clients to disable resend timeouts. Since those
> >> cause the RPC layer to break the connection, they mess up the duplicate
> >> reply caches that remain indexed on the port number in NFSv4..
> >>
> >> This patch includes the code that was missing in the original to
> >> set the appropriate flag in struct rpc_clnt, when the caller of
> >> rpc_create() sets RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT.
> >>
> >> Fixes: 8a19a0b6cb2e (SUNRPC: Add RPC task and client level options to.=
..)
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> ---
> >>  net/sunrpc/clnt.c | 2 ++
> >>  1 file changed, 2 insertions(+)
> >>
> >> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >> index 488ddeed9363..841565450354 100644
> >> --- a/net/sunrpc/clnt.c
> >> +++ b/net/sunrpc/clnt.c
> >> @@ -461,6 +461,8 @@ struct rpc_clnt *rpc_create_xprt(struct rpc_create=
_args *args,
> >>
> >>       if (args->flags & RPC_CLNT_CREATE_AUTOBIND)
> >>               clnt->cl_autobind =3D 1;
> >> +     if (args->flags & RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT)
> >> +             clnt->cl_noretranstimeo =3D 1;
> >>       if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
> >>               clnt->cl_discrtry =3D 1;
> >>       if (!(args->flags & RPC_CLNT_CREATE_QUIET))
> >
> > Hi Trond,
> >  do this relate to my observation in
> >     Subject: Re: NFS auto-reconnect tuning
> >
> >  that NFSv4 closes a connections after the first timeout?
> >  This patch seems to be a step towards changing that behaviour, though =
it
> >  doesn't succeed.
> >
> > You would need
> >
> > @@ -580,6 +582,7 @@ static struct rpc_clnt *__rpc_clone_client(struct r=
pc_create_args *args,
> >         new->cl_autobind =3D 0;
> >         new->cl_softrtry =3D clnt->cl_softrtry;
> >         new->cl_discrtry =3D clnt->cl_discrtry;
> > +       new->cl_noretranstimeo =3D clnt->cl_noretranstimeo;
>=20
> D'oh! Yes, of course that is correct.
>=20
> >         new->cl_chatty =3D clnt->cl_chatty;
> >         return new;
> >
> > as well.
> >
> > What do you think of having the client close the connection more quickl=
y when
> > there is a timeout?  There does seem to be a case for closing sooner th=
an 30
> > minutes...
> >
> > I must admit I'm a bit confused by these flags so I might be missing
> > something important.
>=20
> Actually, the whole idea is to stop the client from disconnecting when
> it doesn't need to. Disconnect =3D=3D very bad, since it typically breaks
> the duplicate reply cache semantics and it can interrupt RPC calls
> that may be in progress on the server.
> Furthermore, the NFSv4 server is supposed to guarantee to us that it
> will always reply to an RPC call (provided that the connection stays
> up), so the whole business of disconnecting was misguided in the first
> place. The only thing we need is to detect accidental disconnections
> (i.e. network partitions), and the way to do that is to use TCP
> keepalive. The new code will therefore interpret the NFSv4 'timeo'
> mount parameter as the TCP keepalive timeout rather than as a
> retransmission timeout.
>=20

OK - that makes sense.

A problem is that TCP keepalives don't help when you change the local IP
address.
tcp_keepalive_timer() sees that tcp_send_head() is always non-NULL
(presumably a packet that it is trying to send but cannot be) and so it just
keeps waiting.
I guess I should raise this on net-dev ....

Thanks,
NeilBrown

--Sig_/KtK70r9Fou7uRLcjPuG9Y.9
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCTOmDnsnt1WYoG5AQKNpw/8DfdUSiRHa1UecVmumVN0NKsRcW3LuSGv
3l5noaUh+eqUFj4r6fEXb279/RvE2aUFlcakIY2rqq7OnUXW2bNRGp1I71ioNlDT
tQhimgT2wVvt8LaZ0EQvJK0n45tOkvD1sAvWJwsqh2Iei66hRSBaIMYH8QmB5LpY
Y/+cWYw0KUTeGnuQ9oT+kJ1QtHrKjlz1ELb5eMsS9xw8jmfZtCvfe+aponoL2Zgb
viLz6sddjMhKXSXmK+Bt7h6HAfYAH3L0JWfxdOiudEq8AC5bZqf18H5SkBhkxOGa
Rs6SypkXYI80scwYVdt4RBwPC199de6cbSEJDzDcydD4clZ/qQYqo4YFJig3CDXy
PJmp4UkGZtj6dZyWYyN3gN0TE/zDsSeZFxXx2v+DtAGOgzICzqHKeB09OlFFfMdq
3cF92LiG0VlQdiqj6MKvm1qwvPm7rpQOMq7IXT+/J9kA80JjBy19OsLncOZhP5MD
LovhhjEdNTyrVMZDmoIQNBuc/StAe0xsXZIt5+nTD6iY64cQs84hk67fHFfGAkvb
lXLUwOH4a7Bqh9U1rRwOKa6+uyokydX/dkjxuplAcFDdDHxj7uY66omANPYJh1qU
6MES2QwVKU1mNUs/WJB2KU9NB8f9E7ECgS0fXpfC2JR772CE+VBkCO6Y+UHoI3hJ
ziF/qdhUVO8=
=f6+E
-----END PGP SIGNATURE-----

--Sig_/KtK70r9Fou7uRLcjPuG9Y.9--

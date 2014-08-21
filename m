Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:58308 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbaHUBP0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2014 21:15:26 -0400
Date: Thu, 21 Aug 2014 11:15:16 +1000
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: track when a client connection is routed to
 the local host.
Message-ID: <20140821111516.5d414462@notabene.brown>
In-Reply-To: <1408581184.4029.5.camel@leira.trondhjem.org>
References: <20140818061727.1449.89101.stgit@notabene.brown>
	<20140818062254.1449.26590.stgit@notabene.brown>
	<1408581184.4029.5.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/O1xbWnf/iCE2EGN7wgBqqi/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/O1xbWnf/iCE2EGN7wgBqqi/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 20 Aug 2014 20:33:04 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, 2014-08-18 at 16:22 +1000, NeilBrown wrote:
> > If requests are being sent to the local host, then NFS will
> > need to take care to avoid deadlocks.
> >=20
> > So keep track when accepting a connection or sending a UDP request
> > and set a flag in the svc_xprt when the peer connected to is local.
> >=20
> > The interface rpc_is_foreign() is provided to check is a given client
> > is connected to a foreign server.  When it returns zero it is either
> > not connected or connected to a local server and in either case
> > greater care is needed.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > ---
> >  include/linux/sunrpc/clnt.h |    1 +
> >  include/linux/sunrpc/xprt.h |    1 +
> >  net/sunrpc/clnt.c           |   25 +++++++++++++++++++++++++
> >  net/sunrpc/xprtsock.c       |    9 +++++++++
> >  4 files changed, 36 insertions(+)
> >=20
> > diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> > index 70736b98c721..cd79b2a28ceb 100644
> > --- a/include/linux/sunrpc/clnt.h
> > +++ b/include/linux/sunrpc/clnt.h
> > @@ -175,6 +175,7 @@ void		rpc_force_rebind(struct rpc_clnt *);
> >  size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
> >  const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_forma=
t_t);
> >  int		rpc_localaddr(struct rpc_clnt *, struct sockaddr *, size_t);
> > +int		rpc_is_foreign(struct rpc_clnt *);
> > =20
> >  #endif /* __KERNEL__ */
> >  #endif /* _LINUX_SUNRPC_CLNT_H */
> > diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> > index fcbfe8783243..6a9dffcb9d3f 100644
> > --- a/include/linux/sunrpc/xprt.h
> > +++ b/include/linux/sunrpc/xprt.h
> > @@ -357,6 +357,7 @@ int			xs_swapper(struct rpc_xprt *xprt, int enable);
> >  #define XPRT_CONNECTION_ABORT	(7)
> >  #define XPRT_CONNECTION_CLOSE	(8)
> >  #define XPRT_CONGESTED		(9)
> > +#define XPRT_LOCAL		(10)
> > =20
>=20
> Can we please rename that to XPRT_LOOPBACK or something along those
> lines? To me XPRT_LOCAL looks a little too close for comfort to
> AF_LOCAL, which is also a supported transport.
>=20

I'm fine with that.  I'll resend once we are in agreement about the other
bits.

Thanks,
NeilBrown

--Sig_/O1xbWnf/iCE2EGN7wgBqqi/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU/VIJDnsnt1WYoG5AQLIqhAAiyHVfVvTKX1whQAZdE9cFd3YAV5N1ooA
HAyE6L59Yynx3O0jVtF6jaZAcvXdvfO/YV1+qs1zBLuBb6k5s6sPobsNLAYfyffi
I4DN11moLiLOANgYhB06ce6dkLBEigTirUUX6Ijz9O+APfguKsHeMk+m1QXv/6FW
O9C1EjYCQ+XnlDKajOIeO4OnIY65Z1PShJ3LAPQMPnLs/+N2sBlWKreRMXMfuNCb
V3ZYAmlJscGsIw09fUkJtMozcpZnlylTsEED9fhS6lDzU2+LxmekPCLryeGX8NVz
HSW4LbTINFKGIXeq528L5Y1RYXyDRLFsWbMdDEj6mKVFqgHlJY5zkTMTpWbJZ6xg
Z9Rlyiu0zbmhMMWjHDArGeKckbAySJvjdm91/Q2zLTapHxL0XRRVnzX7u3FNEao7
9O2JTK9DOWDqROWBd9EOAM7VUxevoQm76J0KBUXgU2+bTfcnxSyMVqPJAyOexJqO
UBwL+KAXape7vj0WaTTbPq2mta9z/86b1RRDjhOOMIn4X4QAUXpv0+0FrYKRzXED
QONsfD1CHn6nCHGx0Hrv9HTpzhhY9n8oQFnjBv1EomHj/xWZJffbvoEoOgBNLcOI
Bk2bh0a9UWxIQwhHyw63Kif80iomIjDt9yJJ5Z2WU08s0ZoB9KJIaZgquLVxUY2o
iGWI+VtUs0c=
=4U02
-----END PGP SIGNATURE-----

--Sig_/O1xbWnf/iCE2EGN7wgBqqi/--

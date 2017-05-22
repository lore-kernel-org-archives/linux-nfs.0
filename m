Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36068 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751108AbdEVMp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 08:45:27 -0400
Date: Mon, 22 May 2017 13:45:25 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@redhat.com" <bfields@redhat.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170522124525.GI12205@stefanha-x1.localdomain>
References: <20170516131142.GA12711@fieldses.org>
 <20170518133441.GC4155@stefanha-x1.localdomain>
 <A720C1BD-D218-43A2-B6FD-C72B1E58D98C@oracle.com>
 <1495119887.11859.1.camel@primarydata.com>
 <20170518150850.GB16256@parsley.fieldses.org>
 <1495120629.13396.1.camel@primarydata.com>
 <20170518152822.GA9725@fieldses.org>
 <1495123747.13396.4.camel@primarydata.com>
 <20170518163159.GD16256@parsley.fieldses.org>
 <1495127625.13396.7.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Li7ckgedzMh1NgdW"
In-Reply-To: <1495127625.13396.7.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Li7ckgedzMh1NgdW
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 18, 2017 at 05:13:48PM +0000, Trond Myklebust wrote:
> On Thu, 2017-05-18 at 12:32 -0400, J. Bruce Fields wrote:
> > On Thu, May 18, 2017 at 04:09:10PM +0000, Trond Myklebust wrote:
> > > On Thu, 2017-05-18 at 11:28 -0400, bfields@fieldses.org wrote:
> > > > On Thu, May 18, 2017 at 03:17:11PM +0000, Trond Myklebust wrote:
> > > > > For the case that Stefan is discussing (kvm) it would literally
> > > > > be
> > > > > a
> > > > > single process that is being migrated. For lxc and
> > > > > docker/kubernetes-
> > > > > style containers, it would be a collection of processes.
> > > > >=20
> > > > > The mountpoints used by these containers are often owned by the
> > > > > host;
> > > > > they are typically set up before starting the containerised
> > > > > processes.
> > > > > Furthermore, there is typically no "start container" system
> > > > > call
> > > > > that
> > > > > we can use to identify which set of processes (or cgroups) are
> > > > > containerised, and should share a clientid.
> > > >=20
> > > > Is that such a hard problem?
> > > >=20
> > >=20
> > > Err, yes... isn't it? How do I identify a container and know where
> > > to
> > > set the lease boundary?
> > >=20
> > > Bear in mind that the definition of "container" is non-existent
> > > beyond
> > > the obvious "a loose collection of processes". It varies from the
> > > docker/lxc/virtuozzo style container, which uses namespaces to
> > > bound
> > > the processes, to the Google type of "container" that is actually
> > > just
> > > a set of cgroups and to the kvm/qemu single process.
> >=20
> > Sure, but, can't we pick *something* to use as the boundary (network
> > namespace?), document it, and let userspace use that to tell us what
> > it
> > wants?
> >=20
> > > > In any case, from the protocol point of view these all sound like
> > > > client
> > > > implementation details.
> > >=20
> > > If you are seeing an obvious architecture for the client, then
> > > please
> > > share...
> >=20
> > Make clientids per-network-namespace and store them in
> > nfs_net?=A0=A0(Maybe
> > that's what's already done, I can't tell.)
> >=20
> > > > The only problem I see with multiple client ID's is that you'd
> > > > like
> > > > to
> > > > keep their delegations from conflicting with each other so they
> > > > can
> > > > share cache.
> > > >=20
> > > > But, maybe I'm missing something else.
> > >=20
> > > Having to an EXCHANGE_ID + CREATE_SESSION on every call to
> > > fork()/clone() and a DESTROY_SESSION/DESTROY_EXCHANGEID in each
> > > process
> > > destructor? Lease renewal pings from 1000 processes running on 1000
> > > clients?
> > >=20
> > > This is what I mean about container boundaries. If they aren't well
> > > defined, then we're down to doing precisely the above.
> >=20
> > Again this sounds like a complaint about the kernel api rather than
> > about the protocol.=A0=A0If the container management system knows what =
it
> > wants and we give it a way to explain it to us, then we avoid most of
> > that, right?
> >=20
>=20
> OK, so consider the use case that inspired this conversation: namely
> using nfsd on the server to proxy for a client running in kvm and using
> the vsock interface.
>=20
> How do I architect knfsd so that it handles that use case? Are you
> saying that I need to set up a container of knfsd threads just to serve
> this one kvm instance? Otherwise, the locks created by knfsd for that
> kvm process will have the same clientid as all the other locks created
> by knfsd?

Another issue with Linux namespaces is that the granularity of the "net"
namespace isn't always what you want.  The application may need its own
NFS client but that requires isolating it from all other services in the
network namespace (like the physical network interfaces :)).

Stefan

--Li7ckgedzMh1NgdW
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZIt1lAAoJEJykq7OBq3PIhiIH+wRU9WvxDW+3tdm52S3bWZq/
JnuukKxJeADCURWT4AFsaKS0CEJsy5zDeOlwQpOqfhExm8I3Wjp4mWbgw6pDnUmH
NbuTMWMAbWAU6stu5+Wd8RkLJjGh0qFiF54JLpQYG3qfutv6Kv0FJ6Y5cVhGt1qh
v6CQ/DB8Hw9pDjhtnyl1FwJcR6cF6/c7hh3aqd9qtRhEHoXPMCSGWaL0oYF1nlzZ
gDxffO6D2C9VQK+NggWp3X0KUCqqqp72fL+jRNASm+ettNupqeu+9ISyC35MQXV2
KapTBfcFofjtYYpCTHlEKsBrX/B8U/Tn0peVKvAc0HaGDhVpVwIKvXht2W1qHpI=
=T1/t
-----END PGP SIGNATURE-----

--Li7ckgedzMh1NgdW--

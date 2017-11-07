Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753905AbdKGLcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 06:32:18 -0500
Date: Tue, 7 Nov 2017 11:32:10 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Matt Benjamin <mbenjami@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Steve Dickson <steved@redhat.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        NFSv4 <nfsv4@ietf.org>
Subject: Re: Draft RFC for ONC RPC over AF_VSOCK
Message-ID: <20171107113210.GJ6809@stefanha-x1.localdomain>
References: <20171005200835.GA31525@stefanha-x1.localdomain>
 <CAKOnarmreQp6c8qM7x=ohGf1sAoj53qbE0bNvKxzyWLiS=2zKw@mail.gmail.com>
 <1509110202.4704.7.camel@redhat.com>
 <20171027132318.GC30686@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="gBdJBemW82xJqIAr"
In-Reply-To: <20171027132318.GC30686@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--gBdJBemW82xJqIAr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 27, 2017 at 02:23:18PM +0100, Daniel P. Berrange wrote:
> On Fri, Oct 27, 2017 at 09:16:42AM -0400, Jeff Layton wrote:
> > On Thu, 2017-10-05 at 16:50 -0400, Matt Benjamin wrote:
> > > Hi Stefan,
> > >=20
> > > On Thu, Oct 5, 2017 at 4:08 PM, Stefan Hajnoczi <stefanha@redhat.com>=
 wrote:
> > > > I have previously submitted patches that implement NFS client and n=
fsd
> > > > support for the AF_VSOCK address family.  In order for this to be
> > > > acceptable for merge the AF_VSOCK transport needs to be defined in =
an
> > > > IETF RFC.  Below is a draft RFC that defines ONC RPC over AF_VSOCK.
> > > >=20
> > > > My patches use netid "vsock" but "tcpv" has also been suggested.  T=
his draft
> > > > RFC still uses "vsock" but I'll update it to "tcpv" if there is con=
sensus.
> > > >=20
> > >=20
> > > I think "vsock" is the appropriate netid, not "tcpv."  Stream
> > > orientation, if anything, is the general category containing TCP and
> > > VSOCK, not the reverse.  But really I think it's just more clear.
> > >=20
> >=20
> > Agreed. VSOCK is its own thing. It bears some resemblance to TCP, but
> > calling it tcpv would be confusing. IIRC, Chuck only proposed that when
> > we were discussing an alternative transport that would look more like a
> > typical network.
> >=20
> > BTW: Does VSOCK have a connectionless mode, analogous to UDP? If so,
> > then it may be nice to consider what the netid for that might look like
> > as well, before we settle on any names.
>=20
> Yes, you can use SOCK_STREAM or SOCK_DGRAM when using vsock.

VMware has implemented both SOCK_STREAM and SOCK_DGRAM.

The virtio-vsock and Hyper-V drivers implement only SOCK_STREAM at the
moment.  In the future they may support SOCK_DGRAM if there are use
cases.

Stefan


--gBdJBemW82xJqIAr
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaAZm6AAoJEJykq7OBq3PIUxAH/39gqk5wfthO7DQ9EXNxn6NH
k9l95BU4ftoqYM2Iirj30C272JXZzwbO4QvwjKVss/yoWjZ9JJFDihvW2aEC8zgO
H8PE1amqG94H5VydFxTI0SPn6Re5V4G8UpnZUZOcMVB/wcA39Nf6drlmt0yebO8g
hTVBwILfMDizTPiZvUfVU/HHOBVigrTLiFE41NdpY9HPvapoLUZFiAYzTMgGw+qF
1GdRrnw3vKUCMScMEkV1tEt5IB5Jz1yhKzaP6yhY9GopY9gpDNQLe3O25Z8xSBfp
gpnZwt+/A+8kl2BScQhUrDVmDotMyjtNXg58kGKWtz4jgGu99Je+lgmRy/9NATA=
=YDDQ
-----END PGP SIGNATURE-----

--gBdJBemW82xJqIAr--

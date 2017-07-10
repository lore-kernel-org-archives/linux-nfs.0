Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44738 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754891AbdGJSKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 14:10:00 -0400
Date: Mon, 10 Jul 2017 19:09:57 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@RedHat.com>, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
Message-ID: <20170710180957.GV14195@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
 <20170703090048.GC22607@stefanha-x1.localdomain>
 <20170706171626.GA30737@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="Pbi2MkfjSbXbI4MN"
In-Reply-To: <20170706171626.GA30737@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Pbi2MkfjSbXbI4MN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 06, 2017 at 01:16:26PM -0400, J. Bruce Fields wrote:
> On Mon, Jul 03, 2017 at 10:00:48AM +0100, Stefan Hajnoczi wrote:
> > On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
> > > On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> > > > Format vsock hosts as "vsock:<cid>" so the addresses can be easily
> > > > distinguished from IPv4 and IPv6 addresses.
> > > >=20
> > > > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> > > > ---
> > > >  utils/mount/network.c | 8 ++++++++
> > > >  1 file changed, 8 insertions(+)
> > > >=20
> > > > diff --git a/utils/mount/network.c b/utils/mount/network.c
> > > > index 281e935..b5dcaa5 100644
> > > > --- a/utils/mount/network.c
> > > > +++ b/utils/mount/network.c
> > > > @@ -45,6 +45,8 @@
> > > >  #include <rpc/pmap_prot.h>
> > > >  #include <rpc/pmap_clnt.h>
> > > > =20
> > > > +#include <linux/vm_sockets.h>
> > > In the previous patch you had this surrounded by #ifdef AF_VSOCK
> > > I'm not keen on sprinkling a bunch ifdefs around since=20
> > > I think it makes the code harder to read. So my question=20
> > > is why is the ifdef need in the previous patch and
> > > not needed in this patch and are they needed in the
> > > previous patch?
> >=20
> > The lack of #ifdef is my mistake.
> >=20
> > My impression of nfs-utils is that the code is written to work in a
> > variety of configurations and still support older kernels.  So I am
> > wrapping AF_VSOCK logic with an #ifdef.
>=20
> It needs to be able to support older kernels at run-time, and I don't
> understand how #ifdefs would help with that.

I will test the nfs-utils binaries against a kernel without AF_VSOCK
support.  What should happen is that an error is returned when creating
a socket, adding an export, etc fails.  I'll make sure the errors are
graceful/meaningful.

Stefan

--Pbi2MkfjSbXbI4MN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZY8L1AAoJEJykq7OBq3PIUi0H/Anb3dUk6rRXyriJbNy4Xmkq
WhL05jLReAlT/TNaAQ2+vrSkQhodIHm1JekaWk3thRFaeSDdVe3A8OqZIiNPKZGU
ETKc3sTgeNYcycYp22/pNuM+tI1VH6j815A1GHBMxmpNIMcDgFtf9DyUn2KupQSK
vJ8sTxxJ7Z21C2Kr0QSkXgvqZ+SPvW9WdwKb65+g6XR4F1NX0pCuGO2KjDBSfWwP
20j+Im9i6fsseebG1CK9GgKJ4bj2jnG7z2OOBewkJsBLV84mHRHr7O9tpMM66XaE
gfrSQVAih5PiqWxcEX/dbCWYAVRi1cPSRmcssxYK2bpHEWu9vhMZ9CeIt0Ov1CA=
=pCT5
-----END PGP SIGNATURE-----

--Pbi2MkfjSbXbI4MN--

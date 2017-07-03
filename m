Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44602 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753307AbdGCJA4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Jul 2017 05:00:56 -0400
Date: Mon, 3 Jul 2017 10:00:48 +0100
From: Stefan Hajnoczi <stefanha@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        Abbas Naderi <abiusx@google.com>
Subject: Re: [PATCH nfs-utils v2 03/12] mount: present AF_VSOCK addresses
Message-ID: <20170703090048.GC22607@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
 <20170630132120.31578-4-stefanha@redhat.com>
 <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="da4uJneut+ArUgXk"
In-Reply-To: <dc1bd4ee-621f-d988-2914-61b1c144f146@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--da4uJneut+ArUgXk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 30, 2017 at 10:40:49AM -0400, Steve Dickson wrote:
> On 06/30/2017 09:21 AM, Stefan Hajnoczi wrote:
> > Format vsock hosts as "vsock:<cid>" so the addresses can be easily
> > distinguished from IPv4 and IPv6 addresses.
> >=20
> > Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> > ---
> >  utils/mount/network.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> >=20
> > diff --git a/utils/mount/network.c b/utils/mount/network.c
> > index 281e935..b5dcaa5 100644
> > --- a/utils/mount/network.c
> > +++ b/utils/mount/network.c
> > @@ -45,6 +45,8 @@
> >  #include <rpc/pmap_prot.h>
> >  #include <rpc/pmap_clnt.h>
> > =20
> > +#include <linux/vm_sockets.h>
> In the previous patch you had this surrounded by #ifdef AF_VSOCK
> I'm not keen on sprinkling a bunch ifdefs around since=20
> I think it makes the code harder to read. So my question=20
> is why is the ifdef need in the previous patch and
> not needed in this patch and are they needed in the
> previous patch?

The lack of #ifdef is my mistake.

My impression of nfs-utils is that the code is written to work in a
variety of configurations and still support older kernels.  So I am
wrapping AF_VSOCK logic with an #ifdef.

AF_VSOCK has been in Linux since v3.9 in commit
d021c344051af91f42c5ba9fdedc176740cbd238 ("VSOCK: Introduce VM
Sockets").

I'd love to eliminate the #ifdefs, but would it be acceptable to simply
drop them?

--da4uJneut+ArUgXk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJZWgfAAAoJEJykq7OBq3PIH3oH+waXtsFudVfZ4JtowXCzDSzB
OnJzFWpjV4c4eryX39F1Qf563m7RlAPnWrbmpWj/2nYF2n6FOaL6fnGVkIzyvmBg
mZwwKrOYIn+EY8M24boXdxk4Yswhovtb9oo+CS/OUPnXSpe+Dg+TsoZUKxRwchJ5
gULNz2n1KwOXgLCvlfw18RbelxioNwD4ylr5s8FTuom3ibJREwB+1YaEgTcrDhBQ
LLz3lm0FikJnpN15WOngemJEllo9twFW16GODs4zVAbsXk3UIMPTHBvV08dyalp3
//GlzdCuP8GELOlaNhZxVh8lqGn11vDcEA/ZDo1SIROMuDyaaxaKEiO5eS8GECU=
=QXb+
-----END PGP SIGNATURE-----

--da4uJneut+ArUgXk--

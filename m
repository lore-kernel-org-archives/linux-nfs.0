From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Fri, 5 Jun 2009 16:50:41 -0400
Message-ID: <200906051650.42007.vapier@gentoo.org>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net> <200906051224.40592.vapier@gentoo.org> <20090605133634.23357e8e@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5815672.StvRsjaa2c";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:45777 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970AbZFEUuk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 16:50:40 -0400
In-Reply-To: <20090605133634.23357e8e-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--nextPart5815672.StvRsjaa2c
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 05 June 2009 13:36:34 Jeff Layton wrote:
> On Fri, 5 Jun 2009 12:24:39 -0400 Mike Frysinger wrote:
> > On Friday 05 June 2009 07:36:48 Jeff Layton wrote:
> > > Doing this now would add wider testing exposure for these codepaths a=
nd
> > > help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
> > > new library dependency for packagers, or they'll need to take the
> > > conscious step to --disable-tirpc when they configure.
> >
> > or have the configure script dump a warning whenever libtirpc is not us=
ed
> > ...
>
> The problem there is that these sorts of warnings tend to get lost in
> the noise. So then you have the situation where people aren't sure
> whether they built against libtirpc or not. Only running ldd against
> the binaries will tell you.

the configure script knows whether it's going to be building against libtir=
pc. =20
it isnt going to happen randomly during `make`.
AC_MSG_WARNING([

You really should think about switching to libtirpc

])

maybe it's different in Gentoo, but people report configure warnings all th=
e=20
time ;)

> > > We could make it so that configure looks for libtirpc and if it's not
> > > available, configures the build against legacy RPC interfaces. I think
> > > this is a bad idea however. While it should "just work" either way,
> > > there are some small behavioral differences when TIRPC support is bui=
lt
> > > in. I think it's probably better to make enabling and disabling TIRPC=
 a
> > > conscious step.
> >
> > i think this is the correct behavior for unspecified configure flags
>
> In general, yes. In this case though I think it's reasonable to force
> people compiling the package without tirpc installed to take the
> conscious step to either install the right libs and headers, or to add
> --disable-tirpc.
>
> I think doing so will lead to a more deterministic outcome in this
> situation. If that's a problem however, I'm willing to listen to the
> reasoning and reconsider...

i just dont agree with having to re-run configure to "fix" a condition that=
=20
the configure script should already be able to handle.  but i'm speaking in=
=20
general terms here, not specific to what you propose as that isnt exactly t=
he=20
same thing.  i dont feel too strongly here, especially since it doesnt affe=
ct=20
me in any realistic way.
=2Dmike

--nextPart5815672.StvRsjaa2c
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iQIcBAABAgAGBQJKKYUhAAoJEEFjO5/oN/WBG6YQAIuwqO6NpDa6qJdxiN09eR8Y
77x+x4shaWFX/dx9aLaRfB/RenijuZp562oEPQ/Gd4CsUto2et9aHT2dFPV7y5i9
d01InvGW7wY84WK6UYnPHc0sJlGANmEZS1mF4YSBciTdKyc4DLaVaVgQ86tDv0Xk
TvFBAEAF0NEcE1h0gcbC+OOeECN6oOwhzEb7eTNZu1dDH+D+aWYWlsgMbMuWt4jM
6oP8NhXXw+vz2JaKprqp03THJ4yj3j3Nvlz9afGCpxHtGSrPUBFpV76VTFdFNRS9
ZLxf4U3APbnPIX5CsIIJn9Maz06L1C0PzJ36ivSsu7/T06G+9vV16YMViLe0KKi9
Q/9c6qCvQGFs4+I/I8uoq3+zC/ZHpnB6asF1mlH0X16501zTB2i4MGdPFPwK7u/X
25y7VzSCwwBM6Ry86u1qYDt7CXzz6OS+KSzTHJxUZ3NHOWxjUiizvVy5/97GWrPP
AL9yejSPqTnp/WxC3qdHuQf8BD55AXtqhTYR4CTYV70yVra4S+E0kfWZ6sRwfjRd
dyDcfv0YYk7UkGE++kngP66g2DYuTc6yITi0qM2K8lbmhzHKYctA+SLquO23+KHj
1oYwQJNb2FGkDzdqdF3H78RUv8U9/qcjoDhuZR5rdMQWEU8gcUMB2a69DTilI11K
xdXC77DGdjYOwyseRWBI
=iYl1
-----END PGP SIGNATURE-----

--nextPart5815672.StvRsjaa2c--

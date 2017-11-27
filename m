Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46202 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751648AbdK0LSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Nov 2017 06:18:02 -0500
Date: Mon, 27 Nov 2017 11:18:01 +0000
From: Stefan Hajnoczi <stefanha@redhat.com>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Dexuan Cui <decui@microsoft.com>
Subject: Re: Remote Procedure Call (RPC) over AF_VSOCK draft 00
Message-ID: <20171127111801.GJ16527@stefanha-x1.localdomain>
References: <20171124105928.GA11868@stefanha-x1.localdomain>
 <1CDDAC90-7309-43F1-8585-AAA632CAE07B@vmware.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="LG0Ll82vYr46+VA1"
In-Reply-To: <1CDDAC90-7309-43F1-8585-AAA632CAE07B@vmware.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--LG0Ll82vYr46+VA1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 24, 2017 at 02:35:36PM +0000, Jorgen S. Hansen wrote:
>=20
> > On Nov 24, 2017, at 11:59 AM, Stefan Hajnoczi <stefanha@redhat.com> wro=
te:
> >=20
> > The first draft of Remote Procedure Call (RPC) over AF_VSOCK is now
> > available for review:
> >=20
> > Jorgen: I've summarized the current AF_VSOCK standardization status
> > (i.e. there is no specification and implementors generally try to follow
> > VMCI semantics for compatibility).  VMware vSockets is a superset of
> > Linux AF_VSOCK because it has additional header files and APIs.  Is
> > there an authoritative reference for plain AF_VSOCK that I'm not aware
> > of?
>=20
> No, unfortunately not. We only have the manual that you already provide a=
 link to.

Okay, thanks.  I'm working on a vsock(7) Linux man page so that AF_VSOCK
has documentation similar to ip(7).  Will keep you and Dexuan
up-to-date.

Stefan

--LG0Ll82vYr46+VA1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJaG/RpAAoJEJykq7OBq3PInRQH/1wSh9vsN4TiNQSyUezH5nHS
8/DauKZ0etrqKxGmGXo/3ahcGvy0pjjPd21/UmwQCxq2mtDovdrnaJaTPHfxBqex
komw0RCeEU4U5SBY85YgB+5GS6bwQqOYtIM/LpiVoPBCguj+p8xMjDu4IpUUUzhh
hDoff2HjRRGTj8+FnQ8GA78zQGxo8DhB0J7OVuSMw8hxV3vERpbgkpbw9gSioCpg
AlDmWBlXjKJ34UvN+B9nuu31sYt+yG1XdhkZGK4htrs3J+7xditdQuCmgeBesWWq
Pl+CpTgB3ksu66p6u4JGtUcIIKWKHcX5UL9Mez1f9FjCtgPxYEKRxjOsW1QWLtE=
=+rQ6
-----END PGP SIGNATURE-----

--LG0Ll82vYr46+VA1--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from becquer.dodds.net ([207.224.24.209]:39961 "EHLO
	becquer.dodds.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbbCFS3t (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2015 13:29:49 -0500
Date: Fri, 6 Mar 2015 10:20:31 -0800
From: Steve Langasek <steve.langasek@ubuntu.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Martin Pitt <martin.pitt@ubuntu.com>, linux-nfs@vger.kernel.org,
        systemd-devel@lists.freedesktop.org
Subject: Re: [PATCH 0/1] details for starting nfs-idmapd also on clients
Message-ID: <20150306182031.GA6228@virgil.dodds.net>
References: <1425640544-24230-1-git-send-email-martin.pitt@ubuntu.com>
 <54F9DA9D.8010106@RedHat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="mYCpIKhGyMATD0i+"
In-Reply-To: <54F9DA9D.8010106@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 06, 2015 at 11:49:33AM -0500, Steve Dickson wrote:
> On 03/06/2015 06:15 AM, Martin Pitt wrote:
> > Hello all,

> > Steve Langasek pointed out in [1] that idmapd is also necessary on the =
client
> > side. It isn't for my very simple NFSv4 test, but then again I don't kn=
ow that
> > much about the various other modes of operation.

> > This patch starts nfs-idmapd.service on clients too.
> This is distro specific... Other distros use the=20
> key ring based nfsidmap(5) command to do the id mapping.

> Make note, with new kernels the default upcall is to the
> nfsdimap command, if that fails then the rpc.idmapd daemon=20
> is tried. Meaning there are two upcalls for every id map
> when rpc.idmapd is used. This was the reason for the switch.

Ah, thanks for the feedback.  We do have nfsidmapd enabled, I had overlooked
that rpc.idmapd was no longer being used on the client.  We'll stick with
just using nfsidmap then.

--=20
Steve Langasek                   Give me a lever long enough and a Free OS
Debian Developer                   to set it on, and I can move the world.
Ubuntu Developer                                    http://www.debian.org/
slangasek@ubuntu.com                                     vorlon@debian.org

--mYCpIKhGyMATD0i+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJU+e/vAAoJEFaNMPMhshM9Y9UQAJQaHzuVa0QBO2gGcRkfguwU
1uFDFS2WVQun34aeZgdhfyaVCT/iliO1TlanZxwakI++uT0XvTgkTmFvCCxLB265
W3X2EGsSJeeElHe6gCQxKv/ILoQcqKmtXXJ9NQW+TW7mSHNHXVSEeuAJOgM2ZrEd
Jry3y/KXwrNi3Kmv1oA/ZW2s3/iH/SNXbS0sjiWnWBm55cGYjokkM2LA0UYYrTfr
EH2mzz2eqc/Z9P7hEmAh8Bo2Jp2sM+rxxwAgW1K9794sn4L8WHAU7C9ouAqjsxdE
LetRizQYQQCkJy/8yFyGG7bH39fUUlGauja9ImHcd2UFUGruaOPN04twGTr9z5h8
xJ4SlhhZceZRYF4VHw/RpxR985z11TAoBP5ZkX/l01rv+yHpmTv0g3DJXkKcL5SC
6c4Up9B8o1GUZTfjVnu3aQBjeeI1DMoMuqz51gDEveNdYd1IRaw4s+4fIHXw5KLk
N39RGs4y499Ti09J4uuUtSjXODC/CLOUUWgrMPolD4w+LtjCGAsPqqYDPLQwPU3l
HdgqfvNVwl+RwKBCCYBB2XzWGbgUtBrBAXzH+jAl2Jg/deewtvIc+Fhy5XGnEmea
CIyCuXm1FKYsBE8TXTpp24tQ66dYZjjbfIk+xc3YCQOKzY9l+VCtiDC162Z4wMQm
IKRTr0kPOdJ2qvG0yCFi
=JHQq
-----END PGP SIGNATURE-----

--mYCpIKhGyMATD0i+--

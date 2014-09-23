Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52712 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbaIWBmj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 21:42:39 -0400
Date: Tue, 23 Sep 2014 11:42:29 +1000
From: NeilBrown <neilb@suse.de>
To: Simo Sorce <simo@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfs-service: Added the starting of gssproxy
Message-ID: <20140923114229.0a9e294f@notabene.brown>
In-Reply-To: <20140922160050.0b85f044@willson.usersys.redhat.com>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
	<1411413608-16462-2-git-send-email-steved@redhat.com>
	<20140922194057.GE26763@fieldses.org>
	<20140922154642.779189c8@willson.usersys.redhat.com>
	<54207E4A.7010300@RedHat.com>
	<20140922160050.0b85f044@willson.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/a3ruU0LdXi.pA_o1=rrA.bh"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/a3ruU0LdXi.pA_o1=rrA.bh
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Sep 2014 16:00:50 -0400 Simo Sorce <simo@redhat.com> wrote:

> On Mon, 22 Sep 2014 15:53:46 -0400
> Steve Dickson <SteveD@redhat.com> wrote:
>=20
> >=20
> >=20
> > On 09/22/2014 03:46 PM, Simo Sorce wrote:
> > > On Mon, 22 Sep 2014 15:40:57 -0400
> > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > >=20
> > >> On Mon, Sep 22, 2014 at 03:20:07PM -0400, Steve Dickson wrote:
> > >>> Added the gssproxy.service to both the Wants=3D and
> > >>> Atfers=3D lines, before the rpc-svcgssd.service. There
> > >>> are  ConditionPathExists=3D lines in the rpc-svcgssd.service
> > >>> unit which will stop the rpc.svcgssd daemon from
> > >>> starting when the gssproxy daemon is already running.
> > >>
> > >> That should read "when the kernel supports gssproxy", not "when the
> > >> gssproxy daemon is already running."
> > >=20
> > > Actually the language is currently correct but it is another bug,
> > > the systemd/rpc-svcgssd.service file still includes
> > > "ConditionPathExists=3D|!/run/gssproxy.pid"
> > > This line should be removed in this patch.
> >=20
> > I left that on purpose because isn't that ConditionPathExists
> > seeing if /run/gssproxy.pid exists and if it does=20
> > it means gssproxy is already running so rpc.svcgssd=20
> > should not start?
>=20
> No.
> First of all the fact gss-proxy is running does not mean it is
> serving nfsd necessarily, it may be running on an older kernel where it
> servers apache or some other process (remember gssproxy is not just
> for nfsd).
> Second you already have
> "ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy" which is the
> correct trigger to decide which of the two to use.
>=20

Surely gssproxy is only serving nfsd requests if both /run/gssproxy.pid
exists and /proc/net/rpc/use-gss-proxy exists.
If either of those files is missing, then rpc.svcgssd needs to run.
In one case, the gssproxy daemon isn't available for some reason.  In the
other case the kernel cannot make use of it.

Is that not correct?

That is exactly the rule that I (tried to) encode in the service file with
these two conditions.

NeilBrown

--Sig_/a3ruU0LdXi.pA_o1=rrA.bh
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBVCDQBTnsnt1WYoG5AQJHKQ//ZOGinU21zWqz2Wb6Heu3rm4cP/VZguCB
O/oXbLANv+aqkHOmmpUiuUb58S6VkWonzoyVtqDblS23GzOHN9pVcE2/dHOCkuGf
Gpt8CvDWnE7YmCMf9RKGgbfmDKbX/PqxUW3OE9YrwHd47EgNc1XfJtQDf3fkdObo
VOx/gZwNE7bgdPGFDeTDHDjZTydwoEyC5aeUpKrIIjHCx8aup3KbH7QTkqb83mK+
oHxH3jVc79fp2wRXxH/tKVWvSB47yW6kVN6IZQIgxAESgv//aE8EL0a3AjZGt/z8
AybJEwhqivnBpMBa8ei70rbLRpENFnQDKsq9l4Ps1aToOnB5W5vegZPbe3E+SkWM
T3yOCp6pUZs9lRlACiMI6CO3+pcyxFn9huVsx/jqJH8mQ/gTMfgMOZl6tmvfLlZf
Rkl0LqaPVzAH/oCza+KHJjslQjXJIf8BcLwNAl8t+lGsInOCHSWWlLWcA43ycTso
PJs8Fk81u84J1VWIPP72wlLKTlRxu9d+aCtK5NlgkPaJJTxX4SZDRX9NS+d2wB49
BbAZm6FdFn2ejk7iF9bOJvdcnd79XJxhvNl5RhJ3VbAT4E6hOcCiUgyg3ALBlDXZ
HqzOTVadmjT6TFazwvmTQ5DmBIDXVpeVhL3/PfzFT/MvXbblDsm9zuSpUzltFund
0tmRxnKzXIE=
=GOoB
-----END PGP SIGNATURE-----

--Sig_/a3ruU0LdXi.pA_o1=rrA.bh--

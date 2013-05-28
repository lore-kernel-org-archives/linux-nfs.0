Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60720 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759163Ab3E1XE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 May 2013 19:04:26 -0400
Date: Wed, 29 May 2013 09:04:15 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
Message-ID: <20130529090415.27af1dec@notabene.brown>
In-Reply-To: <51A4FA3A.1080805@RedHat.com>
References: <1366380998-2581-1-git-send-email-steved@redhat.com>
	<20130502131332.5c0ce2b0@notabene.brown>
	<51A4FA3A.1080805@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=/zrlz3wJhP+0+LMThi=buD"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=/zrlz3wJhP+0+LMThi=buD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 28 May 2013 14:40:58 -0400 Steve Dickson <SteveD@redhat.com> wrote:

>=20
>=20
> On 01/05/13 23:13, NeilBrown wrote:
> > Subject: Fix recent fix to Avoid DNS reverse resolution in gssd.
> >=20
> > The final version for this fix that was committed inverted the test
> > so makes no change in the important cases.
> > The documentation didn't really help a naive user know when the new -D =
flag
> > should be used.
> > And the code (once fixed) avoided DNS resolution on non-qualified names=
 too,
> > which probably isn't a good idea.
> >=20
> > This patch fixes all three issues.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
> Committed....
>=20

Thanks :-)

NeilBrown

--Sig_/=/zrlz3wJhP+0+LMThi=buD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUaU37znsnt1WYoG5AQJ43BAApL8hL7T8M57iznS35HviKArCJu5YfvAf
Sf8MAR9fx/IZakrKHbU9/BYpuXNOxnfAtTjMve1yDiXLEXq9JlOyLHk58vIvWtkl
E9WTlpfa1VGRq1bjr2ikg/MG1ZhRuUT1zbStwoyxXXzBCTtZiNFR/ADzclxuBr3Q
UWkC4U0JR9kkL9qfupIVIEzMUbeIVWvvidpW1DgrcZYbsitMkyGN5gxN4esMnXbo
zR89GAcT/lEmYABqLAyqi398OwcwFy6EVjF0YT47BtfXS9tp+7DJqWoS6Mi6eVm1
wsLkbtDCKDFu8XxlQYEUq7olebf6F4c/sKKAS3s3c+gmkn1UzDqhYmxfIQ3HsMSV
UcJhHoRMnyxlNQL9lKkVVopKAx1PszipEmibsA/vlFX23J3bJcDhII4fAYYRaTI1
mi2WF0jsugfi+3JR7OBhCVOXQv8yjGtG2S5FcHVbXBSFxK5Q87eS982TwUwZI9K1
5TfMGX/FO9DubZIYBucmOJOf5NiRkWu8nHMgj5hC0FDkWIsRByvCmxFQ1ueUCnCx
G+OT99K+rsVXmnxud2VxbwjIMcOvy4+IxuXqn4t11IqUxNRNGEzRCzO9w/AqBIyg
yTaWL4k0Oi8pm+VNnpvaCGozHMPbXGqheQTqW01q3kAqYxRrl9RZG+rSVRc/G7zS
4d0/kLCzLXM=
=IOBN
-----END PGP SIGNATURE-----

--Sig_/=/zrlz3wJhP+0+LMThi=buD--

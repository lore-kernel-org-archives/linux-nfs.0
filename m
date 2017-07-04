Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56415 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752257AbdGDWU7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Jul 2017 18:20:59 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>
Date: Wed, 05 Jul 2017 08:20:49 +1000
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <87tw43fgrf.fsf@notabene.neil.brown.name>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login> <87tw43fgrf.fsf@notabene.neil.brown.name>
Message-ID: <87zicjyhby.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, May 30 2017, NeilBrown wrote:

> Systemd does not, and will not, support "bg" correctly.
> It has other, better, ways to handle "background" mounting.

For those who aren't closely watching systemd development, a
patch was recently accepted which causes systemd to work correctly with
NFS bg mounts.  So the above "and will not" was, happily, not correct.

So this patch to the nfs documentation is no longer relevant.

Thanks everyone,

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllcFMIACgkQOeye3VZi
gblj3xAAiBJDTVvhElEneQSwKJZHCzf87WnrLnFm2eYl1hLrQVMeXIAeRqPuGaye
uBO342iAg+m3AoWWyysQ29SwZKXY3H9RBwcvycyL/bCG4mrVzOhVF2TMcxMzhF4c
v+g8vgX+pEKW99J7vfUg2ZeI2mJiPQyYUabF7bjK8IQ91dZLuzl/U+apWQQCIh6R
7LqK7/M+wwtnUBdKejsVDWDQ6oRJJv50Yovs62NKeBFuqKobca//Dv1425ZbwCw+
sUDokFTga2hzKK/qKdKDZ50xE/IZkDV5yMcfiQ5V71z8AL6ZFSExUbmTbvoim5GO
3X0rS9oJBev5YXZ9yGL5SJzCpePu7HaN1LLKbQ/DxIJCdLyvGstpIkNgBPf76G2+
0KjvN/2YBh2CfAwFxSkq2xNSTVLEEWtu0xioWOqz2TSq4lw3SAyuvP7G/xGwDtY/
+LuN7jecMEHJ7R7c9TyLnCVgbVes48eyq1VCUT7SGR33ZLerWGuxgs6CgjOrKt7u
B6UgvxH1yLvbO3BOpny9gefXPoFe9r5SWgHBP8XSV58tA/kBs8wJrQW3RlzBRIXi
cyT29cNWBp7lL4s0G3hqay/kHXbjMVOHEK0K3eql56yusHmMbpTLFK+rmG3IJX0S
42cVHSTvyB6lQ5sdfEeKOUrnNP8baOjSLU7A9SnFhlhtikixYgg=
=2RFB
-----END PGP SIGNATURE-----
--=-=-=--

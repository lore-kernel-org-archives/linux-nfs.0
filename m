Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52886 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751492AbdFGDLV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 23:11:21 -0400
From: NeilBrown <neilb@suse.com>
To: Justin Mitchell <jumitche@redhat.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Date: Wed, 07 Jun 2017 13:11:13 +1000
Subject: Re: [PATCH 3/3] nfs.conf tidy ups
In-Reply-To: <1495468363.4169.13.camel@redhat.com>
References: <1495468363.4169.13.camel@redhat.com>
Message-ID: <87shjcbige.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, May 22 2017, Justin Mitchell wrote:

> Remove the line length parameter and associated code which
> led to buffer overruns in the line parsing code.
> Also drops the undocumented 'include' directive.

No, please don't drop the "include" directive.
It was there for a reason.  See commit  be38fd8b8011c6bd.

Yes, it should be documented.  I'm happy to provide documentation.  But
please do remove things without first understanding why they are there.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk3btMACgkQOeye3VZi
gbleEA//dMDEZF1M1Wq2Nes3br0V3xz5wvycYJfkQ22slEK6tS4qD0lRuBi/9Dlo
ufXygDTYI/TYYD5LnAiGdCw/sOeuAXT0dqjhiGTOaWLYr3cv1iV9vOaDwbbLQdT1
odGvs7KO3nXPCaHDeBbeZ/f4TbRa4vgSEVPuepN3KHS2nIZlUj7xz37cFFfkpRMC
A7IME5Zoe8L/di58RFXm64puTKqrFofWMkXpc2RLKbnfo0mX4WZng6xARTjRgjnU
gMUFh4ifwGkrbKOHwDzvwWaMVEZRYbEBc2nquBW3JM8jxyTQN/REGjjtqu4R6kIL
w8+d64B6cV2DvyNNC8shhxNv6IMaraMosh3t+ez0VuxaTQOMz7FgiT1mg7c4gJ3b
s+5gcSF9lD1xtsNt740JTUcGguV0I0fI9bFLBxIvqt7kFJGuU3zAVea+VswKVxVm
iEbbX3c77k1JpAINMP3AzApydTTMzSfb+vf1HG3bdDNUlFpDgXkO6Sw3QdYHPrVp
64zWRA9nyYvoKkTm4c2orKfzILAhkH3lmw+nz3UqDc/FRCfAKcGo/Cjg9dG/ysMh
h0/TVZocvS2rBc/9lo0SzLAOKN1B5vFPqtBUgSAl2G33GsZEaZKfYcEOnndNBQAY
PNPzX+S/5NuxTfvaoBClPT6T3ebW73/2Wg79AMUQnt4eitKGIb0=
=cK9D
-----END PGP SIGNATURE-----
--=-=-=--

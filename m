Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:56290 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822Ab3EBGxN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 02:53:13 -0400
Date: Thu, 2 May 2013 16:53:02 +1000
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Avoid DNS reverse resolution for server names (take 3)
Message-ID: <20130502165302.593ec4b6@notabene.brown>
In-Reply-To: <20130502131332.5c0ce2b0@notabene.brown>
References: <1366380998-2581-1-git-send-email-steved@redhat.com>
	<20130502131332.5c0ce2b0@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Z/8EaNtmNTTZhXK.q4o0NhV"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Z/8EaNtmNTTZhXK.q4o0NhV
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 2 May 2013 13:13:32 +1000 NeilBrown <neilb@suse.de> wrote:


> Possible patch below.

BTW if you end up applying that without requiring a second revision, please
add

--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -67,7 +67,6 @@
 #include <errno.h>
 #include <gssapi/gssapi.h>
 #include <netdb.h>
-#include <ctype.h>
=20
 #include "gssd.h"
 #include "err_util.h"


original patch added this include, but doesn't need it.

NeilBrown

--Sig_/Z/8EaNtmNTTZhXK.q4o0NhV
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUYINTznsnt1WYoG5AQIbbhAArRwHw5LNnXkSAUQqtWwcsHUGGrhOtLZ6
nNt3hFXGRlpcHQuE2Xg0FNEX7FqbNNqhKwUmp2hVytSo7rzC1eOfAoMhM3Cj1VY5
8j3uiguwB1qaVxCpK0eP4/yEY+/mN7p3Y+eV2Wm/bviT9svG6cJcKpKhXHoktT/N
ecV1K69y/imzT7VqWEhPmssJ8cK7lg1m0F431XQShCmW1+4xXv/9zfr56yILHqmy
Kb34YvEmhhMgSFlHjmPnZCZDKK928tHX84jfQdpymFLu8qKJboP5c7zki2AUb2/h
sXLhYoVXej9PFjOpxF3ThrV9orQXFZu/LVvW2j0x2Lr+elQPt+ea9flGxbGSkMNV
Bmd04LhUx5xrQktF12oJdtf2n/krWnzlNYIbM3ZGzrxzzy+HdEyaFdl5i9e3DdRu
dai7+YUMUCop6WeO7IYAjkQFpozSnTg1Knn7fbxOfS4pxGQaTq3Yi+JcmhAuiWRF
hrsufeGctoxfiymZdDSbMxK7ofL/Lth71s/GFV48oggVPcfGPdKoCHDw4xBeJzSa
BxPec7LRcDlUUnpOPcCIfmpQFxpr+0Kq/nT3ab/8/ip/XAruGnWHv9zqztdsXfH/
Pa02Ze3RPHN+CjZqxuUNmuHxM5DkUBwUTiU21aWzIubzOv4aieJUVFLeapRYKv80
NJtJb0GmcqE=
=0FY7
-----END PGP SIGNATURE-----

--Sig_/Z/8EaNtmNTTZhXK.q4o0NhV--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48266 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751182AbdH1EnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Aug 2017 00:43:14 -0400
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 14:43:05 +1000
Cc: linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
In-Reply-To: <1503697958-6122-3-git-send-email-bfields@redhat.com>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com> <1503697958-6122-3-git-send-email-bfields@redhat.com>
Message-ID: <878ti4i9pi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Aug 25 2017, J. Bruce Fields wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
>
> Pass around a new struct deleg_break_ctl instead of pointers to inode
> pointers; in a future patch I want to use this to pass a little more
> information from the nfs server to the lease code.

The information you are passing from the nfs server to the lease code is
largely ignored by the lease code and is passed back to the nfs server,
in the sm_breaker_owns_lease call back.

If try_break_deleg() passed the 'delegated_inode' pointer though to
__break_lease(), it could pass it through any_leases_conflict() and
leases_conflict() to the lm_breaker_owns_lease() callback.
Then container_of() could be used to access whatever other data nfsd had
stashed near the inode.  The common code wouldn't need to know any of
the details.

Just a thought...

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmjn1oACgkQOeye3VZi
gbmpnBAAg8BpgHJOI9NJAi4SVihXPQXpaBsd9HerhLcRTNKg7GD/2yDEgMQJidD8
Du6ejO/CMDtyVmFt2d5bxr4IZPLpEv8lXSxNo66nSHdQ30Dpi+KtzsVrxjCNym26
zcyVrtCa6tCwYjh6Iu8WyYRtoah6KdZ+n/WBc8jKkbx3V4um0fy0adbHHaLuGPQo
sODkcrPX4wBT9bo3r4kX8PM6O32ZjNASF3eecrkiPOXSgT2+62YrXqBCffnJwqO0
hvruL0kzLEjuicK3P92jsiCuC77NmyrmybgGYx0hJQsiG7YvwQYBOsTPey+usUF5
dO3UFFyW+JRu8SaJydZKZE2qG/CgcBy2D2Q2e6xgyeoy4vXwPXnxbsEv1idoJwTV
lIBWHz0rdXuiFf2xy1ibGkyePwK4bZgjyh1vIjETW8acU8yQbU/38bH0EMldHvBb
fmhdF4EfBEUifXCwE++WNe/EmXLCNPTUsbXqEoJCL1nt9itLht+jNseAZHyhRGyV
+XsRKoVkHQgFr4e5gSwMPCR8/iNYQ/RTRFzDLw+FWnn+JopTHfqO0+DohfYxkMLO
QfWG1Ht0sHb4h9wrOqm2epica5eEWqIhuba3o5AqMiZzzEsbKw813TKwsIVFU/Oo
6HaJvY0VSTlcelbyMWg3FNS0vLMjA6D9HNbVIN4fgi65PPByFRU=
=y60G
-----END PGP SIGNATURE-----
--=-=-=--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:34498 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932115AbdBHAQ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 19:16:58 -0500
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Wed, 08 Feb 2017 11:16:15 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v3 0/2] Add support for -s/--state-directory-path for rpc.mountd and exportfs
In-Reply-To: <1486134704-59866-1-git-send-email-smayhew@redhat.com>
References: <1486134704-59866-1-git-send-email-smayhew@redhat.com>
Message-ID: <87shnpv8og.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Feb 03 2017, Scott Mayhew wrote:

> Currently, rpc.mountd's -s/--state-directory-path option doesn't really
> do anything (rpc.mountd tests it via chdir() but that's all).  These
> patches implement the -s/--state-directory-path option so that
> rpc.mountd's state files (the etab and rmtab) can be placed in a
> location other than /var/lib/nfs... for example, /run/nfs.
>
> To use /run/nfs, it's necessary to create a systemd-tmpfiles config
> file, e.g.
>
> # cat /usr/lib/tmpfiles.d/nfs.conf=20
> #Type Path           Mode  UID  GID  Age Argument
> d    /run/nfs        0755  root root  -  -
> f    /run/nfs/etab   0644  root root  -  -
> f    /run/nfs/rmtab  0644  root root  -  -
>
> and if selinux is in enforcing mode, the correct context would need to
> be set on the directory (On Fedora, semanage barks at me if I use
> /run/nfs... that's why I'm using /var/run/nfs here instead):
>
> # semanage fcontext -a -t var_lib_nfs_t "/var/run/nfs(/.*)?"
>
> Changes since v1:
>
> - Replaced all newly-added occurrences of the term 'xtab' so it wouldn't
>   be confused with the recently removed 'xtab' file.  I did not replace
>   any existing uses of the term 'xtab' though.
> - Removed the reference to statd on the mountd man page.
>
> Changes since v2:
> - Fixed string-handling blunder I made in generic_setup_basedir(). Tested=
 with=20
>   pathnames of length 4083 (the largest you can have and still append
>   "/.rmtab.lock"), 4084 (generic_make_pathname() will fail for ".rmtab.lo=
ck"),
>   4095, 4096, and 4097.
> - Removed error_check() from support/misc/file.c and added the check dire=
ctly
>   in generic_make_pathname()
> - Removed _PATH_ETAB* and _PATH_RMTAB* as they're no longer used.
> - Updated the nfs.conf.man and exportfs.man pages.
>
>
> Scott Mayhew (2):
>   libnsm.a: refactor nsm_setup_pathnames() and nsm_make_pathname()
>   mountd/exportfs: implement the -s/--state-directory-path option

Both patches
  Reviewed-by: NeilBrown <neilb@suse.com>

Thanks!

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliaY08ACgkQOeye3VZi
gbmBNBAAhlwvnkbllobNiI+KRLJUzUg1VpHivAQ5fOoZwwdiHAkubzS4ApzzZl2a
L83bZuHBJnEgE2B0wwZYBGdGhU2IuuCyZkBFusxx4XyTjH/eTq9aID+bkOTWs9Ug
FEP6xEdFOem8uwc0E0IjDoy42O3J+yoC9xpoTZKwgptTfO+efzahgiB2Vzb5PeqI
txTB/DCndDVHydcnCYMqOQwOBUgrLDkGQUKTFZqUAqiaZCyEfIJK2z/SC2nbOjNQ
MgyqOQxP8/7ZOYATs89im2ZU40iCNb9rhhyAaAhNS4wODnwxPLlzZiER0UQxZRZf
g6iwwuZGVEPr+m9n6EQ5wxplmsEJOhcOEdvSffa3Nfv03r2TIrWVd82wmCtYCxkA
nkQg6msgP/V+GfU3yb/6d9CTF/fMdzxglZ+5LlszfNA9S5KRuRhXidXd8eP0pRA+
yt62MYSsSHY86U8yCFT7a47DQcyZ2kxHTvrN9MwamZhOtPMxuhEbS7F6TaMr8pvt
pEqkFemltMhbsGEg/VCZQqXd8rN0lTX2PqOg3732tFpPcZgtsB0CRiHLmwSIifC3
5Pu2XR8atmjxKJTu+Kbgc3oyTW8nSZbmDVy5w+OiZItNxCpmv7DI0MsiDdybkMAs
1/BppmCwmYLwItMYyugpMkI3BL8c892TxGKSekn05lP0Dtjp/+E=
=h+qs
-----END PGP SIGNATURE-----
--=-=-=--

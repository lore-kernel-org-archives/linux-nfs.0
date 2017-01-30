Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40665 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754451AbdA3VuF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 16:50:05 -0500
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Tue, 31 Jan 2017 08:49:25 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH RFC 0/2] Add support for -s/--state-directory-path for rpc.mountd and exportfs
In-Reply-To: <1485804769-14393-1-git-send-email-smayhew@redhat.com>
References: <1485804769-14393-1-git-send-email-smayhew@redhat.com>
Message-ID: <87bmuorzfe.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 30 2017, Scott Mayhew wrote:

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
> # semanage fcontext -a -t var_lib_nfs_t /var/run/nfs

Hi Scott,
 thanks for these - I think this is a good improvement.

I'm not very fond of the term "xtab" used through.
Presumably the intention is that the code is used for "rmtab" and
"etab", so "xtab" matches both, where "x" is the unknown.
Unfortunately we used to have an "xtab" file, and I keep thinking
of that when I see "xtab".
Maybe "state" ??? or leave it as it is, and I'll get over it.

>
> Notes:
>
> - I didn't actually implement the option (in either the command line or
> the nfs.conf) for exportfs.  Instead it reads rpc.mountd's setting from
> the nfs.conf so that they're using the same value.  Maybe it would be
> better to add the option to exportfs too and emit a warning if exportfs
> is using a different value than rpc.mountd (which would only be
> detectable if mountd is using the nfs.conf).

I like your current solution best.

> - Since the contents of /run are volatile, moving the rmtab file there
> would mean 'showmount -a' would only show NFSv3 mounts that have occurred
> since the last boot.  I'm not sure if that's a big deal or not.  Looking
> at the rmtab file on my main test server I see a lot of outdated
> entries, so this might actually be preferable.

I'd be fairly happy to discard rmtab completely.  It is, at best, a vague
hint and is, as you observed, often inaccurate.

> - Looking at rpc.mountd(8) it actually says 'Specify a directory in which
> to place statd state information'... I'm not sure why mountd would care
> where statd puts its state files.  The point of these two patches was to
> separate that out, so that all that's left on /var/lib/nfs is the stuff
> used by rpc.statd/sm-notify/nfsdcltrack.  I can either use a different
> option or reword that sentence on the man page.

I think it would be best to reword the man page.  As you say, mountd
doesn't care about statd state.

Thanks,
NeilBrown

>
>
> Scott Mayhew (2):
>   libnsm.a: refactor nsm_setup_pathnames() and nsm_make_pathname()
>   mountd/exportfs: implement the -s/--state-directory-path option
>
>  support/export/xtab.c     |  82 +++++++++++++++++++++++++++++++++-
>  support/include/misc.h    |   3 ++
>  support/include/nfslib.h  |  17 +++++++
>  support/misc/Makefile.am  |   2 +-
>  support/misc/file.c       | 110 ++++++++++++++++++++++++++++++++++++++++=
++++++
>  support/nfs/cacheio.c     |   4 +-
>  support/nfs/rmtab.c       |   4 +-
>  support/nsm/file.c        |  45 ++-----------------
>  utils/exportfs/exportfs.c |  13 ++++++
>  utils/mountd/auth.c       |   8 ++--
>  utils/mountd/mountd.c     |  31 ++++++++-----
>  utils/mountd/rmtab.c      |  26 ++++++-----
>  utils/statd/Makefile.am   |   1 +
>  13 files changed, 273 insertions(+), 73 deletions(-)
>  create mode 100644 support/misc/file.c
>
> --=20
> 2.7.4

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliPtOUACgkQOeye3VZi
gbmy7g//fP5tmrsNdN4yjmxrwahHkHvX0D9XC2Ay2clKchyl4T7YTxC1pGihtAea
InvbqR7Xiu4wOgcBBtF8lZG6WcNMb58hjhzgNCBnhgh8i8hTXN9+rWoka3EX6iXk
Wh1IUA/UWGiUfJhnozU8Fk+KacU3J43jCZFUhjXydXt+QpWsZbtMGWZ2dJQ/pdBO
/rI3w+iN3l+AFGFQP8h1BYJl60qebKIszzk/hZceNoCIncs5Uk9oDVLX3DilIMw/
DZRPddEznH48C5UJZf1TRVeHUTCRoazrmWwToFB2863UdPejNCpecREnMUSKDaM9
ZuAtU3ZM23cP9oGt05OpCEZutedLFfjdYnS+ZbefHUsgWu6X4+CBq6rIGtlagYp5
ic2rPWjyS5cAeswWc+KitxWCn7eeYzGyn1EZKSlB0x8ztUFZGzi2iHdCn01B1sFM
3iY3l9dkREVn21htzr3OojLoplgF+ldLNrjXjL+e56KOj0zrptrFU0TsvDzxp14k
FIff9wY6MQ16Qt3UWGMCSDi0/CBYAX5VJTA2cWfZ93UzrjeDJtsHlaKlTBaTU9rc
ez/Yp1yG2yfXYl2VjatELJt5D3PlGREmKVwviJW+MhryJphwHHyiAPtRJNTVs44E
g+M3Nu4artXkZ1xZ4h1eBlEC5cXBf3QDMwGP4m4bfXp0XICVp+I=
=diso
-----END PGP SIGNATURE-----
--=-=-=--

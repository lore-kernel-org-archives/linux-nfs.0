Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45729 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754075AbcLXD3S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 22:29:18 -0500
From: NeilBrown <neilb@suse.com>
To: daggs <daggs@gmx.com>, linux-nfs@vger.kernel.org
Date: Sat, 24 Dec 2016 14:29:08 +1100
Subject: Re: unable to mount nfs4 mount
In-Reply-To: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>
References: <trinity-4254572c-7361-4bba-8056-b645fac97726-1482498754742@3capp-mailcom-bs14>
Message-ID: <87r34yngxn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Sat, Dec 24 2016, daggs wrote:

> Greetings,
>
> I'm trying to mount an nfs mount it seems ti fails, I'd appreciate some help on the matter.
> the client is a gentoo setup with kernel 4.9.0, nfs-utils-1.3.4.
> running showmount -e 10.0.0.10 (the server) returns this:
> Export list for 10.0.0.10:
> /mnt/nfs_exports/media 10.0.0.0/24
> /mnt/nfs_exports       10.0.0.0/24
>
> when I try to mount I get this:
> mount -v -t nfs 10.0.0.10://mnt/nfs_exports/media /tmp/media -o vers=4,rw,async,auto
> mount.nfs: timeout set for Fri Dec 23 14:30:56 2016
> mount.nfs: trying text-based options 'vers=4,addr=10.0.0.10,clientaddr=10.0.0.1'
> mount.nfs: mount(2): Connection timed out
> mount.nfs: Connection timed
>
> the server is a odroidc2 board, the kernel is based 3.14.79 (I know it is old but there is still no full mainline kernel support for this board), nfs-utils-1.3.3 built with latest buildroot.
> cat /etc/exportfs returns this:
> /mnt/nfs_exports        10.0.0.0/24(rw,fsid=0,no_subtree_check)
                                         ^^^^^^^

Get rid of this, or get rid of "/mnt/nfs_exports" in your mount command.
i.e.
  mount -v -t nfs 10.0.0.10:/media /tmp/media -o vers=4,rw,async,auto

NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhd64UACgkQOeye3VZi
gbnVTRAAr5B9/7Q+lw/zclOGvSTe0/qpJcaa0o9B27F3+FPnuLiMC6kyzQjFAy/W
sN7A1bOU82V9rQKX5J7wOPWlXTvN/Qiyw+mFVihEA4p696qCxzQriomJLv027Whh
GwmGaI9eqUQ/CTZQvzoRK4+dwBdirWW6dkvqqI1wRkOeUYPlCr4uNXjIYpSC1nZs
OpKlU3lQ+bHx+ZsodUc3uvt2SA8DJOLfl8sqD98BmaZJJQqcgvkrPrjWDyTwaSVJ
woyR+SCT+TIZTeCXD1q8V0I0CVH4tBPi7bsf4/d+OHisqvpLmCelkcIUlMhB+5do
wWaRRT/UPJXi1BqZHOiEbus7ryZ4FLrk4NAJ7RuLCsbgbDT2rNR7hpG1v4/jnhRt
yMaLLscclbWWLS6HaLdsY279wSpDCwuNAqAa9uWeizQAunYNEhcSGF0mzgHBoXin
436MVJehyHSN40e2yfdE7eOYyBMlHA37xaZmxPWbQI1AJXI0KywL1iTxftyIaAdv
J+wEJAiUbeyXFacxx151eHB3J0uQ/qE1iJ5iluoTqZ2mHmoIvNqHbx/09akKcmNU
07nqsSOgSdH7cjATCRLbuSCRfzrbML+56KRxKl2yaO4esibmU/A57bAq/pBWrDgM
/mGGIfsj+pU/IwwV0N7n7ae5QqhtyLG5uuNlJ40d056+CWZjmPI=
=ocn5
-----END PGP SIGNATURE-----
--=-=-=--

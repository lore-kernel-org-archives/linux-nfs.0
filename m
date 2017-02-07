Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60704 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932115AbdBGXXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 18:23:47 -0500
From: NeilBrown <neilb@suse.com>
To: Rafael David Tinoco <rafael.tinoco@canonical.com>,
        linux-nfs@vger.kernel.org
Date: Wed, 08 Feb 2017 10:03:05 +1100
Subject: Re: [PATCH] Fix nfs-mountd dependency on rpcbind
In-Reply-To: <20170207191650.19219-1-rafael.tinoco@canonical.com>
References: <20170207191650.19219-1-rafael.tinoco@canonical.com>
Message-ID: <874m05wqmu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Feb 07 2017, Rafael David Tinoco wrote:

> Following commit 91da135f - it replaced "rpcbind.target" by "rpcbind.sock=
et" in
> some unit files - "rpcbind.socket" should also be added to "nfs-mountd.se=
rvice"
> as a dependency to avoid race conditions.
>
> Usually "rpcbind.socket" is either started as a "sockets.target" dependen=
cy, or
> as a dependency for "nfs-server.service", when unit files include it in
> "BindsTo" or "After". Unfortunately there is a possilibility to have
> "nfs-mountd.service" started when the rpcbind socket is not yet created:
>
> systemd[1]: Starting NFS Mount Daemon...
> systemd[1]: nfs-mountd.service: Control process exited, code=3Dexited sta=
tus=3D1
> systemd[1]: Failed to start NFS Mount Daemon.
> systemd[1]: nfs-mountd.service: Unit entered failed state.
> systemd[1]: nfs-mountd.service: Failed with result 'exit-code'.
>
> Nowadays "nfs-mountd.service" uses "BindTo" directive to "nfs-server.serv=
ice".
> That, per se, doesn't guarantee ordering for NFS server to start rpcbind =
and for
> nfs-mountd to depend on it.
>
> https://bugs.launchpad.net/bugs/1590799
>
> Signed-off-by: Rafael David Tinoco <rafael.tinoco@canonical.com>

Thanks for finding this!

 Reviewed-by: NeilBrown <neilb@suse.com>

I would not be against adding
  Wants=3Drpcbind.socket

but as you say, it isn't strictly needed.

Thanks,
NeilBrown


> ---
>  systemd/nfs-mountd.service | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/systemd/nfs-mountd.service b/systemd/nfs-mountd.service
> index 15e828b..b0a8bc0 100644
> --- a/systemd/nfs-mountd.service
> +++ b/systemd/nfs-mountd.service
> @@ -4,6 +4,7 @@ DefaultDependencies=3Dno
>  Requires=3Dproc-fs-nfsd.mount
>  After=3Dproc-fs-nfsd.mount
>  After=3Dnetwork.target local-fs.target
> +After=3Drpcbind.socket
>  BindsTo=3Dnfs-server.service
>=20=20
>  [Service]
> --=20
> 2.9.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliaUikACgkQOeye3VZi
gbkvUg/+LC9qhB9CZnjr25horAmyyxczF+/vGeEtggF2Wk/7WdASH313TYN2O3h9
B8lOI3BYmNT0qOdXSKffDUzh1nKkF5EWMXc2kYni8vMvATCAdFH4iNyxwgbWTMk5
lIhRAaXl2UEV6Y+1qvmxJ17U390EDEcMIy+dnfCtgc7C0mLiANzjFHKCW4yW/nUu
KHCquQzd8iOlf2jZ0wOenikgSEO/zuOenkSTUmQIezOdyzpmGXu4wIGuUoUvZ8XZ
NX2pQon/Nyd5JYDr+keEVPdPgpo8OiUxaXtndEHwNkjmQ5XXW4K+UBrsDT8GRL3G
HXySficW6MNSaCye1QzGbu46PAkmf5F9UFa0g6HDfNqDrWS1S3h17KdgSnm+72Po
QLqVwuynmPgRUcAo146wKAaKRrh6Di62enRLPiF1gzaksE6mVbUAuFygShLsF3By
7M2nFAAVb2FZ7RiFMk38cMPvcqwfFselHSO2ZxPFD2ww1R3K0DQNWzLM2HB8OggY
VSkVYplrNv0diHKCHx7DmbGgaOwMkf+RT95cRFvNPq/YEArvsOFs22R/QAY3jKuh
fkvMHst4Nu6AKmwTCPji0YYWV6wzPmxmf+agWF/eKcCZ8xkLL+ryMkULKX2dMJC6
x7nmPbJE9MXRdxHQgCpPTDbdz9J/RJ+T/5a2mCUJVEEyL+Bmv+8=
=xO3G
-----END PGP SIGNATURE-----
--=-=-=--

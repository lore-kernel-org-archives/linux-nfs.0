Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47189 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752022AbaBSDRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 22:17:23 -0500
Date: Wed, 19 Feb 2014 14:17:12 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] rpc-svcgssd.service: removed a the start up
 triggers
Message-ID: <20140219141712.54cb31a7@notabene.brown>
In-Reply-To: <1392713329-17979-2-git-send-email-steved@redhat.com>
References: <1392713329-17979-1-git-send-email-steved@redhat.com>
	<1392713329-17979-2-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/MpmCYB0q=toHJUUvz_x2lxD"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/MpmCYB0q=toHJUUvz_x2lxD
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Feb 2014 03:48:48 -0500 Steve Dickson <steved@redhat.com> wrote:

> The file /proc/net/rpc/use-gss-proxy exists whether
> gss-proxy is or is not installed. So is existence
> can not be used as start up trigger.
>=20
> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
>  systemd/rpc-svcgssd.service | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index 6bd4588..8e10b98 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -7,7 +7,6 @@ PartOf=3Dnfs-utils.service
> =20
>  After=3Dgssproxy.service
>  ConditionPathExists=3D|!@localstatedir@/run/gssproxy.pid
> -ConditionPathExists=3D|!/proc/net/rpc/use-gss-proxy
>  ConditionPathExists=3D/etc/krb5.keytab
> =20
>  [Service]

This is testing for non-existence, not existence.

We need rpc-svcgssd unless gssproxy can perform that task for us, in which
case we don't want rpc-svcgssd.

gssproxy can only perform the task for us if:
 1/ it is running (hence the test on the pid file)
 2/ the kernel knows how to talk to it (hence the test on use-gss-proxy)

With you version, if gssproxy were running on a kernel which did not include
support for nfsd talking to gssproxy, then rpc-svcgssd would fail to start,
which isn't what we want.

This may be an unusual configuration but unless it is an impossible
configuration I would rather the code remained as it was.
(This should work on *all* distros, not just sane distros).

Thanks,
NeilBrown

--Sig_/MpmCYB0q=toHJUUvz_x2lxD
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwQiODnsnt1WYoG5AQI90xAAquYwtcflVNkes+OCH5T7fQyQv+aos4rL
nGPmP3jLO9IvC5/ZLF781cFvrMx032yopznex3mSGUERdhi1U3wRvdehgYHxsOrk
2ssszwEmRPeIQCqX35trqbzbgSVs3fMdM3w44sQ4zFIEXRo+oA1twpmRzRd0J9kY
BtpP0izsJ2DTfvGLACiwhTeoZkXcYxBXk4wpo7NHOUSLkEZngw4ltyaYpWQwUCVi
jHIMcxDnLRYZ2/+tTqccPyF2bBGdYtw/AfHa0tJ+UttygOBdveGjammiU1JerXCZ
xH58nGqUr0RlIGi+a0OaMqLmO0DdDfvU+iYPb3EEeak9XZ4YX7WhgL5Ar80vMRqG
cOM2By5zHc7mr8rAn15QwaHhc0wClcgttD54ks35NZuzuKW5ecgF4elff4iYpXud
u8K4NA/sIsk8nqYBi90t6FDEILupvLwu6mB5TNFqlxF/mtmHLFKiUkJQ6qfuDg99
GCDDlj/0yA7z4GZprRSp+2vuABY/gsJeRuUiULgSpFW+7a4SMkrBQ/MkEiTbaIN3
Nfbn2F2TsmsViApH8AV3kOM4oaqlTiF2S8wvcg0LLbGXYJMRwdzSNtS5lWmKTiif
KaHctMdQk9Hwf3/PqqqqR3sz0oRhby+am8fT+yrMSAxBS0xQ8IepM1QoKSU4uRZm
4cjYo9JHY78=
=lAOM
-----END PGP SIGNATURE-----

--Sig_/MpmCYB0q=toHJUUvz_x2lxD--

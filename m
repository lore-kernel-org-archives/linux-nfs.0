Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43426 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753234AbdGGCac (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jul 2017 22:30:32 -0400
From: NeilBrown <neilb@suse.com>
To: Phil Kauffman <kauffman@cs.uchicago.edu>, linux-nfs@vger.kernel.org
Date: Fri, 07 Jul 2017 12:30:21 +1000
Subject: Re: /etc/mtab read ~900 times by rpc.mountd
In-Reply-To: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
References: <f9dcc371-cd94-6b39-dd6a-b412bdf03df4@cs.uchicago.edu>
Message-ID: <8737a9x9ky.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jul 06 2017, Phil Kauffman wrote:

> In response to this thread that died out a while back: http://marc.info/?=
t=3D142727765600001&r=3D1&w=3D2
>
> I have the same issue and am looking for a solution.
>
> My current setup involves nested ZFS datasets. It looks like this:
>   tank/homes/user{1..6000}
>   tank/stage/somedirname{1..100}
>
> tank/homes and tank/stage are datasets and the immediate children are als=
o datasets.
>
> There are huge benefits to using datasets that I don't want to get into h=
ere, so lets leave it at I would prefer to keep this setup.
>
>
> Now to the issue. Because of the nested mounts I need to use the 'crossmn=
t' export option which seems to invoke a loop over '/etc/mtab'. During vari=
ous straces I have seen /etc/mtab get read over 900 times (on ssh login) wh=
ile a users home directory is being mounted.
>
> Since /etc/mtab has around 6000 lines (and growing) it takes a long time =
to complete. Around 8 seconds actually from the time you start an ssh conne=
ction to when the password prompt appears (tested with 'time ssh -o BatchMo=
de=3Dyes root@client1'). It seems that most of this time is spent by rpc.mo=
untd reading /etc/mtab about 900 times while the client waits for the serve=
r to finish.
>
> # ls -l /etc/mtab
> lrwxrwxrwx 1 root root 19 Jun 22 14:31 /etc/mtab -> ../proc/self/mounts
>
> # cat /proc/self/mounts > mtab
>
> # ls -lh mtab
> -rw-rw---- 1 root root 442K Jul  6 16:51 mtab
>
> # wc -l mtab
> 6051 mtab
>
>
> Right now I am dealing with 'nfs-kernel-server' version '1:1.2.8-9ubuntu1=
2.1' (on Xenial), which I already had to patch with http://git.linux-nfs.or=
g/?p=3Dsteved/nfs-utils.git;a=3Dcommitdiff;h=3D35640883cf34a32f893e9fecefbb=
193782e9bc75 suggested here http://marc.info/?t=3D138684383100001&r=3D1&w=
=3D2=20
> (This works brilliantly BTW, it shaved a good 20 seconds off the mount ti=
me because all those devices were being skipped.)
>
>
> I was hoping you folks might take a look, and maybe provide a patch. /cro=
sses fingers/
>
> steved suggested that this took place around: utils/mountd/cache.c:nfsd_f=
h():path =3D next_mnt(&mnt, exp->m_export.e_path);
>
>
> Cheers,
>
> Phil
>

I can imagine /etc/mtab being read once for every line in /etc/exports,
but unless your /etc/exports is very big, I can't easily see why it
would be read 900 times.
Maybe lots of different mount points are being accessed by something and
each one triggers a few reads...

Can you show your /etc/exports file?

>
> P.S.: I can provide straces on demand if required, I didn't want to clutt=
er up the message.

I don't recommend this approach.  If you have data, just provide it.  If
it is really really big, provide a link.
You have my attention now.  You might not get it again when you send the
strace.  You might have wasted your opportunity.
Yes - please provide the strace showing lots of reads through
/etc/mtab.  Don't provide it privately to me.  Either post it to the
list, or post a link to it.

NeilBrown


>
> --=20
> Phil Kauffman
> Systems Admin
> Dept. of Computer Science
> University of Chicago
> kauffman@cs.uchicago.edu
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlle8j8ACgkQOeye3VZi
gbk3Yg//e/chBZMOBzDECzQwb28Dr3Ss2vO+WD4PjJJIlCYgkCF6tpMqsEI0m0iu
xf7nvX2xsFX5WFky8EOL5Y3wZJIv7Uu/xkuXZX8nWu7dOB05f11S1Npe0JwZvz4p
9KlILH+OWXMxwNE4GWljfRG10pJYvD3/9X6mTkGgMBO6L/owZq3vjKOuB8sQtDu2
3764fqKDx0kI76ptQ+S4s3Ts/SL8Q10MwMK583df3UrU1cXLvIq4KyLUGe43pEEj
anqYZQ+U0pvrabJhcS9w1Fv1UzDkwWO72dOFb2sNAqE6HAJl756m1k5R2DSNFSvx
VnuKx3HKtjgq5pfLnwNYZnlbqimpePZZ5y+5Fz6zDwoa/dYgPUc0x9jCt8V2rYMZ
1WvcAnAPYk09xdVfnUZ97LjhWSc9Y/bE+Ws+turHCtOLjAW11U807ixZA1SMPJBz
fX3YUVTcxYSN6skI+xmF3MWcRQ03ZOotYUMzFMb+rQBLa57kLXk7ACxqXrw69fbj
9tKqGlnG8FoIXHt1jnfUxFOOR/ytqYEFWBKAgII/qT6LJNVPfjcW/ZIcysc3Xl3s
SaCvOWiTXhUGX+KLHAFtzx5rgVO4+q09A79b+5t3U0WUX3hBT6A0yT5uq877sneX
FcWabn0lfrU2v/DnCpnB37SAS0ZJhFzwsib8ZVGNPbtEcIerJ7A=
=FLKl
-----END PGP SIGNATURE-----
--=-=-=--

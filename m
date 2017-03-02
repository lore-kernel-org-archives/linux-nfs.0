Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45801 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdCCBY1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 20:24:27 -0500
From: NeilBrown <neilb@suse.com>
To: "bfields\@fieldses.org" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 03 Mar 2017 09:57:32 +1100
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/2] Fix up nfsd to enable NFSv4.x without NFSv4.0
In-Reply-To: <20170227230357.GA11912@fieldses.org>
References: <20170222233533.23845-1-trond.myklebust@primarydata.com> <87y3wxrcha.fsf@notabene.neil.brown.name> <1487811610.4863.10.camel@primarydata.com> <20170227230357.GA11912@fieldses.org>
Message-ID: <87k287nv6r.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 27 2017, bfields@fieldses.org wrote:

> On Thu, Feb 23, 2017 at 01:00:12AM +0000, Trond Myklebust wrote:
>> On Thu, 2017-02-23 at 11:13 +1100, NeilBrown wrote:
>> > On Wed, Feb 22 2017, Trond Myklebust wrote:
>> >=20
>> > > This patch series was intended as a standalone series. However it
>> > > now
>> > > aims to fix up a few issues with Neil's initial patch:
>> > >=20
>> > > 1) When the user turns off all minor versions of NFSv4, then that
>> > > should
>> > > =C2=A0=C2=A0=C2=A0be equivalent to turning off NFSv4 support, and so=
 when someone
>> > > tries
>> > > =C2=A0=C2=A0=C2=A0to mount, we should return RPC_PROG_MISMATCH.
>> > > 2) Allow the user to use either '4.0' or '4' in order to enable or
>> > > disable
>> > > =C2=A0=C2=A0=C2=A0minor version 0. Other minor versions remain enabl=
ed/disabled
>> > > using the
>> > > =C2=A0=C2=A0=C2=A0'4.x' format.
>> >=20
>> > If I understand you and the code correctly, then this change means
>> > that
>> > if I run
>> >=20
>> > =C2=A0=C2=A0=C2=A0rpc.nfsd -N 4
>> >=20
>> > the nfs server will continue to server v4.1 and v4.2 requests, only
>> > v4.0
>> > will be disabled (Assuming a kernel which defaults to serving v4.0,
>> > v4.1
>> > and v4.0).
>>=20
>> Unfortunately not... The problem is that rpc.nfsd has a borken parser
>> that refuses the '-N4 -V4.2' syntax, and that throws hissy fit if you
>> try to feed it '-N4.0' or '-V4.0'.
>>=20
>> The kernel change needs to be accompanied by a fix to nfs-utils.
>>=20
>> > Is that really what we want?
>> >=20
>> > The text in the man page for rpc.nfsd could be read as allowing this
>> > interpretation, though it isn't explicit.
>> > I've always used "NFSv4" to mean any or all for 4.0, 4.1, 4.2, ...
>>=20
>> We _could_ do that. As I said, that's a question of fixing rpc.nfsd.
>>=20
>> The question here, though, is what should the kernel do when you start
>> poking into /proc/fs/nfsd/versions. I think adding a new field between
>> '4' and '4.0' might be more disruptive than changing the meaning of '4'
>> to mean '4.0' as there might be other parsers of that pseudofile out
>> there today.
>
> I'm OK with that, unless Neil sees a problem.

I don't know ... the more I think about it, the less certain I seem to
be.

Prior to Trond's updates for nfs-utils, "rpc.nfsd -N 4" would write
 "+3 -4"
to the 'versions' file, which will currently disable NFSv4 completely.
With this patch it will disable 4.0, but leave 4.1 active.

This behavior is consistent with the documentation, which says:

   The  current version of rpc.nfsd can support major NFS versions 2,3,4
   and the minor versions 4.1 and 4.2.

which suggests that "4.1" is a different thing to "4", not part of it.
And the current nfs-utils doesn't support disabling just 4.0 at all.
You cannot say "rpc.nfsd -N 4.0".
So this patch gives more control to the old nfs-utils, by changing the
semantics of a particular operation.

Technically, it is a regression though.  It does result in a more
coherent interface, which is a good thing in the long term.

When you read from "versions" you get the major version and minor
version listed separately, with a special case that "+4.0" is never
reported.
So if just 4.1 is enabled, you might get
   -3 +4 -4.0 +4.1 -4.2

after Trond's change "4" means "4.0" and "4.0" is never displayed,
so the above case would become
   -3 -4 +4.1 -4.2

which is very different.  Probably another regression.

I guess I'm not entirely sure what Trond is trying to fix.
This bit:

1) When the user turns off all minor versions of NFSv4, then that should
   be equivalent to turning off NFSv4 support, and so when someone tries
   to mount, we should return RPC_PROG_MISMATCH.

Makes perfect sense.  But I'm not clear on why the format of the
versions file needs to change.
Trond - what am I missing?

Thanks,
NeilBrown



>
> The changelog on the first patch doesn't seem to describe the v2 version
> very well; using the below cribbed from your cover letter instead.
>
>     nfsd: fix configuration of supported minor versions
>=20=20=20=20=20
>     When the user turns off all minor versions of NFSv4, that should be
>     equivalent to turning off NFSv4 support, so a mount attempt using NFS=
v4
>     should get RPC_PROG_MISMATCH, not NFSERR_MINOR_VERS_MISMATCH.
>=20=20=20=20=20
>     Allow the user to use either '4.0' or '4' to enable or disable minor
>     version 0.  Other minor versions are still enabled or disabled using =
the
>     '4.x' format.
>
> --b.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli4o1wACgkQOeye3VZi
gbk0dA/6AoO0+TF+Kav9WT2Zxae5odZqnGrHw67kcdFVyYJc6MwjN74gwvDXgjRr
Rn+2MhWfjrTIX1lkxStNMz79jX7vniczjC3sjLyKsAAcqzHWm41mtDcadkFZ5OUX
qU8gHecA6GbqxEPLKI0II2imtXpBRA+uerkjB06cCZthVrlZutJd94qVFH93Clbz
MW0FOoYt9Q4l7tR5CnFhWVL7oWRifBGtJZhXDznepNMypaRCj/9L/xKub/9a0oW9
W9aA3fwsHeUQGaVh6F1tlYoHbwFHHstMkSFWHO3nsme2QcBrnFIR9TD2ev1lYgjH
YBYzGX2zVDfDM1bzFmak8ogsmQcerusvUgaLfsp3zrGW7kGjL3sEUQ3k9OXOIVmW
jL2XYNH1O5JeFipcSmsSCkl9H3f4vkmULzt9uUZqfawY90+dRPbRdT0vk4Xzf70v
68x0ISrPrG5q97yyOC/rHS5tPNvJcm+2lOjN0w7Gx9WqCm7AWSplmpjbPA/u4sv2
GnhrEGh8DqGjOMY74l9ZnLJPoNGPDKyRdb8EvVrvSoY9ScOoqQmGy5yBsI4PUwwS
mico7i7T0D7GTrrJFSRY7vZD0DXu5pBSzKcX6UUZBdFJ51b/nDghp3pSmdG4jMeq
IFuEbvheAFydHCMl2ZhTEZtIjhfb0W8tsDpCi1vx1T3WJTDmfsM=
=ImT6
-----END PGP SIGNATURE-----
--=-=-=--

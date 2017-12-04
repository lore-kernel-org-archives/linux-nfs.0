Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41556 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752179AbdLDULJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Dec 2017 15:11:09 -0500
From: NeilBrown <neilb@suse.com>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Date: Tue, 05 Dec 2017 07:11:00 +1100
Cc: Thiago Rafael Becker <thiago.becker@gmail.com>,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of set_groups.
In-Reply-To: <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
References: <20171130130457.11429-1-thiago.becker@gmail.com> <20171130130457.11429-3-thiago.becker@gmail.com> <87mv2ztgix.fsf@notabene.neil.brown.name> <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat>
Message-ID: <87efoatfsb.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 04 2017, Thiago Rafael Becker wrote:

> On Mon, 4 Dec 2017, NeilBrown wrote:
>
>> I think you need to add groups_sort() in a few more places.
>> Almost anywhere that calls groups_alloc() should be considered.
>> net/sunrpc/svcauth_unix.c, net/sunrpc/auth_gss/svcauth_gss.c,
>> fs/nfsd/auth.c definitely need it.
>
> So are any other functions that modify group_info. OK, I think I'll=20
> implement the type detection below as it helps detecting where these=20
> situations are located.
>
> This may take some time to make sane. I wonder if we shouldn't=20
> accept the first change suggested to fix the corruption detected in=20
> auth.unix.gid while I work on a new set of patches.=20

As we don't seem to be pursuing this possibility is probably isn't very
important, but I'd like to point out that the original fix isn't a true
fix.
It just sorts a shared group_info early.  This does not stop corruption.
Every time a thread calls set_groups() on that group_info it will be
sorted again.
The sort algorithm used is the heap sort, and a heap sort always moves
elements in the array around - it does not leave a sorted array
untouched (unlike e.g. the quick sort which doesn't move anything in a
sorted array).
So it is still possible for two calls to groups_sort() to race.
We *need* to move groups_sort() out of set_groups().

Thanks,
NeilBrown


>    Also, that patch=20
> doesn't change behavior of set_groups, and is easier to backport if=20
> distros relying on older kernels need to do so and change behavior. The=20
> first suggestion is undergoing tests, and so far we didn't detect any=20
> new corruptions on auth.unix.gid.
>
>> Maybe it could be done with types.
>
> I changed the interfaces on groups_{alloc,sort} to check. There are some=
=20
> extra changes needed in groups_from_user and others to make this viable,=
=20
> but I like it and I'll try to make it happen.
>
>> Thanks,
>> NeilBrown
>>
>
> Thanks,
> trbecker

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlolq9QACgkQOeye3VZi
gbnpPhAAoeD16enhx9q8aonrxzvQfrVN8Fri3BZyzZ/gQDS/s1pTjC7Hlxm1iAXK
Se4KO4v6OTyFCwuy8EOsa5sVKWD6rD/3ko4qO/WZwzvZtUek//4xy4h7hmCyOvjg
UOCXleH6E4Xm69yq2TpZAT98urDZfhmqI/guJkS/cG/0meQuB8ESYSQjlYXEycNc
8opXa0Y/V4QkkcROKZcrwTsHbCs8/9A+Vor++3fGBpv5VL8aPsXWRcDqlYpimhfb
edmDO71A0Z365vXynKpqrstbxciv9aSWQlsmRlkuMKqkZVh3fcGW5qK/AqAYwp/L
JlbipLSU3TGINiX3bPvCqmoAhJmVtElAtbp80g695RU206KyJtIJTeRPJUGrzyTz
YvcOIyBO3AKUyVsq+zDZ3ZjFW0NS3Tu06kqxSeaQMBn55f5Fj8SAfMiTxS8G4Rlo
A8vbQa/UIdTAO15Akmb28QPLLlCYQiqT5WXwDcyessefssL5wva1Sihze7mrzmzP
0T67BO+UMzw6r55Evr4sAJBZNOABJTdivFgu0S0YLk3OkEsyb+V6fqVpYAbVnnLc
yiSL48uAj/qwXgWuIqdIAaBlpVL8Tbe8h6mUp1eJ1+UuyQnBbIdJy0KFTFLnPsmK
B9CXBILnIAOINPAN6bypQylkMIQEkRRy6KfhrdEVON2RRDH+euo=
=Sss0
-----END PGP SIGNATURE-----
--=-=-=--

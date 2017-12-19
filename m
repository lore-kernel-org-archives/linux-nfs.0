Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:47438 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750918AbdLSUOq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Dec 2017 15:14:46 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 20 Dec 2017 07:14:33 +1100
Cc: Thiago Rafael Becker <thiago.becker@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of set_groups.
In-Reply-To: <20171219163023.GB19967@fieldses.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com> <20171130130457.11429-3-thiago.becker@gmail.com> <87mv2ztgix.fsf@notabene.neil.brown.name> <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat> <87efoatfsb.fsf@notabene.neil.brown.name> <20171219163023.GB19967@fieldses.org>
Message-ID: <87mv2elbkm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 19 2017, J. Bruce Fields wrote:

> On Tue, Dec 05, 2017 at 07:11:00AM +1100, NeilBrown wrote:
>> On Mon, Dec 04 2017, Thiago Rafael Becker wrote:
>>=20
>> > On Mon, 4 Dec 2017, NeilBrown wrote:
>> >
>> >> I think you need to add groups_sort() in a few more places.
>> >> Almost anywhere that calls groups_alloc() should be considered.
>> >> net/sunrpc/svcauth_unix.c, net/sunrpc/auth_gss/svcauth_gss.c,
>> >> fs/nfsd/auth.c definitely need it.
>> >
>> > So are any other functions that modify group_info. OK, I think I'll=20
>> > implement the type detection below as it helps detecting where these=20
>> > situations are located.
>> >
>> > This may take some time to make sane. I wonder if we shouldn't=20
>> > accept the first change suggested to fix the corruption detected in=20
>> > auth.unix.gid while I work on a new set of patches.=20
>>=20
>> As we don't seem to be pursuing this possibility is probably isn't very
>> important, but I'd like to point out that the original fix isn't a true
>> fix.
>> It just sorts a shared group_info early.  This does not stop corruption.
>> Every time a thread calls set_groups() on that group_info it will be
>> sorted again.
>> The sort algorithm used is the heap sort, and a heap sort always moves
>> elements in the array around - it does not leave a sorted array
>> untouched (unlike e.g. the quick sort which doesn't move anything in a
>> sorted array).
>> So it is still possible for two calls to groups_sort() to race.
>> We *need* to move groups_sort() out of set_groups().
>
> By the way,
>
> 	https://bugzilla.kernel.org/show_bug.cgi?id=3D197887
>
> looks like it might be this bug.  They report it started to happen on
> upgrade from a 4.10-ish kernel to a 4.13-ish kernel, which would include
> the commit (b7b2562f725) that converted groups_sort to a function that
> is no longer a no-op in the already-sorted case.
>
> Looks like rpc.mountd just uses getgrouplist(), and I don't think that
> guarantees any particular oder.  I wonder if it's the case that many
> common configurations always pass down an already-sorted list.  In that
> case this may show up as a 4.13 regression for some users.

I think the 4.13 patch makes the problem worse, but isn't the only
cause.  We had this reported against SLE12 which is based on 3.12 and
doesn't have that patch backported.

Before 4.13 the problem only occurs if getgrouplist() returns an
unsorted list, and if two threads both try to sort this list at the same
time they can corrupt it.
If you are using /etc/passwd and /etc/group, then the order of groups
returned by getgrouplist is the order that the groups were added to
/etc/group (or at least, the order they appear in the file).
This will often be numerical order, but site-local policies could easily
result in a different order.

4.13-stable is EOL and the patch has already been queued for 4.14.8.
Greg tried 4.9 and 4.4, but the patch didn't apply.  Is anyone
volunteering to do the backport???

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo5cyoACgkQOeye3VZi
gbmn1Q//bcoqRUV0I5z8AA26UpvYrs14+Yp6rMeIO9lz2aO5F5mBqeS/xpkyb702
wvlOL/qiOI0v0UnBJyIqAOT+Ri+s+XhbM/NJV+5Ba9D9SkIVKAQDhzvrmMCY+TXa
eX01EOnjl6IgSe5Vr56jMmiSMxVhynvUreaa77/rLxirm2JaNmjTMMXOht3VUayR
RPA1gDrQeiJQaUMhiX01KymLTq9mb5bQC0P389uSy5TiIbyBm4bqGieWqLYSVlSE
lKLRlKJBn8DosxXg0QAvGDQujBawW0W2LINuQrXW6ahwDuvjDI4s4C6hUsgYq//S
yw1uUsoIw/JgZK4m9DwsXaS1mmq5lWShXNoDhGlxClS/gNVjxIBDskVPdUh3Pb+1
2zWHfCbzfD171rHwuJv2LzmcMSl8GKLOkAQ4A/UPvutMIONU802H8lZA+9oNW9/b
onkhDbFdZHOu2ZOEkCMZdZmuZEtFkOyAz5qL0DKTOdlRlrT2F0l6ie3pwZpkA/WO
0XoiD76X/6mUcso8MMwed5n0mzkLtiFTDHP6XgapHHLZaIDJN/Ydg4MnjGv6/3uh
BAnu1j4OiZ0l4PY6wvjvMzBPvoYHU87ZD6XLxfnHD4BHNZHqKEc7uTo7WOSYs4F7
yXw2mu/PFL5qUzKDuLm6SY2C4J1QDryXQ2G74uNgQIyE3AY09Kw=
=Dx6n
-----END PGP SIGNATURE-----
--=-=-=--

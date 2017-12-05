Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41777 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751066AbdLEWFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Dec 2017 17:05:25 -0500
From: NeilBrown <neilb@suse.com>
To: Matthew Wilcox <willy@infradead.org>
Date: Wed, 06 Dec 2017 09:05:15 +1100
Cc: Thiago Rafael Becker <thiago.becker@gmail.com>,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3, V2] kernel: Move groups_sort to the caller of set_groups.
In-Reply-To: <20171205212847.GF26021@bombadil.infradead.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com> <20171130130457.11429-3-thiago.becker@gmail.com> <87mv2ztgix.fsf@notabene.neil.brown.name> <alpine.LFD.2.21.1712041049280.1738@tbecker-rhat> <87efoatfsb.fsf@notabene.neil.brown.name> <20171205212847.GF26021@bombadil.infradead.org>
Message-ID: <87609ku8ys.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 05 2017, Matthew Wilcox wrote:

> On Tue, Dec 05, 2017 at 07:11:00AM +1100, NeilBrown wrote:
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
> It must be relatively common to sort an already-sorted array.  I wonder
> if something like this patch would be worthwhile?
>
> I have deliberately broken this patch so it can't be applied.  I haven't
> tested it, and for all I know, I got the sign of cmp_func wrong.
>
> diff --git a/lib/sort.c b/lib/sort.c
> index d6b7a202b0b6..2b527fde6dad 100644
> --- a/lib/sort.c
> +++ b/lib/sort.c
> @@ -75,7 +75,14 @@ void sort(void *base, size_t num, size_t size,
>  			swap_func =3D generic_swap;
>  	}
>=20=20
> -       /* heapify */
> +	/* Do not sort an already-sorted array */
> +	for (c =3D 0; c < (n - size); c +=3D size) {
> +		if (cmp_func(base + c, base + c + size) < 0)
> +			goto heapify;
> +	}
> +	return;
> +
> +heapify:
>  	for ( ; i >=3D 0; i -=3D size) {
>  		for (r =3D i; r * 2 + size < n; r  =3D c) {
>  			c =3D r * 2 + size;

I wondered about this possibility...
It is a clear win from a defensive-programming perspective.
Adding a small overhead to every sort call isn't ideal, but I doubt it
is noticeable (typically 2 or 3 tests I suspect).
I probably wouldn't advocate this approach, but I certainly wouldn't
fight it.
I *do* like the way you changed a comment to a label!

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlonGBwACgkQOeye3VZi
gbkVMQ/9EOrH/xPcHvnCoJGX3eIjybMN2vnyvdYrX8SdLLGS0bapXHtsx8Hd0SLQ
WLhtkCwLVjoJHgUjjIinKeCe2L9gRVN5SFHxznWV9eFakFNEejBZmUlJOCRtL1QA
gWSmCono2bTE/WVbvgRJVT96JlWHw3OUvBEz0uICo9oYK/ekxJC8VU6gJepJNNNe
E0JmSH9N/X32FeArYKmDlb0QBUM83i2jZYWTYTOewbJCa9WyjHMxVagARgge8IeG
zKu18rpZsU3UKTlZJ6hNotmd1jft9ABaZNmXnQUy6BldmGYPP00PKwcrZoXuHeXu
rSNj+mMA50zyRWij8nk/JUbqD6KubP9hUR9KrkN3vDMovuC4ycwCyjFNV+oJGlux
ukwT1B49jS83fIxF1IX3PQg9hE0m+HJYnUrqmYkVOhTVGmTdpA1+2GlbBYpctj3Y
1+M5ACXRkzYxcGJPTc+6xqHZBgd06lR43QNvaITMtDzzijvknZkWAzKbuRsTR82x
Vxgb0N+RSaG2GGg7BECSRMsm8QzZWS0/+6me/SqUbHz4Xx0qxu/y9h5XTTxATP1c
INQbQtvF4zGPJCn/EN+8Fks3+qagwXOUmtDz0lHy/DiJzK7Pqja3lxDpe21FtY30
Hu+rCxEf6ux1QsuUdCSQBaSzcTvz1UdAfE/Xv0/Vggq2yKaU4L4=
=+fFI
-----END PGP SIGNATURE-----
--=-=-=--

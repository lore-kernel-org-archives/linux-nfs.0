Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40436 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751835AbdCBXmr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 18:42:47 -0500
From: NeilBrown <neilb@suse.com>
To: Chris Siebenmann <cks.nfs01@cs.toronto.edu>
Date: Fri, 03 Mar 2017 10:28:13 +1100
Cc: Chris Siebenmann <cks.nfs01@cs.toronto.edu>, linux-nfs@vger.kernel.org
Subject: Re: Manual page bug: two inaccuracies in nfsd(7)
In-Reply-To: <20170223164644.E40565A0066@apps1.cs.toronto.edu>
References: <20170223164644.E40565A0066@apps1.cs.toronto.edu>
cc: "steved@redhat.com" <steved@redhat.com>
Message-ID: <87efyfntrm.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Feb 23 2017, Chris Siebenmann wrote:

>> >  I was recently reading this manual page as part of exploring running
>> > an NFS server on Ubuntu 16.04 (with Ubuntu's kernel '4.4.0') and found
>> > two inaccuracies with the current state of the kernel (or at least how
>> > it looks to me based on both experimentation and code).
>> >
>> >  First, there is no /proc/net/rpc/auth.domain directory and cache any
>> > more. This was removed from the kernel in 2006 (in commit efc36aa5608f=
),
>> > so I think it should be safe to remove from current versions of the
>> > manpage.
>>=20
>> I agree.
>>=20
>> >
>> >  Second, the manpage says about the 'flush' files to be found in eg
>> > /proc/net/rpc/auth.unix.ip:
>> >
>> > 	When a number of seconds since epoch (1 Jan 1970) is written to
>> > 	this file, all entries in the cache that were last updated before
>> > 	that file become invalidated and will be flushed out. Writing
>> > 	1 will flush everything. [...]
>> >
>> > The bit about 'writing 1 will flush everything' does not appear to be
>> > accurate.
>>=20
>> I was never accurate.  I vaguely remember writing it.  I must have been
>> confused.
>>=20
>> Would you be able to create a patch which fixes these issues, and post
>> it, with a signed-off-by ?
>
>  Here is a patch that deletes the mention of auth.domain and changes the
> wording around 'flush' files. I'm not attached to the revised wording;
> it's just the best I could manage in something that felt that it was
> within the same style and space as the current wording.
>
> Signed-off-by: Chris Siebenmann <cks.nfs01@cs.toronto.edu>

Thanks.
Acked-by: NeilBrown <neilb@suse.com>

hopefully Steve will pick this up in due course.  He tends to apply
patches in batches every few weeks.

Thanks,
NeilBrown

>
> diff --git a/utils/exportfs/nfsd.man b/utils/exportfs/nfsd.man
> index 0c516fa..9efa29f 100644
> --- a/utils/exportfs/nfsd.man
> +++ b/utils/exportfs/nfsd.man
> @@ -105,11 +105,6 @@ clients have for different filesystems.
>  The caches are:
>=20=20
>  .TP
> -.B auth.domain
> -This cache maps the name of a client (or domain) to an internal data
> -structure.  The only access that is possible is to flush the cache.
> -
> -.TP
>  .B auth.unix.ip
>  This cache contains a mapping from IP address to the name of the
>  authentication domain that the ipaddress should be treated as part of.
> @@ -133,7 +128,8 @@ are:
>  .B flush
>  When a number of seconds since epoch (1 Jan 1970) is written to this
>  file, all entries in the cache that were last updated before that file
> -become invalidated and will be flushed out.  Writing 1 will flush
> +become invalidated and will be flushed out.  Writing a time in the
> +future (in seconds since epoch) will flush
>  everything.  This is the only file that will always be present.
>=20=20
>  .TP
>
>
> 	- cks
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli4qo0ACgkQOeye3VZi
gbkfOA/+OKz1AI1FaQaGa3cfaefHcfWs/AQE5tOvGa0/1DmYoF+BIUJt9BJ4knm0
43npMcsiqg/mX/CDtisMrn8In30Lo37vUu64VSoWUlHcOaWt29yhXc+0TiT6+B+g
wMmAxOHpncOFyQJ6e9KY6YdHPyEjqOsamklWTxgrO4Jmj4ddxAOk/ibqdQsgRS0y
FyWP7by3/loBzEy9Ed6v7qUfGkWfxLCQsixBrqU8ANzZHX/1g/1chBM9yBjIS5r1
NCeWg0z1qmdHgqVt84BD44Rmsnk6hAFG3iHXX7VB4x3vdDVmq8db+HXePfXgER6J
SM6yqBzC2BKAUXUdjwrTA7LSZ8wem3rXn5cFplDnqjcZypg1qwGCc741dBceyWZp
LtVEYgxPF6dOH0UizjfNgvXjOuYE+eF5zOfURHL2xKUizGKIRFZPlhPxQBgXz7f+
l2qdrKdQSjBDiSRAVuAfO1YlSPj+xXvnNmS/OmiaX4r5QYQkpZRPlJlyaQkLSpoR
mXCG4xVoelxRYA+ZTzqvqrV3T4gGbOZv25V1fUH2sv7HLTk06X9O5ju0s6n58iNd
f9Gib8+aFHmUYwfyeexlY/6Wnsiko5WgWtYMNbBfv0Ie7Su4IQzLOsehtntgSDp7
HXX9D51uVnRxC87+ZqkcqHrr32pBDMsaq+GPmz9AdyLQoW+ch70=
=FcaM
-----END PGP SIGNATURE-----
--=-=-=--

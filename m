Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40767 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752252AbdLHCKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Dec 2017 21:10:52 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Joshua Watt <jpewhacker@gmail.com>,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Date: Fri, 08 Dec 2017 13:10:40 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "David Howells" <dhowells@redhat.com>, linux-api@vger.kernel.org
Subject: Re: [RFC v4 0/9] NFS Force Unmounting
In-Reply-To: <1512565420.4048.21.camel@redhat.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com> <1512398194.7031.56.camel@gmail.com> <87indksq9q.fsf@notabene.neil.brown.name> <1512565420.4048.21.camel@redhat.com>
Message-ID: <87bmjaq89r.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 06 2017, Jeff Layton wrote:

> On Wed, 2017-12-06 at 10:34 +1100, NeilBrown wrote:
>>=20
>> The new semantic for MNT_DETACH|MNT_FORCE is interesting.
>> As it was never possible before (from /bin/umount), it should be safe to
>> add a new meaning.
>> The meaning is effectively "detach the filesystem from the namespace and
>> detach the transport from the filesystem", which sounds like it is
>> useful.
>> It is worth highlighting this, and maybe even cc:ing
>> linux-api@vger.kernel.org ... done that.
>>=20
>
> I'm not thrilled with the new flag combo, personally. Given that we're
> introducing new behavior here, I think it wouldn't hurt to add a new
> UMOUNT_* flag for this (UMOUNT_NUKE_FROM_ORBIT?).

Suppose we did... MNT_FORCE_PONIES. What would be the semantics of this
flag?  Once we had it, would anyone ever want to use MNT_FORCE again?

MNT_FORCE is already fairly heavy handled.  It abort an arbitrary
collections of RPC requests being sent for the given filesystem, no
matter where else that filesystem might be mounted.
Is it ever safe to use this flag unless you have good reason to believe
that the server is not available and there is no point pretending any
more?
And if that is the case, why not use the new MNT_FORCE_PONIES which is
at least predictable and reliable.

We've talking a lot about the one NFS filesystem being mounted in
multiple containers.  MNT_FORCE is already a problem for such mounts as
one contains can kill requests generated from another container.  Maybe
MNT_FORCE needs to be restricted to "real" root.
Once we restrict it, do we need to keep it from being too harsh?

What would be really nice is a timeout for umount, and for sync.
The timeout only starts when the filesystem stops making progress for
writeback.  If it eventually does timeout, then the caller can fall back
to MNT_DETACH if they are in a container, or MNT_FORCE if not.
(Maybe MNT_FORCE should map to MNT_DETACH in a container??? or maybe
not).

There is a lot here that still isn't clear to me, but one this does seem
to be becoming clear:  MNT_FORCE as it stands is nearly useless and it
would serve is well to find a semantic that it actually useful, and
impose that.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlop9KAACgkQOeye3VZi
gbmnGA/+LUCXuxlji4dN70TLZJFwzr3sHIJ0mQZpsx/jooeerllMthXHE2HyxJqO
lGlnE1YyaKSjef2gjJp3FyR4z6zr8DFRsJ0TJpbuKNv0dlvmN23enJ8wa0A5lk5a
cZtEDslZAAdNPe9nAKwV7T+LXi+487n2VwTopMlL55EU84CFvT7cQZdjYVxPcVaE
b942feqU75/SSCFFfJwfrtT45hHwbN2lUeTj5AVqiaxmmvoARrxpY1dUTgE6pVzv
wB2p5/BypPcVfbyR39bBgtew+VlHPXa+MOJSXypMExr0Yolgb9/1jEPEXEIqAO6O
ULteF1XvOGafPVJsf+YgbPS7uOC82bT5zb6/rSjn4lNsA0icqbSSmTvfIytjYEKj
4u06cEM4zDl99Bv57vTS9VA39Ri1zFsyg+tJv553n4ZklQT8zFzylAvwrNzb0Wkk
vy2/e8a/nIhF7tGWC3M/txsNO1pN9xuf3OczsgeX+HCus3pCsAgwqh+pKFbC6TBX
17/jW/a0n5ThPxuNE642Pp6MEZ9jgPQtWrkHQ6erAQXUWqQMTJZWDGHNJv5X7Mcv
CG0f5jmelwZQWbkp9UkwB4HN7a0PTzEQNP4EdPzWBN5ep4Q/hHW0zHlQtsahJZu7
EtjoKQ7qVs1l0I8shuL1qPQfDsuOzUBD0kUa6LuH65B8mZNGpZM=
=Xk3D
-----END PGP SIGNATURE-----
--=-=-=--

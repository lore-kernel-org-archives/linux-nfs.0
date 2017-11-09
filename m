Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49202 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754406AbdKIVGY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 16:06:24 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>, Ian Kent <ikent@redhat.com>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Ron Minnich <rminnich@sandia.gov>,
        Trond Myklebust <trondmy@primarydata.com>
Date: Fri, 10 Nov 2017 08:06:09 +1100
Cc: linux-nfs@vger.kernel.org, autofs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 0/3] VFS: name lookup improvements.
In-Reply-To: <1510230754.29194.6.camel@redhat.com>
References: <151021179901.22743.15252956909042161062.stgit@noble> <1510230754.29194.6.camel@redhat.com>
Message-ID: <87a7zvf9ha.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Nov 09 2017, Jeff Layton wrote:

> On Thu, 2017-11-09 at 18:20 +1100, NeilBrown wrote:
>> These three patches address two issues: d_weak_revalidate and
>> path_mountpoint lookups.
>>=20
>> The former is poorly defined and doesn't actually do the one thing
>> that it would be useful for it to do.  So the nfs implemention
>> is improved, the 9p one discarded, and the documentation clarified.
>>=20
>> Given this change and recent change to follow_automount() the
>> mountpoint path lookup functions are no longer needed.  The regular
>> path look functions are quite sufficient.
>> The second two patches remove this with detailed explanation of why
>> it is OK.
>>=20
>> Thanks,
>> NeilBrown
>>=20
>>=20
>> ---
>>=20
>> NeilBrown (3):
>>       VFS/nfs/9p: revise meaning of d_weak_invalidate.
>>       VFS: remove user_path_mountpoint_at()
>>       VFS / autofs4: remove kern_path_mountpoint()
>>=20
>>=20
>>  Documentation/filesystems/porting |    5 +
>>  Documentation/filesystems/vfs.txt |   11 +--
>>  fs/9p/vfs_dentry.c                |    1=20
>>  fs/autofs4/dev-ioctl.c            |    5 -
>>  fs/internal.h                     |    1=20
>>  fs/namei.c                        |  150 ------------------------------=
-------
>>  fs/namespace.c                    |    2=20
>>  fs/nfs/dir.c                      |   60 ++-------------
>>  include/linux/namei.h             |    1=20
>>  9 files changed, 24 insertions(+), 212 deletions(-)
>>=20
>> --
>> Signature
>>=20
>
> I love that diffstat and I think the patches and the logic behind them
> look reasonable. I'm the one that added d_weak_revalidate and while it
> did fix a problem at the time, it has always seemed a bit of an odd
> d_op.
>
> Your patch does make me wonder if we should consider merging
> d_weak_revalidate and d_revalidate back together, and simply require all
> the d_revalidate ops vet the flags more thoroughly.

This boils down to adding

 if (flags & LOOKUP_JUMPED)
 	return 1;

to the front of almost every d_revalidate function.
I'm probably in favour of that, but it isn't an obvious win.
I can certainly offer it as a follow-on patch so we can see
exactly the impact.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloEw0MACgkQOeye3VZi
gbmyGg/+OcpR/hHDyiO5Mtlpf07nrrERcoK6jXdQI83xawiL73Ewu71kWPvzuL2o
5jvumq+W3eK1qJKjYB7IcfrNIaRTv+LHVkUk50Yjs1YyzsXmsyIKc7jYdLPAlEEQ
AHAWdsGnuOIrEzRxAkdh9Rvef1vnmJdNicnAV9G7fKcpws5y0T/KKmEZH5emBaU4
JEWA2M7EcSM6KUa/cWgUNFRRtqh0GamF/OmKQE8+cDvO3T/sl+pmDc+yoUBKd6w4
8BNq46KoeYLTI7Q+sjoVuYAVSbVO0yoDxnUzVwrJHyoaHoyStZvtuuSzHhUqzyIg
LOQdwNbryuY8sn/NNntSdu79ypL+mkVyo8GwJlnLWjmOMAwQOXyoW73h2s9bwdBm
JVqPPjroei/HAZ7Uafh9c9dLYCB1mIqWZDmXAKtyQQv/tG1WHdU6W0KBRzmzxKht
msgHPmsYTEK0MEXX/OIZ0X+Xf5xojzSZ1dK60nAntB0GcwSFUFcV/aePu9s7RRcd
FoigaDWbyilqlh7LadY6Mxbc1oJFCwRJSaCQsYYwaFH0TBee27Nx3LFiLxnCVI/U
qcN6nV7gRvyVcJ0qs4FPIDQovaZgpRN9SKGhVMKYcS4TxOAHjFJ5FoQ016caIZPN
mX+rz6aQNajnwaC+aAhhitLchZUvG0AmjOX3y7GuRDpuqUZTvpE=
=eOBf
-----END PGP SIGNATURE-----
--=-=-=--

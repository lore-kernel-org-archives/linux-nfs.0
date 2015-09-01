Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029AbbIAQW1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2015 12:22:27 -0400
Message-ID: <55E5D0B6.10307@redhat.com>
Date: Tue, 01 Sep 2015 18:22:14 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
To: Mel Gorman <mgorman@techsingularity.net>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com> <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com> <55AF9EA8.6020102@redhat.com> <20150727105216.GD2660@techsingularity.net> <55B6153B.1070604@redhat.com> <20150820122359.GB12432@techsingularity.net>
In-Reply-To: <20150820122359.GB12432@techsingularity.net>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="8TG3LH2fFv3OAsUxLSlllKGb7sTJVdCk6"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--8TG3LH2fFv3OAsUxLSlllKGb7sTJVdCk6
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

On 08/20/2015 02:23 PM, Mel Gorman wrote:
> On Mon, Jul 27, 2015 at 01:25:47PM +0200, Jerome Marchand wrote:
>> On 07/27/2015 12:52 PM, Mel Gorman wrote:
>>> On Wed, Jul 22, 2015 at 03:46:16PM +0200, Jerome Marchand wrote:
>>>> On 07/22/2015 02:23 PM, Trond Myklebust wrote:
>>>>> On Wed, Jul 22, 2015 at 4:10 AM, Jerome Marchand <jmarchan@redhat.c=
om> wrote:
>>>>>>
>>>>>> Lockdep warns about a inconsistent {RECLAIM_FS-ON-W} ->
>>>>>> {IN-RECLAIM_FS-W} usage. The culpritt is the inode->i_mutex taken =
in
>>>>>> nfs_file_direct_write(). This code was introduced by commit a9ab5e=
840669
>>>>>> ("nfs: page cache invalidation for dio").
>>>>>> This naive test patch avoid to take the mutex on a swapfile and ma=
kes
>>>>>> lockdep happy again. However I don't know much about NFS code and =
I
>>>>>> assume it's probably not the proper solution. Any thought?
>>>>>>
>>>>>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>>>>>
>>>>> NFS is not the only O_DIRECT implementation to set the inode->i_mut=
ex.
>>>>> Why can't this be fixed in the generic swap code instead of adding
>>>>> yet-another-exception-for-IS_SWAPFILE?
>>>>
>>>> I meant to cc Mel. Just added him.
>>>>
>>>
>>> Can the full lockdep warning be included as it'll be easier to see th=
en if
>>> the generic swap code can somehow special case this? Currently, gener=
ic
>>> swapping does not not need to care about how the filesystem locked.
>>> For most filesystems, it's writing directly to the blocks on disk and=

>>> bypassing the FS. In the NFS case it'd be surprising to find that the=
re
>>> also are dirty pages in page cache that belong to the swap file as it=
's
>>> going to cause corruption. If there is any special casing it would to=
 only
>>> attempt the invalidation in the !swap case and warn if mapping->nrpag=
es. It
>>> still would look a bit weird but safer than just not acquiring the mu=
tex
>>> and then potentially attempting an invalidation.
>>>
>>
>> [ 6819.501009] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> [ 6819.501009] [ INFO: inconsistent lock state ]
>> [ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not tain=
ted
>> [ 6819.501009] ---------------------------------
>=20
> Thanks. Sorry for the long delay but I finally got back to the bug this=

> week. NFS can be modified to special case the swapfile but I was not ha=
ppy
> with the result for multiple reasons. It took me a while to see a way f=
or
> the core VM to deal with it. What do you think of the following
> approach?

Seems sound to me.

> More importantly, does it work for you?

Yes.

>=20
> ---8<---
> nfs: Use swap_lock to prevent parallel swapon activations
>=20
> Jerome Marchand reported a lockdep warning as follows
>=20
>     [ 6819.501009] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>     [ 6819.501009] [ INFO: inconsistent lock state ]
>     [ 6819.501009] 4.2.0-rc1-shmacct-babka-v2-next-20150709+ #255 Not t=
ainted
>     [ 6819.501009] ---------------------------------
>     [ 6819.501009] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} =
usage.
>     [ 6819.501009] kswapd0/38 [HC0[0]:SC0[0]:HE1:SE1] takes:
>     [ 6819.501009]  (&sb->s_type->i_mutex_key#17){+.+.?.}, at: [<ffffff=
ffa03772a5>] nfs_file_direct_write+0x85/0x3f0 [nfs]
>     [ 6819.501009] {RECLAIM_FS-ON-W} state was registered at:
>     [ 6819.501009]   [<ffffffff81107f51>] mark_held_locks+0x71/0x90
>     [ 6819.501009]   [<ffffffff8110b775>] lockdep_trace_alloc+0x75/0xe0=

>     [ 6819.501009]   [<ffffffff81245529>] kmem_cache_alloc_node_trace+0=
x39/0x440
>     [ 6819.501009]   [<ffffffff81225b8f>] __get_vm_area_node+0x7f/0x160=

>     [ 6819.501009]   [<ffffffff81226eb2>] __vmalloc_node_range+0x72/0x2=
c0
>     [ 6819.501009]   [<ffffffff81227424>] vzalloc+0x54/0x60
>     [ 6819.501009]   [<ffffffff8122c7c8>] SyS_swapon+0x628/0xfc0
>     [ 6819.501009]   [<ffffffff81867772>] entry_SYSCALL_64_fastpath+0x1=
2/0x76
>=20
> It's due to NFS acquiring i_mutex since a9ab5e840669 ("nfs: page
> cache invalidation for dio") to invalidate page cache before direct I/O=
=2E
> Filesystems may safely acquire i_mutex during direct writes but NFS is =
unique
> in its treatment of swap files. Ordinarily swap files are supported by =
the
> core VM looking up the physical block for a given offset in advance. Th=
ere
> is no physical block for NFS and the direct write paths are used after
> calling mapping->swap_activate.
>=20
> The lockdep warning is triggered by swapon(), which is not in reclaim
> context, acquiring the i_mutex to ensure a swapfile is not activated tw=
ice.
>=20
> swapon does not need the i_mutex for this purpose.  There is a requirem=
ent
> that fallocate not be used on swapfiles but this is protected by the in=
ode
> flag S_SWAPFILE and nothing to do with i_mutex. In fact, the current
> protection does nothing for block devices. This patch expands the role
> of swap_lock to protect against parallel activations of block devices a=
nd
> swapfiles and removes the use of i_mutex. This both improves the protec=
tion
> for swapon and avoids the lockdep warning.
>=20
> Reported-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Tested-by: Jerome Marchand <jmarchan@redhat.com>

Thanks,
Jerome

> ---
>  mm/swapfile.c | 16 +++++++---------
>  1 file changed, 7 insertions(+), 9 deletions(-)
>=20
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 41e4581af7c5..d58ed6833fa3 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1928,9 +1928,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, spe=
cialfile)
>  		set_blocksize(bdev, old_block_size);
>  		blkdev_put(bdev, FMODE_READ | FMODE_WRITE | FMODE_EXCL);
>  	} else {
> -		mutex_lock(&inode->i_mutex);
> +		spin_lock(&swap_lock);
>  		inode->i_flags &=3D ~S_SWAPFILE;
> -		mutex_unlock(&inode->i_mutex);
> +		spin_unlock(&swap_lock);
>  	}
>  	filp_close(swap_file, NULL);
> =20
> @@ -2156,7 +2156,6 @@ static int claim_swapfile(struct swap_info_struct=
 *p, struct inode *inode)
>  		p->flags |=3D SWP_BLKDEV;
>  	} else if (S_ISREG(inode->i_mode)) {
>  		p->bdev =3D inode->i_sb->s_bdev;
> -		mutex_lock(&inode->i_mutex);
>  		if (IS_SWAPFILE(inode))
>  			return -EBUSY;
>  	} else
> @@ -2386,6 +2385,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, spec=
ialfile, int, swap_flags)
>  		goto bad_swap;
>  	}
> =20
> +	/* prevent parallel swapons */
> +	spin_lock(&swap_lock);
>  	p->swap_file =3D swap_file;
>  	mapping =3D swap_file->f_mapping;
> =20
> @@ -2396,13 +2397,14 @@ SYSCALL_DEFINE2(swapon, const char __user *, sp=
ecialfile, int, swap_flags)
>  			continue;
>  		if (mapping =3D=3D q->swap_file->f_mapping) {
>  			error =3D -EBUSY;
> +			spin_unlock(&swap_lock);
>  			goto bad_swap;
>  		}
>  	}
> =20
>  	inode =3D mapping->host;
> -	/* If S_ISREG(inode->i_mode) will do mutex_lock(&inode->i_mutex); */
>  	error =3D claim_swapfile(p, inode);
> +	spin_unlock(&swap_lock);
>  	if (unlikely(error))
>  		goto bad_swap;
> =20
> @@ -2543,10 +2545,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, spe=
cialfile, int, swap_flags)
>  	vfree(swap_map);
>  	vfree(cluster_info);
>  	if (swap_file) {
> -		if (inode && S_ISREG(inode->i_mode)) {
> -			mutex_unlock(&inode->i_mutex);
> +		if (inode && S_ISREG(inode->i_mode))
>  			inode =3D NULL;
> -		}
>  		filp_close(swap_file, NULL);
>  	}
>  out:
> @@ -2556,8 +2556,6 @@ SYSCALL_DEFINE2(swapon, const char __user *, spec=
ialfile, int, swap_flags)
>  	}
>  	if (name)
>  		putname(name);
> -	if (inode && S_ISREG(inode->i_mode))
> -		mutex_unlock(&inode->i_mutex);
>  	return error;
>  }
> =20
>=20



--8TG3LH2fFv3OAsUxLSlllKGb7sTJVdCk6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJV5dC9AAoJEHTzHJCtsuoCySMIAITSmo/GNVuknODzBBMeR1ji
8D4e0tVPBFRwSCYrUT884YfSb02XzyxwupZbwXW7aioJvhCOrknIObLVY79u/B4p
FwLkl7qbxx/KgPVnwK/jVPnA7LqnFBsf2xZYLGxuYM38M5Jw+KWAc4cQC8tJw1u2
HI6PF16bRdyois751Au0iE0w/pYd4rhuLitbEvnab+bhoOavw01nc62nolgjsZWy
DHzn0du57G7vmqQG3/c0dTJ3dTDZnIk75BDYjVfvgJ5sn4/Ogskplmg4TiyKhRx3
4UARgpxFKuBfoPeivMkMmy5r+rdCY6VwHotnc7yBxk1W2eCckCr9uF8PURw8n/A=
=hyNx
-----END PGP SIGNATURE-----

--8TG3LH2fFv3OAsUxLSlllKGb7sTJVdCk6--

Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([103.29.64.221]:39202 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363AbcD3VSZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Apr 2016 17:18:25 -0400
From: NeilBrown <mr@neil.brown.name>
To: Steven Whitehouse <swhiteho@redhat.com>, Michal Hocko <mhocko@kernel.org>,
        linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Date: Sun, 01 May 2016 07:17:56 +1000
Cc: linux-nfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        "Theodore Ts'o" <tytso@mit.edu>, linux-ntfs-dev@lists.sourceforge.net,
        LKML <linux-kernel@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>, reiserfs-devel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, logfs@logfs.org,
        cluster-devel@redhat.com, Chris Mason <clm@fb.com>,
        linux-mtd@lists.infradead.org, Jan Kara <jack@suse.cz>,
        Andrew Morton <akpm@linux-foundation.org>, xfs@oss.sgi.com,
        ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-afs@lists.infradead.org,
        cluster-devel <cluster-devel@redhat.com>
Subject: Re: [Cluster-devel] [PATCH 0/2] scop GFP_NOFS api
In-Reply-To: <57233571.50509@redhat.com>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org> <8737q5ugcx.fsf@notabene.neil.brown.name> <57233571.50509@redhat.com>
Message-ID: <87wpneu77f.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 29 2016, Steven Whitehouse wrote:

> Hi,
>
> On 29/04/16 06:35, NeilBrown wrote:
>> If we could similarly move evict() into kswapd (and I believe we can)
>> then most file systems would do nothing in reclaim context that
>> interferes with allocation context.
> evict() is an issue, but moving it into kswapd would be a potential=20
> problem for GFS2. We already have a memory allocation issue when=20
> recovery is taking place and memory is short. The code path is as follows:
>
>   1. Inode is scheduled for eviction (which requires deallocation)
>   2. The glock is required in order to perform the deallocation, which=20
> implies getting a DLM lock
>   3. Another node in the cluster fails, so needs recovery
>   4. When the DLM lock is requested, it gets blocked until recovery is=20
> complete (for the failed node)
>   5. Recovery is performed using a userland fencing utility
>   6. Fencing requires memory and then blocks on the eviction
>   7. Deadlock (Fencing waiting on memory alloc, memory alloc waiting on=20
> DLM lock, DLM lock waiting on fencing)

You even have user-space in the loop there - impressive!  You can't
really pass GFP_NOFS to a user-space thread, can you :-?

>
> It doesn't happen often, but we've been looking at the best place to=20
> break that cycle, and one of the things we've been wondering is whether=20
> we could avoid deallocation evictions from memory related contexts, or=20
> at least make it async somehow.

I think "async" is definitely the answer and I think
evict()/evict_inode() is the best place to focus attention.

I can see now (thanks) that just moving the evict() call to kswapd isn't
really a solution as it will just serve to block kswapd and so lots of
other freeing of memory won't happen.

I'm now imagining giving ->evict_inode() a "don't sleep" flag and
allowing it to return -EAGAIN.  In that case evict would queue the inode
to kswapd (or maybe another thread) for periodic retry.

The flag would only get set when prune_icache_sb() calls dispose_list()
to call evict().  Other uses (e.g. unmount, iput) would still be
synchronous.

How difficult would it be to change gfs's evict_inode() to optionally
never block?

For this to work we would need to add a way for
deactivate_locked_super() to wait for all the async evictions to
complete.  Currently prune_icache_sb() is called under s_umount.  If we
moved part of the eviction out of that lock some other synchronization
would be needed.  Possibly a per-superblock list of "inodes being
evicted" would suffice.

Thanks,
NeilBrown


>
> The issue is that it is not possible to know in advance whether an=20
> eviction will result in mearly writing things back to disk (because the=20
> inode is being dropped from cache, but still resides on disk) which is=20
> easy to do, or whether it requires a full deallocation (n_link=3D=3D0) wh=
ich=20
> may require significant resources and time,
>
> Steve.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXJSEEAAoJEDnsnt1WYoG5r68P/2XBKjAdTUcRbcSSLoUKYpEo
nFQiiu9BM8FRmffmYHNQrRVQQsEA8H5WKekt0heSAUyqbs75dPybzH8Bm447azdm
rb6ZUSSKV0LiDFWxe/mXjDFi9qgplAVAKIMQVoTUADgi6YXfpqYwjkTfXiBPcJF2
NXecVP/OBA0aGT7sUBJOYq1hKCA8e4oIAvEUdjv5c/405U4FoiTmTICwCkhCPTHR
y5tACMN3RtAbzmxsQ0LHIkz8XMKiwtvUkG/Ku054lSQknknjfgESQSsBtEqiTXb+
I9vdZUbg0kjz6KAOJ/QogDjI47ORtoHptnB07NMl2OX9LWq93SPg0F81HfE5eIBc
Y4NvPLg/EyBjW6KpcmYiAlfkRDEvt3/FeyaKCtEKzuu4cpCbGXqxRXqAl/tXzJLx
VlFJqcvn9YNzyqvs4K+ZbHc6KKq+ppHRpWaXemIiwE69hkGiXH12Rb6cMN3XzOuU
Tm7ORKC3HuPdoHLR0Ls/N+C16C2cQhkFlG3MGFyECtG2qKzotOJP/dvN0HNI+LSc
fRW3/BQlCEmtwNJ2cpt6v6zUHmcEoPtxECUhIJllOzlnUqZ941i/tzTPNyY60WDA
OBRNlLoo9qG9IDUVGjGoDA1WS+eLDmptOGi7T7gPHkvwKLJg6CH8Ivdped54sqMP
K3N9YqjgZ+d4FzruChG6
=tfvX
-----END PGP SIGNATURE-----
--=-=-=--

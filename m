Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39262 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751797AbcKREff (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Nov 2016 23:35:35 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 18 Nov 2016 15:35:27 +1100
Cc: Olaf Kirch <OKir@suse.com>, NFS List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: flush data when locking a file to ensure cache coherence for mmap.
In-Reply-To: <877fce8z0o.fsf@notabene.neil.brown.name>
References: <871t4fosvh.fsf@notabene.neil.brown.name> <877fce8z0o.fsf@notabene.neil.brown.name>
Message-ID: <87eg29flrk.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


PING again

Thanks,
NeilBrown

On Fri, Jul 22 2016, NeilBrown wrote:

> PING .... any comments on this patch, or the problem it tries to
> address?
>
> Thanks,
> NeilBrown
>
>
> On Fri, Jun 03 2016, NeilBrown wrote:
>
>> When a byte range lock (or flock) is taken out on an NFS file, the
>> validity of the cached data is checked and the inode is marked
>> NFS_INODE_INVALID_DATA.  However the cached data isn't flushed from
>> the page cache.
>>
>> This is sufficient for future read() requests or mmap() requests as
>> they call nfs_revalidate_mapping() which performs the flush if
>> necessary.
>>
>> However an existing mapping is not affected.  Accessing data through
>> that mapping will continue to return old data even though the inode is
>> marked NFS_INODE_INVALID_DATA.
>>
>> This can easily be confirmed using the 'nfs' tool in
>>   git://github.com/okirch/twopence-nfs.git
>> and running
>>
>>    nfs coherence FILENAME
>> on one client, and
>>    nfs coherence -r FILENAME
>> on another client.
>>
>> It appears that prior to Linux 2.6.0 this worked correctly.
>>
>> However commit:
>>
>> http://git.kernel.org/cgit/linux/kernel/git/history/history.git/commit/?=
id=3Dca9268fe3ddd075714005adecd4afbd7f9ab87d0
>>
>> removed the call to inode_invalidate_pages() from nfs_zap_caches().  I
>> haven't tested this code, but inspection suggests that prior to this
>> commit, file locking would invalidate all inode pages.
>>
>> This patch adds a call to nfs_revalidate_mapping_protected() after a
>> successful SETLK so that invalid data is flushed.  With this patch the
>> above test passes.
>>
>> Cc: Olaf Kirch <okir@suse.com>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>  fs/nfs/file.c | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 717a8d6af52d..781cc6c9c60b 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -822,6 +822,7 @@ do_setlk(struct file *filp, int cmd, struct file_loc=
k *fl, int is_local)
>>  			__nfs_revalidate_inode(NFS_SERVER(inode), inode);
>>  		else
>>  			nfs_zap_caches(inode);
>> +		nfs_revalidate_mapping_protected(inode, filp->f_mapping);
>>  	}
>>  out:
>>  	return status;
>> --=20
>> 2.8.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYLoUPAAoJEDnsnt1WYoG5ZIsQAI+14wJvtOQKQM92vC/hvOb4
Ruhq4lGi9/34KHYCKqFSRRjLdjJbcl2zn122tfdKPbkwoWVFvjYAFbwirFJRq+Pd
RayDBO1cp/cvWZMxuXhJr2E+GY+tofJdno0l97aseqwUM0s/WCmfW0s3M54qkgic
nEFB11ERUpgWHRgLmoPxVxLPlYTH0ZK+w6Y9KAzmCK/sBlKug8YtNjzE57kAj4sD
EFENO4S43cC1ek1i8zKRPgKYan2fSiRcy05V7B/TysR387JveLAJVEXa1/G7Y2RU
Bm9yVNKoaKfoVZheWv7GlynlyiWfzR3/83776uK1NH7dIFzH42/0xEJBV/HrmRjk
6G2AcIGkQDnrtP9Dya7XghQIJNq2vW2x3BBqCBys92QqtR6yYrAKqOIj+Pcmz4p4
sr/KqZdgSghhBPKHa2gu8U5OgpBzEJfbAjgkWAG4ctTQaZaBoIMz2JAp6hmT38mX
Bnou8WDAfnu8G+2oiw4f428mN2FuEKnEXFoW/iA64EyQykx03OIhHlw68BGZTwZ3
Vpze23g1+MEIjwGwaYjNTM4HGtDcpwJhFh2EDZCqLsuWZ9h7xnQZNFErcrC/c1Fj
VdKfHaqJ3d6e3n1hn88V0hQXT2DA1wSJ48MvwrUjAC6AAzc5BguAQmrnnnxxHR4J
r8M/ckYmb7q/kJI6X8sD
=XffX
-----END PGP SIGNATURE-----
--=-=-=--

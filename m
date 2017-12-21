Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48099 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752863AbdLUU76 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Dec 2017 15:59:58 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "chuck.lever\@oracle.com" <chuck.lever@oracle.com>
Date: Fri, 22 Dec 2017 07:59:49 +1100
Cc: "Anna.Schumaker\@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
In-Reply-To: <1513871689.11836.3.camel@primarydata.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name> <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com> <1513871689.11836.3.camel@primarydata.com>
Message-ID: <87efnnkda2.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 21 2017, Trond Myklebust wrote:

> On Thu, 2017-12-21 at 10:39 -0500, Chuck Lever wrote:
>> Hi Neil-
>>=20
>>=20
>> > On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com> wrote:
>> >=20
>> >=20
>> > When an i_op->getattr() call is made on an NFS file
>> > (typically from a 'stat' family system call), NFS
>> > will first flush any dirty data to the server.
>> >=20
>> > This ensures that the mtime reported is correct and stable,
>> > but has a performance penalty.  'stat' is normally thought
>> > to be a quick operation, and imposing this cost can be
>> > surprising.
>>=20
>> To be clear, this behavior is a POSIX requirement.
>>=20
>>=20
>> > I have seen problems when one process is writing a large
>> > file and another process performs "ls -l" on the containing
>> > directory and is blocked for as long as it take to flush
>> > all the dirty data to the server, which can be minutes.
>>=20
>> Yes, a well-known annoyance that cannot be addressed
>> even with a write delegation.
>>=20
>>=20
>> > I have also seen a legacy application which frequently calls
>> > "fstat" on a file that it is writing to.  On a local
>> > filesystem (and in the Solaris implementation of NFS) this
>> > fstat call is cheap.  On Linux/NFS, the causes a noticeable
>> > decrease in throughput.
>>=20
>> If the preceding write is small, Linux could be using
>> a FILE_SYNC write, but Solaris could be using UNSTABLE.
>>=20
>>=20
>> > The only circumstances where an application calling 'stat()'
>> > might get an mtime which is not stable are times when some
>> > other process is writing to the file and the two processes
>> > are not using locking to ensure consistency, or when the one
>> > process is both writing and stating.  In neither of these
>> > cases is it reasonable to expect the mtime to be stable.
>>=20
>> I'm not convinced this is a strong enough rationale
>> for claiming it is safe to disable the existing
>> behavior.
>>=20
>> You've explained cases where the new behavior is
>> reasonable, but do you have any examples where the
>> new behavior would be a problem? There must be a
>> reason why POSIX explicitly requires an up-to-date
>> mtime.
>>=20
>> What guidance would nfs(5) give on when it is safe
>> to specify the new mount option?
>>=20
>>=20
>> > In the most common cases where mtime is important
>> > (e.g. make), no other process has the file open, so there
>> > will be no dirty data and the mtime will be stable.
>>=20
>> Isn't it also the case that make is a multi-process
>> workload where one process modifies a file, then
>> closes it (which triggers a flush), and then another
>> process stats the file? The new mount option does
>> not change the behavior of close(2), does it?
>>=20
>>=20
>> > Rather than unilaterally changing this behavior of 'stat',
>> > this patch adds a "nosyncflush" mount option to allow
>> > sysadmins to have applications which are hurt by the current
>> > behavior to disable it.
>>=20
>> IMO a mount option is at the wrong granularity. A
>> mount point will be shared between applications that
>> can tolerate the non-POSIX behavior and those that
>> cannot, for instance.
>
> Agreed.=20
>
> The other thing to note here is that we now have an embryonic statx()
> system call, which allows the application itself to decide whether or
> not it needs up to date values for the atime/ctime/mtime. While we
> haven't yet plumbed in the NFS side, the intention was always to use
> that information to turn off the writeback flushing when possible.

Yes, if statx() were actually working, we could change the application
to avoid the flush.  But then if changing the application were an
option, I suspect that - for my current customer issue - we could just
remove the fstat() calls.  I doubt they are really necessary.
I think programmers often think of stat() (and particularly fstat()) as
fairly cheap and so they use it whenever convenient.  Only NFS violates
this expectation.

Also statx() is only a real solution if/when it gets widely used.  Will
"ls -l" default to AT_STATX_DONT_SYNC ??

Apart from the Posix requirement (which only requires that the
timestamps be updated, not that the data be flushed), do you know of any
value gained from flushing data before stat()?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo8IMUACgkQOeye3VZi
gbktMQ//RnzvY+r9djijQ3lzp7pO9KMbM6fOCE4VjfgkGMoj58zV93vJ46K4WOF4
2LJIdglZlNynJCauyzcJ2RtYd40WLZBxx09CBCmh/9n9D5Ttv3TUvIWQqQpbibKC
Kku0hGhpTmX1EJ/0mrOwT6FPhWru0/diPTzR/qdtcpRkVX0mIaUVLYZqmqd0rqzD
loE7YPVj0WLBUWJzeaLWfjrG+k/7qVd2KzFfLlqORseapWBUzHKPUweS6LhYxEqg
VVe790aKGSGTXvjlWzMtHp4db8P16Y6azPh7A4IABYdbiI0MXFoVGPT94byTl2LV
HNM8LMv6YU7VtDk4DyW4HQA88vYuW4wjcUJslUv3UFxDcqXyYYaDZkUpTKuLBoW0
iNwEj+ZHx1gDkNMxadXO4WG9FStCRGg+J6/RfVNpgzRsFN1Eic5Fz7UHtRU4/03p
9kRnvix837XodecuUfhlrZO+LuREae7/mecoV6li9HTski3DG6D2JCRJxThkLRdh
RBn9sadMnm++idNZN8m8iIDESCNPOcrNAgl8VrFTwnFB767c5+K4IEmiFO7NZIHu
rzHW8Kt/nIzNcVmBaADF4yIsYc4FurkiBlw34F7xjup2TMJeKaCpDOLctWOrso03
/+jIePA7urgY7l1hPl2MMtSkvocAYeWHOkhws1i4Jsqi3UmFatE=
=6AxK
-----END PGP SIGNATURE-----
--=-=-=--

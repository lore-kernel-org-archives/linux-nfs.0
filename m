Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46646 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751202AbdHMXaG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 13 Aug 2017 19:30:06 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "jlayton\@redhat.com" <jlayton@redhat.com>
Date: Mon, 14 Aug 2017 09:29:55 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <1502430944.3822.1.camel@primarydata.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com>
Message-ID: <87378voxl8.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 11 2017, Trond Myklebust wrote:

> On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>> Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblock
>> flag and introduced the d_weak_revalidate dentry operation instead.
>> We duly removed the flag from NFS superblocks and NFSv4 superblocks,
>> and added the new dentry operation to NFS dentries .... but not to
>> NFSv4
>> dentries.
>>=20
>> And nobody noticed.
>>=20
>> Until today.
>>=20
>> A customer reports a situation where mount(....,MS_REMOUNT,..) on an
>> NFS
>> filesystem hangs because the network has been deconfigured.  This
>> makes
>> perfect sense and I suggested a code change to fix the problem.
>> However when a colleague was trying to reproduce the problem to
>> validate
>> the fix, he couldn't.  Then nor could I.
>>=20
>> The problem is trivially reproducible with NFSv3, and not at all with
>> NFSv4.  The reason is the missing d_weak_revalidate.
>>=20
>> We could simply add d_weak_revalidate for NFSv4, but given that it
>> has been missing for 4.5 years, and the only time anyone noticed was
>> when the ommission resulted in a better user experience, I do wonder
>> if
>> we need to.  Can we just discard d_weak_revalidate?  What purpose
>> does
>> it serve?  I couldn't find one.
>>=20
>> Thanks,
>> NeilBrown
>>=20
>> For reference, see
>> Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>> d_weak_revalidate dentry op")
>>=20
>>=20
>>=20
>> To reproduce the problem at home, on a system that uses systemd:
>> 1/ place (or find) a filesystem image in a file on an NFS filesystem.
>> 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>> 3/ loop-mount the filesystem image read-only somewhere
>> 4/ reboot
>>=20
>> If you choose v4, the reboot will succeed, possibly after a 90second
>> timeout.
>> If you choose v3, the reboot will hang indefinitely in systemd-
>> shutdown while
>> remounting the nfs filesystem read-only.
>>=20
>> If you don't use "noac" it can still hang, but only if something
>> slows
>> down the reboot enough that attributes have timed out by the time
>> that
>> systemd-shutdown runs.  This happens for our customer.
>>=20
>> If the loop-mounted filesystem is not read-only, you get other
>> problems.
>>=20
>> We really want systemd to figure out that the loop-mount needs to be
>> unmounted first.  I have ideas concerning that, but it is messy.  But
>> that isn't the only bug here.
>
> The main purpose of d_weak_revalidate() was to catch the issues that
> arise when someone changes the contents of the current working
> directory or its parent on the server. Since '.' and '..' are treated
> specially in the lookup code, they would not be revalidated without
> special treatment. That leads to issues when looking up files as
> ./<filename> or ../<filename>, since the client won't detect that its
> dcache is stale until it tries to use the cached dentry+inode.

I don't think that is quite right.
d_weak_revalidate() is only called from complete_walk() if LOOKUP_JUMPED
is set.  The happens when the final component of a path:
 - is a mount point
 - is ".."
or if the whole path is "/".  I thought "." was treated specially too,
but I cannot find that in the code.

After a path walk completes, the operation that acts on the path will
revalidate the inode one way or another so having an extra early
validation seems hard to justify.

If the inode has been removed, ESTALE is returned.  The slightly earlier
return of ESTALE might change some behavior.... All I can think of is
that if the directory under a mountpoint gets deleted, the mountpoint is
automatically removed.., but that happens in d_invalidate() which isn't
called when d_weak_revalidate() is called.

>
> The one thing that has changed since its introduction is, I believe,
> the ESTALE handling in the VFS layer. That might fix a lot of the
> dcache lookup bugs that were previously handled by d_weak_revalidate().
> I haven't done an audit to figure out if it actually can handle all of
> them.

I agree that seems like it might be relevant, but I don't see how it
would relate to any of the three cases that d_weak_revalidate affects.
Maybe there is some other change that we don't remember.

Thanks,
NeilBrown


>
> --=20
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmQ4PUACgkQOeye3VZi
gbkZoRAAlOxV1NR3IpXM9wTa0DhPpck85qjxb12k84UelScf3pYEea+Qt8S/vBPS
0B6exa6IdXGOD6hfehzEDLHJfAVZKKO/BKDhz3OwqPaIRvnGeWlUILHufPAaw38R
I6a6Hnhw1v1rw+Ji+WYaj+X5hUnJUDyieoDuaEYA/LDiL9aGGc2We9ZRtkt9wIKO
PpBTr5hXEtndo56os6Q6lo2Fy99p1b3MSucZes8mAF4z/PbBypC36UBo4+4BZJzh
7JjP0dhluTSnBxQtf1TqqqjnGhITZiZoBVEkUT4mOmMPGXwGlyAKKGcgq6MxFx6N
ecUBBV3Q60buC3qPXBbFN4nRH++CxyzWiUGsWZe4EIxtqT/4V5yXUtSadBsNJINA
RdMYc0WXJHAYNdScMHPuwHOx/PfBGRlOlQL4gQDdOhGNuL4eIkmc9XXy5FntqEfw
O5Xt9Zv8OLmlm+MHdZwzWZpXmlj7HA3ZRog2wmPzMx6Zziu/ecFjK9j/KVrAYJjy
qRQQGDUQ6t2tOj8TI5N0bVB+pERaYTE84FhncVKHQsqtFU3ptS1iE5gkHAu0PP8U
3vluoK9tAEG5w5eLjP3F2MhGs+M9UpHJDQVt+k0Onmla3lFvDd1C94nYoCEn4bV0
5Psihy4le2qQCCiSniX8O05RmL9gKZF6SktmMIr+i4FwnJA8Iro=
=ttbc
-----END PGP SIGNATURE-----
--=-=-=--

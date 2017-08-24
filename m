Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41289 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751124AbdHXGey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 24 Aug 2017 02:34:54 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "jlayton\@redhat.com" <jlayton@redhat.com>
Date: Thu, 24 Aug 2017 16:34:43 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <87378voxl8.fsf@notabene.neil.brown.name>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <87378voxl8.fsf@notabene.neil.brown.name>
Message-ID: <87fuchjwxo.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 14 2017, NeilBrown wrote:

> On Fri, Aug 11 2017, Trond Myklebust wrote:
>
>> On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>>> Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblock
>>> flag and introduced the d_weak_revalidate dentry operation instead.
>>> We duly removed the flag from NFS superblocks and NFSv4 superblocks,
>>> and added the new dentry operation to NFS dentries .... but not to
>>> NFSv4
>>> dentries.
>>>=20
>>> And nobody noticed.
>>>=20
>>> Until today.
>>>=20
>>> A customer reports a situation where mount(....,MS_REMOUNT,..) on an
>>> NFS
>>> filesystem hangs because the network has been deconfigured.  This
>>> makes
>>> perfect sense and I suggested a code change to fix the problem.
>>> However when a colleague was trying to reproduce the problem to
>>> validate
>>> the fix, he couldn't.  Then nor could I.
>>>=20
>>> The problem is trivially reproducible with NFSv3, and not at all with
>>> NFSv4.  The reason is the missing d_weak_revalidate.
>>>=20
>>> We could simply add d_weak_revalidate for NFSv4, but given that it
>>> has been missing for 4.5 years, and the only time anyone noticed was
>>> when the ommission resulted in a better user experience, I do wonder
>>> if
>>> we need to.  Can we just discard d_weak_revalidate?  What purpose
>>> does
>>> it serve?  I couldn't find one.
>>>=20
>>> Thanks,
>>> NeilBrown
>>>=20
>>> For reference, see
>>> Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>>> d_weak_revalidate dentry op")
>>>=20
>>>=20
>>>=20
>>> To reproduce the problem at home, on a system that uses systemd:
>>> 1/ place (or find) a filesystem image in a file on an NFS filesystem.
>>> 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>>> 3/ loop-mount the filesystem image read-only somewhere
>>> 4/ reboot
>>>=20
>>> If you choose v4, the reboot will succeed, possibly after a 90second
>>> timeout.
>>> If you choose v3, the reboot will hang indefinitely in systemd-
>>> shutdown while
>>> remounting the nfs filesystem read-only.
>>>=20
>>> If you don't use "noac" it can still hang, but only if something
>>> slows
>>> down the reboot enough that attributes have timed out by the time
>>> that
>>> systemd-shutdown runs.  This happens for our customer.
>>>=20
>>> If the loop-mounted filesystem is not read-only, you get other
>>> problems.
>>>=20
>>> We really want systemd to figure out that the loop-mount needs to be
>>> unmounted first.  I have ideas concerning that, but it is messy.  But
>>> that isn't the only bug here.
>>
>> The main purpose of d_weak_revalidate() was to catch the issues that
>> arise when someone changes the contents of the current working
>> directory or its parent on the server. Since '.' and '..' are treated
>> specially in the lookup code, they would not be revalidated without
>> special treatment. That leads to issues when looking up files as
>> ./<filename> or ../<filename>, since the client won't detect that its
>> dcache is stale until it tries to use the cached dentry+inode.
>
> I don't think that is quite right.
> d_weak_revalidate() is only called from complete_walk() if LOOKUP_JUMPED
> is set.  The happens when the final component of a path:
>  - is a mount point
>  - is ".."
> or if the whole path is "/".  I thought "." was treated specially too,
> but I cannot find that in the code.

Actually, you were very close to the right answer, and I was missing
something important.

The issue (or, at least "an" issue) happens when you open "." or ".." or
a mount point, or a /proc/*/fd/* symlink.

In each case LOOKUP_JUMPED is set.  "." doesn't set it, but it doesn't
clear it either and it is always set at the start of a path lookup.

When you open a file (or directory) on NFS you need to validate the
attributes to ensure close-to-open consistency rules are met.
When you open any path that ends with a LAST_NORM name, d_revalidate will
be passed the LOOKUP_OPEN flag and so nfs_lookup_verify_inode() will
force a revalidate with __nfs_revalidate_inode().

When you open something that ends with LOOKUP_JUMPED, the task of
forcing the revalidate falls to d_weak_revalidate().  Unfortunately it
doesn't actually do that.  With NFSv4, there is no d_weak_revalidate().
With NFSv3 there is - but it doesn't know if LOOKUP_JUMPED is set, and
doesn't force the revalidate.

This means that if you
   echo *
or
   echo ../*

there might be no communication with the server, and you might get stale
data.

These command *do* work as expected only when the directory being listed
is a mountpoint.  This is because nfs_opendir() contains:

	if (filp->f_path.dentry =3D=3D filp->f_path.mnt->mnt_root) {
		/* This is a mountpoint, so d_revalidate will never
		 * have been called, so we need to refresh the
		 * inode (for close-open consistency) ourselves.
		 */
		__nfs_revalidate_inode(NFS_SERVER(inode), inode);
	}

which I put there some years ago, when things worked differently.

There are various ways we could fix this.
The simplest would be to change complete_walk() to only call
d_weak_revalidate if (nd->flags & LOOKUP_OPEN), and change
d_weak_revalidate to call __nfs_revalidate_inode() unconditionally.  And
to get NFSv4 to call this too.

However I would like to take a different approach.  I'd like to change
nfs_lookup_revalidate to check LOOKUP_JUMPED itself, and to consider
only the inode when the flag is set.
When we can discard d_weak_revalidate() and call d_revalidate (with
LOOKUP_JUMPED set) in complete_walk().  Maybe this is too intrusive on
other filesystems that don't differentiate revalidate on open ... nfs is
the only filesystem which tests LOOKUP_OPEN in d_revalidate.

Or maybe the LAST_JUMPED flag could be passed to ->open (atomic_open
doesn't need it) - but that could get messy.  It would have to go
through vfs_open

Either approach will mean that umount can go back to using
user_path_at(), as the final dentry will only be revalidated on open,
not on other accesses.

The LOOKUP_JUMPED flag and d_weak_revalidate() trace their history back
to FS_REVAL_DOT, and the issue has always been about handling open()
correctly when the path doesn't ends LAST_NORM.

NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmec4UACgkQOeye3VZi
gbnFkBAAhQeoE88kTApoNUVja3HBPVAopJJielqEoRwtSgOAMP3/S36Gso6rQi8q
G1doXm2iiT/iO/kGuOPIqAsa+zf7aLM/yLayZgbIl+wKsTa5M6BiOhALWCAL8Jox
A5rALKJvu8KD60MqWj4oCltOfd4udQlDxlcGVjWPA6AwPp2dM4HDi8rr5C6Wg9tY
sKftdbUIeQ0/qzJMv7zC4B+sSuxn+6mnmh9c6L+ehuj72nLkEpFyheed40YPU+O2
B/1DoqBqvJt0YHpUOUs5s1OwLULOh1U6tROA3vCkIpxyHPM5nkWKWIs6VfU3sb7F
jHvLgpmoy6fSqrEHr+sEUKEaGrBm8WrerG+ZC9SfXW/t8TAnPMSAP8xBH81ss8xK
kyctobNspaWLrmD/XUq3QoUNeg66FFAAXV9Fs8cgRhdzrIH1JKRWiK83dc9y3hl2
bERS546DHdYRcf6YpWeGyI+w0wM+0ZTfRBArDnnlfb6L/QbEaaSfl9XNyliSJvzC
hVrE5YXNPLwXEMb0p/4WwT6+60TeY+4Y9Fr6Q8vxXSPsysERuwy5YIcvyDY/mZT9
eX+7iPIECi9GafXNbwVt7/tUX6ZG3yiYySKT/hlHgEoYFHwtNb2U4XFUuR2473TH
n3sSWIMFlwBcLtrbzSKg9Be0QiHoiv+mbq/51u7s3B9j1U9ay6U=
=7R56
-----END PGP SIGNATURE-----
--=-=-=--

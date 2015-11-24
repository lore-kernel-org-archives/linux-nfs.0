Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36072 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753623AbbKXQ2d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 11:28:33 -0500
Received: by pacdm15 with SMTP id dm15so26787032pac.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2015 08:28:32 -0800 (PST)
Subject: Re: [RFC][PATCH 00/12] Enhanced file stat system call
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: multipart/signed; boundary="Apple-Mail=_B3073CE5-8B8D-451D-8FF9-185642D38F51"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <564F4F4E.8060603@schaufler-ca.com>
Date: Tue, 24 Nov 2015 09:28:26 -0700
Cc: David Howells <dhowells@redhat.com>, arnd@arndb.de,
        linux-afs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org
Message-Id: <05671A95-75FC-4A57-8477-8FFA0BC2FC08@dilger.ca>
References: <20151120145422.18930.72662.stgit@warthog.procyon.org.uk> <564F4F4E.8060603@schaufler-ca.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_B3073CE5-8B8D-451D-8FF9-185642D38F51
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Nov 20, 2015, at 9:50 AM, Casey Schaufler <casey@schaufler-ca.com> =
wrote:
> On 11/20/2015 6:54 AM, David Howells wrote:
>> Implement new system calls to provide enhanced file stats and =
enhanced
>> filesystem stats.  The patches can be found here:
>>=20
>> 	=
http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=3D=
xstat
>>=20
>>=20
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> DESCRIPTION
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>=20
>> The third patch provides this new system call:
>>=20
>> 	long ret =3D statx(int dfd,
>> 			 const char *filename,
>> 			 unsigned atflag,
>> 			 unsigned mask,
>> 			 struct statx *buffer);
>>=20
>> This is an enhanced file stat function that provides a number of =
useful
>> features, in summary:
>>=20
>>  (1) More information: creation time, data version number,
>>      flags/attributes.  A subset of these is available through a =
number of
>>      filesystems (such as CIFS, NFS, AFS, Ext4 and BTRFS).
>>=20
>>  (2) Lightweight stat (AT_NO_ATTR_SYNC): Ask for just those details =
of
>>      interest, and allow a network fs to approximate anything not of
>>      interest, without going to the server.
>>=20
>>  (3) Heavyweight stat (AT_FORCE_ATTR_SYNC): Force a network fs to =
flush
>>      buffers and go to the server, even if it thinks its cached =
attributes
>>      are up to date.
>>=20
>>  (4) Allow the filesystem to indicate what it can/cannot provide: A
>>      filesystem can now say it doesn't support a standard stat =
feature if
>>      that isn't available.
>>=20
>>  (5) Make the fields a consistent size on all arches, and make them =
large.
>>=20
>>  (6) Can be extended by using more request flags and using up the =
padding
>>      space in the statx struct.
>=20
> How about relevant xattrs? SELinux context, ACL, that sort of thing.
> The fact that these are optional should be taken care of by (4).

Given that there are a wide variety of xattrs that different apps might =
be
interested in, this would probably be better served by an enhancement to
getxattr() or listxattr() to be able to retrieve a whole list of xattrs
at once, possibly with some wildcard support (e.g. "security.*") instead
of returning all or a specific subset of xattrs with statx() (which is
geared toward fixed-size attributes).

Cheers, Andreas


>> Note that no lstat() equivalent is required as that can be =
implemented
>> through statx() with atflag =3D=3D 0.  There is also no fstat() =
equivalent as
>> that can be implemented through statx() with filename =3D=3D NULL and =
the
>> relevant fd passed as dfd.
>>=20
>>=20
>> The seventh patch provides another new system call:
>>=20
>> 	long ret =3D fsinfo(int dfd,
>> 			  const char *filename,
>> 			  unsigned atflag,
>> 			  unsigned request,
>> 			  void *buffer);
>>=20
>> This is an enhanced filesystem stat and information retrieval =
function that
>> provides more information, in summary:
>>=20
>>  (1) All the information provided by statfs() and more.  The fields =
are
>>      made large.
>>=20
>>  (2) Provides information about timestamp range and resolution to
>>      complement statx().
>>=20
>>  (3) Provides information about IOC flags supported in statx()'s =
return.
>>=20
>>  (4) Provides volume binary IDs and UUIDs.
>>=20
>>  (5) Provides the filesystem name according to the kernel as a string
>>      (eg. "ext4" or "nfs3") in addition to the magic number.
>>=20
>>  (6) Provides information obtained from network filesystems, such as =
volume
>>      and domain names.
>>=20
>>  (7) Has lots of spare space that can be used for future extenstions =
and a
>>      bit mask indicating what was provided.
>>=20
>> Note that I've added a 'request' identifier.  This is to select the =
set of
>> data to be returned.  The idea is that 'buffer' points to a =
fixed-size
>> struct selected by request.  Currently only 0 is available and this =
refers
>> to 'struct fsinfo'.  However, I could split up the buffer into say 3:
>>=20
>>  (0) statfs-type information
>>=20
>>  (1) Timestamp and IOC flags info.
>>=20
>>  (2) Network fs strings.
>>=20
>> However, some of this might be better retrieved through getxattr().
>>=20
>>=20
>> =3D=3D=3D=3D=3D=3D=3D
>> TESTING
>> =3D=3D=3D=3D=3D=3D=3D
>>=20
>> Test programs are added into samples/statx/ by the appropriate =
patches.
>>=20
>> David
>> ---
>> David Howells (12):
>>       Ext4: Fix extended timestamp encoding and decoding
>>       statx: Provide IOC flags for Windows fs attributes
>>       statx: Add a system call to make enhanced file info available
>>       statx: AFS: Return enhanced file attributes
>>       statx: Ext4: Return enhanced file attributes
>>       statx: NFS: Return enhanced file attributes
>>       statx: CIFS: Return enhanced attributes
>>       fsinfo: Add a system call to make enhanced filesystem info =
available
>>       fsinfo: Ext4: Return information through the filesystem info =
syscall
>>       fsinfo: AFS: Return information through the filesystem info =
syscall
>>       fsinfo: NFS: Return information through the filesystem info =
syscall
>>       fsinfo: CIFS: Return information through the filesystem info =
syscall
>>=20
>>=20
>>  arch/x86/entry/syscalls/syscall_32.tbl |    2
>>  arch/x86/entry/syscalls/syscall_64.tbl |    2
>>  fs/afs/inode.c                         |   23 ++
>>  fs/afs/super.c                         |   39 ++++
>>  fs/cifs/cifsfs.c                       |   25 +++
>>  fs/cifs/cifsfs.h                       |    4
>>  fs/cifs/cifsglob.h                     |    8 +
>>  fs/cifs/dir.c                          |    2
>>  fs/cifs/inode.c                        |  124 ++++++++++---
>>  fs/cifs/netmisc.c                      |    4
>>  fs/exportfs/expfs.c                    |    4
>>  fs/ext4/ext4.h                         |   24 ++-
>>  fs/ext4/file.c                         |    2
>>  fs/ext4/inode.c                        |   31 +++
>>  fs/ext4/namei.c                        |    2
>>  fs/ext4/super.c                        |   39 ++++
>>  fs/ext4/symlink.c                      |    2
>>  fs/nfs/inode.c                         |   45 ++++-
>>  fs/nfs/internal.h                      |    1
>>  fs/nfs/nfs4super.c                     |    1
>>  fs/nfs/super.c                         |   58 ++++++
>>  fs/ntfs/time.h                         |    2
>>  fs/stat.c                              |  305 =
+++++++++++++++++++++++++++++---
>>  fs/statfs.c                            |  218 =
+++++++++++++++++++++++
>>  include/linux/fs.h                     |    7 +
>>  include/linux/stat.h                   |   14 +
>>  include/linux/syscalls.h               |    6 +
>>  include/linux/time64.h                 |    2
>>  include/uapi/linux/fcntl.h             |    2
>>  include/uapi/linux/fs.h                |    7 +
>>  include/uapi/linux/stat.h              |  185 +++++++++++++++++++
>>  samples/Makefile                       |    3
>>  samples/statx/Makefile                 |   13 +
>>  samples/statx/test-fsinfo.c            |  179 +++++++++++++++++++
>>  samples/statx/test-statx.c             |  273 =
+++++++++++++++++++++++++++++
>>  35 files changed, 1558 insertions(+), 100 deletions(-)
>>  create mode 100644 samples/statx/Makefile
>>  create mode 100644 samples/statx/test-fsinfo.c
>>  create mode 100644 samples/statx/test-statx.c
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe =
linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_B3073CE5-8B8D-451D-8FF9-185642D38F51
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVlSQK3Kl2rkXzB/gAQgcyw//WEgt5hF3pkZrmJkTEwDoPdkVR2WuQnJr
Ht9gdG7VVEKK90TinDafuN0qvUYCnoGn4SGBE0kIGrpr1LuQ4LQv2reIwzyhEPuu
y4mxqfnU5a0Ej/K3RwDgNyYEdhdQxPhraBfchrDgKeRFtzwmYdFq2YMjxJ3Ri8Ct
LDp4RH9KOWkHK0SFxqAQ71xENdM4FyqJ54v/JOsYzk15flz5LbUpyMXOyC24no1u
k7Tc/ATH4yJBGPdHz/5xJL5xq+5j6/mOW+2vF7hTwg6pq4uECisK9Qdg0Eaac3OD
TKncgTmlJtDrKUvpKGCjilFMVkDOAD/RuIW4amVl8Q8EQogX72cHyKIXjEG3Mo2S
J1BE8UWrCwwo4NcBGq+sIs1frBrcExFsh0e+kGAwJXFNmo2MPjQeMcf+Qt8ULbLt
RvD2K4lqtdYW2BJQA+e2XiVbEdvQXauQ84Xh3Bn0xyJgxk5SP/t3gj0Rny+KUY0u
jqb50/oeQAXR8eCcP8TMQVbeCmpbJ6cN1kIDdn3hNo2uBMgioJqjh+n3UdRqseRL
tPrZM5OqZnJ1mSKB9kmN5fXqPnOghgcmeKa3GrXb5okKIjNrrRaLF1U51TyAog1l
E4k0SGFHCe1xFMneGV/Cp9KmLW1ZsJ2U9R+K578XqbBheJTA3fqvctfm0+JS344S
ZQGPldAA8Es=
=BBGZ
-----END PGP SIGNATURE-----

--Apple-Mail=_B3073CE5-8B8D-451D-8FF9-185642D38F51--

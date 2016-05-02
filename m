Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:36165 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932241AbcEBWqt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 18:46:49 -0400
Received: by mail-ig0-f194.google.com with SMTP id c3so506619igl.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2016 15:46:49 -0700 (PDT)
Subject: Re: [PATCH 1/6] statx: Add a system call to make enhanced file info available
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_B277523B-33CE-49E3-B328-0B8F68EED2FC"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
Date: Mon, 2 May 2016 16:46:42 -0600
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Message-Id: <E67F5D32-A06A-4C30-8DCB-EF20D86200D4@dilger.ca>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125743.23636.85219.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_B277523B-33CE-49E3-B328-0B8F68EED2FC
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 29, 2016, at 6:57 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Add a system call to make extended file information available, =
including
> file creation time, inode version and data version where available =
through
> the underlying filesystem.

Hi David,
thanks for resubmitting the patch series.  No requests to add features =
here,
just a couple of comments on the patches regarding the implementation...

> =3D=3D=3D=3D=3D=3D=3D=3D
> OVERVIEW
> =3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The idea was initially proposed as a set of xattrs that could be =
retrieved
> with getxattr(), but the general preferance proved to be for a new =
syscall
> with an extended stat structure.
>=20
> This has a number of uses:
>=20
> (1) Better support for the y2038 problem [Arnd Bergmann].
>=20
> (2) Creation time: The SMB protocol carries the creation time, which =
could
>     be exported by Samba, which will in turn help CIFS make use of
>     FS-Cache as that can be used for coherency data.
>=20
>     This is also specified in NFSv4 as a recommended attribute and =
could
>     be exported by NFSD [Steve French].
>=20
> (3) Lightweight stat: Ask for just those details of interest, and =
allow a
>     netfs (such as NFS) to approximate anything not of interest, =
possibly
>     without going to the server [Trond Myklebust, Ulrich Drepper, =
Andreas
>     Dilger].
>=20
> (4) Heavyweight stat: Force a netfs to go to the server, even if it =
thinks
>     its cached attributes are up to date [Trond Myklebust].
>=20
> (5) Data version number: Could be used by userspace NFS servers =
[Aneesh
>     Kumar].
>=20
>     Can also be used to modify fill_post_wcc() in NFSD which retrieves
>     i_version directly, but has just called vfs_getattr().  It could =
get
>     it from the kstat struct if it used vfs_xgetattr() instead.
>=20
> (6) BSD stat compatibility: Including more fields from the BSD stat =
such
>     as creation time (st_btime) and inode generation number (st_gen)
>     [Jeremy Allison, Bernd Schubert].
>=20
> (7) Inode generation number: Useful for FUSE and userspace NFS servers
>     [Bernd Schubert].  This was asked for but later deemed unnecessary
>     with the open-by-handle capability available
>=20
> (8) Extra coherency data may be useful in making backups [Andreas =
Dilger].
>=20
> (9) Allow the filesystem to indicate what it can/cannot provide: A
>     filesystem can now say it doesn't support a standard stat feature =
if
>     that isn't available, so if, for instance, inode numbers or UIDs =
don't
>     exist or are fabricated locally...
>=20
> (10) Make the fields a consistent size on all arches and make them =
large.
>=20
> (11) Store a 16-byte volume ID in the superblock that can be returned =
in
>     struct xstat [Steve French].
>=20
> (12) Include granularity fields in the time data to indicate the
>     granularity of each of the times (NFSv4 time_delta) [Steve =
French].
>=20
> (13) FS_IOC_GETFLAGS value.  These could be translated to BSD's =
st_flags.
>     Note that the Linux IOC flags are a mess and filesystems such as =
Ext4
>     define flags that aren't in linux/fs.h, so translation in the =
kernel
>     may be a necessity (or, possibly, we provide the filesystem type =
too).
>=20
> (14) Mask of features available on file (eg: ACLs, seclabel) [Brad =
Boyer,
>     Michael Kerrisk].
>=20
> (15) Spare space, request flags and information flags are provided for
>     future expansion.
>=20
> Note that not all of the above are implemented here.
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> NEW SYSTEM CALL
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The new system call is:
>=20
> 	int ret =3D statx(int dfd,
> 			const char *filename,
> 			unsigned int flags,
> 			unsigned int mask,
> 			struct statx *buffer);
>=20
> The dfd, filename and flags parameters indicate the file to query.  =
There
> is no equivalent of lstat() as that can be emulated with statx() by =
passing
> AT_SYMLINK_NOFOLLOW in flags.  There is also no equivalent of fstat() =
as
> that can be emulated by passing a NULL filename to statx() with the fd =
of
> interest in dfd.
>=20
> AT_FORCE_ATTR_SYNC can be set in flags.  This will require a network
> filesystem to synchronise its attributes with the server.
>=20
> AT_NO_ATTR_SYNC can be set in flags.  This will suppress =
synchronisation
> with the server in a network filesystem.  The resulting values should =
be
> considered approximate.
>=20
> mask is a bitmask indicating the fields in struct statx that are of
> interest to the caller.  The user should set this to STATX_BASIC_STATS =
to
> get the basic set returned by stat().
>=20
> buffer points to the destination for the data.  This must be 256 bytes =
in
> size.
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> MAIN ATTRIBUTES RECORD
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The following structures are defined in which to return the main =
attribute
> set:
>=20
> 	struct statx {
> 		__u32	st_mask;
> 		__u32	st_information;
> 		__u32	st_blksize;
> 		__u32	st_nlink;
> 		__u32	st_gen;
> 		__u32	st_uid;
> 		__u32	st_gid;
> 		__u16	st_mode;
> 		__u16	__spare0[1];
> 		__u64	st_ino;
> 		__u64	st_size;
> 		__u64	st_blocks;
> 		__u64	st_version;
> 		__s64	st_atime;
> 		__s64	st_btime;
> 		__s64	st_ctime;
> 		__s64	st_mtime;
> 		__s32	st_atime_ns;
> 		__s32	st_btime_ns;
> 		__s32	st_ctime_ns;
> 		__s32	st_mtime_ns;
> 		__u32	st_rdev_major;
> 		__u32	st_rdev_minor;
> 		__u32	st_dev_major;
> 		__u32	st_dev_minor;
> 		__u64	__spare1[16];
> 	};
>=20
> where st_information is local system information about the file, =
st_gen is
> the inode generation number, st_btime is the file creation time, =
st_version
> is the data version number (i_version), st_mask is a bitmask =
indicating the
> data provided and __spares*[] are where as-yet undefined fields can be
> placed.
>=20
> Time fields are split into separate seconds and nanoseconds fields to =
make
> packing easier and the granularities can be queried with the =
filesystem
> info system call.  Note that times will be negative if before 1970; in =
such
> a case, the nanosecond fields should also be negative if not zero.
>=20
> The defined bits in request_mask and st_mask are:
>=20
> 	STATX_MODE		Want/got st_mode
> 	STATX_NLINK		Want/got st_nlink
> 	STATX_UID		Want/got st_uid
> 	STATX_GID		Want/got st_gid
> 	STATX_RDEV		Want/got st_rdev_*
> 	STATX_ATIME		Want/got st_atime
> 	STATX_MTIME		Want/got st_mtime
> 	STATX_CTIME		Want/got st_ctime
> 	STATX_INO		Want/got st_ino
> 	STATX_SIZE		Want/got st_size
> 	STATX_BLOCKS		Want/got st_blocks
> 	STATX_BASIC_STATS	[The stuff in the normal stat struct]
> 	STATX_BTIME		Want/got st_btime
> 	STATX_VERSION		Want/got st_data_version
> 	STATX_GEN		Want/got st_gen
> 	STATX_ALL_STATS		[All currently available stuff]
>=20
> The defined bits in the st_information field give local system data on =
a
> file, how it is accessed, where it is and what it does:
>=20
> 	STATX_INFO_ENCRYPTED		File is encrypted

This flag overlaps with FS_ENCRYPT_FL that is encoded in the =
FS_IOC_GETFLAGS
attributes.  Are the FS_* flags expected to be translated into =
STATX_INFO_*
flags by each filesystem, or will they be partly duplicated in a =
separate
"st_attrs" field added in the future?

Cheers, Andreas

> 	STATX_INFO_TEMPORARY		File is temporary
> 	STATX_INFO_FABRICATED		File was made up by filesystem
> 	STATX_INFO_KERNEL_API		File is kernel API (eg: =
procfs/sysfs)
> 	STATX_INFO_REMOTE		File is remote
> 	STATX_INFO_AUTOMOUNT		Dir is automount trigger
> 	STATX_INFO_AUTODIR		Dir provides unlisted automounts
> 	STATX_INFO_NONSYSTEM_OWNERSHIP	File has non-system ownership =
details
>=20
> These are for the use of GUI tools that might want to mark files =
specially,
> depending on what they are.
>=20
> Fields in struct statx come in a number of classes:
>=20
> (0) st_information, st_dev_*, st_blksize.
>=20
>     These are local data and are always available.
>=20
> (1) st_nlinks, st_uid, st_gid, st_[amc]time*, st_ino, st_size, =
st_blocks.
>=20
>     These will be returned whether the caller asks for them or not.  =
The
>     corresponding bits in st_mask will be set to indicate whether they
>     actually have valid values.
>=20
>     If the caller didn't ask for them, then they may be approximated.  =
For
>     example, NFS won't waste any time updating them from the server,
>     unless as a byproduct of updating something requested.
>=20
>     If the values don't actually exist for the underlying object (such =
as
>     UID or GID on a DOS file), then the bit won't be set in the =
st_mask,
>     even if the caller asked for the value.  In such a case, the =
returned
>     value will be a fabrication.
>=20
> (2) st_mode.
>=20
>     The part of this that identifies the file type will always be
>     available, irrespective of the setting of STATX_MODE.  The access
>     flags and sticky bit are as for class (1).
>=20
> (3) st_rdev_*.
>=20
>     As for class (1), but this will be cleared if the file is not a
>     blockdev or chardev.  The bit will be cleared if the value is not
>     returned.
>=20
> (4) File creation time (st_btime*), data version (st_version), inode
>     generation number (st_gen).
>=20
>     These will be returned if available whether the caller asked for =
them or
>     not.  The corresponding bits in st_mask will be set or cleared as
>     appropriate to indicate a valid value.
>=20
>     If the caller didn't ask for them, then they may be approximated.  =
For
>     example, NFS won't waste any time updating them from the server, =
unless
>     as a byproduct of updating something requested.
>=20
>=20
> =3D=3D=3D=3D=3D=3D=3D
> TESTING
> =3D=3D=3D=3D=3D=3D=3D
>=20
> The following test program can be used to test the statx system call:
>=20
> 	samples/statx/test-statx.c
>=20
> Just compile and run, passing it paths to the files you want to =
examine.
> The file is built automatically if CONFIG_SAMPLES is enabled.
>=20
> Here's some example output.  Firstly, an NFS directory that crosses to
> another FSID.  Note that the FABRICATED and AUTOMOUNT info flags are =
set.
> The former because the directory is invented locally as we don't see =
the
> underlying dir on the server, the latter because transiting this =
directory
> will cause d_automount to be invoked by the VFS.
>=20
> 	[root@andromeda tmp]# ./samples/statx/test-statx -A =
/warthog/data
> 	statx(/warthog/data) =3D 0
> 	results=3D4fef
> 	  Size: 4096            Blocks: 8          IO Block: 1048576  =
directory
> 	Device: 00:1d           Inode: 2           Links: 110
> 	Access: (3777/drwxrwxrwx)  Uid: -2
> 	Gid: 4294967294
> 	Access: 2012-04-30 09:01:55.283819565+0100
> 	Modify: 2012-03-28 19:01:19.405465361+0100
> 	Change: 2012-03-28 19:01:19.405465361+0100
> 	Data version: ef51734f11e92a18h
> 	Information: 00000134 (-------- -------- -------a --mr-f--)
>=20
> Secondly, the result of automounting on that directory.
>=20
> 	[root@andromeda tmp]# ./samples/statx/test-statx /warthog/data
> 	statx(/warthog/data) =3D 0
> 	results=3D14fef
> 	  Size: 4096            Blocks: 8          IO Block: 1048576  =
directory
> 	Device: 00:1e           Inode: 2           Links: 110
> 	Access: (3777/drwxrwxrwx)  Uid: -2
> 	Gid: 4294967294
> 	Access: 2012-04-30 09:01:55.283819565+0100
> 	Modify: 2012-03-28 19:01:19.405465361+0100
> 	Change: 2012-03-28 19:01:19.405465361+0100
> 	Data version: ef51734f11e92a18h
> 	Information: 00000110 (-------- -------- -------a ---r----)
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> arch/x86/entry/syscalls/syscall_32.tbl |    1
> arch/x86/entry/syscalls/syscall_64.tbl |    1
> fs/exportfs/expfs.c                    |    4
> fs/stat.c                              |  303 =
+++++++++++++++++++++++++++++---
> include/linux/fs.h                     |    5 -
> include/linux/stat.h                   |   15 +-
> include/linux/syscalls.h               |    4
> include/uapi/linux/fcntl.h             |    2
> include/uapi/linux/stat.h              |  109 ++++++++++++
> samples/Makefile                       |    2
> samples/statx/Makefile                 |   10 +
> samples/statx/test-statx.c             |  243 =
++++++++++++++++++++++++++
> 12 files changed, 662 insertions(+), 37 deletions(-)
> create mode 100644 samples/statx/Makefile
> create mode 100644 samples/statx/test-statx.c
>=20
> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl =
b/arch/x86/entry/syscalls/syscall_32.tbl
> index b30dd8154cc2..b99a6b3a167c 100644
> --- a/arch/x86/entry/syscalls/syscall_32.tbl
> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
> @@ -386,3 +386,4 @@
> 377	i386	copy_file_range		sys_copy_file_range
> 378	i386	preadv2			sys_preadv2
> 379	i386	pwritev2		sys_pwritev2
> +380	i386	statx			sys_statx
> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl =
b/arch/x86/entry/syscalls/syscall_64.tbl
> index cac6d17ce5db..6d5ef6c87cdc 100644
> --- a/arch/x86/entry/syscalls/syscall_64.tbl
> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
> @@ -335,6 +335,7 @@
> 326	common	copy_file_range		sys_copy_file_range
> 327	64	preadv2			sys_preadv2
> 328	64	pwritev2		sys_pwritev2
> +329	common	statx			sys_statx
>=20
> #
> # x32-specific system call numbers start at 512 to avoid cache impact
> diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
> index c46f1a190b8d..cd6d9cbc9300 100644
> --- a/fs/exportfs/expfs.c
> +++ b/fs/exportfs/expfs.c
> @@ -295,7 +295,9 @@ static int get_name(const struct path *path, char =
*name, struct dentry *child)
> 	 * filesystem supports 64-bit inode numbers.  So we need to
> 	 * actually call ->getattr, not just read i_ino:
> 	 */
> -	error =3D vfs_getattr_nosec(&child_path, &stat);
> +	stat.query_flags =3D 0;
> +	stat.request_mask =3D STATX_BASIC_STATS;
> +	error =3D vfs_xgetattr_nosec(&child_path, &stat);
> 	if (error)
> 		return error;
> 	buffer.ino =3D stat.ino;
> diff --git a/fs/stat.c b/fs/stat.c
> index bc045c7994e1..c2f8370dab13 100644
> --- a/fs/stat.c
> +++ b/fs/stat.c
> @@ -18,6 +18,15 @@
> #include <asm/uaccess.h>
> #include <asm/unistd.h>
>=20
> +/**
> + * generic_fillattr - Fill in the basic attributes from the inode =
struct
> + * @inode: Inode to use as the source
> + * @stat: Where to fill in the attributes
> + *
> + * Fill in the basic attributes in the kstat structure from data =
that's to be
> + * found on the VFS inode structure.  This is the default if no =
getattr inode
> + * operation is supplied.
> + */
> void generic_fillattr(struct inode *inode, struct kstat *stat)
> {
> 	stat->dev =3D inode->i_sb->s_dev;
> @@ -27,87 +36,197 @@ void generic_fillattr(struct inode *inode, struct =
kstat *stat)
> 	stat->uid =3D inode->i_uid;
> 	stat->gid =3D inode->i_gid;
> 	stat->rdev =3D inode->i_rdev;
> -	stat->size =3D i_size_read(inode);
> -	stat->atime =3D inode->i_atime;
> 	stat->mtime =3D inode->i_mtime;
> 	stat->ctime =3D inode->i_ctime;
> -	stat->blksize =3D (1 << inode->i_blkbits);
> +	stat->size =3D i_size_read(inode);
> 	stat->blocks =3D inode->i_blocks;
> -}
> +	stat->blksize =3D 1 << inode->i_blkbits;
>=20
> +	stat->result_mask |=3D STATX_BASIC_STATS & ~STATX_RDEV;
> +	if (IS_NOATIME(inode))
> +		stat->result_mask &=3D ~STATX_ATIME;
> +	else
> +		stat->atime =3D inode->i_atime;
> +
> +	if (S_ISREG(stat->mode) && stat->nlink =3D=3D 0)
> +		stat->information |=3D STATX_INFO_TEMPORARY;
> +	if (IS_AUTOMOUNT(inode))
> +		stat->information |=3D STATX_INFO_AUTOMOUNT;
> +
> +	if (unlikely(S_ISBLK(stat->mode) || S_ISCHR(stat->mode)))
> +		stat->result_mask |=3D STATX_RDEV;
> +}
> EXPORT_SYMBOL(generic_fillattr);
>=20
> /**
> - * vfs_getattr_nosec - getattr without security checks
> + * vfs_xgetattr_nosec - getattr without security checks
>  * @path: file to get attributes from
>  * @stat: structure to return attributes in
>  *
>  * Get attributes without calling security_inode_getattr.
>  *
> - * Currently the only caller other than vfs_getattr is internal to =
the
> - * filehandle lookup code, which uses only the inode number and =
returns
> - * no attributes to any user.  Any other code probably wants
> - * vfs_getattr.
> + * Currently the only caller other than vfs_xgetattr is internal to =
the
> + * filehandle lookup code, which uses only the inode number and =
returns no
> + * attributes to any user.  Any other code probably wants =
vfs_xgetattr.
> + *
> + * The caller must set stat->request_mask to indicate what they want =
and
> + * stat->query_flags to indicate whether the server should be =
queried.
>  */
> -int vfs_getattr_nosec(struct path *path, struct kstat *stat)
> +int vfs_xgetattr_nosec(struct path *path, struct kstat *stat)
> {
> 	struct inode *inode =3D d_backing_inode(path->dentry);
>=20
> +	stat->query_flags &=3D ~KSTAT_QUERY_FLAGS;
> +	if ((stat->query_flags & AT_FORCE_ATTR_SYNC) &&
> +	    (stat->query_flags & AT_NO_ATTR_SYNC))
> +		return -EINVAL;
> +
> +	stat->result_mask =3D 0;
> +	stat->information =3D 0;
> 	if (inode->i_op->getattr)
> 		return inode->i_op->getattr(path->mnt, path->dentry, =
stat);
>=20
> 	generic_fillattr(inode, stat);
> 	return 0;
> }
> +EXPORT_SYMBOL(vfs_xgetattr_nosec);
>=20
> -EXPORT_SYMBOL(vfs_getattr_nosec);
> -
> -int vfs_getattr(struct path *path, struct kstat *stat)
> +/*
> + * vfs_xgetattr - Get the enhanced basic attributes of a file
> + * @path: The file of interest
> + * @stat: Where to return the statistics
> + *
> + * Ask the filesystem for a file's attributes.  The caller must have =
preset
> + * stat->request_mask and stat->query_flags to indicate what they =
want.
> + *
> + * If the file is remote, the filesystem can be forced to update the =
attributes
> + * from the backing store by passing AT_FORCE_ATTR_SYNC in =
query_flags or can
> + * suppress the update by passing AT_NO_ATTR_SYNC.
> + *
> + * Bits must have been set in stat->request_mask to indicate which =
attributes
> + * the caller wants retrieving.  Any such attribute not requested may =
be
> + * returned anyway, but the value may be approximate, and, if remote, =
may not
> + * have been synchronised with the server.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_xgetattr(struct path *path, struct kstat *stat)
> {
> 	int retval;
>=20
> 	retval =3D security_inode_getattr(path);
> 	if (retval)
> 		return retval;
> -	return vfs_getattr_nosec(path, stat);
> +	return vfs_xgetattr_nosec(path, stat);
> }
> +EXPORT_SYMBOL(vfs_xgetattr);
>=20
> +/**
> + * vfs_getattr - Get the basic attributes of a file
> + * @path: The file of interest
> + * @stat: Where to return the statistics
> + *
> + * Ask the filesystem for a file's attributes.  If remote, the =
filesystem isn't
> + * forced to update its files from the backing store.  Only the basic =
set of
> + * attributes will be retrieved; anyone wanting more must use =
vfs_xgetattr(),
> + * as must anyone who wants to force attributes to be sync'd with the =
server.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_getattr(struct path *path, struct kstat *stat)
> +{
> +	stat->query_flags =3D 0;
> +	stat->request_mask =3D STATX_BASIC_STATS;
> +	return vfs_xgetattr(path, stat);
> +}
> EXPORT_SYMBOL(vfs_getattr);
>=20
> -int vfs_fstat(unsigned int fd, struct kstat *stat)
> +/**
> + * vfs_fstatx - Get the enhanced basic attributes by file descriptor
> + * @fd: The file descriptor referring to the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xgetattr().  The main =
difference is
> + * that it uses a file descriptor to determine the file location.
> + *
> + * The caller must have preset stat->query_flags and =
stat->request_mask as for
> + * vfs_xgetattr().
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_fstatx(unsigned int fd, struct kstat *stat)
> {
> 	struct fd f =3D fdget_raw(fd);
> 	int error =3D -EBADF;
>=20
> 	if (f.file) {
> -		error =3D vfs_getattr(&f.file->f_path, stat);
> +		error =3D vfs_xgetattr(&f.file->f_path, stat);
> 		fdput(f);
> 	}
> 	return error;
> }
> +EXPORT_SYMBOL(vfs_fstatx);
> +
> +/**
> + * vfs_fstat - Get basic attributes by file descriptor
> + * @fd: The file descriptor referring to the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_getattr().  The main =
difference is
> + * that it uses a file descriptor to determine the file location.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_fstat(unsigned int fd, struct kstat *stat)
> +{
> +	stat->query_flags =3D 0;
> +	stat->request_mask =3D STATX_BASIC_STATS;
> +	return vfs_fstatx(fd, stat);
> +}
> EXPORT_SYMBOL(vfs_fstat);
>=20
> -int vfs_fstatat(int dfd, const char __user *filename, struct kstat =
*stat,
> -		int flag)
> +/**
> + * vfs_statx - Get basic and extra attributes by filename
> + * @dfd: A file descriptor representing the base dir for a relative =
filename
> + * @filename: The name of the file of interest
> + * @flags: Flags to control the query
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_xgetattr().  The main =
difference is
> + * that it uses a filename and base directory to determine the file =
location.
> + * Additionally, the addition of AT_SYMLINK_NOFOLLOW to flags will =
prevent a
> + * symlink at the given name from being referenced.
> + *
> + * The caller must have preset stat->request_mask as for =
vfs_xgetattr().  The
> + * flags are also used to load up stat->query_flags.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_statx(int dfd, const char __user *filename, int flags,
> +	      struct kstat *stat)
> {
> 	struct path path;
> 	int error =3D -EINVAL;
> -	unsigned int lookup_flags =3D 0;
> +	unsigned int lookup_flags =3D LOOKUP_FOLLOW | LOOKUP_AUTOMOUNT;
>=20
> -	if ((flag & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
> -		      AT_EMPTY_PATH)) !=3D 0)
> -		goto out;
> +	if ((flags & ~(AT_SYMLINK_NOFOLLOW | AT_NO_AUTOMOUNT |
> +		       AT_EMPTY_PATH | KSTAT_QUERY_FLAGS)) !=3D 0)
> +		return -EINVAL;
>=20
> -	if (!(flag & AT_SYMLINK_NOFOLLOW))
> -		lookup_flags |=3D LOOKUP_FOLLOW;
> -	if (flag & AT_EMPTY_PATH)
> +	if (flags & AT_SYMLINK_NOFOLLOW)
> +		lookup_flags &=3D ~LOOKUP_FOLLOW;
> +	if (flags & AT_NO_AUTOMOUNT)
> +		lookup_flags &=3D ~LOOKUP_AUTOMOUNT;
> +	if (flags & AT_EMPTY_PATH)
> 		lookup_flags |=3D LOOKUP_EMPTY;
> +	stat->query_flags =3D flags;
> +
> retry:
> 	error =3D user_path_at(dfd, filename, lookup_flags, &path);
> 	if (error)
> 		goto out;
>=20
> -	error =3D vfs_getattr(&path, stat);
> +	error =3D vfs_xgetattr(&path, stat);
> 	path_put(&path);
> 	if (retry_estale(error, lookup_flags)) {
> 		lookup_flags |=3D LOOKUP_REVAL;
> @@ -116,17 +235,65 @@ retry:
> out:
> 	return error;
> }
> +EXPORT_SYMBOL(vfs_statx);
> +
> +/**
> + * vfs_fstatat - Get basic attributes by filename
> + * @dfd: A file descriptor representing the base dir for a relative =
filename
> + * @filename: The name of the file of interest
> + * @flags: Flags to control the query
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_statx().  The difference is =
that it
> + * preselects basic stats only.  The flags are used to load up
> + * stat->query_flags in addition to indicating symlink handling =
during path
> + * resolution.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_fstatat(int dfd, const char __user *filename, struct kstat =
*stat,
> +		int flags)
> +{
> +	stat->request_mask =3D STATX_BASIC_STATS;
> +	return vfs_statx(dfd, filename, flags, stat);
> +}
> EXPORT_SYMBOL(vfs_fstatat);
>=20
> -int vfs_stat(const char __user *name, struct kstat *stat)
> +/**
> + * vfs_stat - Get basic attributes by filename
> + * @filename: The name of the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_statx().  The difference is =
that it
> + * preselects basic stats only, terminal symlinks are followed =
regardless and a
> + * remote filesystem can't be forced to query the server.  If such is =
desired,
> + * vfs_statx() should be used instead.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> +int vfs_stat(const char __user *filename, struct kstat *stat)
> {
> -	return vfs_fstatat(AT_FDCWD, name, stat, 0);
> +	stat->request_mask =3D STATX_BASIC_STATS;
> +	return vfs_statx(AT_FDCWD, filename, 0, stat);
> }
> EXPORT_SYMBOL(vfs_stat);
>=20
> +/**
> + * vfs_lstat - Get basic attrs by filename, without following =
terminal symlink
> + * @filename: The name of the file of interest
> + * @stat: The result structure to fill in.
> + *
> + * This function is a wrapper around vfs_statx().  The difference is =
that it
> + * preselects basic stats only, terminal symlinks are note followed =
regardless
> + * and a remote filesystem can't be forced to query the server.  If =
such is
> + * desired, vfs_statx() should be used instead.
> + *
> + * 0 will be returned on success, and a -ve error code if =
unsuccessful.
> + */
> int vfs_lstat(const char __user *name, struct kstat *stat)
> {
> -	return vfs_fstatat(AT_FDCWD, name, stat, AT_SYMLINK_NOFOLLOW);
> +	stat->request_mask =3D STATX_BASIC_STATS;
> +	return vfs_statx(AT_FDCWD, name, AT_SYMLINK_NOFOLLOW, stat);
> }
> EXPORT_SYMBOL(vfs_lstat);
>=20
> @@ -141,7 +308,7 @@ static int cp_old_stat(struct kstat *stat, struct =
__old_kernel_stat __user * sta
> {
> 	static int warncount =3D 5;
> 	struct __old_kernel_stat tmp;
> -
> +
> 	if (warncount > 0) {
> 		warncount--;
> 		printk(KERN_WARNING "VFS: Warning: %s using old stat() =
call. Recompile your binary.\n",
> @@ -166,7 +333,7 @@ static int cp_old_stat(struct kstat *stat, struct =
__old_kernel_stat __user * sta
> #if BITS_PER_LONG =3D=3D 32
> 	if (stat->size > MAX_NON_LFS)
> 		return -EOVERFLOW;
> -#endif
> +#endif
> 	tmp.st_size =3D stat->size;
> 	tmp.st_atime =3D stat->atime.tv_sec;
> 	tmp.st_mtime =3D stat->mtime.tv_sec;
> @@ -443,6 +610,80 @@ SYSCALL_DEFINE4(fstatat64, int, dfd, const char =
__user *, filename,
> }
> #endif /* __ARCH_WANT_STAT64 || __ARCH_WANT_COMPAT_STAT64 */
>=20
> +/*
> + * Set the statx results.
> + */
> +static long statx_set_result(struct kstat *stat, struct statx __user =
*buffer)
> +{
> +	uid_t uid =3D from_kuid_munged(current_user_ns(), stat->uid);
> +	gid_t gid =3D from_kgid_munged(current_user_ns(), stat->gid);
> +
> +#define __put_timestamp(kts, uts) (				\
> +		__put_user(kts.tv_sec,	uts##_s		) ||	\
> +		__put_user(kts.tv_nsec,	uts##_ns	))
> +
> +	if (__put_user(stat->result_mask,	&buffer->st_mask	=
) ||
> +	    __put_user(stat->mode,		&buffer->st_mode	=
) ||
> +	    __clear_user(&buffer->__spare0, sizeof(buffer->__spare0))	 =
 ||
> +	    __put_user(stat->nlink,		&buffer->st_nlink	=
) ||
> +	    __put_user(uid,			&buffer->st_uid		=
) ||
> +	    __put_user(gid,			&buffer->st_gid		=
) ||
> +	    __put_user(stat->information,	&buffer->st_information	=
) ||
> +	    __put_user(stat->blksize,		&buffer->st_blksize	=
) ||
> +	    __put_user(MAJOR(stat->rdev),	&buffer->st_rdev_major	=
) ||
> +	    __put_user(MINOR(stat->rdev),	&buffer->st_rdev_minor	=
) ||
> +	    __put_user(MAJOR(stat->dev),	&buffer->st_dev_major	=
) ||
> +	    __put_user(MINOR(stat->dev),	&buffer->st_dev_minor	=
) ||
> +	    __put_timestamp(stat->atime,	&buffer->st_atime	=
) ||
> +	    __put_timestamp(stat->btime,	&buffer->st_btime	=
) ||
> +	    __put_timestamp(stat->ctime,	&buffer->st_ctime	=
) ||
> +	    __put_timestamp(stat->mtime,	&buffer->st_mtime	=
) ||
> +	    __put_user(stat->ino,		&buffer->st_ino		=
) ||
> +	    __put_user(stat->size,		&buffer->st_size	=
) ||
> +	    __put_user(stat->blocks,		&buffer->st_blocks	=
) ||
> +	    __put_user(stat->version,		&buffer->st_version	=
) ||
> +	    __put_user(stat->gen,		&buffer->st_gen		=
) ||
> +	    __clear_user(&buffer->__spare1, sizeof(buffer->__spare1)))
> +		return -EFAULT;
> +
> +	return 0;
> +}
> +
> +/**
> + * sys_statx - System call to get enhanced stats
> + * @dfd: Base directory to pathwalk from *or* fd to stat.
> + * @filename: File to stat *or* NULL.
> + * @flags: AT_* flags to control pathwalk.
> + * @mask: Parts of statx struct actually required.
> + * @buffer: Result buffer.
> + *
> + * Note that if filename is NULL, then it does the equivalent of =
fstat() using
> + * dfd to indicate the file of interest.
> + */
> +SYSCALL_DEFINE5(statx,
> +		int, dfd, const char __user *, filename, unsigned, =
flags,
> +		unsigned int, mask,
> +		struct statx __user *, buffer)
> +{
> +	struct kstat stat;
> +	int error;
> +
> +	if (!access_ok(VERIFY_WRITE, buffer, sizeof(*buffer)))
> +		return -EFAULT;
> +
> +	memset(&stat, 0, sizeof(stat));
> +	stat.query_flags =3D flags;
> +	stat.request_mask =3D mask & STATX_ALL_STATS;
> +
> +	if (filename)
> +		error =3D vfs_statx(dfd, filename, flags, &stat);
> +	else
> +		error =3D vfs_fstatx(dfd, &stat);
> +	if (error)
> +		return error;
> +	return statx_set_result(&stat, buffer);
> +}
> +
> /* Caller is here responsible for sufficient locking (ie. =
inode->i_lock) */
> void __inode_add_bytes(struct inode *inode, loff_t bytes)
> {
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 70e61b58baaf..8b2f6df924e9 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2827,8 +2827,9 @@ extern const struct inode_operations =
page_symlink_inode_operations;
> extern void kfree_link(void *);
> extern int generic_readlink(struct dentry *, char __user *, int);
> extern void generic_fillattr(struct inode *, struct kstat *);
> -int vfs_getattr_nosec(struct path *path, struct kstat *stat);
> +extern int vfs_xgetattr_nosec(struct path *path, struct kstat *stat);
> extern int vfs_getattr(struct path *, struct kstat *);
> +extern int vfs_xgetattr(struct path *, struct kstat *);
> void __inode_add_bytes(struct inode *inode, loff_t bytes);
> void inode_add_bytes(struct inode *inode, loff_t bytes);
> void __inode_sub_bytes(struct inode *inode, loff_t bytes);
> @@ -2845,6 +2846,8 @@ extern int vfs_stat(const char __user *, struct =
kstat *);
> extern int vfs_lstat(const char __user *, struct kstat *);
> extern int vfs_fstat(unsigned int, struct kstat *);
> extern int vfs_fstatat(int , const char __user *, struct kstat *, =
int);
> +extern int vfs_xstat(int, const char __user *, int, struct kstat *);
> +extern int vfs_xfstat(unsigned int, struct kstat *);
>=20
> extern int __generic_block_fiemap(struct inode *inode,
> 				  struct fiemap_extent_info *fieinfo,
> diff --git a/include/linux/stat.h b/include/linux/stat.h
> index 075cb0c7eb2a..4f1902b0cb94 100644
> --- a/include/linux/stat.h
> +++ b/include/linux/stat.h
> @@ -19,6 +19,13 @@
> #include <linux/uidgid.h>
>=20
> struct kstat {
> +	u32		query_flags;		/* Operational flags */
> +#define KSTAT_QUERY_FLAGS (AT_FORCE_ATTR_SYNC | AT_NO_ATTR_SYNC)
> +	u32		request_mask;		/* What fields the user =
asked for */
> +	u32		result_mask;		/* What fields the user =
got */
> +	u32		information;
> +	u32		win_attrs;		/* Windows file =
attributes */
> +	u32		gen;
> 	u64		ino;
> 	dev_t		dev;
> 	umode_t		mode;
> @@ -27,11 +34,13 @@ struct kstat {
> 	kgid_t		gid;
> 	dev_t		rdev;
> 	loff_t		size;
> -	struct timespec  atime;
> +	struct timespec	atime;
> 	struct timespec	mtime;
> 	struct timespec	ctime;
> -	unsigned long	blksize;
> -	unsigned long long	blocks;
> +	struct timespec	btime;			/* File creation time */
> +	uint32_t	blksize;		/* Preferred I/O size */
> +	u64		blocks;
> +	u64		version;		/* Data version */
> };
>=20
> #endif
> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
> index d795472c54d8..f6bfbf74e44d 100644
> --- a/include/linux/syscalls.h
> +++ b/include/linux/syscalls.h
> @@ -48,6 +48,7 @@ struct stat;
> struct stat64;
> struct statfs;
> struct statfs64;
> +struct statx;
> struct __sysctl_args;
> struct sysinfo;
> struct timespec;
> @@ -898,4 +899,7 @@ asmlinkage long sys_copy_file_range(int fd_in, =
loff_t __user *off_in,
>=20
> asmlinkage long sys_mlock2(unsigned long start, size_t len, int =
flags);
>=20
> +asmlinkage long sys_statx(int dfd, const char __user *path, unsigned =
flags,
> +			  unsigned mask, struct statx __user *buffer);
> +
> #endif
> diff --git a/include/uapi/linux/fcntl.h b/include/uapi/linux/fcntl.h
> index beed138bd359..5c8143b04ff7 100644
> --- a/include/uapi/linux/fcntl.h
> +++ b/include/uapi/linux/fcntl.h
> @@ -62,6 +62,8 @@
> #define AT_SYMLINK_FOLLOW	0x400   /* Follow symbolic links.  */
> #define AT_NO_AUTOMOUNT		0x800	/* Suppress terminal =
automount traversal */
> #define AT_EMPTY_PATH		0x1000	/* Allow empty relative pathname =
*/
> +#define AT_FORCE_ATTR_SYNC	0x2000	/* Force the attributes to be =
sync'd with the server */
> +#define AT_NO_ATTR_SYNC		0x4000	/* Don't sync attributes =
with the server */
>=20
>=20
> #endif /* _UAPI_LINUX_FCNTL_H */
> diff --git a/include/uapi/linux/stat.h b/include/uapi/linux/stat.h
> index 7fec7e36d921..55ce6607dab6 100644
> --- a/include/uapi/linux/stat.h
> +++ b/include/uapi/linux/stat.h
> @@ -1,6 +1,7 @@
> #ifndef _UAPI_LINUX_STAT_H
> #define _UAPI_LINUX_STAT_H
>=20
> +#include <linux/types.h>
>=20
> #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
>=20
> @@ -41,5 +42,113 @@
>=20
> #endif
>=20
> +/*
> + * Structures for the extended file attribute retrieval system call
> + * (statx()).
> + *
> + * The caller passes a mask of what they're specifically interested =
in as a
> + * parameter to statx().  What statx() actually got will be indicated =
in
> + * st_mask upon return.
> + *
> + * For each bit in the mask argument:
> + *
> + * - if the datum is not available at all, the field and the bit will =
both be
> + *   cleared;
> + *
> + * - otherwise, if explicitly requested:
> + *
> + *   - the datum will be synchronised to the server if =
AT_FORCE_ATTR_SYNC is
> + *     set or if the datum is considered out of date, and
> + *
> + *   - the field will be filled in and the bit will be set;
> + *
> + * - otherwise, if not requested, but available in approximate form =
without any
> + *   effort, it will be filled in anyway, and the bit will be set =
upon return
> + *   (it might not be up to date, however, and no attempt will be =
made to
> + *   synchronise the internal state first);
> + *
> + * - otherwise the field and the bit will be cleared before =
returning.
> + *
> + * Items in STATX_BASIC_STATS may be marked unavailable on return, =
but they
> + * will have values installed for compatibility purposes so that =
stat() and
> + * co. can be emulated in userspace.
> + */
> +struct statx {
> +	/* 0x00 */
> +	__u32	st_mask;	/* What results were written [uncond] */
> +	__u32	st_information;	/* Information about the file [uncond] =
*/
> +	__u32	st_blksize;	/* Preferred general I/O size [uncond] =
*/
> +	__u32	st_nlink;	/* Number of hard links */
> +	/* 0x10 */
> +	__u32	st_gen;		/* Inode generation number */
> +	__u32	st_uid;		/* User ID of owner */
> +	__u32	st_gid;		/* Group ID of owner */
> +	__u16	st_mode;	/* File mode */
> +	__u16	__spare0[1];
> +	/* 0x20 */
> +	__u64	st_ino;		/* Inode number */
> +	__u64	st_size;	/* File size */
> +	__u64	st_blocks;	/* Number of 512-byte blocks allocated =
*/
> +	__u64	st_version;	/* Data version number */
> +	/* 0x40 */
> +	__s64	st_atime_s;	/* Last access time */
> +	__s64	st_btime_s;	/* File creation time */
> +	__s64	st_ctime_s;	/* Last attribute change time */
> +	__s64	st_mtime_s;	/* Last data modification time */
> +	/* 0x60 */
> +	__s32	st_atime_ns;	/* Last access time (ns part) */
> +	__s32	st_btime_ns;	/* File creation time (ns part) */
> +	__s32	st_ctime_ns;	/* Last attribute change time (ns part) =
*/
> +	__s32	st_mtime_ns;	/* Last data modification time (ns part) =
*/
> +	/* 0x70 */
> +	__u32	st_rdev_major;	/* Device ID of special file */
> +	__u32	st_rdev_minor;
> +	__u32	st_dev_major;	/* ID of device containing file [uncond] =
*/
> +	__u32	st_dev_minor;
> +	/* 0x80 */
> +	__u64	__spare1[16];	/* Spare space for future expansion */
> +	/* 0x100 */
> +};
> +
> +/*
> + * Flags to be st_mask
> + *
> + * Query request/result mask for statx() and struct statx::st_mask.
> + *
> + * These bits should be set in the mask argument of statx() to =
request
> + * particular items when calling statx().
> + */
> +#define STATX_MODE		0x00000001U	/* Want/got st_mode */
> +#define STATX_NLINK		0x00000002U	/* Want/got st_nlink */
> +#define STATX_UID		0x00000004U	/* Want/got st_uid */
> +#define STATX_GID		0x00000008U	/* Want/got st_gid */
> +#define STATX_RDEV		0x00000010U	/* Want/got st_rdev */
> +#define STATX_ATIME		0x00000020U	/* Want/got st_atime */
> +#define STATX_MTIME		0x00000040U	/* Want/got st_mtime */
> +#define STATX_CTIME		0x00000080U	/* Want/got st_ctime */
> +#define STATX_INO		0x00000100U	/* Want/got st_ino */
> +#define STATX_SIZE		0x00000200U	/* Want/got st_size */
> +#define STATX_BLOCKS		0x00000400U	/* Want/got st_blocks */
> +#define STATX_BASIC_STATS	0x000007ffU	/* The stuff in the =
normal stat struct */
> +#define STATX_BTIME		0x00000800U	/* Want/got st_btime */
> +#define STATX_VERSION		0x00001000U	/* Want/got =
st_version */
> +#define STATX_GEN		0x00002000U	/* Want/got st_gen */
> +#define STATX_ALL_STATS		0x00003fffU	/* All supported =
stats */
> +
> +/*
> + * Flags to be found in st_information
> + *
> + * These give information about the features or the state of a file =
that might
> + * be of use to ordinary userspace programs such as GUIs or ls rather =
than
> + * specialised tools.
> + */
> +#define STATX_INFO_ENCRYPTED		0x00000001U /* File is encrypted =
*/
> +#define STATX_INFO_TEMPORARY		0x00000002U /* File is temporary =
*/
> +#define STATX_INFO_FABRICATED		0x00000004U /* File was =
made up by filesystem */
> +#define STATX_INFO_KERNEL_API		0x00000008U /* File is =
kernel API (eg: procfs/sysfs) */
> +#define STATX_INFO_REMOTE		0x00000010U /* File is remote */
> +#define STATX_INFO_AUTOMOUNT		0x00000020U /* Dir is automount =
trigger */
> +#define STATX_INFO_AUTODIR		0x00000040U /* Dir provides =
unlisted automounts */
> +#define STATX_INFO_NONSYSTEM_OWNERSHIP	0x00000080U /* File has =
non-system ownership details */
>=20
> #endif /* _UAPI_LINUX_STAT_H */
> diff --git a/samples/Makefile b/samples/Makefile
> index 48001d7e23f0..d2ebb4e48d19 100644
> --- a/samples/Makefile
> +++ b/samples/Makefile
> @@ -2,4 +2,4 @@
>=20
> obj-$(CONFIG_SAMPLES)	+=3D kobject/ kprobes/ trace_events/ livepatch/ =
\
> 			   hw_breakpoint/ kfifo/ kdb/ hidraw/ rpmsg/ =
seccomp/ \
> -			   configfs/
> +			   configfs/ statx/
> diff --git a/samples/statx/Makefile b/samples/statx/Makefile
> new file mode 100644
> index 000000000000..6765dabc4c8d
> --- /dev/null
> +++ b/samples/statx/Makefile
> @@ -0,0 +1,10 @@
> +# kbuild trick to avoid linker error. Can be omitted if a module is =
built.
> +obj- :=3D dummy.o
> +
> +# List of programs to build
> +hostprogs-y :=3D test-statx
> +
> +# Tell kbuild to always build the programs
> +always :=3D $(hostprogs-y)
> +
> +HOSTCFLAGS_test-statx.o +=3D -I$(objtree)/usr/include
> diff --git a/samples/statx/test-statx.c b/samples/statx/test-statx.c
> new file mode 100644
> index 000000000000..38ef23c12e7d
> --- /dev/null
> +++ b/samples/statx/test-statx.c
> @@ -0,0 +1,243 @@
> +/* Test the statx() system call
> + *
> + * Copyright (C) 2015 Red Hat, Inc. All Rights Reserved.
> + * Written by David Howells (dhowells@redhat.com)
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public Licence
> + * as published by the Free Software Foundation; either version
> + * 2 of the Licence, or (at your option) any later version.
> + */
> +
> +#define _GNU_SOURCE
> +#define _ATFILE_SOURCE
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <unistd.h>
> +#include <ctype.h>
> +#include <errno.h>
> +#include <time.h>
> +#include <sys/syscall.h>
> +#include <sys/types.h>
> +#include <linux/stat.h>
> +#include <linux/fcntl.h>
> +#include <sys/stat.h>
> +
> +#define AT_FORCE_ATTR_SYNC	0x2000
> +#define AT_NO_ATTR_SYNC		0x4000
> +
> +static __attribute__((unused))
> +ssize_t statx(int dfd, const char *filename, unsigned flags,
> +	      unsigned int mask, struct statx *buffer)
> +{
> +	return syscall(__NR_statx, dfd, filename, flags, mask, buffer);
> +}
> +
> +static void print_time(const char *field, __s64 tv_sec, __s32 =
tv_nsec)
> +{
> +	struct tm tm;
> +	time_t tim;
> +	char buffer[100];
> +	int len;
> +
> +	tim =3D tv_sec;
> +	if (!localtime_r(&tim, &tm)) {
> +		perror("localtime_r");
> +		exit(1);
> +	}
> +	len =3D strftime(buffer, 100, "%F %T", &tm);
> +	if (len =3D=3D 0) {
> +		perror("strftime");
> +		exit(1);
> +	}
> +	printf("%s", field);
> +	fwrite(buffer, 1, len, stdout);
> +	printf(".%09u", tv_nsec);
> +	len =3D strftime(buffer, 100, "%z", &tm);
> +	if (len =3D=3D 0) {
> +		perror("strftime2");
> +		exit(1);
> +	}
> +	fwrite(buffer, 1, len, stdout);
> +	printf("\n");
> +}
> +
> +static void dump_statx(struct statx *stx)
> +{
> +	char buffer[256], ft =3D '?';
> +
> +	printf("results=3D%x\n", stx->st_mask);
> +
> +	printf(" ");
> +	if (stx->st_mask & STATX_SIZE)
> +		printf(" Size: %-15llu", (unsigned long =
long)stx->st_size);
> +	if (stx->st_mask & STATX_BLOCKS)
> +		printf(" Blocks: %-10llu", (unsigned long =
long)stx->st_blocks);
> +	printf(" IO Block: %-6llu ", (unsigned long =
long)stx->st_blksize);
> +	if (stx->st_mask & STATX_MODE) {
> +		switch (stx->st_mode & S_IFMT) {
> +		case S_IFIFO:	printf(" FIFO\n");			=
ft =3D 'p'; break;
> +		case S_IFCHR:	printf(" character special file\n");	=
ft =3D 'c'; break;
> +		case S_IFDIR:	printf(" directory\n");			=
ft =3D 'd'; break;
> +		case S_IFBLK:	printf(" block special file\n");	=
ft =3D 'b'; break;
> +		case S_IFREG:	printf(" regular file\n");		=
ft =3D '-'; break;
> +		case S_IFLNK:	printf(" symbolic link\n");		=
ft =3D 'l'; break;
> +		case S_IFSOCK:	printf(" socket\n");			=
ft =3D 's'; break;
> +		default:
> +			printf("unknown type (%o)\n", stx->st_mode & =
S_IFMT);
> +			break;
> +		}
> +	}
> +
> +	sprintf(buffer, "%02x:%02x", stx->st_dev_major, =
stx->st_dev_minor);
> +	printf("Device: %-15s", buffer);
> +	if (stx->st_mask & STATX_INO)
> +		printf(" Inode: %-11llu", (unsigned long long) =
stx->st_ino);
> +	if (stx->st_mask & STATX_SIZE)
> +		printf(" Links: %-5u", stx->st_nlink);
> +	if (stx->st_mask & STATX_RDEV)
> +		printf(" Device type: %u,%u", stx->st_rdev_major, =
stx->st_rdev_minor);
> +	printf("\n");
> +
> +	if (stx->st_mask & STATX_MODE)
> +		printf("Access: (%04o/%c%c%c%c%c%c%c%c%c%c)  ",
> +		       stx->st_mode & 07777,
> +		       ft,
> +		       stx->st_mode & S_IRUSR ? 'r' : '-',
> +		       stx->st_mode & S_IWUSR ? 'w' : '-',
> +		       stx->st_mode & S_IXUSR ? 'x' : '-',
> +		       stx->st_mode & S_IRGRP ? 'r' : '-',
> +		       stx->st_mode & S_IWGRP ? 'w' : '-',
> +		       stx->st_mode & S_IXGRP ? 'x' : '-',
> +		       stx->st_mode & S_IROTH ? 'r' : '-',
> +		       stx->st_mode & S_IWOTH ? 'w' : '-',
> +		       stx->st_mode & S_IXOTH ? 'x' : '-');
> +	if (stx->st_mask & STATX_UID)
> +		printf("Uid: %5d   ", stx->st_uid);
> +	if (stx->st_mask & STATX_GID)
> +		printf("Gid: %5d\n", stx->st_gid);
> +
> +	if (stx->st_mask & STATX_ATIME)
> +		print_time("Access: ", stx->st_atime_s, =
stx->st_atime_ns);
> +	if (stx->st_mask & STATX_MTIME)
> +		print_time("Modify: ", stx->st_mtime_s, =
stx->st_mtime_ns);
> +	if (stx->st_mask & STATX_CTIME)
> +		print_time("Change: ", stx->st_ctime_s, =
stx->st_ctime_ns);
> +	if (stx->st_mask & STATX_BTIME)
> +		print_time(" Birth: ", stx->st_btime_s, =
stx->st_btime_ns);
> +
> +	if (stx->st_mask & STATX_VERSION)
> +		printf("Data version: %llxh\n",
> +		       (unsigned long long)stx->st_version);
> +
> +	if (stx->st_mask & STATX_GEN)
> +		printf("Inode gen   : %xh\n", stx->st_gen);
> +
> +	if (stx->st_information) {
> +		unsigned char bits;
> +		int loop, byte;
> +
> +		static char info_representation[32 + 1] =3D
> +			/* STATX_INFO_ flags: */
> +			"????????"	/* 31-24	=
0x00000000-ff000000 */
> +			"????????"	/* 23-16	=
0x00000000-00ff0000 */
> +			"????????"	/* 15- 8	=
0x00000000-0000ff00 */
> +			"ndmrkfte"	/*  7- 0	=
0x00000000-000000ff */
> +			;
> +
> +		printf("Information: %08x (", stx->st_information);
> +		for (byte =3D 32 - 8; byte >=3D 0; byte -=3D 8) {
> +			bits =3D stx->st_information >> byte;
> +			for (loop =3D 7; loop >=3D 0; loop--) {
> +				int bit =3D byte + loop;
> +
> +				if (bits & 0x80)
> +					putchar(info_representation[31 - =
bit]);
> +				else
> +					putchar('-');
> +				bits <<=3D 1;
> +			}
> +			if (byte)
> +				putchar(' ');
> +		}
> +		printf(")\n");
> +	}
> +
> +	printf("IO-blocksize: blksize=3D%u\n", stx->st_blksize);
> +}
> +
> +static void dump_hex(unsigned long long *data, int from, int to)
> +{
> +	unsigned offset, print_offset =3D 1, col =3D 0;
> +
> +	from /=3D 8;
> +	to =3D (to + 7) / 8;
> +
> +	for (offset =3D from; offset < to; offset++) {
> +		if (print_offset) {
> +			printf("%04x: ", offset * 8);
> +			print_offset =3D 0;
> +		}
> +		printf("%016llx", data[offset]);
> +		col++;
> +		if ((col & 3) =3D=3D 0) {
> +			printf("\n");
> +			print_offset =3D 1;
> +		} else {
> +			printf(" ");
> +		}
> +	}
> +
> +	if (!print_offset)
> +		printf("\n");
> +}
> +
> +int main(int argc, char **argv)
> +{
> +	struct statx stx;
> +	int ret, raw =3D 0, atflag =3D AT_SYMLINK_NOFOLLOW;
> +
> +	unsigned int mask =3D STATX_ALL_STATS;
> +
> +	for (argv++; *argv; argv++) {
> +		if (strcmp(*argv, "-F") =3D=3D 0) {
> +			atflag |=3D AT_FORCE_ATTR_SYNC;
> +			continue;
> +		}
> +		if (strcmp(*argv, "-N") =3D=3D 0) {
> +			atflag |=3D AT_NO_ATTR_SYNC;
> +			continue;
> +		}
> +		if (strcmp(*argv, "-L") =3D=3D 0) {
> +			atflag &=3D ~AT_SYMLINK_NOFOLLOW;
> +			continue;
> +		}
> +		if (strcmp(*argv, "-O") =3D=3D 0) {
> +			mask &=3D ~STATX_BASIC_STATS;
> +			continue;
> +		}
> +		if (strcmp(*argv, "-A") =3D=3D 0) {
> +			atflag |=3D AT_NO_AUTOMOUNT;
> +			continue;
> +		}
> +		if (strcmp(*argv, "-R") =3D=3D 0) {
> +			raw =3D 1;
> +			continue;
> +		}
> +
> +		memset(&stx, 0xbf, sizeof(stx));
> +		ret =3D statx(AT_FDCWD, *argv, atflag, mask, &stx);
> +		printf("statx(%s) =3D %d\n", *argv, ret);
> +		if (ret < 0) {
> +			perror(*argv);
> +			exit(1);
> +		}
> +
> +		if (raw)
> +			dump_hex((unsigned long long *)&stx, 0, =
sizeof(stx));
> +
> +		dump_statx(&stx);
> +	}
> +	return 0;
> +}
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_B277523B-33CE-49E3-B328-0B8F68EED2FC
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVyfY03Kl2rkXzB/gAQjAww//bcnOKSWwErvSSAk6u5ja6EMZfC41eMDr
D3DNyOnwqP+USg+b/tRqZKKcCdt0CDxOPfe46EI71yJrBGq/SqYGMOfgrQ4uAKv2
ivPj5+zbXCWaaCEmR4SYVEpFQOcJIxNggQhM+3jo5LOqA5ix3TCJr5ZCENx7nUSD
U6Oj2EfVwNN3l5FNJOBhYadMfRx4z48qQ1FChPTqEKNF/KiCFjUfyVBS/ixDxG1G
3xfKsvXOr9xw/T8Kopk8+HWSBshvhcxlFTGh9gKA6MTJoreTTcF6tHNANdQdEcGL
mvn8knWVgfqVaMCVnR0wOJYasQV6VV2uP2YDRhly2PQ+doLy+XmNQWviJcScKZ9J
eY9J21V2Tg0PGzOH4K20Imj0vbVasaGq8rQI5k+/DmKVendJzfk05BiwABzU8CWp
jlmHjJf0H4RlzCv2SC/LtzmIeZ39y0WE4VqAnsR5H6PnG0hFcuwNeIVuoOJIJcv6
rtFerEuaces6IO8Y+jXJympc2H5Fr4NevXlrm5h8Qo1vsUHzi/onShwpec8AUUpA
0+PMy0mnI4fO/BUYWZ93mucRRPxu7B4P5lskxLjR2aajAafFWrjd7Gdr1AxF3Hmr
2c0aoz5lx9AweWQksFbFaCpZMDaC1UypmKecbOVAJ3ftGFf1J5JEB/g0wQnp9A0f
HdS1/yhdUZ0=
=p3Ms
-----END PGP SIGNATURE-----

--Apple-Mail=_B277523B-33CE-49E3-B328-0B8F68EED2FC--

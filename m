Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:36229 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbcEBWsS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 18:48:18 -0400
Received: by mail-io0-f193.google.com with SMTP id k129so515099iof.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2016 15:48:18 -0700 (PDT)
Subject: Re: [PATCH 3/6] statx: Ext4: Return enhanced file attributes
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_F605C87F-14B4-4F4A-BE07-9E135F851676"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20160429125759.23636.10635.stgit@warthog.procyon.org.uk>
Date: Mon, 2 May 2016 16:48:13 -0600
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Message-Id: <ABA29DAB-BDD2-44E9-8E2B-AE227A823ECD@dilger.ca>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125759.23636.10635.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_F605C87F-14B4-4F4A-BE07-9E135F851676
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 29, 2016, at 6:57 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Return enhanced file attributes from the Ext4 filesystem.  This =
includes
> the following:
>=20
> (1) The inode creation time (i_crtime) as i_btime, setting =
STATX_BTIME.
>=20
> (2) The inode i_version as st_version if a file with I_VERSION set or =
a
>     directory, setting STATX_VERSION.
>=20
> (3) FS_xxx_FL flags are returned as for ioctl(FS_IOC_GETFLAGS), =
setting
>     STATX_IOC_FLAGS.

I don't see where this is implemented in this patch, and it should be
removed from the commit message to avoid confusion.

> This requires that all ext4 inodes have a getattr call, not just some =
of
> them, so to this end, split the ext4_getattr() function and only call =
part
> of it where appropriate.
>=20
> Example output:
>=20
> 	[root@andromeda ~]# ./samples/statx/test-statx /usr
> 	statx(/usr) =3D 0
> 	results=3D37ef
> 	  Size: 4096            Blocks: 16         IO Block: 4096    =
directory
> 	Device: 08:02           Inode: 1572865     Links: 14
> 	Access: (0755/drwxr-xr-x)  Uid:     0   Gid:     0
> 	Access: 2015-11-03 16:12:30.000000000+0000
> 	Modify: 2013-10-18 15:29:18.000000000+0100
> 	Change: 2013-10-18 15:29:18.000000000+0100
> 	Data version: 2fh
> 	Inode flags: 00000000 (-------- -------- -------- --------)
> 	IO-blocksize: blksize=3D4096

One minor strangeness in this commit message is that the above usage =
example
doesn't include nanoseconds or Birth time for ext4, when this should be
supported for all ext4 filesystems?  Was this example run on an older =
ext3
filesystem (or some filesystem upgraded from ext3)?  Any ext4-formatted =
fs
should have the larger inode size to handle these extra fields.

Also a bit strange that "IO Block: 4096" and "IO-blocksize: =
blksize=3D4096"
is listed twice, but that seems to be an issue with the test-statx tool
and not necessarily the data being returned.

Cheers, Andreas

>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> fs/ext4/ext4.h    |    2 ++
> fs/ext4/file.c    |    2 +-
> fs/ext4/inode.c   |   30 +++++++++++++++++++++++++++---
> fs/ext4/namei.c   |    2 ++
> fs/ext4/symlink.c |    2 ++
> 5 files changed, 34 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 349afebe21ee..2f25eaa63f39 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -2549,6 +2549,8 @@ extern int  ext4_getattr(struct vfsmount *mnt, =
struct dentry *dentry,
> 				struct kstat *stat);
> extern void ext4_evict_inode(struct inode *);
> extern void ext4_clear_inode(struct inode *);
> +extern int  ext4_file_getattr(struct vfsmount *mnt, struct dentry =
*dentry,
> +			      struct kstat *stat);
> extern int  ext4_sync_inode(handle_t *, struct inode *);
> extern void ext4_dirty_inode(struct inode *, int);
> extern int ext4_change_inode_journal_flag(struct inode *, int);
> diff --git a/fs/ext4/file.c b/fs/ext4/file.c
> index fa2208bae2e1..45c7b8644d0e 100644
> --- a/fs/ext4/file.c
> +++ b/fs/ext4/file.c
> @@ -715,7 +715,7 @@ const struct file_operations ext4_file_operations =
=3D {
>=20
> const struct inode_operations ext4_file_inode_operations =3D {
> 	.setattr	=3D ext4_setattr,
> -	.getattr	=3D ext4_getattr,
> +	.getattr	=3D ext4_file_getattr,
> 	.setxattr	=3D generic_setxattr,
> 	.getxattr	=3D generic_getxattr,
> 	.listxattr	=3D ext4_listxattr,
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 981a1fc30eaa..309b6cff8afc 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -5100,11 +5100,35 @@ err_out:
> int ext4_getattr(struct vfsmount *mnt, struct dentry *dentry,
> 		 struct kstat *stat)
> {
> -	struct inode *inode;
> -	unsigned long long delalloc_blocks;
> +	struct inode *inode =3D d_inode(dentry);
> +	struct ext4_inode *raw_inode;
> +	struct ext4_inode_info *ei =3D EXT4_I(inode);
> +
> +	stat->result_mask |=3D STATX_GEN;
> +	stat->gen =3D inode->i_generation;
> +
> +	if (EXT4_FITS_IN_INODE(raw_inode, ei, i_crtime)) {
> +		stat->result_mask |=3D STATX_BTIME;
> +		stat->btime.tv_sec =3D ei->i_crtime.tv_sec;
> +		stat->btime.tv_nsec =3D ei->i_crtime.tv_nsec;
> +	}
> +
> +	if (S_ISDIR(inode->i_mode) || IS_I_VERSION(inode)) {
> +		stat->result_mask |=3D STATX_VERSION;
> +		stat->version =3D inode->i_version;
> +	}
>=20
> -	inode =3D d_inode(dentry);
> 	generic_fillattr(inode, stat);
> +	return 0;
> +}
> +
> +int ext4_file_getattr(struct vfsmount *mnt, struct dentry *dentry,
> +		      struct kstat *stat)
> +{
> +	struct inode *inode =3D dentry->d_inode;
> +	u64 delalloc_blocks;
> +
> +	ext4_getattr(mnt, dentry, stat);
>=20
> 	/*
> 	 * If there is inline data in the inode, the inode will normally =
not
> diff --git a/fs/ext4/namei.c b/fs/ext4/namei.c
> index 48e4b8907826..9b5fdc971e22 100644
> --- a/fs/ext4/namei.c
> +++ b/fs/ext4/namei.c
> @@ -3882,6 +3882,7 @@ const struct inode_operations =
ext4_dir_inode_operations =3D {
> 	.tmpfile	=3D ext4_tmpfile,
> 	.rename2	=3D ext4_rename2,
> 	.setattr	=3D ext4_setattr,
> +	.getattr	=3D ext4_getattr,
> 	.setxattr	=3D generic_setxattr,
> 	.getxattr	=3D generic_getxattr,
> 	.listxattr	=3D ext4_listxattr,
> @@ -3893,6 +3894,7 @@ const struct inode_operations =
ext4_dir_inode_operations =3D {
>=20
> const struct inode_operations ext4_special_inode_operations =3D {
> 	.setattr	=3D ext4_setattr,
> +	.getattr	=3D ext4_getattr,
> 	.setxattr	=3D generic_setxattr,
> 	.getxattr	=3D generic_getxattr,
> 	.listxattr	=3D ext4_listxattr,
> diff --git a/fs/ext4/symlink.c b/fs/ext4/symlink.c
> index 75ed5c2f0c16..54015f3d7516 100644
> --- a/fs/ext4/symlink.c
> +++ b/fs/ext4/symlink.c
> @@ -105,6 +105,7 @@ const struct inode_operations =
ext4_symlink_inode_operations =3D {
> 	.readlink	=3D generic_readlink,
> 	.get_link	=3D page_get_link,
> 	.setattr	=3D ext4_setattr,
> +	.getattr	=3D ext4_getattr,
> 	.setxattr	=3D generic_setxattr,
> 	.getxattr	=3D generic_getxattr,
> 	.listxattr	=3D ext4_listxattr,
> @@ -115,6 +116,7 @@ const struct inode_operations =
ext4_fast_symlink_inode_operations =3D {
> 	.readlink	=3D generic_readlink,
> 	.get_link	=3D simple_get_link,
> 	.setattr	=3D ext4_setattr,
> +	.getattr	=3D ext4_getattr,
> 	.setxattr	=3D generic_setxattr,
> 	.getxattr	=3D generic_getxattr,
> 	.listxattr	=3D ext4_listxattr,
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_F605C87F-14B4-4F4A-BE07-9E135F851676
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVyfZLXKl2rkXzB/gAQiXqw//bEWApBDx2WpepUjFgFNtfiUsOhCzwSvN
Uj2aRJ4aE4F+H8JLw+BMRKlWwgLfYQuFklFoIhIG6mQK5hZqCvhPvnUUJXrbHP8l
rGzymQB7YAKODiYZOsYYOl2XG+blKYBGUVEhRFp4yFOqgFNTbW1/NlTixg71d2M2
UeQHgoexYb8BMV0OhqyGQ90Oi1lBvkJaSRmD6sl+4VQxSabkCVr3MB+M9IqvjB8w
HiVkdLGDu17U3cihLySX6Ml5kjOKhFhfXMawrkW9wAhdvT2DoFEvWhDCzGC1T11H
AGhPzdOhzpgzpxFTyaR6T6Eu2BW+dUZijDOEeuMxqtzpFsNT10PsU+45AZaMsDP2
6OcotT5X8SVVGY13G//wBOG6U0cqXlmlJBPknyAC9fnhirS2iXIVJ+rOGHj3KqW2
/BaO1rW2aZOw11ibVfS3URKG3xZT/TMv/U03DHVA/RM8oBqVTTgnyt8GKLv9YIw0
QA4dbM6aK5y/275KO4STwPUBkTiNXGWbZ0S1xxcr0ziU+afeV9+rIiBXJbD2AXPY
KTI4S4p0F1cDhVa93Ec2R4nsDqMdNyW8m++o4ZP72TETxhSSp+Lv24LswX721LKS
72cv85GMXi726Oz/L5eIrN7S6sRsasI9zMmOGJ0KWIv1v8YJy20Yklp3GNQx5M5I
wKREMNCcQQk=
=VDYy
-----END PGP SIGNATURE-----

--Apple-Mail=_F605C87F-14B4-4F4A-BE07-9E135F851676--

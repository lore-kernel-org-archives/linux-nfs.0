Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:34357 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269AbcEBWs4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 18:48:56 -0400
Received: by mail-io0-f195.google.com with SMTP id d62so524257iof.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 May 2016 15:48:55 -0700 (PDT)
Subject: Re: [PATCH 4/6] statx: NFS: Return enhanced file attributes
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: multipart/signed; boundary="Apple-Mail=_C94E8197-945C-4983-883F-2667C3339B99"; protocol="application/pgp-signature"; micalg=pgp-sha256
From: Andreas Dilger <adilger@dilger.ca>
In-Reply-To: <20160429125806.23636.51590.stgit@warthog.procyon.org.uk>
Date: Mon, 2 May 2016 16:48:50 -0600
Cc: linux-fsdevel@vger.kernel.org, linux-afs@vger.kernel.org,
        linux-nfs@vger.kernel.org, samba-technical@lists.samba.org,
        linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org
Message-Id: <CA657A25-B00C-47BC-B9BB-DF6C22B6D5CF@dilger.ca>
References: <20160429125736.23636.47874.stgit@warthog.procyon.org.uk> <20160429125806.23636.51590.stgit@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail=_C94E8197-945C-4983-883F-2667C3339B99
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

On Apr 29, 2016, at 6:58 AM, David Howells <dhowells@redhat.com> wrote:
>=20
> Return enhanced file atrributes from the NFS filesystem.  This =
includes the
> following:
>=20
> (1) The change attribute as st_version if NFSv4.
>=20
> (2) STATX_INFO_AUTOMOUNT and STATX_INFO_FABRICATED are set on referral =
or
>     submount directories that are automounted upon.  NFS shows one
>     directory with a different FSID, but the local filesystem has two: =
the
>     mountpoint directory and the root of the filesystem mounted upon =
it.
>=20
> (3) STATX_INFO_REMOTE is set on files acquired over NFS.
>=20
> (4) STATX_IOC_FLAGS is set and if the atime is unavailable on a file,
>     st_ioc_flags will have FL_NOATIME_FL set in it.

This is not implemented in this patch, and should removed from the =
commit
message.  The generic_fillattr() change in [1/6] will clear the =
STATX_ATIME
flag if IS_NOATIME() is true, so maybe that is enough for what you =
intended?

Cheers, Andreas

> Furthermore, what nfs_getattr() does can be controlled as follows:
>=20
> (1) If AT_NO_ATTR_SYNC is indicated then this will suppress the =
flushing
>     of outstanding writes and the rereading of the inode's attributes =
with
>     the server as detailed below.
>=20
> (2) Otherwise:
>=20
>     (a) If AT_FORCE_ATTR_SYNC is indicated, or mtime, ctime or
>     	 data_version (NFSv4 only) are requested then the outstanding
>     	 writes will be written to the server first.
>=20
>     (b) The inode's attributes will be reread from the server:
>=20
>     	 (i) if AT_FORCE_ATTR_SYNC is indicated;
>=20
>        (ii) if atime is requested (and atime updating is not =
suppressed by
>     	     a mount flag); or
>=20
>       (iii) if the cached attributes have expired;
>=20
> If the inode isn't synchronised, then the cached attributes will be =
used -
> even if expired - without reference to the server.
>=20
> Example output:
>=20
> 	[root@andromeda ~]# ./samples/statx/test-statx /warthog/
> 	statx(/warthog/) =3D 0
> 	results=3D37ef
> 	  Size: 4096            Blocks: 8          IO Block: 1048576  =
directory
> 	Device: 00:26           Inode: 2           Links: 122
> 	Access: (3777/drwxrwxrwx)  Uid:     0   Gid:  4041
> 	Access: 2015-10-30 16:15:41.730925545+0000
> 	Modify: 2015-10-07 10:33:19.896108112+0100
> 	Change: 2015-10-07 10:33:19.896108112+0100
> 	Data version: 5614e6df35698650h
> 	Inode flags: 00000000 (-------- -------- -------- --------)
> 	Information: 00000010 (-------- -------- -------- ---r----)
> 	IO-blocksize: blksize=3D1048576
>=20
> Note that the NFS4 protocol potentially provides a creation time that =
could
> be passed through this interface and system, hidden and archive values =
that
> could be passed as IOC flags.  There is also a backup time that could =
be
> added.
>=20
> Signed-off-by: David Howells <dhowells@redhat.com>
> ---
>=20
> fs/nfs/inode.c |   41 ++++++++++++++++++++++++++++++++++-------
> 1 file changed, 34 insertions(+), 7 deletions(-)
>=20
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 738c84a42eb0..8637236bca0c 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -655,12 +655,23 @@ static bool nfs_need_revalidate_inode(struct =
inode *inode)
> int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct =
kstat *stat)
> {
> 	struct inode *inode =3D d_inode(dentry);
> -	int need_atime =3D NFS_I(inode)->cache_validity & =
NFS_INO_INVALID_ATIME;
> +	bool force_sync =3D stat->query_flags & AT_FORCE_ATTR_SYNC;
> +	bool suppress_sync =3D stat->query_flags & AT_NO_ATTR_SYNC;
> +	bool need_atime =3D NFS_I(inode)->cache_validity & =
NFS_INO_INVALID_ATIME;
> 	int err =3D 0;
>=20
> 	trace_nfs_getattr_enter(inode);
> -	/* Flush out writes to the server in order to update c/mtime.  =
*/
> -	if (S_ISREG(inode->i_mode)) {
> +
> +	if (NFS_SERVER(inode)->nfs_client->rpc_ops->version < 4)
> +		stat->request_mask &=3D ~STATX_VERSION;
> +
> +	/* Flush out writes to the server in order to update c/mtime or =
data
> +	 * version if the user wants them.
> +	 */
> +	if (S_ISREG(inode->i_mode) && !suppress_sync &&
> +	    (force_sync || (stat->request_mask &
> +			    (STATX_MTIME | STATX_CTIME | =
STATX_VERSION)))
> +	    ) {
> 		inode_lock(inode);
> 		err =3D nfs_sync_inode(inode);
> 		inode_unlock(inode);
> @@ -677,11 +688,13 @@ int nfs_getattr(struct vfsmount *mnt, struct =
dentry *dentry, struct kstat *stat)
> 	 *  - NFS never sets MS_NOATIME or MS_NODIRATIME so there is
> 	 *    no point in checking those.
> 	 */
> - 	if ((mnt->mnt_flags & MNT_NOATIME) ||
> - 	    ((mnt->mnt_flags & MNT_NODIRATIME) && =
S_ISDIR(inode->i_mode)))
> -		need_atime =3D 0;
> +	if (!(stat->request_mask & STATX_ATIME) ||
> +	    (mnt->mnt_flags & MNT_NOATIME) ||
> +	    ((mnt->mnt_flags & MNT_NODIRATIME) && =
S_ISDIR(inode->i_mode)))
> +		need_atime =3D false;
>=20
> -	if (need_atime || nfs_need_revalidate_inode(inode)) {
> +	if (!suppress_sync &&
> +	    (force_sync || need_atime || =
nfs_need_revalidate_inode(inode))) {
> 		struct nfs_server *server =3D NFS_SERVER(inode);
>=20
> 		if (server->caps & NFS_CAP_READDIRPLUS)
> @@ -694,6 +707,20 @@ int nfs_getattr(struct vfsmount *mnt, struct =
dentry *dentry, struct kstat *stat)
> 		if (S_ISDIR(inode->i_mode))
> 			stat->blksize =3D NFS_SERVER(inode)->dtsize;
> 	}
> +
> +	generic_fillattr(inode, stat);
> +	stat->ino =3D nfs_compat_user_ino64(NFS_FILEID(inode));
> +
> +	if (stat->request_mask & STATX_VERSION) {
> +		stat->version =3D inode->i_version;
> +		stat->result_mask |=3D STATX_VERSION;
> +	}
> +
> +	if (IS_AUTOMOUNT(inode))
> +		stat->information |=3D STATX_INFO_FABRICATED;
> +
> +	stat->information |=3D STATX_INFO_REMOTE;
> +
> out:
> 	trace_nfs_getattr_exit(inode, err);
> 	return err;
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


Cheers, Andreas






--Apple-Mail=_C94E8197-945C-4983-883F-2667C3339B99
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIVAwUBVyfZU3Kl2rkXzB/gAQg1FQ/9G+MJXA56XOofCpLrTnAMUP0qGU9WpyvE
NsBJbAouHFbI+jA35V4tOS6cp8vtl8njNl0QLUxNR9AupUk8F2oB1JzO7vLtU7yw
L1w2uybtO7jIAZIp+aICUclaTjEPa8FK9CVfRoTEjJL9utCmuMoFiWd2wEcwpEAa
vqGCJWYf2ERhelP/rKxyD3yrtuAEl+7DHMKtwHITUnkEr/eQH8FatO1cLPe9ULJV
JX1P74fTnBgwTGTVddcsbXsCeuoHL6lpzh5iJZNhhJpq+AVAQcrHzGxNsIiFTfmj
JCe+ovH+SSVvwe0HleGE3HYuPxXojXAtuI9FRpP+Wn9fsrw0S/cUMpsVajMk9nhz
/i4TGJV3rnFwvxGNgHnRAy40NXmyJgHzw0QhimZcNqVbcgZhMEqPENqt5eLQbB97
4pDQoqOXqMb26n6MQdMz9OZt0mDtOHldJuxy1ZEd5FTMuzPZ4E+lOerqGxOylQBF
476reffwmek/EBercN+Xayjt5xH1qp05QVndd+CO/07LrGoW4u9GyFft2tGfz9Yj
BNwRDSfr7hZIcUIafgMfxVOqcXwaRkIpRcJAv3nOjUQ/6wd888+LdVxr9VHh9ukb
VPqyg1dV2K54LBP3KMba8g+VOEDmaTP/UDP0eGH+XPCDpTWFijl8qbbYRTrPtgY9
EhwvHVxYY1o=
=eAGq
-----END PGP SIGNATURE-----

--Apple-Mail=_C94E8197-945C-4983-883F-2667C3339B99--

From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 11:15:21 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E57B@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERvzz-0007Kp-Qz
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:15:43 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ERvzy-00060o-Fn
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:15:43 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

this is going in the right direction.

should we quickly look at other test cases?  what return code should/do
you get when you try to rename a directory onto a target directory that
still has stuff in it?

have you tested both the file onto directory and directory onto file
cases?


> ty den 18.10.2005 klokka 12:57 (-0400) skreiv Peter Staubach:
> > However, renaming one directory to another directory, when=20
> the target
> > directory is "empty", should not fail.
>=20
> Ah... I see now. OK, so when I rewrite the test case to the attached
> code then it does indeed succeed.
>=20
> The following patch should do the right thing then.
>=20
> Cheers,
>   Trond
>=20
> NFS: Fix rename of directory onto empty directory
>=20
>  If someone tries to rename a directory onto an empty directory, we
>  currently fail and return EBUSY.
>  This patch ensures that we try the rename if both source and target
>  are directories, and that we fail with a correct error of EISDIR if
>  the source is not a directory.
>=20
>  Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>  fs/nfs/dir.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
>=20
> Index: linux-2.6/fs/nfs/dir.c
> =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/fs/nfs/dir.c
> +++ linux-2.6/fs/nfs/dir.c
> @@ -1511,9 +1511,11 @@ static int nfs_rename(struct inode *old_
>  	 */
>  	if (!new_inode)
>  		goto go_ahead;
> -	if (S_ISDIR(new_inode->i_mode))
> -		goto out;
> -	else if (atomic_read(&new_dentry->d_count) > 2) {
> +	if (S_ISDIR(new_inode->i_mode)) {
> +		error =3D -EISDIR;
> +		if (!S_ISDIR(old_inode->i_mode))
> +			goto out;
> +	} else if (atomic_read(&new_dentry->d_count) > 2) {
>  		int err;
>  		/* copy the target dentry's name */
>  		dentry =3D d_alloc(new_dentry->d_parent,
>=20
>=20


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

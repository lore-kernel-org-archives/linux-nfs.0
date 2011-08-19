Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from atreides.gradator.net ([212.85.155.42]:45297 "EHLO
	atreides.gradator.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244Ab1HSXKZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 19:10:25 -0400
Date: Sat, 20 Aug 2011 01:03:44 +0200
From: Sylvain Rochet <gradator@gradator.net>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: Sylvain Rochet <gradator@gradator.net>
Message-ID: <20110819230344.GA24784@gradator.net>
References: <20101018223540.GA20730@gradator.net>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4Ckj6UjgE2iN1+kY"
In-Reply-To: <20101018223540.GA20730@gradator.net>
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--4Ckj6UjgE2iN1+kY
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Oct 19, 2010 at 12:35:40AM +0200, Sylvain Rochet wrote:
>=20
> ... upgraded to 2.6.33.5, then 2.6.33.7, finally to 2.6.35.7, and I=20
> always end up with the same ending, it seems inotify can miss some VFS=20
> events from time to time.

I finally find out why.

The NFS server does not always know the name of the modified file, if=20
the modified inode was cleared from the VFS cache fsnotify does not know=20
as well the filename then inotify child events on directories are=20
silently tossed.

Easy way to reproduce:

Add a few printk debug (here it only works if /data is the NFS export):

--- begin//fs/nfsd/vfs.c        2011-07-22 04:17:23.000000000 +0200
+++ linux-3.0/fs/nfsd/vfs.c     2011-07-30 03:18:17.837560809 +0200
@@ -975,6 +975,8 @@
        inode =3D dentry->d_inode;
        exp   =3D fhp->fh_export;
=20
+       printk("nfsd write inode=3D%ld name=3D%s\n", inode->i_ino, dentry->=
d_name.name);
+
        /*
         * Request sync writes if
         *  -   the sync export option has been set, or

diff -Nru begin//include/linux/fsnotify.h linux-3.0/include/linux/fsnotify.h
--- begin//include/linux/fsnotify.h     2011-07-22 04:17:23.000000000 +0200
+++ linux-3.0/include/linux/fsnotify.h  2011-07-30 03:07:00.330239062 +0200
@@ -216,8 +232,15 @@
                mask |=3D FS_ISDIR;
=20
        if (!(file->f_mode & FMODE_NONOTIFY)) {
+               if( !strcmp(path->mnt->mnt_mountpoint->d_name.name, "data")=
 )
+                       printk("fsnotify modify inode=3D%ld name=3D%s\n", i=
node->i_ino, file->f_dentry->d_name.name);
                fsnotify_parent(path, NULL, mask);
                fsnotify(inode, mask, path, FSNOTIFY_EVENT_PATH, NULL, 0);
+       } else {
+               if( !strcmp(path->mnt->mnt_mountpoint->d_name.name, "data")=
 )
+                       printk("fsnotify modify-nonotify inode=3D%ld name=
=3D%s\n", inode->i_ino, file->f_dentry->d_name.name);
        }
 }


On the NFS client, open a fd and send some data:

# exec 1> test
# ls -la
#=20

On the NFS server, check the kern log:

Aug 20 00:57:44 inotifydebug kernel: nfsd write inode=3D13 name=3Dtest
Aug 20 00:57:44 inotifydebug kernel: fsnotify modify inode=3D13 name=3Dtest

Everything goes well.

Now, clear the VFS cache on the NFS server:

# echo 3 > /proc/sys/vm/drop_caches=20

On the NFS client, send some data to the fd:

# ls -la
#=20

On the NFS server, check the kern log:

Aug 20 00:58:56 inotifydebug kernel: nfsd write inode=3D13 name=3D
Aug 20 00:58:56 inotifydebug kernel: fsnotify modify inode=3D13 name=3D

The filename is lost, fsnotify does not know the filename anymore,=20
therefore inotify cannot send event about a modified file in a watched=20
directory.

End of the story.

I guess this is almost impossible to fix this fsnotify bug, this is due=20
by the fact that NFS use inode as file identifiers, so in some case this=20
is impossible to know the modified filepath, and therefore impossible to=20
match the file event to the directory watch.

Kind regards,
Sylvain

--4Ckj6UjgE2iN1+kY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk5O69AACgkQDFub3qtEsS8zPgCfe5WwDzEh1Vxi3omGs8i6qx9J
UB0AoIUPMsJ9f/vsK/kEwHLqcoVr978l
=XDSa
-----END PGP SIGNATURE-----

--4Ckj6UjgE2iN1+kY--

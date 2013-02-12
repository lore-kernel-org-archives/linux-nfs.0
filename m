Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:55976 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760951Ab3BLAi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 19:38:28 -0500
Date: Tue, 12 Feb 2013 11:38:13 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: More fun with unmounting ESTALE directories.
Message-ID: <20130212113813.427b8e05@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/qjt59wfNdkJqZ9jGiQHq8QL"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/qjt59wfNdkJqZ9jGiQHq8QL
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


I've been exploring difficulties with unmounting stale directories and
discovered another bug.

If I:

SERVER:  mkdir /foo/bar  #and make sure it is exported
CLIENT:  mount -o vers=3D4 server:/foo/bar /mnt
SERVER:  rm -r /foo
CLIENT:  > /mnt/baz # gets an error of course
CLIENT:  ls -l /mnt # error again
CLIENT:  umount /mnt

The result of that last command is:

/mnt was not found in /proc/mounts
/mnt was not found in /proc/mounts

Strange?

cat /proc/mounts

.....
10.0.2.2://foo/bar /mnt\040(deleted) nfs4 rw,relatime,vers=3D4,rsize=3D1048=
576,wsize=3D1048576,namlen=3D255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,s=
ec=3Dsys,clientaddr=3D10.0.2.15,minorversion=3D0,local_lock=3Dnone,addr=3D1=
0.0.2.2 0 0
....

Notice the "\040(deleted)".

NFS has unhashed that directory because it is obviously bad, and d_path()
notices and adds " (deleted)".

Now I might be able to argue that NFS shouldn't be unhashing a directory th=
at
is a mountpoint - it certainly seems strange behaviour.

But I think I can more strongly argue that /proc/mounts shouldn't be showing
the mounted directory, but instead the directory that it is mounted on.
Obviously these both have the same name so it shouldn't matter ... except
that here is a case where it does.

I "fixed" it with

--- a/fs/proc_namespace.c
+++ b/fs/proc_namespace.c
@@ -93,7 +93,7 @@ static int show_vfsmnt(struct seq_file *m, struct vfsmoun=
t *mnt)
 {
 	struct mount *r =3D real_mount(mnt);
 	int err =3D 0;
-	struct path mnt_path =3D { .dentry =3D mnt->mnt_root, .mnt =3D mnt };
+	struct path mnt_path =3D { .dentry =3D r->mnt_mountpoint, .mnt =3D &(r->m=
nt_parent)->mnt };
 	struct super_block *sb =3D mnt_path.dentry->d_sb;
=20
 	if (sb->s_op->show_devname) {

though I suspect that isn't safe and needs some locking.

Probably both should be fixed:  NFS should not invalidate any mounted
directory, and show_vfsmnt() should report the mointpoint, not the mounted
directory.

I can't figure out any way to get NFS to not invalidate the mounted directo=
ry.
I think it happens in nfs_lookup_revalidate() when it calls d_drop(), but I
don't know how to tell if a given dentry is a mnt_root for any mountpoint.

Suggestions?  Thoughts?

Thanks,
NeilBrown


--Sig_/qjt59wfNdkJqZ9jGiQHq8QL
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBURmO9Tnsnt1WYoG5AQK0Ew/9EQuyRZHVLXpuWJuaxKhgTYZo+DTi2b49
BFkSA6k9mK07ZT1ciP3GXLjLH9QCFfX03B/37BDElE/AXPBDIklyvvkXpHfr/2Iu
HEwwXYBBesvs36ztaM8UrLj3zA2DOonUwy+w1gXUiRo1spGmBQrSqRfV1vJnWTD6
ep5MM0mTeuAH7kcieV3kDKHQdCxVyxzG5Kx97M1k8sYo3UmxKY5FpqbwLUGE3dZD
HMXbK6TpfmISKDxb9svGe08mNz8GAaFAwuM+TC636vm06dM5G10hQXeK3oerhtmC
p29x86RshFUIU4H6QrCS+TmtZpIwCUYjFeKipOjI2OiDJlzKVti5tXBYJ0OrjU5s
zgLuiLQCwA2PHSSBhGkR2OtROdtYn5QELSjMAnz+FUolAl6nc396EmN2zpye4ytV
rH/1qpJQp5hLt/ODyGmaMLLciAi8OkGsFRcuMozCsrBt8iQRq8CbNHEM1XUm5xPb
UZ3iJWJbVmBbCx+hhw/kY4h8OpiI6UWiVmQVIH6y715ultSUTf1qCyM/WW8+h+TL
HtG/VRG5YiJi6RtmcMwyEDkmdTaD9jG+Xn7AaQBAmZvuS7UzDReGhgu0ZNjVNcf9
M+BZRTswiw/zTi9Q4MMAYce5Gm7RuCQ6odyBLIYV/OeGQ4ij39BapcHX93Qo7CEz
I9ozZ1wY51Q=
=1cJY
-----END PGP SIGNATURE-----

--Sig_/qjt59wfNdkJqZ9jGiQHq8QL--

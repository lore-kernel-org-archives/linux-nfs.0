Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:39356 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161781AbbKFW5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Nov 2015 17:57:19 -0500
Date: Fri, 6 Nov 2015 23:57:15 +0100
From: William Dauchy <william@gandi.net>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Subject: strange behavior with nfsv3 using linux v4.1
Message-ID: <20151106225715.GH12546@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKijDXBCEH69PxaN"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--gKijDXBCEH69PxaN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I am seeing strange behaviors with a single nfsv3 mount on linux
v4.1.x. I first started to see two kworker in D state while I was not
doing anything. The server is an opensolaris nfs server.

If I try to get more info I am seeing getattr loop as follow:

echo 65535 > /proc/sys/sunrpc/nfs_debug

NFS call  getattr
NFS reply getattr: 0
NFS: nfs_update_inode(0:15/22630 fh_crc=3D0x1df1ef00 ct=3D1 info=3D0x27e7f)
NFS: (0:15/22630) revalidation complete
NFS: nfs_lookup_revalidate(x86_64-linux-gnu/libc-2.19.so) is valid
NFS: permission(0:15/22630), mask=3D0x24, res=3D0
NFS: open file(x86_64-linux-gnu/libc-2.19.so)
NFS: dentry_delete(x86_64-linux-gnu/libc.so.6, 6808cc)
NFS: read(x86_64-linux-gnu/libc-2.19.so, 832@0)
NFS: mmap(x86_64-linux-gnu/libc-2.19.so)
NFS: mmap(x86_64-linux-gnu/libc-2.19.so)
NFS: flush(x86_64-linux-gnu/libc-2.19.so)
NFS: permission(0:15/4), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(/etc) is valid
NFS: permission(0:15/12), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(etc/ld.so.nohwcap) is valid
NFS: permission(0:15/4), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(/lib) is valid
NFS: permission(0:15/14), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(lib/x86_64-linux-gnu) is valid
NFS: permission(0:15/1178), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(x86_64-linux-gnu/libpthread.so.0) is valid
NFS: permission(0:15/1178), mask=3D0x1, res=3D0
NFS: revalidating (0:15/22644)
NFS call  getattr
NFS reply getattr: 0
NFS: nfs_update_inode(0:15/22644 fh_crc=3D0x9a566cc1 ct=3D1 info=3D0x27e7f)
NFS: (0:15/22644) revalidation complete
NFS: nfs_lookup_revalidate(x86_64-linux-gnu/libpthread-2.19.so) is valid
NFS: permission(0:15/22644), mask=3D0x24, res=3D0
NFS: open file(x86_64-linux-gnu/libpthread-2.19.so)
NFS: dentry_delete(x86_64-linux-gnu/libpthread.so.0, 6808cc)
NFS: read(x86_64-linux-gnu/libpthread-2.19.so, 832@0)
NFS: mmap(x86_64-linux-gnu/libpthread-2.19.so)
NFS: mmap(x86_64-linux-gnu/libpthread-2.19.so)
NFS: flush(x86_64-linux-gnu/libpthread-2.19.so)
NFS: release(etc/ld.so.cache)
NFS: dentry_delete(etc/ld.so.cache, 4808cc)
NFS: permission(0:15/4), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(/root) is valid
NFS: permission(0:15/20), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(root/.config) is valid
NFS: permission(0:15/4), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(/etc) is valid
NFS: permission(0:15/12), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(etc/terminal-colors.d) is valid
NFS: permission(0:15/4), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(/dev) is valid
NFS: permission(0:15/4), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(/var) is valid
NFS: permission(0:15/27), mask=3D0x81, res=3D0
NFS: nfs_lookup_revalidate(var/lib) is valid
NFS: permission(0:15/19882), mask=3D0x81, res=3D0
NFS: revalidating (0:15/19990)
[...]


Do you have some hints in order to help debug this issue?
If I reboot using my older v3.14.x with same config, I don't have that
behavior.

Best regards,
--=20
William

--gKijDXBCEH69PxaN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlY9MEsACgkQ1I6eqOUidQH+XACgu7O7JIRyey7mQDTqz/6/vqv2
nMkAn1rNcMT5LiIW4VnjjoCBvqKUMxHC
=XWNn
-----END PGP SIGNATURE-----

--gKijDXBCEH69PxaN--

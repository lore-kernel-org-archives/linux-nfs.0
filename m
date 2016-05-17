Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35702 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751427AbcEQNgn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 09:36:43 -0400
Date: Tue, 17 May 2016 14:36:31 +0100
From: Ben Hutchings <ben@decadent.org.uk>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Message-ID: <20160517133631.GF7555@decadent.org.uk>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="ZPDwMsyfds7q4mrK"
Subject: [PATCH] fs: Add MODULE_SOFTDEP declarations for hard-coded crypto
 drivers
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--ZPDwMsyfds7q4mrK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

This helps initramfs builders and other tools to find the full
dependencies of a module.

References: https://bugs.debian.org/819725
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
--- a/fs/btrfs/super.c
+++ b/fs/btrfs/super.c
@@ -2456,3 +2456,4 @@ late_initcall(init_btrfs_fs);
 module_exit(exit_btrfs_fs)
=20
 MODULE_LICENSE("GPL");
+MODULE_SOFTDEP("pre: crypto-crc32c");
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1373,5 +1373,13 @@ MODULE_DESCRIPTION
     ("VFS to access servers complying with the SNIA CIFS Specification "
      "e.g. Samba and Windows");
 MODULE_VERSION(CIFS_VERSION);
+
+#ifdef CONFIG_CIFS_SMB2
+#define CIFS_SMB2_EXTRA_SOFTDEPS " crypto-aes crypto-cmac crypto-sha256"
+#else
+#define CIFS_SMB2_EXTRA_SOFTDEPS ""
+#endif
+MODULE_SOFTDEP("pre: crypto-arc4 crypto-des crypto-ecb crypto-hmac crypto-=
md4 crypto-md5" CIFS_SMB2_EXTRA_SOFTDEPS);
+
 module_init(init_cifs)
 module_exit(exit_cifs)
--- a/fs/crypto/crypto.c
+++ b/fs/crypto/crypto.c
@@ -566,3 +566,4 @@ static void __exit fscrypt_exit(void)
 module_exit(fscrypt_exit);
=20
 MODULE_LICENSE("GPL");
+MODULE_SOFTDEP("pre: crypto-aes crypto-ecb");
--- a/fs/ext4/super.c
+++ b/fs/ext4/super.c
@@ -5441,5 +5441,13 @@ static void __exit ext4_exit_fs(void)
 MODULE_AUTHOR("Remy Card, Stephen Tweedie, Andrew Morton, Andreas Dilger, =
Theodore Ts'o and others");
 MODULE_DESCRIPTION("Fourth Extended Filesystem");
 MODULE_LICENSE("GPL");
+
+#ifdef CONFIG_EXT4_FS_ENCRYPTION
+#define EXT4_ENC_EXTRA_SOFTDEPS " crypto-aes crypto-ecb"
+#else
+#define EXT4_ENC_EXTRA_SOFTDEPS ""
+#endif
+MODULE_SOFTDEP("pre: crypto-crc32c" EXT4_ENC_EXTRA_SOFTDEPS);
+
 module_init(ext4_init_fs)
 module_exit(ext4_exit_fs)
--- a/fs/f2fs/super.c
+++ b/fs/f2fs/super.c
@@ -1742,3 +1742,4 @@ module_exit(exit_f2fs_fs)
 MODULE_AUTHOR("Samsung Electronics's Praesto Team");
 MODULE_DESCRIPTION("Flash Friendly File System");
 MODULE_LICENSE("GPL");
+MODULE_SOFTDEP("pre: crypto-crc32c");
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2716,6 +2716,7 @@ static void __exit journal_exit(void)
 }
=20
 MODULE_LICENSE("GPL");
+MODULE_SOFTDEP("pre: crypto-crc32c");
 module_init(journal_init);
 module_exit(journal_exit);
=20
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1314,5 +1314,8 @@ static void __exit exit_nfsd(void)
=20
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
+#ifdef CONFIG_NFSD_V4
+MODULE_SOFTDEP("pre: crypto-md5");
+#endif
 module_init(init_nfsd)
 module_exit(exit_nfsd)

--ZPDwMsyfds7q4mrK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBVzseX+e/yOyVhhEJAQo9nxAAkw5+eR9vhbXV9h0ooS/CdB5uAhj7rn6F
UjYndD41cQoC3P/GsjwhQMqITpGh6eiNPszz4aq5fQPhLhRCl2u6v2hBF84R2RaE
mRzBQ4TngtMo5QjMTps1J0QW6x8giQg6wLz+xpnBrMDl96g/TypERSrh6LO9K0sf
If3fUAFSv2WFgfs3TnBWA5jmilO5qtqtvgJazUbhT1414/o54UwQb6Korv5tnqkh
ltJIsF03l9378CMUgKBQMzDnGpRUXHM2/TyEuc+x3jZVU+yIbtxUiANL3igIVQ2/
4xeENC1zRCanDxF7yZtYfsVrr22HAFuEbxoJ/nrhqlVZZ1451/KFMIo6vo/z+1rR
wLq2PyRkqtnPyu5qIsByly2a/jUphZ/mbJAY8YJA+5Ny2LzNwgTaR7adhlENk55k
CUbVLM+LJOPYjYyJ1oLH2w42zGu+ow4QZA5JRfdPy5Y6R3Vvsq5egHCVI8gGiYoD
IZSJGyHG7G+R6574Cjd9vKuNse0x9RBNGmVLzAf3blURbdprCX/UCrorT/1T8F4j
53XvDrcILMixiYXRW4VSIau1gSxmc7Gmr0tKicilCcM6ehLtaNezYTkdTAj2fxOc
S+PGyhKoGK0V/cMsFW9X+jGg4LzWeK6ED9oEqStTUJYUr1cVxs4tTDVfJjrTIWxF
6LmFlbaD9Ao=
=08zK
-----END PGP SIGNATURE-----

--ZPDwMsyfds7q4mrK--

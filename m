Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:57872 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752630Ab2HIB5X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 21:57:23 -0400
Date: Thu, 9 Aug 2012 11:57:06 +1000
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@zeniv.linux.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
Subject: [PATCH] VFS: d_obtain_alias needs to use "/" as default name.
Message-ID: <20120809115706.260a1e4b@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aUhv.Dbm7uu3iPFz_s_lI_v"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aUhv.Dbm7uu3iPFz_s_lI_v
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


NFS appears to use d_obtain_alias() to create the root dentry rather
than d_make_root.  This can cause 'prepend_path()' to complain that the
root has a weird name if an NFS filesystem is lazily unmounted.
e.g. if "/mnt" is an NFS mount then

 { cd /mnt; umount -l /mnt ; ls -l /proc/self/cwd; }

will cause a WARN message like
   WARNING: at /home/git/linux/fs/dcache.c:2624 prepend_path+0x1d7/0x1e0()
   ...
   Root dentry has weird name <>

to appear in kernel logs.

So change d_obtain_alias() to use "/" rather than "" as the anonymous
name.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/dcache.c b/fs/dcache.c
index 8086636..c959e41 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1579,7 +1579,7 @@ EXPORT_SYMBOL(d_find_any_alias);
  */
 struct dentry *d_obtain_alias(struct inode *inode)
 {
-	static const struct qstr anonstring =3D { .name =3D "" };
+	static const struct qstr anonstring =3D QSTR_INIT("/", 1);
 	struct dentry *tmp;
 	struct dentry *res;
=20

--Sig_/aUhv.Dbm7uu3iPFz_s_lI_v
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUCMY8jnsnt1WYoG5AQIJvA/9FgTPiFxUp/e3Jd971qIK2IYynyDGMSKU
g2R7iyZp1qPEH4A0qDvd7/B9asWlLuhaNOQjXPPyWCKdc6q12UREnw0bluJDfetI
FeM+oKU+kzytuvAE+pVixtsS+A6vE7DLV4uRW4fYSfdhZoWcQ3UQwvitdAQOQcV9
fWySE5oBRmp1bmb2MDICM7+BtvJGBW4NyHjdHc/oLmWgCeb1naEilAraralpqCpA
fnOyvl8VYJ5qIm7lyOUdqEMxCN9wkapmtKnAQGciCXQtbjtUPK3CDVqfNytykWpw
VWzTTqA7p5vws6i6eQYw22iY1laDhak+4GDfFhzzhpFDnGz/OUyUt7SGopqVO9RL
TVVkiHeIDaELYCvEhC6+TLfaz8SNJA1Tg2Fp0HpWylYu7RrIG9XWJ4vk+tAZ6VcT
Grn/WuDknzB0k9ykk8qVeMkK90RBCuaMx+cqFVBsyxb/kndxum8PfB6Lo6UYUd74
UqAxvCtCCtDK4sE/zunxe1P6tft2C9j6O1GFUM4mzjGJcNku/Y+YvwIyWRCDD+Bo
bUrP/ZNie7LV+60ckEEAvc+ZaNj7lwn+1A4CWipdBpiW+XDL2eN6Ey+dkNbh9SyA
KMKd/L+272s4yCcwkQNRppST8bM45e5Gd4vX9s4+kvgBeSzHpimNlPouUoBm9CKh
JqV9s/VptgA=
=VhnA
-----END PGP SIGNATURE-----

--Sig_/aUhv.Dbm7uu3iPFz_s_lI_v--

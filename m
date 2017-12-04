Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53318 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752917AbdLDD11 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Dec 2017 22:27:27 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna.Schumaker@Netapp.com, Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 04 Dec 2017 14:27:14 +1100
Cc: lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: [PATCH] fhandle: avoid -EINVAL if requested size is too large.
In-Reply-To: <87po7zv62h.fsf@notabene.neil.brown.name>
References: <87po7zv62h.fsf@notabene.neil.brown.name>
Message-ID: <87k1y3tbot.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Lennart Poettering observes that if the newly increased
MAX_HANDLE_SZ is exported to user space, and then used in an
application running on an old kernel, name_to_handle_at() will
report -EINVAL, which is unhelpful and inconsistent with
the documentation.

So:
 1/ add a comment making it clear that the new value must
    not be exposed to user-space.
 2/ remove the completely unnecessary restriction on the size
    of buffer provided by the application.

Reported-by: Lennart Poettering <lennart@poettering.net>
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

This is a followup to the previous fhandle-for-Amazon-EFS
patch which adds further refinements.

Thanks,
NeilBrown


 fs/fhandle.c             | 2 +-
 include/linux/exportfs.h | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/fhandle.c b/fs/fhandle.c
index 0ace128f5d23..30bf1c20e143 100644
=2D-- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -35,7 +35,7 @@ static long do_sys_name_to_handle(struct path *path,
 		return -EFAULT;
=20
 	if (f_handle.handle_bytes > MAX_HANDLE_SZ)
=2D		return -EINVAL;
+		f_handle.handle_bytes =3D MAX_HANDLE_SZ;
=20
 	handle =3D kmalloc(sizeof(struct file_handle) + f_handle.handle_bytes,
 			 GFP_KERNEL);
diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index e7ab1b071c5e..097704e80c89 100644
=2D-- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -14,6 +14,10 @@ struct vfsmount;
 /* Must be larger than NFSv4 file handle, but small
  * enough for an on-stack allocation. overlayfs doesn't
  * want this too close to 255.
+ * NOTE: This value MUST NOT be exported to user-space.
+ * Applications must only ever see MAX_HANDLE_SZ =3D=3D 128.
+ * If they try a larger number on older kernels, they
+ * will get -EINVAL which will be confusing.
  */
 #define MAX_HANDLE_SZ 200
=20
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlokwJMACgkQOeye3VZi
gbkWixAAqar78MB40ErocOW8wwakC5rB6sKMez2+n1ggeUO6coibAxifSu5YUXSp
ar+0WUK660/x53GNtWDkTXk11DcxDtOANZ5nsPDLJae/vHaV5crR4Meb+Id8SlP4
qyuW+u6pEq4iEf8bT2yM3aAqOTXj9D4qmn8FDfoClszqyL7N9LSuubg0I5Tr3kUz
Tjs2xM3FGOl0VL6GsGpOYHaFp6BqJtkUQqrWz5R+OPJkA2rPw6eFvjrqF7stiTnj
Se28cl2TxT0LcL2GKwnUiPtLJ/a/wJfgUxwsxn+miC6KnL8eHe4pVWIrqoXdhVJD
vz9V928p4RyS2hXRqmENvKWbtU9N9XaXNrkYryEZGDvyn4k+mCYwQrWbf/+Xx++o
+v39J/as/6BjcdZF9BaFIOCR+fuQ3C6TOI9gdgNL0gTKVJxwTfMMqMn0QU10AhVx
qYoshEUW9+w1SINmnyV7z6rMUpaKglQI1QDr0EbEa9IlBBrQTuGzAVNUUnC2FbR3
zscZopolNMNVZSzPlMVx327EMBVGiXHetAz9XzT+FZM1TQP2BaFM3MBP000l+KgZ
o0SZYfBVYFexkE/uCK1/GqI4auaBaxxwtC2iW+nZ9I/0pUIXbjQdeRs+9X/rn4MM
PClMBwdKwQ8p1ml6cHvjZtB7/F8sgU/hsNDoXIFs+nAfAyCYMK8=
=1BuT
-----END PGP SIGNATURE-----
--=-=-=--

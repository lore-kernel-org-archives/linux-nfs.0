Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54230 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752273AbdLKWMn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 11 Dec 2017 17:12:43 -0500
From: NeilBrown <neilb@suse.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Date: Tue, 12 Dec 2017 09:12:32 +1100
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Amir Goldstein <amir73il@gmail.com>,
        lkml <linux-kernel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH 1/4] fs/notify: fdinfo can report unsupported file handles.
In-Reply-To: <20171211062946.GX21978@ZenIV.linux.org.uk>
References: <151297214390.7818.7216826079527521005.stgit@noble> <151297224512.7818.18333908109878259066.stgit@noble> <20171211062946.GX21978@ZenIV.linux.org.uk>
Message-ID: <87374gq5gv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 11 2017, Al Viro wrote:

> On Mon, Dec 11, 2017 at 05:04:05PM +1100, NeilBrown wrote:
>> @@ -385,7 +385,9 @@ int exportfs_encode_inode_fh(struct inode *inode, st=
ruct fid *fid,
>>  {
>>  	const struct export_operations *nop =3D inode->i_sb->s_export_op;
>>=20=20
>> -	if (nop && nop->encode_fh)
>> +	if (nop)
>> +		return FILEID_INVALID;
>> +	if (nop->encode_fh)
>>  		return nop->encode_fh(inode, fid->raw, max_len, parent);
>
> This might as well have been
>
> 	if (nop)
> 		return FILEID_INVALID;
> 	BUG();
>
> Have you ever tested that?

I have now - except for testing against Amazon EFS.
Only problem is the one you found - thanks.

NeilBrown

=2D----------8<------------>8----------------
From: NeilBrown <neilb@suse.com>
Date: Mon, 11 Dec 2017 16:41:01 +1100
Subject: [PATCH] fs/notify: fdinfo can report unsupported file handles.

If a filesystem does not set sb->s_export_op, then it
does not support filehandles and export_fs_encode_fh()
and exportfs_encode_inode_fh() should not be called.
They will use export_encode_fh() is which is a default
that uses inode number generation number, but in general
they may not be stable.

So change exportfs_encode_inode_fh() to return FILEID_INVALID
if called on an unsupported Filesystem.  Currently only
notify/fdinfo can do that.

Also remove the WARNing from fdinfo when exportfs_encode_inode_fh()
returns FILEID_INVALID, as that is no an erroneous condition.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 fs/exportfs/expfs.c | 4 +++-
 fs/notify/fdinfo.c  | 4 +---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/exportfs/expfs.c b/fs/exportfs/expfs.c
index 329a5d103846..2fff333b750c 100644
=2D-- a/fs/exportfs/expfs.c
+++ b/fs/exportfs/expfs.c
@@ -385,7 +385,9 @@ int exportfs_encode_inode_fh(struct inode *inode, struc=
t fid *fid,
 {
 	const struct export_operations *nop =3D inode->i_sb->s_export_op;
=20
=2D	if (nop && nop->encode_fh)
+	if (!nop)
+		return FILEID_INVALID;
+	if (nop->encode_fh)
 		return nop->encode_fh(inode, fid->raw, max_len, parent);
=20
 	return export_encode_fh(inode, fid, max_len, parent);
diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
index d478629c728b..d1135ed61229 100644
=2D-- a/fs/notify/fdinfo.c
+++ b/fs/notify/fdinfo.c
@@ -50,10 +50,8 @@ static void show_mark_fhandle(struct seq_file *m, struct=
 inode *inode)
 	size =3D f.handle.handle_bytes >> 2;
=20
 	ret =3D exportfs_encode_inode_fh(inode, (struct fid *)f.handle.f_handle, =
&size, 0);
=2D	if ((ret =3D=3D FILEID_INVALID) || (ret < 0)) {
=2D		WARN_ONCE(1, "Can't encode file handler for inotify: %d\n", ret);
+	if ((ret =3D=3D FILEID_INVALID) || (ret < 0))
 		return;
=2D	}
=20
 	f.handle.handle_type =3D ret;
 	f.handle.handle_bytes =3D size * sizeof(u32);
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlovAtAACgkQOeye3VZi
gbkTGA//fsu4DsN/JoByuFoRoIlkgK0j6GRcYMVlME8Qzf1zdtsNm5b1cNQufzIw
WC6xFYWkD/Q3tQOy6Z3M7MgRzbfFJhfKEy3UqsM1AnQpDI5vsarzWWd2H+iKLEyH
DqXeLHHithgiEF63xnhK3VCZJF+fi7qEnm+K6ftp7o3ZOQFa5kZAmHpHufc+uNMe
dHRn/93uaWmfdluI4qjXFk5H+1IBp6mfDt26SiDs2D46Mwrh6LqW6wFbfxw0sQz8
bCPnh9Qid+JGBQh6o9lm+28HSttyEKC2Z22yge55hvg0Ks6e+dpscR2Ouf/P3Ebz
w+xs3lJUQunoDaEftwhC8si4wJUtYGIY2e2/47NRwohOX4A9d9qY6QW/A5xwbhk3
zoUrk7T4/pZZHL2lqC4X0VQ1hrP1kr7D+W0bEHefX0XTup+cG26MBE4sZ1maQnPD
8KS2YK1mDuPr4Dqs2WE/qijNz7eUq0Gos3DuZJSbWJoryexlE5rKiDVyv/Mk92hu
n4QmP5RlsB3Fk0ejHMccJjeZ7SCMYCBHPaL+YoIK9tOYDyRZNWZfTIMz1tOtxgrY
qhj5w7APXl3vTeKApfR4Mav6ehyxC2YyTmVyLUPYQ2Y7XkssLcSM0nKo9UJcBcws
C64GccdQale3fKEHPzyNkFJpFUnTXx0fzHuFGLropScEIXL3qr4=
=Tbdm
-----END PGP SIGNATURE-----
--=-=-=--

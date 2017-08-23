Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58353 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752841AbdHWBHS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 Aug 2017 21:07:18 -0400
From: NeilBrown <neilb@suse.com>
To: Ian Kent <ikent@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Wed, 23 Aug 2017 11:06:54 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name> <1502883253.4847.6.camel@redhat.com> <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com> <878tihmora.fsf@notabene.neil.brown.name> <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com> <87h8x1l9qp.fsf@notabene.neil.brown.name> <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
Message-ID: <87r2w3jdn5.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 21 2017, Ian Kent wrote:

>>=20
>> A mount isn't triggered by kern_path(pathname, 0, &path).
>> That '0' would need to include one of
>>   LOOKUP_PARENT | LOOKUP_DIRECTORY |
>>   LOOKUP_OPEN | LOOKUP_CREATE | LOOKUP_AUTOMOUNT
>>=20
>> to trigger an automount (otherwise you just get -EISDIR).
>
> It's perfectly sensible to think that but there is a case where a
> a mount is triggered when using kern_path().
>
> The EISDIR return occurs for positive dentrys, negative dentrys
> will still trigger an automount (which is autofs specific,
> indirect mount map using nobrowse option, the install default).

Ok, I understand this better now.  This difference between direct and
indirect mounts is slightly awkward. It is visible from user-space, but
not elegant to document.
When you use O_PATH to open a direct automount that has not already been
triggered, the open returns the underlying directory (and fstatfs
confirms that it is AUTOFS_SUPER_MAGIC).  When you use O_PATH on
an indirect automount, it *will* trigger the automount when "nobrowse" is
in effect, but it won't when "browse" is in effect.

So we cannot just say "O_PATH doesn't trigger automounts", which is
essentially what I said in

https://git.kernel.org/pub/scm/docs/man-pages/man-pages.git/commit/?id=3D97=
a45d02e6671482e8b2cdcce3951930bf6bdb94

It might be possible to modify automount so that it was more consistent
=2D i.e. if the point is triggered by a mkdir has been done, just to the
mkdir.  If it is triggered after a mkdir has been done, do the mount.  I
guess that might be racy, and in any case is hard to justify.

Maybe I should change it to be about "direct automounts", and add a note
that indirect automounts aren't so predictable.

But back to my original issue of wanting to discard
kern_path_mountpoint, what would you think of the following approach -
slight revised from before.

Thanks,
NeilBrown

diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index beef981aa54f..7663ea82e68d 100644
=2D-- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -135,10 +135,13 @@ static inline struct autofs_info *autofs4_dentry_ino(=
struct dentry *dentry)
 /* autofs4_oz_mode(): do we see the man behind the curtain?  (The
  * processes which do manipulations for us in user space sees the raw
  * filesystem without "magic".)
+ * A process performing certain ioctls can get temporary oz status.
  */
+extern struct task_struct *autofs_tmp_oz;
 static inline int autofs4_oz_mode(struct autofs_sb_info *sbi)
 {
=2D	return sbi->catatonic || task_pgrp(current) =3D=3D sbi->oz_pgrp;
+	return sbi->catatonic || task_pgrp(current) =3D=3D sbi->oz_pgrp ||
+		autofs_tmp_oz =3D=3D current;
 }
=20
 struct inode *autofs4_get_inode(struct super_block *, umode_t);
diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
index dd9f1bebb5a3..d76401669a20 100644
=2D-- a/fs/autofs4/dev-ioctl.c
+++ b/fs/autofs4/dev-ioctl.c
@@ -200,6 +200,20 @@ static int autofs_dev_ioctl_protosubver(struct file *f=
p,
 	return 0;
 }
=20
+struct task_struct *autofs_tmp_oz;
+int kern_path_oz(const char *pathname, int flags, struct path *path)
+{
+	static DEFINE_MUTEX(autofs_oz);
+	int err;
+
+	mutex_lock(&autofs_oz);
+	autofs_tmp_oz =3D current;
+	err =3D kern_path(pathname, flags, path);
+	autofs_tmp_oz =3D NULL;
+	mutex_unlock(&autofs_oz);
+	return err;
+}
+
 /* Find the topmost mount satisfying test() */
 static int find_autofs_mount(const char *pathname,
 			     struct path *res,
@@ -209,7 +223,8 @@ static int find_autofs_mount(const char *pathname,
 	struct path path;
 	int err;
=20
=2D	err =3D kern_path_mountpoint(AT_FDCWD, pathname, &path, 0);
+	err =3D kern_path_oz(pathname, 0, &path);
+
 	if (err)
 		return err;
 	err =3D -ENOENT;
@@ -552,8 +567,7 @@ static int autofs_dev_ioctl_ismountpoint(struct file *f=
p,
=20
 	if (!fp || param->ioctlfd =3D=3D -1) {
 		if (autofs_type_any(type))
=2D			err =3D kern_path_mountpoint(AT_FDCWD,
=2D						   name, &path, LOOKUP_FOLLOW);
+			err =3D kern_path_oz(name, LOOKUP_FOLLOW, &path);
 		else
 			err =3D find_autofs_mount(name, &path,
 						test_by_type, &type);

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmc1TAACgkQOeye3VZi
gbk0eg//fJFSkPHvnfpc9R7KNkAw63jdljw6aTY0KPNhsC63lgmU5y2gauS+bzTJ
iERKqBhsYEJOj7fgmnpUmt+q/lOgE/EHHbqwY5gexXnj5Jo7jQd2IpalCCisZEfx
OAQqwTDZrWdmPU1MMNChj+JYmm69GtCgONUpCmmpwrW1DHFwoGLnv6ZWBXETUEGB
zskgrztgpxGWVnermrHnG5dWLywZas4Q5ZaG5Q0PG4rTwJQIRwzsTP4Bm9EVGWuX
Jo4eg+t6D2I/BuTJRGP2vtxvCUHnXNnuHJiVHE9KkNrd8Ow967Npp/lo1aPpyJ7J
wrFocpjvVm+DQkA5OSqQeUk7S3gpWoAN+RgOzdyqlHECIOufgr5aJZMTT9faYwug
F47krW+EMjJoIO3W6lrg3iasI1WX6nVg+GPlCvdbvcd+1sZn5KnonQerJRwSuqdg
v7exteDYLrb6tkR9jcUvkNCUJIOfLJ0PXMgrhhqZ9PJmL6X3wHoYwZ+FoVX62KFN
nk9+/f0lw25xSAiUczwIZBcvsYfIsbczmuZnXrB6U50mLptZJgeis7fu9rFFiR8v
G6ltPExMRly2thBuJJntOCUiDtLk6EIqQKDdLTcSV+AZD+bSxKD1Ykq8TRegxwGm
zFcsZGzJfFE1sMBNI6wuOWche5OfXOclGkYjVeGm5qBYAAlRFzI=
=gylV
-----END PGP SIGNATURE-----
--=-=-=--

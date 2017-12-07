Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45090 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752129AbdLGDUR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Dec 2017 22:20:17 -0500
From: NeilBrown <neilb@suse.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 07 Dec 2017 14:20:05 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] NFS: allow name_to_handle_at() to work for Amazon EFS.
In-Reply-To: <CA+55aFxHmVi-PuAWWrZqQzrich1QS9NR35DbdGpMts=y9uMAVA@mail.gmail.com>
References: <87po7zv62h.fsf@notabene.neil.brown.name> <CA+55aFxHmVi-PuAWWrZqQzrich1QS9NR35DbdGpMts=y9uMAVA@mail.gmail.com>
Message-ID: <87r2s7ql5m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 06 2017, Linus Torvalds wrote:

> On Thu, Nov 30, 2017 at 12:56 PM, NeilBrown <neilb@suse.com> wrote:
>>
>> -/* limit the handle size to NFSv4 handle size now */
>> -#define MAX_HANDLE_SZ 128
>> +/* Must be larger than NFSv4 file handle, but small
>> + * enough for an on-stack allocation. overlayfs doesn't
>> + * want this too close to 255.
>> + */
>> +#define MAX_HANDLE_SZ 200
>
> This really smells for so many reasons.
>
> Also, that really is starting to be a fairly big stack allocation, and
> it seems to be used in exactly one place (show_mark_fhandle), which
> makes me go "why is that on the stack anyway?".
>
> Could we just allocate a buffer at open time or something?
>
>                Linus

"open time" would be when /proc/X/fdinfo/Y was opened in
seq_fdinfo_open(), and allocating a file_handle there seems a bit odd.

We can allocate in fs/notify/fdinfo.c:show_fdinfo() which is
the earliest 'notify' specific code to run.  There is no
opportunity to return an error but GFP_KERNEL allocations under 1 page
never fail..

This patch allocates a single buffer for all inodes reported for a given
inotify fdinfo, and if the allocation files, the filehandle is silently
left blank.  More surgery would be needed to be able to return an error.

Is that at all suitable?

Thanks,
NeilBrown

From: NeilBrown <neilb@suse.com>
Subject: fs/notify: don't put file handle buffer on stack.

A file handle buffer is not tiny, and could need to be larger in future,
so it isn't safe to allocate one on the stack.  Instead, we need to
kmalloc().

There is no way to return an error status from a ->show_fdinfo()
function, so if the kmalloc fails, we silently exclude the filehandle
from the output.  As it is at the end of line, this shouldn't
upset parsing too much.

Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
index d478629c728b..20d863b9ae16 100644
=2D-- a/fs/notify/fdinfo.c
+++ b/fs/notify/fdinfo.c
@@ -23,56 +23,58 @@
=20
 static void show_fdinfo(struct seq_file *m, struct file *f,
 			void (*show)(struct seq_file *m,
=2D				     struct fsnotify_mark *mark))
+				     struct fsnotify_mark *mark,
+				     struct fid *fh))
 {
 	struct fsnotify_group *group =3D f->private_data;
 	struct fsnotify_mark *mark;
+	struct fid *fh =3D kmalloc(MAX_HANDLE_SZ, GFP_KERNEL);
=20
 	mutex_lock(&group->mark_mutex);
 	list_for_each_entry(mark, &group->marks_list, g_list) {
=2D		show(m, mark);
+		show(m, mark, fh);
 		if (seq_has_overflowed(m))
 			break;
 	}
 	mutex_unlock(&group->mark_mutex);
+	kfree(fh);
 }
=20
 #if defined(CONFIG_EXPORTFS)
=2Dstatic void show_mark_fhandle(struct seq_file *m, struct inode *inode)
+static void show_mark_fhandle(struct seq_file *m, struct inode *inode,
+			      struct fid *fhbuf)
 {
=2D	struct {
=2D		struct file_handle handle;
=2D		u8 pad[MAX_HANDLE_SZ];
=2D	} f;
 	int size, ret, i;
+	unsigned char *bytes;
=20
=2D	f.handle.handle_bytes =3D sizeof(f.pad);
=2D	size =3D f.handle.handle_bytes >> 2;
+	if (!fhbuf)
+		return;
+	size =3D MAX_HANDLE_SZ >> 2;
=20
=2D	ret =3D exportfs_encode_inode_fh(inode, (struct fid *)f.handle.f_handle=
, &size, 0);
+	ret =3D exportfs_encode_inode_fh(inode, fhbuf, &size, 0);
 	if ((ret =3D=3D FILEID_INVALID) || (ret < 0)) {
 		WARN_ONCE(1, "Can't encode file handler for inotify: %d\n", ret);
 		return;
 	}
=20
=2D	f.handle.handle_type =3D ret;
=2D	f.handle.handle_bytes =3D size * sizeof(u32);
=2D
=2D	seq_printf(m, "fhandle-bytes:%x fhandle-type:%x f_handle:",
=2D		   f.handle.handle_bytes, f.handle.handle_type);
+	seq_printf(m, "fhandle-bytes:%zx fhandle-type:%x f_handle:",
+		   size * sizeof(u32), ret);
=20
=2D	for (i =3D 0; i < f.handle.handle_bytes; i++)
=2D		seq_printf(m, "%02x", (int)f.handle.f_handle[i]);
+	bytes =3D (unsigned char *)(fhbuf->raw);
+	for (i =3D 0; i < size * sizeof(u32); i++)
+		seq_printf(m, "%02x", bytes[i]);
 }
 #else
=2Dstatic void show_mark_fhandle(struct seq_file *m, struct inode *inode)
+static void show_mark_fhandle(struct seq_file *m, struct inode *inode,
+			      struct fid *fhbuf)
 {
 }
 #endif
=20
 #ifdef CONFIG_INOTIFY_USER
=20
=2Dstatic void inotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mar=
k)
+static void inotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark,
+			   struct fid *fhbuf)
 {
 	struct inotify_inode_mark *inode_mark;
 	struct inode *inode;
@@ -93,7 +95,7 @@ static void inotify_fdinfo(struct seq_file *m, struct fsn=
otify_mark *mark)
 		seq_printf(m, "inotify wd:%x ino:%lx sdev:%x mask:%x ignored_mask:%x ",
 			   inode_mark->wd, inode->i_ino, inode->i_sb->s_dev,
 			   mask, mark->ignored_mask);
=2D		show_mark_fhandle(m, inode);
+		show_mark_fhandle(m, inode, fhbuf);
 		seq_putc(m, '\n');
 		iput(inode);
 	}
@@ -108,7 +110,8 @@ void inotify_show_fdinfo(struct seq_file *m, struct fil=
e *f)
=20
 #ifdef CONFIG_FANOTIFY
=20
=2Dstatic void fanotify_fdinfo(struct seq_file *m, struct fsnotify_mark *ma=
rk)
+static void fanotify_fdinfo(struct seq_file *m, struct fsnotify_mark *mark,
+			    struct fid *fhbuf)
 {
 	unsigned int mflags =3D 0;
 	struct inode *inode;
@@ -123,7 +126,7 @@ static void fanotify_fdinfo(struct seq_file *m, struct =
fsnotify_mark *mark)
 		seq_printf(m, "fanotify ino:%lx sdev:%x mflags:%x mask:%x ignored_mask:%=
x ",
 			   inode->i_ino, inode->i_sb->s_dev,
 			   mflags, mark->mask, mark->ignored_mask);
=2D		show_mark_fhandle(m, inode);
+		show_mark_fhandle(m, inode, fhbuf);
 		seq_putc(m, '\n');
 		iput(inode);
 	} else if (mark->connector->flags & FSNOTIFY_OBJ_TYPE_VFSMOUNT) {

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloos2UACgkQOeye3VZi
gbmcNQ/9G/b1tQ2BOXDJpQFlBisREieVOvUS1BbD4AWJbwYjOCxxT0E2qMXXqpBL
F+ieSC43MKao6fIOjEcLVhBDRrkNbfcETsyV6RkmESTSVvUtR5Z3xyDNMgXEb5ts
LHsEn0HzNRU0QAFGE6MGw2fcKKJk98br5If+kajdwUZpUGZxYrZJZVARBGvuAQ1W
H25uL3uwpCOdSpYVBDOGwSNv/E21otqdPFiPXlRKHp6rW3CNhQz1lihWnDbPZZ+T
7z2fZyD1kXzoCSfnGo6lkSuRdGgHV9xb2/YKKU5fkYEHOhQT0udNwig8DLXcHdSZ
nvlcI15olPhpf3Tx6JUXa0uBY/YEyjcH6CHo/1pTWznUdwdWkm2Gl1v8LDJc4U5u
ZSSxzHZrJuazHlkAKg8CyaX5i3rrRFw+DWEgjGfsfR/DMSJPlWg9TRjwWYHax7/u
DyXVUxaEhm9IeMKCmax0vvyAUQX84BiwBAzJ9jkDvfj7ZSFF04DROh0p/q2pGOsh
2ybtRAmEofLabx5ZzxsKCkqWBDzBa+iLJ+x6WDeU5ld2XQDrAu9w+F17+ISNT4u/
nLokY/Fj5egS5/t1pdv2q3gfG5bcz98gjjtclSFuRnXJCyGERwAK61vgS3vkzYJB
XVokpNzmjgOPrnsHETcs1mOHJbKi3bf6rJ8OP8csM4nRK4+eHug=
=TnVt
-----END PGP SIGNATURE-----
--=-=-=--

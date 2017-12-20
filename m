Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60469 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755406AbdLTVXS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Dec 2017 16:23:18 -0500
From: NeilBrown <neilb@suse.com>
To: Jan Kara <jack@suse.cz>
Date: Thu, 21 Dec 2017 08:23:05 +1100
Cc: Amir Goldstein <amir73il@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>,
        Pavel Emelyanov <xemul@virtuozzo.com>, Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] NFS: allow name_to_handle_at() to work for Amazon EFS.
In-Reply-To: <20171219124234.GH2277@quack2.suse.cz>
References: <87po7zv62h.fsf@notabene.neil.brown.name> <CA+55aFxHmVi-PuAWWrZqQzrich1QS9NR35DbdGpMts=y9uMAVA@mail.gmail.com> <87r2s7ql5m.fsf@notabene.neil.brown.name> <CAOQ4uxgg0cugypouB=Wyk1Uevm9EyqxpsHPaVqy0LxgS-bNGKw@mail.gmail.com> <878teeq7yc.fsf@notabene.neil.brown.name> <20171219124234.GH2277@quack2.suse.cz>
Message-ID: <871sjpksau.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, Dec 19 2017, Jan Kara wrote:

> On Fri 08-12-17 13:17:31, NeilBrown wrote:
>> On Thu, Dec 07 2017, Amir Goldstein wrote:
>>=20
>> > On Thu, Dec 7, 2017 at 5:20 AM, NeilBrown <neilb@suse.com> wrote:
>> >> On Wed, Dec 06 2017, Linus Torvalds wrote:
>> >>
>> >>> On Thu, Nov 30, 2017 at 12:56 PM, NeilBrown <neilb@suse.com> wrote:
>> >>>>
>> >>>> -/* limit the handle size to NFSv4 handle size now */
>> >>>> -#define MAX_HANDLE_SZ 128
>> >>>> +/* Must be larger than NFSv4 file handle, but small
>> >>>> + * enough for an on-stack allocation. overlayfs doesn't
>> >>>> + * want this too close to 255.
>> >>>> + */
>> >>>> +#define MAX_HANDLE_SZ 200
>> >>>
>> >>> This really smells for so many reasons.
>> >>>
>> >>> Also, that really is starting to be a fairly big stack allocation, a=
nd
>> >>> it seems to be used in exactly one place (show_mark_fhandle), which
>> >>> makes me go "why is that on the stack anyway?".
>> >>>
>> >>> Could we just allocate a buffer at open time or something?
>> >>>
>> >>>                Linus
>> >>
>> >> "open time" would be when /proc/X/fdinfo/Y was opened in
>> >> seq_fdinfo_open(), and allocating a file_handle there seems a bit odd.
>> >>
>> >> We can allocate in fs/notify/fdinfo.c:show_fdinfo() which is
>> >> the earliest 'notify' specific code to run.  There is no
>> >> opportunity to return an error but GFP_KERNEL allocations under 1 page
>> >> never fail..
>> >>
>> >> This patch allocates a single buffer for all inodes reported for a gi=
ven
>> >> inotify fdinfo, and if the allocation files, the filehandle is silent=
ly
>> >> left blank.  More surgery would be needed to be able to return an err=
or.
>> >>
>> >> Is that at all suitable?
>> >>
>> >> Thanks,
>> >> NeilBrown
>> >>
>> >> From: NeilBrown <neilb@suse.com>
>> >> Subject: fs/notify: don't put file handle buffer on stack.
>> >>
>> >> A file handle buffer is not tiny, and could need to be larger in futu=
re,
>> >> so it isn't safe to allocate one on the stack.  Instead, we need to
>> >> kmalloc().
>> >>
>> >> There is no way to return an error status from a ->show_fdinfo()
>> >> function, so if the kmalloc fails, we silently exclude the filehandle
>> >> from the output.  As it is at the end of line, this shouldn't
>> >> upset parsing too much.
>> >
>> > It shouldn't upset parsing because that would be the same out
>> > output as without CONFIG_EXPORTFS. AFAIK this information
>> > is used by CRUI.
>> >
>> >>
>> >> Signed-off-by: NeilBrown <neilb@suse.com>
>> >>
>> >> diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
>> >> index d478629c728b..20d863b9ae16 100644
>> >> --- a/fs/notify/fdinfo.c
>> >> +++ b/fs/notify/fdinfo.c
>> >> @@ -23,56 +23,58 @@
>> >>
>> >>  static void show_fdinfo(struct seq_file *m, struct file *f,
>> >>                         void (*show)(struct seq_file *m,
>> >> -                                    struct fsnotify_mark *mark))
>> >> +                                    struct fsnotify_mark *mark,
>> >> +                                    struct fid *fh))
>> >>  {
>> >>         struct fsnotify_group *group =3D f->private_data;
>> >>         struct fsnotify_mark *mark;
>> >> +       struct fid *fh =3D kmalloc(MAX_HANDLE_SZ, GFP_KERNEL);
>> >>
>> >>         mutex_lock(&group->mark_mutex);
>> >>         list_for_each_entry(mark, &group->marks_list, g_list) {
>> >> -               show(m, mark);
>> >> +               show(m, mark, fh);
>> >>                 if (seq_has_overflowed(m))
>> >>                         break;
>> >>         }
>> >>         mutex_unlock(&group->mark_mutex);
>> >> +       kfree(fh);
>> >>  }
>> >>
>> >>  #if defined(CONFIG_EXPORTFS)
>> >> -static void show_mark_fhandle(struct seq_file *m, struct inode *inod=
e)
>> >> +static void show_mark_fhandle(struct seq_file *m, struct inode *inod=
e,
>> >> +                             struct fid *fhbuf)
>> >>  {
>> >> -       struct {
>> >> -               struct file_handle handle;
>> >> -               u8 pad[MAX_HANDLE_SZ];
>> >> -       } f;
>> >>         int size, ret, i;
>> >> +       unsigned char *bytes;
>> >>
>> >> -       f.handle.handle_bytes =3D sizeof(f.pad);
>> >> -       size =3D f.handle.handle_bytes >> 2;
>> >> +       if (!fhbuf)
>> >> +               return;
>> >> +       size =3D MAX_HANDLE_SZ >> 2;
>> >>
>> >> -       ret =3D exportfs_encode_inode_fh(inode, (struct fid *)f.handl=
e.f_handle, &size, 0);
>> >> +       ret =3D exportfs_encode_inode_fh(inode, fhbuf, &size, 0);
>> >>         if ((ret =3D=3D FILEID_INVALID) || (ret < 0)) {
>> >>                 WARN_ONCE(1, "Can't encode file handler for inotify: =
%d\n", ret);
>> >
>> > This WARN_ONCE is out of order. It is perfectly valid for inotify/fano=
tify
>> > to watch over fs that doesn't support exportfs. Care to clean it up?
>> > Perhaps a pr_warn_ratelimited() for either !fhbuf or can't encode?
>>=20
>> If I were going to clean it up, I would need to do more than remove the
>> WARN_ONCE(), which almost certainly never fires.
>>=20
>> exportfs_encode_inode_fh() should only be called if sb->s_export_op is
>> not NULL.
>> When it is NULL, it means that the filesystem doesn't support file
>> handles.
>> do_sys_name_to_handle() tests this, as does nfsd.  But this inotify code
>> doesn't.
>> So it can report a "file handle" for a file for which file handles
>> aren't supported.  It will use the default export_encode_fh which
>> reports i_ino and i_generation, which may or may not be stable or
>> meaningful.
>>=20
>> So yes, this code does need a bit of cleaning up....
>
> So something like the patch below?
>

I prefer to fix it in exportfs, as in
 https://patchwork.kernel.org/patch/10104253/

Thanks,
NeilBrown


> 								Honza
> --=20
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
> From 66a6c05ae2fbe6cfcb24ca3088de39885a6fa5b8 Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Tue, 19 Dec 2017 13:38:54 +0100
> Subject: [PATCH] fsnotify: Do not show file handles for unsupported
>  filesystems
>
> Filesystems not setting their s_export_op do not support file handles.
> Do no try to encode them using exportfs_encode_inode_fh() since that may
> fail or return garbage.
>
> Reported-by: NeilBrown <neilb@suse.com>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/notify/fdinfo.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/fs/notify/fdinfo.c b/fs/notify/fdinfo.c
> index d478629c728b..041c2b0cc145 100644
> --- a/fs/notify/fdinfo.c
> +++ b/fs/notify/fdinfo.c
> @@ -46,6 +46,9 @@ static void show_mark_fhandle(struct seq_file *m, struc=
t inode *inode)
>  	} f;
>  	int size, ret, i;
>=20=20
> +	if (!inode->i_sb->s_export_op)
> +		return;
> +
>  	f.handle.handle_bytes =3D sizeof(f.pad);
>  	size =3D f.handle.handle_bytes >> 2;
>=20=20
> --=20
> 2.12.3

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlo61LkACgkQOeye3VZi
gbkLARAAordu1lBUc7ivzOeAmg2powbXX/eoeQxmHskLo02l+AL+E3ZspE01k2Ee
ojt2hUx+WDmXVY4ATXrCHMXjRD8VYylWCbXwtMYRaiS3CpLukm3dekTNDA/HUqrG
1Ma60rOytYniiSkYbOwJh8kc6VZ2gbWa1zLZaOUVquSaF376X9L78e9tfOxlNVSw
FWHJf5v/1gbOxty8o6YTfmwz0Zt4/515T2j91ilai5X2YI26pGwL01bglGD2BZKP
Zuptp+xlJsocSB7jLGil1YDZflySSs8ouTsjB/oGbkZzSDdPqKed41OyvLNXdqxD
a2qRh1E36Bu2xban75gY9drvkYau0ZMLECMZJieg2NTORGID0k0P1ePc5HCMNU5S
vOG/Lya7N/bhPFjLdURj+CwsZgDbOoc3j4nWvu1S9SH8AdYwAtLcIYIwbMgpfavq
JozwWNl++KqTij6Q+jPPRXujflJKfbbb67UsnSo0mPEIoswKcYcivRbw4BxVU34K
9j8YIlmXBB4s6XP5jrLkojk9VHUvtOi9zqluk91TAbbCZBs39Z8DanAJj84kxiBW
6ZybEeXa9mu7M/7iLgmzwslIMh46nDHmk2vOXCOPeF/eL8kuNGc5plYLxqyoY3HI
QpfiRL2+pNJPJf/uB0s5WXUogd7CR6c1/GGbHZIErN+whCanE18=
=f/17
-----END PGP SIGNATURE-----
--=-=-=--

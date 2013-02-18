Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754691Ab3BRMlu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 07:41:50 -0500
Date: Mon, 18 Feb 2013 07:41:05 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>, steved@redhat.com
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130218074105.38cf49ea@tlielax.poochiereds.net>
In-Reply-To: <20130218132509.0ce779de@notabene.brown>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
	<20130218132509.0ce779de@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/c/ey8zh/uZL3+VQA8yVw83b"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/c/ey8zh/uZL3+VQA8yVw83b
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Mon, 18 Feb 2013 13:25:09 +1100
NeilBrown <neilb@suse.de> wrote:

> On Thu, 14 Feb 2013 10:42:30 -0500 Jeff Layton <jlayton@redhat.com> wrote:
>=20
> > On Tue, 12 Feb 2013 11:38:13 +1100
> > NeilBrown <neilb@suse.de> wrote:
> >=20
> > >=20
> > > I've been exploring difficulties with unmounting stale directories and
> > > discovered another bug.
> > >=20
> > > If I:
> > >=20
> > > SERVER:  mkdir /foo/bar  #and make sure it is exported
> > > CLIENT:  mount -o vers=3D4 server:/foo/bar /mnt
> > > SERVER:  rm -r /foo
> > > CLIENT:  > /mnt/baz # gets an error of course
> > > CLIENT:  ls -l /mnt # error again
> > > CLIENT:  umount /mnt
> > >=20
> > > The result of that last command is:
> > >=20
> > > /mnt was not found in /proc/mounts
> > > /mnt was not found in /proc/mounts
> > >=20
> > > Strange?
> > >=20
> > > cat /proc/mounts
> > >=20
> > > .....
> > > 10.0.2.2://foo/bar /mnt\040(deleted) nfs4 rw,relatime,vers=3D4,rsize=
=3D1048576,wsize=3D1048576,namlen=3D255,hard,proto=3Dtcp,timeo=3D600,retran=
s=3D2,sec=3Dsys,clientaddr=3D10.0.2.15,minorversion=3D0,local_lock=3Dnone,a=
ddr=3D10.0.2.2 0 0
> > > ....
> > >=20
> > > Notice the "\040(deleted)".
> > >=20
> > > NFS has unhashed that directory because it is obviously bad, and d_pa=
th()
> > > notices and adds " (deleted)".
> > >=20
> > > Now I might be able to argue that NFS shouldn't be unhashing a direct=
ory that
> > > is a mountpoint - it certainly seems strange behaviour.
> > >=20
> > > But I think I can more strongly argue that /proc/mounts shouldn't be =
showing
> > > the mounted directory, but instead the directory that it is mounted o=
n.
> > > Obviously these both have the same name so it shouldn't matter ... ex=
cept
> > > that here is a case where it does.
> > >=20
> > > I "fixed" it with
> > >=20
> > > --- a/fs/proc_namespace.c
> > > +++ b/fs/proc_namespace.c
> > > @@ -93,7 +93,7 @@ static int show_vfsmnt(struct seq_file *m, struct v=
fsmount *mnt)
> > >  {
> > >  	struct mount *r =3D real_mount(mnt);
> > >  	int err =3D 0;
> > > -	struct path mnt_path =3D { .dentry =3D mnt->mnt_root, .mnt =3D mnt =
};
> > > +	struct path mnt_path =3D { .dentry =3D r->mnt_mountpoint, .mnt =3D =
&(r->mnt_parent)->mnt };
> > >  	struct super_block *sb =3D mnt_path.dentry->d_sb;
> > > =20
> > >  	if (sb->s_op->show_devname) {
> > >=20
> > > though I suspect that isn't safe and needs some locking.
> > >=20
> > > Probably both should be fixed:  NFS should not invalidate any mounted
> > > directory, and show_vfsmnt() should report the mointpoint, not the mo=
unted
> > > directory.
> > >=20
> > > I can't figure out any way to get NFS to not invalidate the mounted d=
irectory.
> > > I think it happens in nfs_lookup_revalidate() when it calls d_drop(),=
 but I
> > > don't know how to tell if a given dentry is a mnt_root for any mountp=
oint.
> > >=20
> > > Suggestions?  Thoughts?
> > >=20
> > > Thanks,
> > > NeilBrown
> > >=20
> >=20
> > I've also been looking at some weird ESTALE problems. Here's another
> > fun one that doesn't involve mountpoints. Assume here that we're
> > working in the same exported directory on client and server:
> >=20
> >     server# mkdir a
> >     client# cd a
> >     server# mv a a.bak
> >     client# sleep 30  # (or whatever the dir attrcache timeout is)
> >     client# stat .
> >     stat: cannot stat =E2=80=98.=E2=80=99: Stale NFS file handle
> >=20
> > Obviously, "." should not be stale. It got renamed, but the inode still
> > exists on the server.
> >=20
> > If you sniff on the wire, you'll see that the server doesn't ever send
> > an ESTALE here. What happens is that due to FS_REVAL_DOT being set, we
> > end up trying to revalidate the dentry that "." refers to. We find that
> > the parent changed (obviously) and then try to redo the lookup of "a".
> > At that point we notice that it doesn't exist and turn it into ESTALE.
> >=20
> > I don't really understand the point of FS_REVAL_DOT. What does that
> > actually buy us? I wonder if removing it would also help your testcase?
> >=20
>=20
> I think that is a slightly different issue, but certainly related.=20
> I have hit your problem before and have the following patch in SLES.  I t=
hink
> I tried pushing it upstream, but didn't get much in the way of a useful
> response.
> (patch is space-damaged - don't try to apply with 'patch').
>=20
> BTW I have another problem, related to this one and which could be fixed =
by
> removing FS_REVAL_DOT.
>=20
> If you
>    mount -o vers=3D4,noac server:/some/path /mnt
> then stop nfsd on the server and
>    umount /mnt
>=20
> it hangs.
> Partly it hangs because  'mount' tries to do a 'readlink' on the mountpoi=
nt.
> I can probably get it to not do that (or use --no-canonicalize).
> But then sys_umount hangs because it tries to check with the server that =
the
> thing being unmounted really is still a directory...
>=20
> I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag that
> works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips the v=
ery
> last step and returns the mounted-on directory, not the mountpoint that is
> mounted there - or at least makes sure not revalidate happens on that fin=
al
> mounted directory.
>=20
>=20
> I think FS_REVAL_DOT is needed so that if you call stat("."), it will upd=
ate
> attributes from the server if the cache is old.  However it seems to do a
> whole lot more than that, including "lookup" calls which it I'm sure is w=
rong.
>=20
>=20
>=20
> Subject: [PATCH] nfs - handle d_revalidate of 'dot' correctly.
>=20
> When d_revalidate is called on a dentry because FS_REVAL_DOT is set
> it isn't really appropriate to revalidate the name.
>=20
> If the path was simply ".", then the current-working-directory could
> have been renamed on the server and should still be accessible as "."
> even if it has a new name.
>=20
> If the path was "/some/long/path/.", then the final component ("path" in
> this case) has already been revalidated and there is no particular
> need to do it again.
>=20
> If we change nd->last_type to refer to "the last component looked at"
> rather than just "the last component", then these cases can be
> detected by "nd->last_type !=3D LAST_NORM".
>=20
> Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> ---
>  fs/namei.c   |    2 +-
>  fs/nfs/dir.c |    9 +++++++++
>  2 files changed, 10 insertions(+), 1 deletion(-)
>=20
> --- linux-3.0-SLE11-SP2.orig/fs/namei.c
> +++ linux-3.0-SLE11-SP2/fs/namei.c
> @@ -1460,6 +1460,7 @@ static int link_path_walk(const char *na
>                         }
>                 }
> =20
> +               nd->last_type =3D type;
>                 /* remove trailing slashes? */
>                 if (!c)
>                         goto last_component;
> @@ -1486,7 +1487,6 @@ last_component:
>                 /* Clear LOOKUP_CONTINUE iff it was previously unset */
>                 nd->flags &=3D lookup_flags | ~LOOKUP_CONTINUE;
>                 nd->last =3D this;
> -               nd->last_type =3D type;
>                 return 0;
>         }
>         terminate_walk(nd);
> --- linux-3.0-SLE11-SP2.orig/fs/nfs/dir.c
> +++ linux-3.0-SLE11-SP2/fs/nfs/dir.c
> @@ -1138,6 +1138,15 @@ static int nfs_lookup_revalidate(struct
>         if (NFS_STALE(inode))
>                 goto out_bad;
> =20
> +       if (nd->last_type !=3D LAST_NORM) {
> +               /* name not relevant, just inode */
> +               error =3D nfs_revalidate_inode(NFS_SERVER(inode), inode);
> +               if (error)
> +                       goto out_bad;
> +               else
> +                       goto out_valid;
> +       }
> +
>         error =3D -ENOMEM;
>         fhandle =3D nfs_alloc_fhandle();
>         fattr =3D nfs_alloc_fattr();

Ahh thanks -- that is the same problem exactly. I'll have to look over
your patch and see whether and how it could be applied to current
mainline code.

I think the umount thing may be the same problem that steved was
talking about the other day (V4 unmount causes a GETATTR). I hadn't put
the two together, but you're probably right.

LOOKUP_MOUNTPOINT is a very interesting idea and might even be
reasonable in conjunction with removing FS_REVAL_DOT as it would make
the needs of umount more explicit.

As far as FS_REVAL_DOT goes though, in the current mainline code, the
only place that looks at it is complete_walk(), and it just means that
we won't skip doing a d_revalidate on the final component (which will
only have not been done if it's a '.', right?).

If we remove FS_REVAL_DOT altogether, then we can chop off the bottom
half of that function, which has a certain appeal. I guess the question
we have to answer is -- if we remove FS_REVAL_DOT, what (if anything)
will break?


--=20
Jeff Layton <jlayton@redhat.com>

--Sig_/c/ey8zh/uZL3+VQA8yVw83b
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRIiFhAAoJEAAOaEEZVoIVVr0P/j5SrJ5FZA7FY6e391KbcJoW
mVwWosFdGBcfOkm08VF3V30Ytf1qPeOSa5YX5RSmq9qwbAnbB0oRe5TVNYhQPTTW
xE/+qm20a5Cb+lecACPLZSRbnLB+hkFe4O1LdNx1kdlCci2Ri33+1L929kg9MuSo
ebN3w0d8TVebJec1VYizvXabGl4NIwLUEV9fSlvapzQqffALH74WvRFEBzmd8K/i
KUZ+Kzx+3jeywslxDBVSSM+4s5mSAn5asbpcYT/HTaVuq9H1Y5PBAypwpWuUpke2
xA10Q1WNRxQGUel43+n+I2TpQ/OlGWkT7sDm+j0dP5ExLPqDQiBXZ2/ybUfbjEA9
dgkMwOWwmeZo/C4mdGpRCMPX4IT0KxjY+wb+DKufN3lB6yOJljgnqzNrmt3WzIJN
KzkaUY6h/g9jkjQfx+iQOr6qyRoOtPouBxpxF9Zh5wELHLL/vmyZZrPPovSxL0DX
b+ybKIPyFVWBZ6wYYtvrBNHa4/jRdXaFxrHrPqPJiaMJdkdnDykr+LXSJ0UK5H37
u20JCxI57lN3k+jWqDqNvJCUSjeeaxjoUi8qT89eoWHvPRW1AauuYOTX72twDF40
D2ZIDm6KeYNZQmrDeGRCeBDc/JRmZo0oouanBnG08AkHHaegx5X9dALb3R7pU0NM
grllc8eb229LFCZva/ZB
=gqMI
-----END PGP SIGNATURE-----

--Sig_/c/ey8zh/uZL3+VQA8yVw83b--

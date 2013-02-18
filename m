Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33953 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755687Ab3BRCZ1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Feb 2013 21:25:27 -0500
Date: Mon, 18 Feb 2013 13:25:09 +1100
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130218132509.0ce779de@notabene.brown>
In-Reply-To: <20130214104230.013b7f71@tlielax.poochiereds.net>
References: <20130212113813.427b8e05@notabene.brown>
	<20130214104230.013b7f71@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/r222JDZMcsuApLx/2.Ugf1y"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/r222JDZMcsuApLx/2.Ugf1y
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Thu, 14 Feb 2013 10:42:30 -0500 Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 12 Feb 2013 11:38:13 +1100
> NeilBrown <neilb@suse.de> wrote:
>=20
> >=20
> > I've been exploring difficulties with unmounting stale directories and
> > discovered another bug.
> >=20
> > If I:
> >=20
> > SERVER:  mkdir /foo/bar  #and make sure it is exported
> > CLIENT:  mount -o vers=3D4 server:/foo/bar /mnt
> > SERVER:  rm -r /foo
> > CLIENT:  > /mnt/baz # gets an error of course
> > CLIENT:  ls -l /mnt # error again
> > CLIENT:  umount /mnt
> >=20
> > The result of that last command is:
> >=20
> > /mnt was not found in /proc/mounts
> > /mnt was not found in /proc/mounts
> >=20
> > Strange?
> >=20
> > cat /proc/mounts
> >=20
> > .....
> > 10.0.2.2://foo/bar /mnt\040(deleted) nfs4 rw,relatime,vers=3D4,rsize=3D=
1048576,wsize=3D1048576,namlen=3D255,hard,proto=3Dtcp,timeo=3D600,retrans=
=3D2,sec=3Dsys,clientaddr=3D10.0.2.15,minorversion=3D0,local_lock=3Dnone,ad=
dr=3D10.0.2.2 0 0
> > ....
> >=20
> > Notice the "\040(deleted)".
> >=20
> > NFS has unhashed that directory because it is obviously bad, and d_path=
()
> > notices and adds " (deleted)".
> >=20
> > Now I might be able to argue that NFS shouldn't be unhashing a director=
y that
> > is a mountpoint - it certainly seems strange behaviour.
> >=20
> > But I think I can more strongly argue that /proc/mounts shouldn't be sh=
owing
> > the mounted directory, but instead the directory that it is mounted on.
> > Obviously these both have the same name so it shouldn't matter ... exce=
pt
> > that here is a case where it does.
> >=20
> > I "fixed" it with
> >=20
> > --- a/fs/proc_namespace.c
> > +++ b/fs/proc_namespace.c
> > @@ -93,7 +93,7 @@ static int show_vfsmnt(struct seq_file *m, struct vfs=
mount *mnt)
> >  {
> >  	struct mount *r =3D real_mount(mnt);
> >  	int err =3D 0;
> > -	struct path mnt_path =3D { .dentry =3D mnt->mnt_root, .mnt =3D mnt };
> > +	struct path mnt_path =3D { .dentry =3D r->mnt_mountpoint, .mnt =3D &(=
r->mnt_parent)->mnt };
> >  	struct super_block *sb =3D mnt_path.dentry->d_sb;
> > =20
> >  	if (sb->s_op->show_devname) {
> >=20
> > though I suspect that isn't safe and needs some locking.
> >=20
> > Probably both should be fixed:  NFS should not invalidate any mounted
> > directory, and show_vfsmnt() should report the mointpoint, not the moun=
ted
> > directory.
> >=20
> > I can't figure out any way to get NFS to not invalidate the mounted dir=
ectory.
> > I think it happens in nfs_lookup_revalidate() when it calls d_drop(), b=
ut I
> > don't know how to tell if a given dentry is a mnt_root for any mountpoi=
nt.
> >=20
> > Suggestions?  Thoughts?
> >=20
> > Thanks,
> > NeilBrown
> >=20
>=20
> I've also been looking at some weird ESTALE problems. Here's another
> fun one that doesn't involve mountpoints. Assume here that we're
> working in the same exported directory on client and server:
>=20
>     server# mkdir a
>     client# cd a
>     server# mv a a.bak
>     client# sleep 30  # (or whatever the dir attrcache timeout is)
>     client# stat .
>     stat: cannot stat =E2=80=98.=E2=80=99: Stale NFS file handle
>=20
> Obviously, "." should not be stale. It got renamed, but the inode still
> exists on the server.
>=20
> If you sniff on the wire, you'll see that the server doesn't ever send
> an ESTALE here. What happens is that due to FS_REVAL_DOT being set, we
> end up trying to revalidate the dentry that "." refers to. We find that
> the parent changed (obviously) and then try to redo the lookup of "a".
> At that point we notice that it doesn't exist and turn it into ESTALE.
>=20
> I don't really understand the point of FS_REVAL_DOT. What does that
> actually buy us? I wonder if removing it would also help your testcase?
>=20

I think that is a slightly different issue, but certainly related.=20
I have hit your problem before and have the following patch in SLES.  I thi=
nk
I tried pushing it upstream, but didn't get much in the way of a useful
response.
(patch is space-damaged - don't try to apply with 'patch').

BTW I have another problem, related to this one and which could be fixed by
removing FS_REVAL_DOT.

If you
   mount -o vers=3D4,noac server:/some/path /mnt
then stop nfsd on the server and
   umount /mnt

it hangs.
Partly it hangs because  'mount' tries to do a 'readlink' on the mountpoint.
I can probably get it to not do that (or use --no-canonicalize).
But then sys_umount hangs because it tries to check with the server that the
thing being unmounted really is still a directory...

I would be really nice if sys_unmount used a LOOKUP_MOUNTPOINT flag that
works a bit like LOOKUP_PARENT and LOOKUP_NOFOLLOW in that it skips the very
last step and returns the mounted-on directory, not the mountpoint that is
mounted there - or at least makes sure not revalidate happens on that final
mounted directory.


I think FS_REVAL_DOT is needed so that if you call stat("."), it will update
attributes from the server if the cache is old.  However it seems to do a
whole lot more than that, including "lookup" calls which it I'm sure is wro=
ng.

NeilBrown


Subject: [PATCH] nfs - handle d_revalidate of 'dot' correctly.

When d_revalidate is called on a dentry because FS_REVAL_DOT is set
it isn't really appropriate to revalidate the name.

If the path was simply ".", then the current-working-directory could
have been renamed on the server and should still be accessible as "."
even if it has a new name.

If the path was "/some/long/path/.", then the final component ("path" in
this case) has already been revalidated and there is no particular
need to do it again.

If we change nd->last_type to refer to "the last component looked at"
rather than just "the last component", then these cases can be
detected by "nd->last_type !=3D LAST_NORM".

Signed-off-by: NeilBrown <neilb@suse.de>

---
 fs/namei.c   |    2 +-
 fs/nfs/dir.c |    9 +++++++++
 2 files changed, 10 insertions(+), 1 deletion(-)

--- linux-3.0-SLE11-SP2.orig/fs/namei.c
+++ linux-3.0-SLE11-SP2/fs/namei.c
@@ -1460,6 +1460,7 @@ static int link_path_walk(const char *na
                        }
                }
=20
+               nd->last_type =3D type;
                /* remove trailing slashes? */
                if (!c)
                        goto last_component;
@@ -1486,7 +1487,6 @@ last_component:
                /* Clear LOOKUP_CONTINUE iff it was previously unset */
                nd->flags &=3D lookup_flags | ~LOOKUP_CONTINUE;
                nd->last =3D this;
-               nd->last_type =3D type;
                return 0;
        }
        terminate_walk(nd);
--- linux-3.0-SLE11-SP2.orig/fs/nfs/dir.c
+++ linux-3.0-SLE11-SP2/fs/nfs/dir.c
@@ -1138,6 +1138,15 @@ static int nfs_lookup_revalidate(struct
        if (NFS_STALE(inode))
                goto out_bad;
=20
+       if (nd->last_type !=3D LAST_NORM) {
+               /* name not relevant, just inode */
+               error =3D nfs_revalidate_inode(NFS_SERVER(inode), inode);
+               if (error)
+                       goto out_bad;
+               else
+                       goto out_valid;
+       }
+
        error =3D -ENOMEM;
        fhandle =3D nfs_alloc_fhandle();
        fattr =3D nfs_alloc_fattr();

--Sig_/r222JDZMcsuApLx/2.Ugf1y
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUSGRBTnsnt1WYoG5AQJpEw//YMsvMY9TxlYG2ZgMFRvtfapJtneIw/p+
EYEcGQQYqrxgmA9m9vbqvUog1ue9RxxCJPmxAIWOeTzltY0pdTEz49PgZZ9FPckT
8sp2FvPDecYZZ81vowJwR/Uku8JFDjJ6OItZqEhcPFGZHwpzj1ki851FfK+41Qlp
qWNnAY9qetyQgEWCZ8A0BrY+AMoB+IY0PxHOUDScNC5lv4uHkhRD9Xs0wZ4Zg7ag
QOWf7K+syIWuxPCIjg8nySICxhfgEzigpKJPbANNv7PFjBDlSQlupx7kMHF4pWGf
tqyNOAhRI8HtdXOuKsXX1f4idSOLhSlhPphYaRgAdNyjk6uONM+yqA5nBTID7KFa
THxVqi2fmmszb15OUUq7DvpP/87TcamuRb0xA70KljsLeB31LL741HDXrgs/Ft7P
4TPWwcPHsqV3CYWo5XdhTV2XD5J2Rc4VLFLzSwa4l5s1nF1vjBogahirNJ3G4aeD
p/uDscKuv75Tmc+jKhYxwAxDNtd5a4Ezc9WA3tulwqk/bIE8JshlfjN7j2swDWkv
mDZgDdJZAIr1kShPcztK4rvOg2dKOYaXW7DBWcPctRZSZy63Ym3OQ8yz0sCZ+M3O
bzKbUcNNCWEaf2ANaz148rO6KmWeKkaA36RTcmK04MTULbj7FvKTWIDlIdMyCTbd
vqiHaAfdGMw=
=GauG
-----END PGP SIGNATURE-----

--Sig_/r222JDZMcsuApLx/2.Ugf1y--

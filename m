Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57177 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752426AbdHPXrv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Aug 2017 19:47:51 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro\@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>
Date: Thu, 17 Aug 2017 09:47:38 +1000
Cc: "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny\@suse.com" <mkoutny@suse.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        Ian Kent <ikent@redhat.com>
Subject: Re: Do we really need d_weak_revalidate???
In-Reply-To: <1502883253.4847.6.camel@redhat.com>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com> <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name> <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name> <1502883253.4847.6.camel@redhat.com>
Message-ID: <87y3qjm5wl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 16 2017, Jeff Layton wrote:

> On Wed, 2017-08-16 at 12:43 +1000, NeilBrown wrote:
>> On Mon, Aug 14 2017, Jeff Layton wrote:
>>=20
>> > On Mon, 2017-08-14 at 09:36 +1000, NeilBrown wrote:
>> > > On Fri, Aug 11 2017, Jeff Layton wrote:
>> > >=20
>> > > > On Fri, 2017-08-11 at 05:55 +0000, Trond Myklebust wrote:
>> > > > > On Fri, 2017-08-11 at 14:31 +1000, NeilBrown wrote:
>> > > > > > Funny story.  4.5 years ago we discarded the FS_REVAL_DOT supe=
rblock
>> > > > > > flag and introduced the d_weak_revalidate dentry operation ins=
tead.
>> > > > > > We duly removed the flag from NFS superblocks and NFSv4 superb=
locks,
>> > > > > > and added the new dentry operation to NFS dentries .... but no=
t to
>> > > > > > NFSv4
>> > > > > > dentries.
>> > > > > >=20
>> > > > > > And nobody noticed.
>> > > > > >=20
>> > > > > > Until today.
>> > > > > >=20
>> > > > > > A customer reports a situation where mount(....,MS_REMOUNT,..)=
 on an
>> > > > > > NFS
>> > > > > > filesystem hangs because the network has been deconfigured.  T=
his
>> > > > > > makes
>> > > > > > perfect sense and I suggested a code change to fix the problem.
>> > > > > > However when a colleague was trying to reproduce the problem to
>> > > > > > validate
>> > > > > > the fix, he couldn't.  Then nor could I.
>> > > > > >=20
>> > > > > > The problem is trivially reproducible with NFSv3, and not at a=
ll with
>> > > > > > NFSv4.  The reason is the missing d_weak_revalidate.
>> > > > > >=20
>> > > > > > We could simply add d_weak_revalidate for NFSv4, but given tha=
t it
>> > > > > > has been missing for 4.5 years, and the only time anyone notic=
ed was
>> > > > > > when the ommission resulted in a better user experience, I do =
wonder
>> > > > > > if
>> > > > > > we need to.  Can we just discard d_weak_revalidate?  What purp=
ose
>> > > > > > does
>> > > > > > it serve?  I couldn't find one.
>> > > > > >=20
>> > > > > > Thanks,
>> > > > > > NeilBrown
>> > > > > >=20
>> > > > > > For reference, see
>> > > > > > Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a
>> > > > > > d_weak_revalidate dentry op")
>> > > > > >=20
>> > > > > >=20
>> > > > > >=20
>> > > > > > To reproduce the problem at home, on a system that uses system=
d:
>> > > > > > 1/ place (or find) a filesystem image in a file on an NFS file=
system.
>> > > > > > 2/ mount the nfs filesystem with "noac" - choose v3 or v4
>> > > > > > 3/ loop-mount the filesystem image read-only somewhere
>> > > > > > 4/ reboot
>> > > > > >=20
>> > > > > > If you choose v4, the reboot will succeed, possibly after a 90=
second
>> > > > > > timeout.
>> > > > > > If you choose v3, the reboot will hang indefinitely in systemd-
>> > > > > > shutdown while
>> > > > > > remounting the nfs filesystem read-only.
>> > > > > >=20
>> > > > > > If you don't use "noac" it can still hang, but only if somethi=
ng
>> > > > > > slows
>> > > > > > down the reboot enough that attributes have timed out by the t=
ime
>> > > > > > that
>> > > > > > systemd-shutdown runs.  This happens for our customer.
>> > > > > >=20
>> > > > > > If the loop-mounted filesystem is not read-only, you get other
>> > > > > > problems.
>> > > > > >=20
>> > > > > > We really want systemd to figure out that the loop-mount needs=
 to be
>> > > > > > unmounted first.  I have ideas concerning that, but it is mess=
y.  But
>> > > > > > that isn't the only bug here.
>> > > > >=20
>> > > > > The main purpose of d_weak_revalidate() was to catch the issues =
that
>> > > > > arise when someone changes the contents of the current working
>> > > > > directory or its parent on the server. Since '.' and '..' are tr=
eated
>> > > > > specially in the lookup code, they would not be revalidated with=
out
>> > > > > special treatment. That leads to issues when looking up files as
>> > > > > ./<filename> or ../<filename>, since the client won't detect tha=
t its
>> > > > > dcache is stale until it tries to use the cached dentry+inode.
>> > > > >=20
>> > > > > The one thing that has changed since its introduction is, I beli=
eve,
>> > > > > the ESTALE handling in the VFS layer. That might fix a lot of the
>> > > > > dcache lookup bugs that were previously handled by d_weak_revali=
date().
>> > > > > I haven't done an audit to figure out if it actually can handle =
all of
>> > > > > them.
>> > > > >=20
>> > > >=20
>> > > > It may also be related to 8033426e6bdb2690d302872ac1e1fadaec1a5581:
>> > > >=20
>> > > >     vfs: allow umount to handle mountpoints without revalidating t=
hem
>> > >=20
>> > > You say in the comment for that commit:
>> > >=20
>> > >      but there
>> > >     are cases where we do want to revalidate the root of the fs.
>> > >=20
>> > > Do you happen to remember what those cases are?
>> > >=20
>> >=20
>> > Not exactly, but I _think_ I might have been assuming that we needed to
>> > ensure that the inode attrs on the root were up to date after the
>> > pathwalk.
>> >=20
>> > I think that was probably wrong. d_revalidate is really intended to
>> > ensure that the dentry in question still points to the same inode. In
>> > the case of the root of the mount though, we don't really care about t=
he
>> > dentry on the server at all. We're attaching the root of the mount to =
an
>> > inode and don't care of the dentry name changes. If we do need to ensu=
re
>> > the inode attrs are updated, we'll just revalidate them at that point.
>> >=20
>> > > >=20
>> > > > Possibly the fact that we no longer try to revalidate during unmou=
nt
>> > > > means that this is no longer necessary?
>> > > >=20
>> > > > The original patch that added d_weak_revalidate had a reproducer i=
n the
>> > > > patch description. Have you verified that that problem is still not
>> > > > reproducible when you remove d_weak_revalidate?
>> > >=20
>> > > I did try the reproducer and it works as expected both with and with=
out
>> > > d_weak_revalidate.
>> > > On reflection, the problem it displayed was caused by d_revalidate()
>> > > being called when the dentry name was irrelevant.  We remove that
>> > > (fixing the problem) and introduce d_weak_revalidate because we thou=
ght
>> > > that minimum functionality was still useful.  I'm currently not
>> > > convinced that even that is needed.
>> > >=20
>> > > If we discarded d_weak_revalidate(), we could get rid of the special
>> > > handling of umount....
>> >=20
>> > I like idea. I say go for it and we can see what (if anything) breaks?
>>=20
>> Getting rid of d_weak_revalidate is easy enough - hardly any users.
>>=20
>> Getting rid of filename_mountpoint() isn't so easy unfortunately.
>> autofs4 uses kern_path_mountpoint() - presumably to avoid getting stuck
>> in autofs4_d_manage()?  It would be a shame to keep this infrastructure
>> around just so that one part of autofs4 can talk to another part of
>> autofs4.
>>=20
>> Do you know if the fact that filename_mountpoint() skips ->d_manage is
>> important for sys_umount ??
>>=20
>> Thanks,
>> NeilBrown
>>=20
>
> (cc'ing David and Ian)
>
> I'm less familiar with the automounting machinery, but I imagine you
> don't really want to go triggering new mounts when your intent is to
> unmount something. As long as that doesn't happen I'd think we'd be ok
> here.

New mounts don't get triggered unless asked for (LOOKUP_AUTOMOUNT) so
that isn't a problem.  But the d_manage() operation does get called, and
it can block.  I think the purpose of the interface is to avoid races
with expiring automounts.  Once the decision has been made to expire the
mount, you want to be able to stop anyone getting a new access.
d_manage() can do that.  umount() probably doesn't need d_manage() to be
skipped.

autofs *does* for certain ioctls which are used to re-establish
ownership of an automount (e.g. when restarting automountd).  The owner
never gets blocked, but if the new automountd isn't the owner yet, it
needs help.

The current code causes the lookup to never call d_manage(), which I
think is overkill.  There might be some other filesystem which uses
d_manage() (not actually possible at present) and those shouldn't be
ignored.

So I came up with this.  It isn't exactly elegant, but it should avoid
the deadlock that caused autofs4 to start using kern_path_mount().

If we apply this change, and get rid of d_weak_revalidate(), then I
think we can get rid of all the "mountpoint" pathname lookup code.

Ian/David - you do have any thoughts on this approach?

Thanks,
NeilBrown



diff --git a/fs/autofs4/autofs_i.h b/fs/autofs4/autofs_i.h
index beef981aa54f..478a9aafd6d3 100644
=2D-- a/fs/autofs4/autofs_i.h
+++ b/fs/autofs4/autofs_i.h
@@ -271,3 +271,4 @@ static inline void autofs4_del_expiring(struct dentry *=
dentry)
 }
=20
 void autofs4_kill_sb(struct super_block *);
+int is_autofs_finder(void);
diff --git a/fs/autofs4/dev-ioctl.c b/fs/autofs4/dev-ioctl.c
index dd9f1bebb5a3..f3e84bfed85a 100644
=2D-- a/fs/autofs4/dev-ioctl.c
+++ b/fs/autofs4/dev-ioctl.c
@@ -200,6 +200,13 @@ static int autofs_dev_ioctl_protosubver(struct file *f=
p,
 	return 0;
 }
=20
+static DEFINE_MUTEX(autofs_find);
+static struct task_struct *autofs_finder =3D NULL;
+int is_autofs_finder(void)
+{
+	return autofs_finder =3D=3D current;
+}
+
 /* Find the topmost mount satisfying test() */
 static int find_autofs_mount(const char *pathname,
 			     struct path *res,
@@ -209,7 +216,12 @@ static int find_autofs_mount(const char *pathname,
 	struct path path;
 	int err;
=20
=2D	err =3D kern_path_mountpoint(AT_FDCWD, pathname, &path, 0);
+	mutex_lock(&autofs_find);
+	autofs_finder =3D current;
+	err =3D kern_path(pathname, 0, &path);
+	autofs_finder =3D NULL;
+	mutex_unlock(&autofs_find);
+
 	if (err)
 		return err;
 	err =3D -ENOENT;
diff --git a/fs/autofs4/root.c b/fs/autofs4/root.c
index d79ced925861..e93a3112d60c 100644
=2D-- a/fs/autofs4/root.c
+++ b/fs/autofs4/root.c
@@ -438,7 +438,7 @@ static int autofs4_d_manage(const struct path *path, bo=
ol rcu_walk)
 	pr_debug("dentry=3D%p %pd\n", dentry, dentry);
=20
 	/* The daemon never waits. */
=2D	if (autofs4_oz_mode(sbi)) {
+	if (autofs4_oz_mode(sbi) || is_autofs_finder()) {
 		if (!path_is_mountpoint(path))
 			return -EISDIR;
 		return 0;

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmU2ZwACgkQOeye3VZi
gbls/w/+IIxqlCQSVfpc3jVmudGCgujhI9OygLBKlKB9/knyWYIyA++Zm6FMUOvv
4B9L+CTBS+ZMZawNuEoQbbZHIIM156217nVrRi/XvC8GzngkC4Lhpu2t2lh19bLQ
uWDGeDS+IY0EhN6fw6K+km4kVT/vBdIvD8v+3TGeudAA+sONxkZvcsQPnmupuOZc
T1T0Wbavw9sf1asbtIF4iEaqLL42wtkBo7+pcN84QIrCml9rP+3u3Y7hAaQ4bzhQ
vkVChVSTXtMI6OxWFdmtzBTUUyb2sro9+5wbDbJG8ntupvFpW+SqmS2jf30qUAOR
eD5vTctGICQW0YS46UD8MW+AYVz9zfCb0YhwP0tiLBO5Xsnkbr5eazyOkIB9oEZj
HDbHNIKkwf9wiT1S6Fu/5+pVWi6SaQVB5LdR4Ph89YWEh5d8RpH8fvFyGWuFXq4p
dSOpab+g2uieb4cTmeeMq3grk/+ZkuJtOGCy3oSU3MywmhvKYsYyhXPLwjQz5XDK
jXTob3gLEtk48qeVEGxpIkzUdo2kYDoPaj5LE6PfvzbNZWbfX7oxnm55THF6nzWp
cV9fFboYgn80xNwrbUzdtwaWaB4pbZyAHzzcPDu7q3Lf1LnKgYv+nlKPyKiWiO8s
6lBPgnJqUV9Z3VVsfJABRTzmfjuyUMEn9QXmKlSMo+9b3mNKGbg=
=SMDb
-----END PGP SIGNATURE-----
--=-=-=--

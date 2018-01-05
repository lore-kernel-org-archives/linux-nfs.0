Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:24317 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751100AbeAEBeH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jan 2018 20:34:07 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "neilb@suse.com" <neilb@suse.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFS: add nostatflush mount option.
Date: Fri, 5 Jan 2018 01:34:02 +0000
Message-ID: <1515116033.87651.1.camel@primarydata.com>
References: <87k1xgkct1.fsf@notabene.neil.brown.name>
         <4B4DA4D4-8068-4C10-92BE-F03632522C75@oracle.com>
         <1513871689.11836.3.camel@primarydata.com>
         <87efnnkda2.fsf@notabene.neil.brown.name>
         <1514035013.3425.8.camel@kernel.org>
         <87d12tf99x.fsf@notabene.neil.brown.name>
In-Reply-To: <87d12tf99x.fsf@notabene.neil.brown.name>
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="=-5kzzpFN4P5FT5TZEkamN"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-5kzzpFN4P5FT5TZEkamN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Neil,

On Tue, 2018-01-02 at 10:29 +1100, NeilBrown wrote:
> On Sat, Dec 23 2017, Jeff Layton wrote:
>=20
> > On Fri, 2017-12-22 at 07:59 +1100, NeilBrown wrote:
> > > On Thu, Dec 21 2017, Trond Myklebust wrote:
> > >=20
> > > > On Thu, 2017-12-21 at 10:39 -0500, Chuck Lever wrote:
> > > > > Hi Neil-
> > > > >=20
> > > > >=20
> > > > > > On Dec 20, 2017, at 9:57 PM, NeilBrown <neilb@suse.com>
> > > > > > wrote:
> > > > > >=20
> > > > > >=20
> > > > > > When an i_op->getattr() call is made on an NFS file
> > > > > > (typically from a 'stat' family system call), NFS
> > > > > > will first flush any dirty data to the server.
> > > > > >=20
> > > > > > This ensures that the mtime reported is correct and stable,
> > > > > > but has a performance penalty.  'stat' is normally thought
> > > > > > to be a quick operation, and imposing this cost can be
> > > > > > surprising.
> > > > >=20
> > > > > To be clear, this behavior is a POSIX requirement.
> > > > >=20
> > > > >=20
> > > > > > I have seen problems when one process is writing a large
> > > > > > file and another process performs "ls -l" on the containing
> > > > > > directory and is blocked for as long as it take to flush
> > > > > > all the dirty data to the server, which can be minutes.
> > > > >=20
> > > > > Yes, a well-known annoyance that cannot be addressed
> > > > > even with a write delegation.
> > > > >=20
> > > > >=20
> > > > > > I have also seen a legacy application which frequently
> > > > > > calls
> > > > > > "fstat" on a file that it is writing to.  On a local
> > > > > > filesystem (and in the Solaris implementation of NFS) this
> > > > > > fstat call is cheap.  On Linux/NFS, the causes a noticeable
> > > > > > decrease in throughput.
> > > > >=20
> > > > > If the preceding write is small, Linux could be using
> > > > > a FILE_SYNC write, but Solaris could be using UNSTABLE.
> > > > >=20
> > > > >=20
> > > > > > The only circumstances where an application calling
> > > > > > 'stat()'
> > > > > > might get an mtime which is not stable are times when some
> > > > > > other process is writing to the file and the two processes
> > > > > > are not using locking to ensure consistency, or when the
> > > > > > one
> > > > > > process is both writing and stating.  In neither of these
> > > > > > cases is it reasonable to expect the mtime to be stable.
> > > > >=20
> > > > > I'm not convinced this is a strong enough rationale
> > > > > for claiming it is safe to disable the existing
> > > > > behavior.
> > > > >=20
> > > > > You've explained cases where the new behavior is
> > > > > reasonable, but do you have any examples where the
> > > > > new behavior would be a problem? There must be a
> > > > > reason why POSIX explicitly requires an up-to-date
> > > > > mtime.
> > > > >=20
> > > > > What guidance would nfs(5) give on when it is safe
> > > > > to specify the new mount option?
> > > > >=20
> > > > >=20
> > > > > > In the most common cases where mtime is important
> > > > > > (e.g. make), no other process has the file open, so there
> > > > > > will be no dirty data and the mtime will be stable.
> > > > >=20
> > > > > Isn't it also the case that make is a multi-process
> > > > > workload where one process modifies a file, then
> > > > > closes it (which triggers a flush), and then another
> > > > > process stats the file? The new mount option does
> > > > > not change the behavior of close(2), does it?
> > > > >=20
> > > > >=20
> > > > > > Rather than unilaterally changing this behavior of 'stat',
> > > > > > this patch adds a "nosyncflush" mount option to allow
> > > > > > sysadmins to have applications which are hurt by the
> > > > > > current
> > > > > > behavior to disable it.
> > > > >=20
> > > > > IMO a mount option is at the wrong granularity. A
> > > > > mount point will be shared between applications that
> > > > > can tolerate the non-POSIX behavior and those that
> > > > > cannot, for instance.
> > > >=20
> > > > Agreed.=20
> > > >=20
> > > > The other thing to note here is that we now have an embryonic
> > > > statx()
> > > > system call, which allows the application itself to decide
> > > > whether or
> > > > not it needs up to date values for the atime/ctime/mtime. While
> > > > we
> > > > haven't yet plumbed in the NFS side, the intention was always
> > > > to use
> > > > that information to turn off the writeback flushing when
> > > > possible.
> > >=20
> > > Yes, if statx() were actually working, we could change the
> > > application
> > > to avoid the flush.  But then if changing the application were an
> > > option, I suspect that - for my current customer issue - we could
> > > just
> > > remove the fstat() calls.  I doubt they are really necessary.
> > > I think programmers often think of stat() (and particularly
> > > fstat()) as
> > > fairly cheap and so they use it whenever convenient.  Only NFS
> > > violates
> > > this expectation.
> > >=20
> > > Also statx() is only a real solution if/when it gets widely
> > > used.  Will
> > > "ls -l" default to AT_STATX_DONT_SYNC ??
> > >=20
> >=20
> > Maybe. Eventually, I could see glibc converting normal
> > stat/fstat/etc.
> > to use a statx() syscall under the hood (similar to how stat
> > syscalls on
> > 32-bit arches will use stat64 in most cases).
> >=20
> > With that, we could look at any number of ways to sneak a "don't
> > flush"
> > flag into the call. Maybe an environment variable that causes the
> > stat
> > syscall wrapper to add it? I think there are possibilities there
> > that
> > don't necessarily require recompiling applications.
>=20
> Thanks - interesting ideas.
>=20
> One possibility would be an LD_PRELOAD which implements fstat() using
> statx().
> That doesn't address the "ls -l is needlessly slow" problem, but it
> would address the "legacy application calls fstat too often" problem.
>=20
> This isn't an option for the "enterprise kernel" the customer is
> using
> (statx?  what is statx?), but having a clear view of a credible
> upstream solution is very helpful.
>=20
> So thanks - and thanks a lot to Trond and Chuck for your input.  It
> helped clarify my thoughts a lot.
>=20
> Is anyone working on proper statx support for NFS, or is it a case of
> "that shouldn't be hard and we should do that, but it isn't a high
> priority for anyone" ??

How about something like the following?

Cheers
  Trond

8<--------------------------------------------------------
=46rom 755b6771deb8d793c90f56fddf7070d7c2ea87b5 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 4 Jan 2018 17:46:09 -0500
Subject: [PATCH] Support statx() mask and query flags parameters

Support the query flags AT_STATX_FORCE_SYNC by forcing an attribute
revalidation, and AT_STATX_DONT_SYNC by returning cached attributes
only.

Use the mask to optimise away server revalidation for attributes
that are not being requested by the user.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/inode.c | 40 ++++++++++++++++++++++++++++++++++------
 1 file changed, 34 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index b112002dbdb2..a703b1d1500d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -735,12 +735,22 @@ int nfs_getattr(const struct path *path, struct kstat=
 *stat,
 		u32 request_mask, unsigned int query_flags)
 {
 	struct inode *inode =3D d_inode(path->dentry);
-	int need_atime =3D NFS_I(inode)->cache_validity & NFS_INO_INVALID_ATIME;
+	unsigned long cache_validity;
+	bool force_sync =3D query_flags & AT_STATX_FORCE_SYNC;
+	bool dont_sync =3D !force_sync && query_flags & AT_STATX_DONT_SYNC;
+	bool need_atime =3D !dont_sync;
+	bool need_cmtime =3D !dont_sync;
+	bool reval =3D force_sync;
 	int err =3D 0;
=20
+	if (!(request_mask & STATX_ATIME))
+		need_atime =3D false;
+	if (!(request_mask & (STATX_CTIME|STATX_MTIME)))
+		need_cmtime =3D false;
+
 	trace_nfs_getattr_enter(inode);
 	/* Flush out writes to the server in order to update c/mtime.  */
-	if (S_ISREG(inode->i_mode)) {
+	if (S_ISREG(inode->i_mode) && need_cmtime) {
 		err =3D filemap_write_and_wait(inode->i_mapping);
 		if (err)
 			goto out;
@@ -757,9 +767,22 @@ int nfs_getattr(const struct path *path, struct kstat =
*stat,
 	 */
 	if ((path->mnt->mnt_flags & MNT_NOATIME) ||
 	    ((path->mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
-		need_atime =3D 0;
-
-	if (need_atime || nfs_need_revalidate_inode(inode)) {
+		need_atime =3D false;
+
+	/* Check for whether the cached attributes are invalid */
+	cache_validity =3D READ_ONCE(NFS_I(inode)->cache_validity);
+	if (need_cmtime)
+		reval |=3D cache_validity & NFS_INO_REVAL_PAGECACHE;
+	if (need_atime)
+		reval |=3D cache_validity & NFS_INO_INVALID_ATIME;
+	if (request_mask & (STATX_MODE|STATX_NLINK|STATX_UID|STATX_GID|
+				STATX_ATIME|STATX_MTIME|STATX_CTIME|
+				STATX_SIZE|STATX_BLOCKS))
+		reval |=3D cache_validity & NFS_INO_INVALID_ATTR;
+	if (dont_sync)
+		reval =3D false;
+
+	if (reval) {
 		struct nfs_server *server =3D NFS_SERVER(inode);
=20
 		if (!(server->flags & NFS_MOUNT_NOAC))
@@ -767,13 +790,18 @@ int nfs_getattr(const struct path *path, struct kstat=
 *stat,
 		else
 			nfs_readdirplus_parent_cache_hit(path->dentry);
 		err =3D __nfs_revalidate_inode(server, inode);
-	} else
+	} else if (!dont_sync)
 		nfs_readdirplus_parent_cache_hit(path->dentry);
 	if (!err) {
 		generic_fillattr(inode, stat);
 		stat->ino =3D nfs_compat_user_ino64(NFS_FILEID(inode));
 		if (S_ISDIR(inode->i_mode))
 			stat->blksize =3D NFS_SERVER(inode)->dtsize;
+		/* Return only the requested attrs if others may be stale */
+		if (!reval && cache_validity & (NFS_INO_REVAL_PAGECACHE|
+					NFS_INO_INVALID_ATIME|
+					NFS_INO_INVALID_ATTR))
+			stat->result_mask &=3D request_mask;
 	}
 out:
 	trace_nfs_getattr_exit(inode, err);
--=20
2.14.3


--=20
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

--=-5kzzpFN4P5FT5TZEkamN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEESQctxSBg8JpV8KqEZwvnipYKAPIFAlpO1gEACgkQZwvnipYK
APKJUhAAlZoxrWoNqOMODMik0jY24UghGqzrdIwJFciS25xOpjWXq6pl1ln9lslz
SoHeSkZnpEAnv50skz4GyjT/+lkAmEGlHZ8VP4TEfiZNiLxZHuIKci776n4PL5PK
pD4Au/OtTJpcdTZ2YYE7C4kHDMNoP6k35BGb4s8QoI65dVthILYGribA4XzcO9Nv
Z9v//JBT4+ox7f71PQhikdxDG/CruH8mT9dRBdaeMmew7OXfhAhcI51IiJxAVj6V
J69SccIQ1Pq7njHZSit/3l9yx4ifPS0qK6Rh+sAos87jJ5kDwXpjYMOzPDz4QeKY
1puozvCvrr/8qvSMwXVFPm6P3er1xkAFtd4jV9g1ttB4t+Q8dGfYoRueNKCcs7fs
zttbI7dmkBADWGS3/jDPOVGhScM4zYC+G1UljnSCsxpmcpwBe57gChw5g55x+9GN
vfJHN5ko6IrCJwckBdjgYN0EQO+VjqnGMQBst2xcUkUPcX1GTS36maSjuGEDhjAv
zLQXG+UGiDARZnN2m9yRG2ihtvaCkhtbaTsJ3bG+OiX67fkhhIsqXE6ePcuTnxZq
73sAGEZIa2MQpiNkDp5cV+dyxsKI8XAPtapJjWGWPHOgaGv+bNKBxM+6p9FKfWMz
Y/8tBBJDGkki+rP2ZL283amQE/f0j/S79dcCnyJSEhiyZJ2dyHQ=
=BQop
-----END PGP SIGNATURE-----

--=-5kzzpFN4P5FT5TZEkamN--


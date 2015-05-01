Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50485 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbbEABxf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 21:53:35 -0400
Date: Fri, 1 May 2015 11:53:26 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under
 pseudo root
Message-ID: <20150501115326.51f5613a@notabene.brown>
In-Reply-To: <20150430213602.GB9509@fieldses.org>
References: <20150421215417.GE13782@fieldses.org>
	<553781E2.1000900@gmail.com>
	<20150422150703.GA1247@fieldses.org>
	<20150423094431.1a8aa68b@notabene.brown>
	<5538EB18.7080802@gmail.com>
	<20150424130045.6bbdb2f9@notabene.brown>
	<553E2784.6020906@gmail.com>
	<20150429125728.69ddfc6c@notabene.brown>
	<20150429191934.GA23980@fieldses.org>
	<20150430075225.21a71056@notabene.brown>
	<20150430213602.GB9509@fieldses.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/n7CLNXGxMxQWleVXf9f95F7"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/n7CLNXGxMxQWleVXf9f95F7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 30 Apr 2015 17:36:02 -0400 "J. Bruce Fields" <bfields@fieldses.org>
wrote:

> On Thu, Apr 30, 2015 at 07:52:25AM +1000, NeilBrown wrote:
> > On Wed, 29 Apr 2015 15:19:34 -0400 "J. Bruce Fields" <bfields@fieldses.=
org>
> > wrote:
> > > Maybe drop the locking from nfsd_buffered_readdir and *just* take the
> > > i_mutex around lookup_one_len(), if that's the only place we need it?
> >=20
> > I think it is the only place needed.  Certainly normal path lookup
> > only takes i_mutex very briefly around __lookup_hash().
> >=20
> > One cost would be that we would take the mutex for every name instead
> > of once for a whole set of names.  That is generally frowned upon for
> > performance reasons.
> >=20
> > An alternative might be to stop using lookup_one_len, and use
> > kern_path() instead.  Or kern_path_mountpoint if we don't want to
> > cross a mountpoint.
> >=20
> > They would only take the i_mutex if absolutely necessary.
> >=20
> > The draw back is that they don't take a 'len' argument, so we would
> > need to make sure the name  is nul terminated (and maybe double-check
> > that there is no '/'??).  It would be fairly easy to nul-terminate
> > names from readdir - just use a bit more space  in the buffer in
> > nfsd_buffered_filldir().
>=20
> They're also a lot more complicated than lookup_one_len.  Is any of this
> extra stuff they do (audit?) going to bite us?
>=20
> For me understanding that would be harder than writing a variant of
> lookup_one_len that took the i_mutex when required.  But I guess that's
> my problem, I should try to understand the lookup code better....

Tempting though ... see below (untested).

While writing that I began to wonder if lookup_one_len is really the right
interface to be used, even though it was introduced (in 2.3.99pre2-4)
specifically for nfsd.
The problem is that it assumes things about the filesystem.  So it makes
perfect sense for various filesystems to use it on themselves, but I'm not
sure how *right* it is for nfsd (or cachefiles etc) to use it on some
*other* filesystem.
The particular issue is that it avoids the d_revalidate call.
Both vfat and reiserfs have that call ... I wonder if that could ever be a
problem.

So I'm really leaning towards creating a variant of kern_path_mountpoint and
using a variant of that which takes a length.

I think adding the d_revalidate is correct  and even adding auditing is
probably a good idea.

Maybe I'll try that (unless someone beats me to it...)

NeilBrown


>=20
> > I'm less sure about the locking needed in nfsd_lookup_dentry().  The
> > comments suggests that there is good reason to keep the lock for an
> > extended period.  But that reasoning might only apply to files, and
> > nfsd_mountpoint should  only be true for directories... I hope.
>=20
> I thought d_mountpoint() could be true for files, but certainly we won't
> be doing nfs4 opens on directories.
>=20
> > A different approach would be to pass NULL for the rqstp to
> > nfsd_cross_mnt().  This will ensure it doesn't block, but it might
> > fail incorrectly.  If it does fail, we drop the lock, retry with the
> > real rqstp, retake the lock and .... no, I think that gets a bit too
> > messy.
>=20
> Yes.
>=20
> > I think I'm in favour of:
> >  - not taking the lock in readdir
> >  - maybe not taking it in lookup
> >  - using kern_path_mountpoint or kern_path
> >  - nul terminating then names, copying the nfsd_lookup name to
> >    __getname() if necessary.
> >=20
> > Sound reasonable?
>=20
> I guess so, though I wish I understood kern_path_mountpoint better.
>=20
> And nfsd_lookup_dentry looks like work for another day.  No, wait, I
> forgot the goal here: you're right, nfsd_lookup_dentry has the same
> upcall-under-i_mutex problem, so we need to fix it too.
>=20
> OK, agreed.
>=20
> --b.


diff --git a/fs/namei.c b/fs/namei.c
index 4a8d998b7274..d6b2dc36029e 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2182,6 +2182,56 @@ struct dentry *lookup_one_len(const char *name, stru=
ct dentry *base, int len)
 }
 EXPORT_SYMBOL(lookup_one_len);
=20
+struct dentry *lookup_one_len_unlocked(const char *name,
+				       struct dentry *base, int len)
+{
+	struct qstr this;
+	unsigned int c;
+	int err;
+	struct dentry *ret;
+
+	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
+
+	this.name =3D name;
+	this.len =3D len;
+	this.hash =3D full_name_hash(name, len);
+	if (!len)
+		return ERR_PTR(-EACCES);
+
+	if (unlikely(name[0] =3D=3D '.')) {
+		if (len < 2 || (len =3D=3D 2 && name[1] =3D=3D '.'))
+			return ERR_PTR(-EACCES);
+	}
+
+	while (len--) {
+		c =3D *(const unsigned char *)name++;
+		if (c =3D=3D '/' || c =3D=3D '\0')
+			return ERR_PTR(-EACCES);
+	}
+	/*
+	 * See if the low-level filesystem might want
+	 * to use its own hash..
+	 */
+	if (base->d_flags & DCACHE_OP_HASH) {
+		int err =3D base->d_op->d_hash(base, &this);
+		if (err < 0)
+			return ERR_PTR(err);
+	}
+
+	err =3D inode_permission(base->d_inode, MAY_EXEC);
+	if (err)
+		return ERR_PTR(err);
+
+	ret =3D __d_lookup(base, &this);
+	if (ret)
+		retrun ret;
+	mutex_lock(&base->d_inode->i_mutex);
+	ret =3D  __lookup_hash(&this, base, 0);
+	mutex_unlock(&base->d_inode->i_mutex);
+	return ret;
+}
+EXPORT_SYMBOL(lookup_one_len_unlocked);
+
 int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
 		 struct path *path, int *empty)
 {

--Sig_/n7CLNXGxMxQWleVXf9f95F7
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVULcljnsnt1WYoG5AQKQUA//XkUuarl/ViQJMOgs93qCqiuBNUR2lDPn
ts0Rp4M2DZpQnqccjeGBpW9sjJewDQnxK1tlVazpJZkmRPAubpU+5YR04z/jvL5u
i+XfIY+t+GRdp4LaRscxzYI3NP5hiDj7+bzhdvHfvZKyAkJf1X7rwqpZtdZynyhe
j9WvlZZaX0AaSpiN4pVk3u2ha6UWCAv9jizRLKRBhn6wplh0l6aj0x1CGbCwy2pb
y40ySAKAXC8BSbdDZt6IUv5V+lD+oZS6aCmg1Ak0heakkykoqEDeH/AH9CsKuXD6
OQVCLWtbUI8zhJdtxdtCjNKsfiTYudIp24RZB+GqGEeeGaEGqzt81DppbhO9nb4f
v0ZjWu9OyIUw2MUFIJqjQjASzbxszbVWEn+EBNq63hGzs0Vor2J2HpGQG9VBOTZy
L/YUAZb1mzwYb+0ZiPwL+MULHWuZiCNq9fAAmgoiw7cwFwTMhVJBtLL68IrX+9Wu
g9Uddm0IGt8VJQ7P/HbLvn8kHdASHl8j1cqfWImC2sQ/Ghbk53flnUYtBCCA8NJt
WeDJfhKDatbFMEE8NTUYbTJtng6SFQAkF7cLX25bV2G5Gv5nF7EHLw72gdvjrJFo
DJc//0qC0fNeogc5E7M7kC8qT4hA6Un1FrgLIHhTIS7SWnuiCtSnEhTZrIRlqvTP
bysh7Wfg9eg=
=i4+b
-----END PGP SIGNATURE-----

--Sig_/n7CLNXGxMxQWleVXf9f95F7--

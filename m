Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:46853 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790AbaCFFrT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Mar 2014 00:47:19 -0500
Date: Thu, 6 Mar 2014 16:47:11 +1100
From: NeilBrown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/8] NFS: prepare for RCU-walk support but pushing tests
 later in code.
Message-ID: <20140306164711.5bda7693@notabene.brown>
In-Reply-To: <20140305064946.GY18016@ZenIV.linux.org.uk>
References: <20140305025813.27421.23871.stgit@notabene.brown>
	<20140305030028.27421.92032.stgit@notabene.brown>
	<20140305053441.GX18016@ZenIV.linux.org.uk>
	<20140305165933.09ca9d84@notabene.brown>
	<20140305064946.GY18016@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/Q9nj2uciUWV_JOytF5A7=qX"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/Q9nj2uciUWV_JOytF5A7=qX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 5 Mar 2014 06:49:46 +0000 Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Wed, Mar 05, 2014 at 04:59:33PM +1100, NeilBrown wrote:
> > > 	b) having already become negative.
> >=20
> > I didn't think dentries ever became negative.  When a file is deleted t=
he old
> > positive dentry is unlinked and a new negative dentry is created in it's
> > place.
> > Or has that changed since last I looked?
>=20
> It has never been true.  See what d_delete() is doing.  If there was only
> one reference to dentry, it *does* become negative.

Seems I missed that - thanks.

>=20
> > If they can become negative, then I could
> >    dir =3D ACCESS_ONCE(parent->d_inode);
> >    if (!dir)
> >         return -ECHILD;
> >=20
> > Do you think that would be safe?
>=20
> Depends on what you do with it afterwards...

It deferences i_sb, reads a couple of integer fields (never writes) and=20
    rcu_dereference(NFS_I(inode)->delegation);

which will currently always be NULL on a directory and if we ever did have
directory delegation, should clearly be safe to reference under rcu.

Here is my current version of that patch.
Thanks again,
NeilBrown

=46rom 8b85de80ccc7be4e9a31a547737e091fba2ae81f Mon Sep 17 00:00:00 2001
From: NeilBrown <neilb@suse.de>
Date: Tue, 4 Mar 2014 15:06:58 +1100
Subject: [PATCH] NFS: prepare for RCU-walk support but pushing tests later =
in
 code.

nfs_lookup_revalidate, nfs4_lookup_revalidate, and nfs_permission
all need to understand and handle RCU-walk for NFS to gain the
benefits of RCU-walk for cached information.

Currently these functions all immediately return -ECHILD
if the relevant flag (LOOKUP_RCU or MAY_NOT_BLOCK) is set.

This patch pushes those tests later in the code so that we only abort
immediately before we enter rcu-unsafe code.  As subsequent patches
make that rcu-unsafe code rcu-safe, several of these new tests will
disappear.

With this patch there are several paths through the code which will no
longer return -ECHILD during an RCU-walk.  However these are mostly
error paths or other uninteresting cases.

A noteworthy change in nfs_lookup_revalidate is that we don't take
(or put) the reference to ->d_parent when LOOKUP_RCU is set.
Rather we rcu_dereference ->d_parent, and check that ->d_inode
is not NULL.  We also check that ->d_parent hasn't changed after
all the tests.

In nfs4_lookup_revalidate we simple avoid testing LOOKUP_RCU on the
path that simply calls nfs_lookup_revalidate() as that function
already performs the required test.



Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f5509f95f261..7530acdc5c42 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1055,21 +1055,30 @@ static int nfs_lookup_revalidate(struct dentry *den=
try, unsigned int flags)
 	struct nfs4_label *label =3D NULL;
 	int error;
=20
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
-	parent =3D dget_parent(dentry);
-	dir =3D parent->d_inode;
+	if (flags & LOOKUP_RCU) {
+		parent =3D rcu_dereference(dentry->d_parent);
+		dir =3D ACCESS_ONCE(parent->d_inode);
+		if (!dir)
+			return -ECHILD;
+	} else {
+		parent =3D dget_parent(dentry);
+		dir =3D parent->d_inode;
+	}
 	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);
 	inode =3D dentry->d_inode;
=20
 	if (!inode) {
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		if (nfs_neg_need_reval(dir, dentry, flags))
 			goto out_bad;
 		goto out_valid_noent;
 	}
=20
 	if (is_bad_inode(inode)) {
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
 		dfprintk(LOOKUPCACHE, "%s: %pd2 has dud inode\n",
 				__func__, dentry);
 		goto out_bad;
@@ -1078,6 +1087,9 @@ static int nfs_lookup_revalidate(struct dentry *dentr=
y, unsigned int flags)
 	if (NFS_PROTO(dir)->have_delegation(inode, FMODE_READ))
 		goto out_set_verifier;
=20
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
 	/* Force a full look up iff the parent directory has changed */
 	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentr=
y)) {
 		if (nfs_lookup_verify_inode(inode, flags))
@@ -1120,13 +1132,18 @@ out_set_verifier:
 	/* Success: notify readdir to use READDIRPLUS */
 	nfs_advise_use_readdirplus(dir);
  out_valid_noent:
-	dput(parent);
+	if (flags & LOOKUP_RCU) {
+		if (parent !=3D rcu_dereference(dentry->d_parent))
+			return -ECHILD;
+	} else
+		dput(parent);
 	dfprintk(LOOKUPCACHE, "NFS: %s(%pd2) is valid\n",
 			__func__, dentry);
 	return 1;
 out_zap_parent:
 	nfs_zap_caches(dir);
  out_bad:
+	BUG_ON(flags & LOOKUP_RCU);
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	nfs4_label_free(label);
@@ -1152,6 +1169,7 @@ out_zap_parent:
 			__func__, dentry);
 	return 0;
 out_error:
+	BUG_ON(flags & LOOKUP_RCU);
 	nfs_free_fattr(fattr);
 	nfs_free_fhandle(fhandle);
 	nfs4_label_free(label);
@@ -1499,9 +1517,6 @@ static int nfs4_lookup_revalidate(struct dentry *dent=
ry, unsigned int flags)
 	struct inode *inode;
 	int ret =3D 0;
=20
-	if (flags & LOOKUP_RCU)
-		return -ECHILD;
-
 	if (!(flags & LOOKUP_OPEN) || (flags & LOOKUP_DIRECTORY))
 		goto no_open;
 	if (d_mountpoint(dentry))
@@ -1518,6 +1533,9 @@ static int nfs4_lookup_revalidate(struct dentry *dent=
ry, unsigned int flags)
 		struct dentry *parent;
 		struct inode *dir;
=20
+		if (flags & LOOKUP_RCU)
+			return -ECHILD;
+
 		parent =3D dget_parent(dentry);
 		dir =3D parent->d_inode;
 		if (!nfs_neg_need_reval(dir, dentry, flags))
@@ -2273,9 +2291,6 @@ int nfs_permission(struct inode *inode, int mask)
 	struct rpc_cred *cred;
 	int res =3D 0;
=20
-	if (mask & MAY_NOT_BLOCK)
-		return -ECHILD;
-
 	nfs_inc_stats(inode, NFSIOS_VFSACCESS);
=20
 	if ((mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) =3D=3D 0)
@@ -2302,6 +2317,9 @@ force_lookup:
 	if (!NFS_PROTO(inode)->access)
 		goto out_notsup;
=20
+	if (mask & MAY_NOT_BLOCK)
+		return -ECHILD;
+
 	cred =3D rpc_lookup_cred();
 	if (!IS_ERR(cred)) {
 		res =3D nfs_do_access(inode, cred, mask);
@@ -2316,6 +2334,9 @@ out:
 		inode->i_sb->s_id, inode->i_ino, mask, res);
 	return res;
 out_notsup:
+	if (mask & MAY_NOT_BLOCK)
+		return -ECHILD;
+
 	res =3D nfs_revalidate_inode(NFS_SERVER(inode), inode);
 	if (res =3D=3D 0)
 		res =3D generic_permission(inode, mask);

--Sig_/Q9nj2uciUWV_JOytF5A7=qX
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUxgL3znsnt1WYoG5AQJIcQ/6AtE5iqU3nwj2RIBaQHOe4hRcF8gCfaFJ
qvbC7mkKXQDczhKdbe1121cOThNdxOfy+fGYfWOebyDSbQgNuG7SMs5nea3RqxaX
tjJYFJsOxwzYtVui8oxOmcqQvn8o09NmkiUWRHsD33mqqKzAAbjvo8ilLqby6g6V
XJgEH/det0qJ6G8ggatN4n2sSfYnKPJ+5qJkVWRWuyj8xyWgpVwEBtIKhdSQOE4/
/vLQwYdHmH5e2xLqoZXR//VJx3GSADigYFShE8ijT2UOThhy4QCM3l+eyuNr/8Wp
CUZCBS4Zy8t0XurLbk/zNtS2VPTRfL/RI8PKvGuJKYKwqVYYk6rW5rWTJxjQ+ULn
cXW9aTfBzPoPQUPAfazsfqvA/bp/VMpfFmoNiTqzxUAH0dQaMiGqhGLMfbn0+KGX
7tK4lL0TCnUy9+xMVNaFQVqsANbrNELgs49zYTnzs9Zuhegj/uhGy8NM9HfzuLPs
+HXmMOdqAS/Td87KJ80kGMh60n9e+RK2NLpP46SQdonG/8UK1UkP1vorn5JZRCbb
a/PETbjdDA0noGsJUwevqJaxwsH2SGo0wQZzED54r2qTeSKMngD2C1Dvsmxnrndc
rGrmXPyU+iV8F5PnKlNsdm8ycH3TxuxMMB+APLZEYBDMh9nlpPtQGllbjMbwaE83
WD9xLgAB/tg=
=EcAg
-----END PGP SIGNATURE-----

--Sig_/Q9nj2uciUWV_JOytF5A7=qX--

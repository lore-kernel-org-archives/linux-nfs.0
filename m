Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 027F71E1024;
	Sat, 12 Sep 2026 02:59:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789181980; cv=none; b=K91raxKRcKlfVoJSQji7/rtuRc8pquraQkRDrol0JJPPCs3feeutUBwESi5tpXUPdsWqvYdFr/jfu1ik2Zkm104Rz6ZvzdbessO5A2mtTbwfrN4FQFfOU3T3vqWFRn+Qrx3qKcrvEg76yMupgv58y1LusnYWrTy5lQujpbUD3S4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789181980; c=relaxed/simple;
	bh=yIU2CRNgmzJweC9RLYMbDaF7MKPxliyBuuloFxZebMk=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=CkROG00NqhjFfiBl5BPkAyYnEJhtyZvOXYCZFSBy2TJ/smd7UsqaBgpll10RFKfEvRxDpstvz5Y5TwtaIPKThB1JANXXlVuDs5x+a5gihJgCgiUJeODZ8hkHFHND1wyc3v7NYU01G+BbofxGiXkSJwjicrMxgYxC6K1fdjczHTI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gHNIMKYB; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=gwolIUG0; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gHNIMKYB";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gwolIUG0"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 0D0937A0096;
	Fri, 11 Sep 2026 22:59:37 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Fri, 11 Sep 2026 22:59:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789181976; x=1789268376; bh=LHH08Lbxk3CBjSEXN6sXmXPpvve6CmbUsn9
	fOOpErTE=; b=gHNIMKYBigwtdatUfynE5mV8rHYCiR+bHEKW2yfmLKG6rBSk/h7
	bjXl8UVR76ddEhQC1SMlugaiy8FSTK5JNXd8d+InwEyYo6C3KzWqJABlsKdqFFXv
	a+13KTNqJ2iN0JS13c1nkMjaXayUD1ZLVeqNna+NmyJON3dpraNq9nMLAFuqcG3b
	+r830XYcvvo/SyH3v6Gi7ViWfRkXrjzyV9+J2JYhsm87MzvEbTDGbK9KMIwS5YO8
	lzfvWJ/lOGFJ+bSskF+NFIEx7H/SPn0csrpnyqodOWtQzQtv2BOAKk3ESm+PQIl3
	7cd7Hhi13jmDUpH/p1oIUVcR+uB+aLGspcQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789181976; x=
	1789268376; bh=LHH08Lbxk3CBjSEXN6sXmXPpvve6CmbUsn9fOOpErTE=; b=g
	wolIUG0Xm7JAI/cWO5vMHlissMPV5/fjT89MvZjD/vWsvar+JZTLzsUelZweU/yL
	1C+Jtuzltf3l2/h1IQnUntR5s0E7ZXdDqmwTnqc4LEO8+SfkYiu3GEEq/1aGw/pD
	nJL/ByopOACPfyZIdLG03T2HG7zrMvpJjsYLwEEFHdG9zGakocIMTeFE6UTbV9Oh
	3YQrU0Wt1Nlqt6EfGcp0cEfZiT6zMNmQg9l56y4+HBwkaAP0gwIX7OPchHcMqkBh
	cN8h74jzHNNzgaDMryspjpeUsTZ4CvEefJgfnt7BFlelP0V5FcPblxa1OG0LGwur
	r8Fn8ETVoXdnReKBImA8Q==
X-ME-Sender: <xms:GMCkahxdmUDIBooS-rR_F2pMK-lsnv2nS2NVaXrD-Mz0wujstPHpxw>
    <xme:GMCkajjRkWfwAAn0gevUH9uuawQ4UXkhjH3T6246Jy7yLd3AAfiwBx3fofuQRnGTH
    sWXvudn4pY2wgBX7ojhmheMAUI4Lc3caAcL_V1JA3ZoaeRlKJQi>
X-ME-Received: <xmr:GMCkatlA8nVcgCSQM8zkmk2Mtbks2oOdqIqb--qkGppB-52IXh3KGobQdQqf6OxVfxVBDd5it-l31ZhKn4CBG1uH4_8PI48>
X-ME-Proxy-Cause: dmFkZTGxQb0JYXgbUJZqXdXKxGmOez554xmHAImfaYx8EcilyXYGz0JiKw5VrrSFbZM6lJ
    7PCDMieqkvnLv8rgP6KU9qGTZJi6UmJa8TV3xK76Jzpxm5nWbDeSfdQ4xo5j9AVfHaEEyM
    tjN/DaxMPj2DxBfIQLHFcRQoRvUPUCgJtaGQxQCE/xJCq0WZLiQGxmbejGoNTLYrruAhNn
    Zg/6gbvneMRNDsZ1VmxV/bmnPmwcbjArm79smObm2SaURjJscE6wxZZbIjj25T8WkN8AXd
    LGd7jZFtM9hnf2QtYbmPVAi5jEcvyN4peoV2RctEx//73m1DqurxbhRHDe8DdZFdmMcGcm
    BowePH0y7Ud90w5+XQDsnLo1mAc+biKFbKUAUnliSccWmhupbW8Vv469obs0rNfeFbGCT/
    BdwZxwVLnUHLIkE78R4IFdCxGSY9avdPrJQDBRPpOXmonyuVeIQXtqNJGR1AnNBA93Rjaz
    ZZBr8Ss5Lx615KX4NToGGS3ekfOQFsWEZXGcXzV/Eyjkq3mOTLcBrz2bEybHZpwr50eGmF
    +NOUDoyNLTHrQdWeqUv5rdGnqd17GgTaMC5b82r2ZE7veZzwjPqjxg1xjA8ai6ObBJzXFi
    q+Ky2UMwVOM1fQ1W/8uIbP1xuwdpNdiqPhesOV0f1WYopMAMXwnvtyi/pVvg
X-ME-Proxy: <xmx:GMCkapgAJGOfyHn2JUnaYJriGmF2SUCDu5xZB7K_s3jOFDRaNfgy6Q>
    <xmx:GMCkah2lsTL4fqVHTqjshGAXDKqwy2xIK_GXbZ2gzpl4aMfG_Ya4dw>
    <xmx:GMCkaiK7BN8qZbLvLsc7UJ3vYNpNY03NETj8sk4Tv9QTtEiN8fMv_A>
    <xmx:GMCkahyVVqiIGI2lUVdyEgzDJEfaaazDZ_h1HBV5x3TQz9DGyJ21Fw>
    <xmx:GMCkag-WbhvbDTyZf89DsA0cjK4iJE-maNmmZprcPGapJpE0ZFqokuQY>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 11 Sep 2026 22:59:34 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
In-reply-to: <61fedba0-78f4-403f-9f74-0795ccbfaf52@slotpi15m67>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-5-neilb@ownmail.net>
  <61fedba0-78f4-403f-9f74-0795ccbfaf52@slotpi15m67>
Date: Sat, 12 Sep 2026 12:59:30 +1000
Message-id: <178918197027.207413.88835240014013392@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 11 Sep 2026, Chuck Lever wrote:
> On Thu, 10 Sep 2026, NeilBrown wrote:
>=20
> > vfs: change vfs_lookup_open() to return found dentry in path.dentry.
> >
> > The caller - nfsd - needs to know the type of object found when a
> > non-regular file was found to exist.  This is most easily done
> > by passing back the dentry.
> >
> > So change calling pattern so that the path (now called "path") contains
> > the parent dentry on entry and the child dentry on exit.
> > vfs_lookup_open() will dput() the parent and caller must dput() the
> > child.
> >
> > If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> > use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> > dentry to the dcache we return %NULL in %path->dentry.
> >
> > Signed-off-by: NeilBrown <neil@brown.name>
>=20
> "vfs_lookup_open() will dput() the parent and caller must dput() the
> child."
>=20
> Is that the whole contract? When lookup_noperm_common() or
> alloc_empty_file() fails, path->dentry still holds the parent on return:
>=20
> 	error =3D lookup_noperm_common(last, path->dentry);
> 	if (error)
> 		return ERR_PTR(error);
>=20
> 	file =3D alloc_empty_file(open_flag, current_cred());
> 	if (IS_ERR(file))
> 		return file;
>=20
> The parent is replaced only after lookup_open() returns. Could the
> message say that on success and on -EFTYPE the parent is replaced by
> the child and its reference dropped, and that on any other error @path
> is untouched?

The "contract" is in the kdoc comment:

 * Consequently the caller must be prepared for @path.dentry to be
 * dput(), and it must dput() whatever is in @path.dentry after the
 * call.

plus the statement above that about -EFTYPE.  But I'll improve the
commit message to match.


>=20
>=20
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata =
*nd, struct file *file,
> >
> >  /**
> >   * vfs_lookup_open - open and possibly create a regular file
> > - * @parent: directory to contain file
> > + * @path: directory to contain file
>=20
> Now that @path is in/out, could this say what it holds on return as
> well? Something like "on entry, the directory to contain the file; on
> return, the dentry found".
>=20
> The prototype in include/linux/namei.h still names this parameter
> "parent".
>=20
> > @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata=
 *nd, struct file *file,
> >   * If the fs object found is not a regular file then -EFTYPE is
> >   * returned.
> >   *
> > + * @path is updated to contain the dentry that was found if possible.
> > + * In particular, if -EFTYPE is returned, then @path.dentry will be the
> > + * object that is not a regular file, or %NULL.
> > + * Consequently the caller must be prepared for @path.dentry to be
> > + * dput(), an it must dput() whatever is in @path.dentry after the call.
>=20
> "an it must dput()" -> "and it must dput()".
>=20
> "if possible" leaves the reader guessing which paths update @path. As
> above, it is updated on success and on -EFTYPE, and untouched on every
> other error. Since the caller cannot tell the two cases apart from the
> return value alone, is that worth stating here?

The current code also may update on -ENOENT and -EEXIST, depending on
whether the filesystem provided ->atomic_open.  I guess it would be
cleaner to updated it precisely on success and -EFTYPE.

>=20
>=20
> > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, =
struct qstr *last,
> >  	op.mode =3D mode;
> >  	dentry =3D lookup_open(&nd, file, &op);
> >
> > -	if (IS_ERR(dentry))
> > +	if (IS_ERR(dentry)) {
> > +		if (dentry =3D=3D -EFTYPE) {
>=20
> dentry is a struct dentry * and -EFTYPE is an int. Both compilers warn:
>=20
> warning: comparison between pointer and integer ('struct dentry *' and
> 'int') [-Wpointer-integer-compare]
>=20
> and with CONFIG_WERROR (the default for COMPILE_TEST builds) fs/namei.c
> no longer compiles. It evaluates as intended only because the int is
> converted to a pointer with the same bits as ERR_PTR(-EFTYPE). Should
> this be:

I didn't know about CONFIG_WERROR ... I've enabled it for future builds.

>=20
> 		if (PTR_ERR(dentry) =3D=3D -EFTYPE) {
>=20
>=20
> > +			/* Try to determine what was found */
> > +			struct dentry *child =3D d_lookup(path->dentry, &nd.last);
> > +			dput(path->dentry);
> > +			path->dentry =3D child;
> > +			WARN_ON_ONCE(child && d_is_reg(child));
>=20
> lookup_open() drops the parent's inode lock before returning, so this
> d_lookup() runs unlocked. Between ->atomic_open() rejecting a
> non-regular object and this lookup, another task can unlink it and
> create a regular file with the same name. d_lookup() can also return a
> hashed negative dentry.
>=20
> Either way @path.dentry is then neither "the object that is not a
> regular file" nor NULL, and the WARN fires on a race that ordinary
> concurrent activity (remote, over nfsd) can drive. Could this store
> NULL when the child is negative or regular, and drop the WARN, so the
> documented contract always holds?

Yes, it could race, couldn't it.  Doing that lookup in atomic_open()
in the locked region might be possible, but I don't think it would be a
good idea.

I wonder if I could drop __O_REGULAR and just check the dentry returned...

>=20
> Does this recovery find anything for most ->atomic_open()
> implementations? lookup_open() only reaches ->atomic_open() with a
> negative or in-lookup dentry, and atomic_open() dputs it on error, so
> what d_lookup() sees is whatever the filesystem hashed before failing.

Hmmm...
I think that if cephfs return -EFTYPE then there will be a dentry in the
dcache.  In other cases there wan't.
As if we don't pass __O_REGULAR to ceph it will happily open whatever
it finds - device or pipe or whatever.  So that isn't good.

>=20
> The NFS client d_drop()s the dentry before returning -EFTYPE:
>=20
> fs/nfs/dir.c:nfs_atomic_open() {
> 	...
> 		d_drop(dentry);
> 		switch (err) {
> 		...
> 		case -EISDIR:
> 		case -ENOTDIR:
> 			if (open_flags & __O_REGULAR) {
> 				err =3D -EFTYPE;
> 				break;
> 			}
>=20
> gfs2 and cifs return -EFTYPE before instantiating anything. Only ceph
> checks d_is_reg() on a dentry it has already spliced. So on gfs2, cifs
> and a re-exported NFS mount, path->dentry is always NULL here, and the
> caller cannot distinguish a directory from a symlink. That might not
> be acceptable for what nfsd needs. The found type needs to come
> back from ->atomic_open() itself, probably.

gfs2_atomic_open() does a lookup which will return whatever is found.
Then it call gfs2_create_inode() which gets an exclusive lock on the
directory and repeats the lookup - the second time it checks __O_REGULAR
as you say, before instantiating anything.

Maybe I should start by tidying up the __O_REGULAR handling.
I think the inode, if available, should always be instantiated, and
non-regular files should always go to finish_no_open() - finish_open()
should only be called on regular files and (maybe) directories.
VFS code should be responsible for __O_REGULAR handling.

I agree that getting the found type back, when possible, would be an
improvement.  I don't know how best to do it...
We *could* get NFSv4 to make a bad inode (make_bad_inode()?), set the
type, unhash the dentry and attach the inode, and pass that to
finish_no_open().   It would be ugly.

And I wonder if it is important at all.  Linux NFS client doesn't seem
to handle there error from OPEN at all - except maybe in
flexfilelayout.c.

Thanks,
NeilBrown



>=20
>=20
> --=20
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
>=20


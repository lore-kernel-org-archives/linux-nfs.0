Received: from fout-b5-smtp.messagingengine.com (fout-b5-smtp.messagingengine.com [202.12.124.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE82D37CD2E;
	Sun, 13 Sep 2026 21:09:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789333792; cv=none; b=HOLZ97w8kj78cbWYh076DjkvRo/qDhyN/9ZR+eu4gsQOcbT/rJz3CDeVWhAJcRhxuRal1C4TJd1oEDlPB2h+vvK1hrpUaM4iRg6e/KeYK+ZMlhK874Uh6UrB47BcLxWwC8pib3dwuHXljgSa8CLosm2yLY1alHT0YDaAyWBb7VE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789333792; c=relaxed/simple;
	bh=vWR6WlpGJ80LF5bez3GdEKaamRmKZpKy3aitDW0zwf8=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=BYZxqOEQlECi8ev2lBrkWuqaF489QFVH+8YrQKwITLgbgd2fw0aTqN5eQswV0Qm2sFccG/qpkZkIMVuJjwIhmo6Hh1frs80aT0Bu2hIyTzuVMWtQMpghMMzxrQzMzMYCeEhcJuRzcoVZ7rWcAERpM58DrpEkYf42paOSA+vRSMM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=CsanxDBr; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Jsm+rmha; arc=none smtp.client-ip=202.12.124.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="CsanxDBr";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Jsm+rmha"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id E481B1D000EC;
	Sun, 13 Sep 2026 17:09:48 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Sun, 13 Sep 2026 17:09:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789333788; x=1789420188; bh=qsu1FzY9cpwL5bdd7XYkYoI9sazaULPh/ry
	aVdffyi4=; b=CsanxDBrPm222oUfqW3RRPczbAYatNeJx9MRkWok/LVER7KcCVo
	sGA4CjZYXWn2TuuONEgpTUMC18TGqBfDG2PJfEIDmn1YWfZB6e8ZxU0RFK5qrnyW
	XWtVlE0zfrc/w5jlJQwizMBJ8Jl6/lXa222njtSUyxnWIZ8fa/sOBBX4/Ol4DT92
	vRMeOW4CwEOFyYC5fSU5LuJypoOuCqyHUkuu15xmXCzpjgrCCb4+F6rfETuqbvuo
	/gaMqMGeawSY+bmxOvJHJ0o3pFnFgOaYI7IGhhBPWee/nAG5G9EbfJJzN5Ka9PJc
	gF9fwPo8i6N7G/16VKMvbjPOIy4Gg2ctagQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789333788; x=
	1789420188; bh=qsu1FzY9cpwL5bdd7XYkYoI9sazaULPh/ryaVdffyi4=; b=J
	sm+rmhac24VyBKR1u8znMO4lzDRN681UqSSv93Bq5XSKn0VKMMeRjTNMJaRxkh5Y
	Yq4UpWF304hM4WBkguw9P/EhNkuRuT22yCv2c0fwp9g13wQB//gqD9J2rBLJPTJw
	w+NsPxkb28YjhTxpAPCRqkrmisbrmvqg5Vd2JJ8VOWH+5idNCwF7zsQcwksyI0cS
	3NN7ejGEyLKfZjOzKNp6q0h39mtggjMR6jf3ZG+MF/zezRXrsI5IQ2KF2KadTn1V
	XAGzaWTpyoAHaHir0cKxms+Uhn9yIzmcjwVhPcgV6n+Jm2EL0UtDrZMpvNuAdd0/
	YEnz0WWYhCsxYb5yYrPUg==
X-ME-Sender: <xms:HBGnapvj-8HDQ1l2qfCBwyAdlQFCrl0Pdxr3HvVPw9LjWgfh-cc1wQ>
    <xme:HBGnahgmCrJs6c3xEwqo0la9d6o_vlFEH1ZDhYKY3INfmLDS5GN-ip2mBFvu9CgyN
    JHjf2qeT4UsWPJjdUQaaU-bc4PYfSBDSJfaOXPekRogqBY1wsM>
X-ME-Received: <xmr:HBGnai-GOG5RdO-Lq6gZlS7vp8fAzfECv_EEOBLulzH-qojcBir5cj9DAA5mxnXKaKvc9jY0SKndkmY0G4As4eqVaufu0Co>
X-ME-Proxy-Cause: dmFkZTF5inYGGVUtG+h0+sZ2cK+qAb8g6Xzv8VKSnoIP8+koX90BmLEHdwovsYXiv0YSD/
    hXDthF8Oz9MhEvL9/q+k8++qaxFWCedsRzWCDzzPiaWNItyZvr88W8U3SgMXgV2BDe79PF
    BNBotaaBRBxZ2Wk+hE/yUUSkTLgFpXtTurDdtj0H0fX+uFe2kV7vd3R9+d2HxOP+PLDzd1
    h3AWAWy8IMEEq6urjAQ+ePiqVyNV0AeulxQVLZp3ijga2qIyUvs4sJVCMTw3xzSwkS8+F+
    omkaNuKunDlupSzuEuqF0RfM4nAvVQJ8oVfbdVqVB4f9Zg5t6286syFdnXx2jfPe2opfR1
    kN2UklXnUbf9CSKsYWNkKC+nAlepsudrP1loXwSP1t743Rkq/Iw6H95/cvu0wFHoF6JhjH
    /MDsJMtzHUpqXbk5+O5bfV3meg2gENxFDqtiDaR59Qk1M8QHJrpQiClhmwuwCsfZMVGp0c
    lV6yQqWdgzIAU/4Gnd85OgEdpz61JxnOLMkUG8e3yYXikitsEnhG44Y0XbQbzAAS4nenNu
    7UgIlUvhcnJYA3DIze7Ikf6MQEUhoCIe/ptVjTISMVpJpvgg4QiJe+JUHYkgGaKV9avWdv
    aq88FFIWCjjY7D5KaDLsoIG+bDTisJo1o1dqZtYQyoR13nDZgON7CIRFDMng
X-ME-Proxy: <xmx:HBGnast53KDJUtMHSMoPmHnoy7i4uXVzX9h3r4JSI3DdYclZ6hfJVg>
    <xmx:HBGnaurLrgzf61D0GzVPCEmyvQY1_YkF7jsYT7QF7i8HuR-eXE8qJw>
    <xmx:HBGnaooMETpKzU4g-CHihtt3OUZ3OcsdMFX4HslAcCF1M5wLVNK7QA>
    <xmx:HBGnalajgcgzO0e9ShNb5mGqH93p68qXN49X93_FaUdq87A-_KkWjw>
    <xmx:HBGnahi_Uoc4YIZMqKoMLuWfzVa-cv_vECLZu0dtL448hNyZpo75omUi>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 13 Sep 2026 17:09:46 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Mateusz Guzik" <mjguzik@gmail.com>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
In-reply-to: <2mr6afww7r67o2hjblafhdwqffg3zicsqjkddnquunfaalolpd@yq54r5nlqftm>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-5-neilb@ownmail.net>
  <2mr6afww7r67o2hjblafhdwqffg3zicsqjkddnquunfaalolpd@yq54r5nlqftm>
Date: Mon, 14 Sep 2026 07:09:42 +1000
Message-id: <178933378203.207413.6142548185484898062@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 14 Sep 2026, Mateusz Guzik wrote:
> On Thu, Sep 10, 2026 at 10:20:50AM +1000, NeilBrown wrote:
> > From: NeilBrown <neil@brown.name>
> >=20
> > The caller - nfsd - needs to know the type of object found when a
> > non-regular file was found to exist.  This is most easily done
> > by passing back the dentry.
> >=20
> > So change calling pattern so that the path (now called "path") contains
> > the parent dentry on entry and the child dentry on exit.
> > vfs_lookup_open() will dput() the parent and caller must dput() the
> > child.
> >=20
> > If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> > use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> > dentry to the dcache we return %NULL in %path->dentry.
> >=20
> > Signed-off-by: NeilBrown <neil@brown.name>
> > ---
> >  fs/namei.c | 31 ++++++++++++++++++++++---------
> >  1 file changed, 22 insertions(+), 9 deletions(-)
> >=20
> > diff --git a/fs/namei.c b/fs/namei.c
> > index 0c787363b101..30ccc0c2f02f 100644
> > --- a/fs/namei.c
> > +++ b/fs/namei.c
> > @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata =
*nd, struct file *file,
> > =20
> >  /**
> >   * vfs_lookup_open - open and possibly create a regular file
> > - * @parent: directory to contain file
> > + * @path: directory to contain file
> >   * @last: final component of file name
> >   * @open_flag: O_flags
> >   * @mode: initial permissions for file
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
> > + *
> >   * Returns: the opened struct file, or an error.
> >   */
> > -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> > +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
> >  			     int open_flag, umode_t mode)
> >  {
> >  	struct file *file __free(fput) =3D NULL;
> > @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *parent, s=
truct qstr *last,
> >  	mode |=3D S_IFREG;
> >  	open_flag |=3D __O_REGULAR;
> > =20
> > -	error =3D lookup_noperm_common(last, parent->dentry);
> > +	error =3D lookup_noperm_common(last, path->dentry);
> >  	if (error)
> >  		return ERR_PTR(error);
> > =20
> > @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *parent, s=
truct qstr *last,
> >  	if (IS_ERR(file))
> >  		return file;
> > =20
> > -	nd.path =3D *parent;
> > +	nd.path =3D *path;
> >  	nd.last =3D *last;
> >  	nd.flags =3D LOOKUP_OPEN;
> >  	if (open_flag & O_CREAT) {
> > @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, =
struct qstr *last,
> >  	op.mode =3D mode;
> >  	dentry =3D lookup_open(&nd, file, &op);
> > =20
> > -	if (IS_ERR(dentry))
> > +	if (IS_ERR(dentry)) {
> > +		if (dentry =3D=3D -EFTYPE) {
> > +			/* Try to determine what was found */
> > +			struct dentry *child =3D d_lookup(path->dentry, &nd.last);
> > +			dput(path->dentry);
> > +			path->dentry =3D child;
> > +			WARN_ON_ONCE(child && d_is_reg(child));
> > +		}
>=20
> Does anything prevent the child from flipping over to regular?

Yes.  An inode is never allow to changes its type.
And while you hold a reference on a positive dentry, the inode is that
dentry is not allowed to change (a negative dentry may become positive,
but a positive dentry must keep the same inode).

Thanks,
NeilBrown


>=20
> >  		return ERR_CAST(dentry);
> > -
> > +	}
> > +	dput(path->dentry);
> > +	path->dentry =3D dentry;
> >  	if (d_really_is_negative(dentry)) {
> >  		error =3D -ENOENT;
> >  	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
> > @@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *parent, =
struct qstr *last,
> >  	} else if (!d_is_reg(dentry)) {
> >  		error =3D -EFTYPE;
> >  	} else if (!(file->f_mode & FMODE_OPENED)) {
> > -		nd.path.dentry =3D dentry;
> > -		error =3D vfs_open(&nd.path, file);
> > +		error =3D vfs_open(path, file);
> >  	}
> > -	dput(dentry);
> > =20
> >  	if (error)
> >  		return ERR_PTR(error);
>=20
>=20
> I would say this is the wrong approach to the API. The path dentry
> switching is a massive hack and should be avoidable. So happens I was
> working on cleaning up the overall handling and you convinced me to post
> the patchset early, see:
>=20
> https://lore.kernel.org/linux-fsdevel/20260913144918.1606123-1-mjguzik@gmai=
l.com/
>=20
> On top of that the routine as is has avoidable refcount traffic and it
> seems you are adding to it. Instead it can switch to vfs_open_consume.
>=20
> On cursory reading of the nfs patch, the following should do the trick inst=
ead: split the
> helper into 2 parts (say vfs_open_lookup + vfs_open_lookup_finish, maybe add
> vfs_open_lookup_abort should the caller decide to not go through with
> the open).
>=20
> Then in nfsd you could have something like this:
> struct vfs_open_lookup_arg v;
>=20
> vfs_open_lookup(&v, parent_path, ....);
> [ child dentry is in v->path->dentry, do arbitrary work with it]
> if (ok)
> 	file =3D vfs_open_lookup_finish(&v);
> else
> 	vfs_open_lookup_abort(&v);
>=20
> The new struct would hide 'struct file' and whatever else
> vfs_open_lookup might want to allocate first.
>=20


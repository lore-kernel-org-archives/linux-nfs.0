Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C61D44BFE93;
	Thu, 10 Sep 2026 00:39:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000795; cv=none; b=i15pz7oxkpkBxT2qGdpcyx5G9vQeHkksY2UzbBDl9Ab2VxUBGI8ET55wQeXgnDQ6weSJMMSAQbQee8vUIg0EGNc62sc2poQ2a/UqeuZgPI+pTUKoS4y6d+CoXUxL4YDGkiVsuUPn4GAxZnn0ukbATJAPaCtsC74rBYVqkjPkhhM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000795; c=relaxed/simple;
	bh=8jo+fzFN6hzN16t7W199IgXxCRD3zhnxEo+sPkeFLCA=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=HNCJYUvb56cVrCwnsQJWKrZAfBOlAS2m7rLnuRwA2B4TVkc4FHr5QK9gL2W4F2OxFi25CDSi5r53S+EvxWNIe/2mQjbQ3F8avZ/HlbF+BhEbfvuZObbWKyvcKFnJsjL0pKNyAVwPUf73yYmE0r7eg7oVAvp9j+gIwbhQrLi+59k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=DnJ00AfZ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=EmZm7+6c; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="DnJ00AfZ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="EmZm7+6c"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id EE54A1D0009D;
	Wed,  9 Sep 2026 20:39:52 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Wed, 09 Sep 2026 20:39:53 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789000792; x=1789087192; bh=wxUjT2sG+sTnGWPLlow79y7oRtS8opJfU2k
	z499l4+Q=; b=DnJ00AfZOsoKatlqiYrb7/s1g6UF7mNux51ovuHMDThSMPfX1EH
	9pS/GpnqhJRALxtNhKaaW+LtCQQVL7wWJW1fTYpYbsycNHbyW6p4fQz0KCjKP9ag
	eELCqzLIOwzCYteTBgjAd7Gu/cGHon7ejawr/p5Vw8tSgAhURRAQi9h9pcuQUoCd
	vxzSJWBWeg8iBpxtYzjs65kGPzvZ2rU5xNtw79g8TlAo98n0gX45L3qBtDH4bL9n
	QlOanAEyT1MG/TGoiTCB3FYegnHtV9bAYFrxGQtY2D7dBDcY0ICkuQztGFSOVCmM
	Np2TLwb0ZhcdPjkmdQuDU93uj3gbIznW90A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789000792; x=
	1789087192; bh=wxUjT2sG+sTnGWPLlow79y7oRtS8opJfU2kz499l4+Q=; b=E
	mZm7+6cU8TULJ0Fn04n46Zo/IMaWcMVR+ZJOTIwgz6sh9C1LMM1bNVCW3xfEa2Rs
	zZwd27sg9WR6TxgWpj9a5EYWzPbtPlH3WU3Pql/EI3ZnkmgUUrrDafJTGHVSpmFX
	pIkSCmYyw2LeiJi48VZKeaUcHWN8dZYAyR6WaH0/b7MZPQZ9CKXvfXsfKKn1GUgb
	dEanbYYTQNM+0PVD6VgdmGXcVmDTPpDSyrKMOBaDk6hLM+hjDt7tjfPGjkDsCu93
	rsJ5ZHeu4NNzypP4a1dsOm6FMT+46eZECa2HE1jDa7/2NhafWUCfC2gzoAy59Fvg
	PjxvB19GznD47UVqyJCng==
X-ME-Sender: <xms:WPyhapOOaKEMkLzZZyEYfrmCQh4JX8b-7xQPsy9eBTsSw2Rc75A6lA>
    <xme:WPyhauPK7pEOpY08YLsNuue0ekBHCjq1FVc-NUZX4uVsllxBqNYhgQBqTxqUIj7Fw
    PB77E4QP-rX2tBm7v9QkLqFvJetxd3kYovV99DRan0WIwHMwx0>
X-ME-Received: <xmr:WPyhaqgwfHu-WgnCl8KKKFtMLacWvmmuY8Tu5NhOwgg3MgjIPoDu3wroVfazNmNpSw>
X-ME-Proxy-Cause: dmFkZTGkxsnFfitG7NwcWklIPwHLEnyUolWLPSSLRJv1qQxTj6q/hs5MX71vtxakwYjTuG
    gUUPqK6BgmUCyzpN5Eq7eSka0RwFhlzyn8bwDHm2cLvaxEOzicFkJubsbUH14Ggf05Yh5+
    Ysm262a7R1NGW+VV2UIp+jWLD34TK1qVqhYVaR8Ga4zb9uNrDd45Z5icKjzw+ekq+WS32M
    UcTTkAnX6emwZzro/otRdoX1MBtX1NKdfE/HHMvwdhvZegJJoCu9hClFMedYXz+GQspGU3
    dsExL6dhsRyw41SSOgX+rxsNSIwWSN7Zf25orfPygY6sm3cqCM3zUl4VBR/lZnz9xdrMfA
    wz80ZMlpPnk4r9QEbT+puJVTRCQb4tjEZnScLKKdrxTKfdxrWiDrosADXAkxbYeUsSrKfs
    Aa8elHjXjky6WPTXjoe2KVnHzLnLzKLZCcWsr1ZXVl9fiQCklooU/rBqPfB4eXnHwAYHgy
    Blqa3oEY4LG4oNnoNIO766fk64FI9fBoK+Tq0i0uA7vpI8AiJgWfCCemd5sia8kV/i8Q6a
    d6fWBwzQLNXxLNWaKOftzh2DbDd40i4MkEanqh4e0MhG2kUgeDjoaxB1bdBpg4aZ9u+I3b
    /wb6b99jQPe8QebUL5r0nWfh7+r7tvox5IiLX1b8nQGFiTbIq1Id0mR99CpA
X-ME-Proxy: <xmx:WPyharsVJ0EzlGqpeUybu_m86IhJDwZ9yAnh4uuAEk-dpJA4LyK9Mw>
    <xmx:WPyhagQXQ1WVRB0Tp2t4RFcrVZm2rr4WUFDPdy3XvYn0Cke2eNXCrw>
    <xmx:WPyhan3EO5YnmSvFNqiecvBjUG_RzQOqwBSt1_o_O8M-WBolQazcqA>
    <xmx:WPyhattSEaeja5sFeXh-uT1yvKeryHe-zAL8cT8IFak7oAzlgb1EGg>
    <xmx:WPyhah4LY18W1iLR-rH7r2j5P_bNqlndUHkqLy9Wq7DAlFSn-2m9Zgqx>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:39:50 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry
 in path.dentry.
In-reply-to: <20260910002934.192979-5-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
  <20260910002934.192979-5-neilb@ownmail.net>
Date: Thu, 10 Sep 2026 10:39:46 +1000
Message-id: <178900078673.207413.10948515234098876470@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Thu, 10 Sep 2026, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
>=20
> The caller - nfsd - needs to know the type of object found when a
> non-regular file was found to exist.  This is most easily done
> by passing back the dentry.
>=20
> So change calling pattern so that the path (now called "path") contains
> the parent dentry on entry and the child dentry on exit.
> vfs_lookup_open() will dput() the parent and caller must dput() the
> child.
>=20
> If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> dentry to the dcache we return %NULL in %path->dentry.
>=20
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c | 31 ++++++++++++++++++++++---------
>  1 file changed, 22 insertions(+), 9 deletions(-)
>=20
> diff --git a/fs/namei.c b/fs/namei.c
> index 0c787363b101..30ccc0c2f02f 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata *n=
d, struct file *file,
> =20
>  /**
>   * vfs_lookup_open - open and possibly create a regular file
> - * @parent: directory to contain file
> + * @path: directory to contain file
>   * @last: final component of file name
>   * @open_flag: O_flags
>   * @mode: initial permissions for file
> @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata *=
nd, struct file *file,
>   * If the fs object found is not a regular file then -EFTYPE is
>   * returned.
>   *
> + * @path is updated to contain the dentry that was found if possible.
> + * In particular, if -EFTYPE is returned, then @path.dentry will be the
> + * object that is not a regular file, or %NULL.
> + * Consequently the caller must be prepared for @path.dentry to be
> + * dput(), an it must dput() whatever is in @path.dentry after the call.
> + *
>   * Returns: the opened struct file, or an error.
>   */
> -struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
> +struct file *vfs_lookup_open(struct path *path, struct qstr *last,
>  			     int open_flag, umode_t mode)
>  {
>  	struct file *file __free(fput) =3D NULL;
> @@ -4638,7 +4644,7 @@ struct file *vfs_lookup_open(struct path *parent, str=
uct qstr *last,
>  	mode |=3D S_IFREG;
>  	open_flag |=3D __O_REGULAR;
> =20
> -	error =3D lookup_noperm_common(last, parent->dentry);
> +	error =3D lookup_noperm_common(last, path->dentry);
>  	if (error)
>  		return ERR_PTR(error);
> =20
> @@ -4646,7 +4652,7 @@ struct file *vfs_lookup_open(struct path *parent, str=
uct qstr *last,
>  	if (IS_ERR(file))
>  		return file;
> =20
> -	nd.path =3D *parent;
> +	nd.path =3D *path;
>  	nd.last =3D *last;
>  	nd.flags =3D LOOKUP_OPEN;
>  	if (open_flag & O_CREAT) {
> @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, st=
ruct qstr *last,
>  	op.mode =3D mode;
>  	dentry =3D lookup_open(&nd, file, &op);
> =20
> -	if (IS_ERR(dentry))
> +	if (IS_ERR(dentry)) {
> +		if (dentry =3D=3D -EFTYPE) {

                if (dentry =3D=3D ERR_PTR(-EFTYPE)) {

of course.

NeilBrown

> +			/* Try to determine what was found */
> +			struct dentry *child =3D d_lookup(path->dentry, &nd.last);
> +			dput(path->dentry);
> +			path->dentry =3D child;
> +			WARN_ON_ONCE(child && d_is_reg(child));
> +		}
>  		return ERR_CAST(dentry);
> -
> +	}
> +	dput(path->dentry);
> +	path->dentry =3D dentry;
>  	if (d_really_is_negative(dentry)) {
>  		error =3D -ENOENT;
>  	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
> @@ -4668,10 +4683,8 @@ struct file *vfs_lookup_open(struct path *parent, st=
ruct qstr *last,
>  	} else if (!d_is_reg(dentry)) {
>  		error =3D -EFTYPE;
>  	} else if (!(file->f_mode & FMODE_OPENED)) {
> -		nd.path.dentry =3D dentry;
> -		error =3D vfs_open(&nd.path, file);
> +		error =3D vfs_open(path, file);
>  	}
> -	dput(dentry);
> =20
>  	if (error)
>  		return ERR_PTR(error);
> --=20
> 2.50.0.107.gf914562f5916.dirty
>=20
>=20
>=20


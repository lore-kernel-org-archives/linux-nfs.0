Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B88953C0625
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 15:13:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789053242; cv=none; b=HsTX/Rg7Qm8yr4k9WlS2KTLjMqysMIIPO0sUtleVbxF3iw/B0ZnVDSr0r4C8dSIuyFEbIZbSEZAeyKIJPQuNpVk1Z1+xh5x/lQCXOgNlAP8Liv09yOMjdDQx+7GmCuhchAAVUNYnwKoSgum0g2gdMuNQ/tJA0oV6iSTlHy4r6TA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789053242; c=relaxed/simple;
	bh=et2hVQjnM3BQKhnb3J6REZkdT7yFdOxFX6XEa2xybFs=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=t+joYlAxT+IeNFyjsNMC8efLZYFthQ/OBMgBw1sey13VsPcPFGC7cFH5NQYRfQsO5EGfPYjSfDD8TJfrKlSxKB8FvXOEA/0XnJbqYmVT2/KALtEzQuhFb+gWGm69Cr8GnaE9VwCglTQQ186ZCFepbD4hOzHYrts55AE6A4AgsnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VGyENCSb; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VGyENCSb"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BA8551F00893;
	Thu, 10 Sep 2026 15:13:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789053237;
	bh=STMMdUEc/iUSoMKNtrSK7nMg+cH+09G+OqLnjouKKhE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=VGyENCSb0963ksb2NyQgs94Cg54k1tnv/11NJ97GsYZHKIKr3g1a70shoOpIiAbG+
	 SMwKJKVOiRB4LLpjkBvcoqE5BeyF9V6BO1bZnWzFiWOHnS36KjZv6G1xMdO6dJAXWG
	 5SnrrVCrVT2/aLv6wXjythcKeINDHp78tlfWq8OFsbAEGCcAOzzRZUDhWU6ytam8mk
	 jV8ceudX9f7agkIBBNivJOte8ygGwruSMZ/qr8A/hHpwTtdlLPdAY874rCO8ldz0HF
	 IAMnNKIrubs8ATee0l/ntDNmKKzHKF7kUvIWheVqRQ8NNErruEw/Gq7nkJxl+GgjMs
	 RjN3yegRg3ztw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id CE955F40066;
	Thu, 10 Sep 2026 11:13:55 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 10 Sep 2026 11:13:55 -0400
X-ME-Sender: <xms:M8miarJGn9aB7FD0nHqJXzL3E_iJQAAOnQM0IudC2g_KPu70VWq3Ng>
    <xme:M8miap_Z-95FjU4uZUYs0W7GMSjqUv33NQOdtzd6EK14uEHwQ7H7HgpIqikqAnSfv
    Qs-BLaD7TegSz9rbe0g6AK5TVe8xN03n6sYpD739nMiflNsURakc2KY>
X-ME-Proxy-Cause: dmFkZTGz9yw37NiNxrgu68qp72mc4Kby7FBaBgVSY0w80MkGDnRS/8x8dHDXvpiAILXD3u
    8RQyI3A6mi4Z0nOlYWyIIIfB/1JDEtsuRAYSt3HgEYjGr+Pu8kygX5GJiiNt085sZ6daBh
    TLIu4zi4gj3I6Ae0e2ObL4H+HVTIuPF0E2D9NFl0Bb+QPRgFSj/VyJUmDuU8HGmXxcuwDn
    k7Ye8JShhEUmxe1NunLTAtqkALH0rvcX1rZwm3Fa6HfCazplLgOiZ5DHxnJWpgTgkJZU+2
    DCq6hLZcAf98jS97YeWrBm5oG3KWr7CIwcW6/qx4wrCAlrTW6xnkEwkwUmpoBPJq9fkSC3
    USGDVDayF+HHnhyIwSGHIik3i9UMoIOTK8qV1Fcrh40MFzxJMMSKi/yE/wvb3m2AHaVBce
    R5P5+7KmPXbXdd2tM4WT3Y7pkm8Z3MUFAM8YdnkX3hGiPKNSTyeAFQaRLQqtM4bzaab7SO
    kNuxAh2N9+hC4NQORuSqS2nQ9JZvrWZWWy4mIK0rxUTv4dFLnxo7U1Ap+yfbYWR9zgckhK
    KfvvwgiQXiDFu8zzQdF8dCY6PxWFBANGzogUL6asFmyUqw/y5WN6R/sWjajcDMlmwV+T2l
    CGE1Fl2rLmFvR/UScexOhTP1+ta3IfXiHq89jiaT3gjT4V7winXXIgV7j7Ig
X-ME-Proxy: <xmx:M8miavBWarfUa6D6IysT9CYKeQgrJNTUSTo-A0zpUg3D7UuL_IKAPg>
    <xmx:M8miamMSUnZ5QmvI7-jdEMuVM3QTHpBb_LNb3Qy1xf6yakZigGAtIw>
    <xmx:M8miaoyabzKC_ovDCCXPzXA0EZ5JT0xi6L9AcbqfdjeOhbEbaqi2aQ>
    <xmx:M8miamX1u_GmC_DleDZppdcDY86ZeRV8OwSxVy-bc2VY_7EiR8n9vQ>
    <xmx:M8miaqOVdg7HbofQAz-FwQk74bIbe-o7H30cUdv7Q17rOeKRKEdGFkdD>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A8E4C7811F0; Thu, 10 Sep 2026 11:13:55 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A5RAmHdl2Lqc
Date: Thu, 10 Sep 2026 11:13:33 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <61fedba0-78f4-403f-9f74-0795ccbfaf52@slotpi15m67>
In-Reply-To: <20260910002934.192979-5-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-5-neilb@ownmail.net>
Subject: Re: [PATCH 4/7] vfs: change vfs_lookup_open() to return found dentry in
 path.dentry.
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 10 Sep 2026, NeilBrown wrote:

> vfs: change vfs_lookup_open() to return found dentry in path.dentry.
>
> The caller - nfsd - needs to know the type of object found when a
> non-regular file was found to exist.  This is most easily done
> by passing back the dentry.
>
> So change calling pattern so that the path (now called "path") contains
> the parent dentry on entry and the child dentry on exit.
> vfs_lookup_open() will dput() the parent and caller must dput() the
> child.
>
> If lookup_open() returns -EFTYPE (from ->atomic_open()) we need to
> use d_lookup() to find the dentry.  If ->atomic_open() didn't add a
> dentry to the dcache we return %NULL in %path->dentry.
>
> Signed-off-by: NeilBrown <neil@brown.name>

"vfs_lookup_open() will dput() the parent and caller must dput() the
child."

Is that the whole contract? When lookup_noperm_common() or
alloc_empty_file() fails, path->dentry still holds the parent on return:

	error = lookup_noperm_common(last, path->dentry);
	if (error)
		return ERR_PTR(error);

	file = alloc_empty_file(open_flag, current_cred());
	if (IS_ERR(file))
		return file;

The parent is replaced only after lookup_open() returns. Could the
message say that on success and on -EFTYPE the parent is replaced by
the child and its reference dropped, and that on any other error @path
is untouched?


> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4606,7 +4606,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
>
>  /**
>   * vfs_lookup_open - open and possibly create a regular file
> - * @parent: directory to contain file
> + * @path: directory to contain file

Now that @path is in/out, could this say what it holds on return as
well? Something like "on entry, the directory to contain the file; on
return, the dentry found".

The prototype in include/linux/namei.h still names this parameter
"parent".

> @@ -4619,9 +4619,15 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
>   * If the fs object found is not a regular file then -EFTYPE is
>   * returned.
>   *
> + * @path is updated to contain the dentry that was found if possible.
> + * In particular, if -EFTYPE is returned, then @path.dentry will be the
> + * object that is not a regular file, or %NULL.
> + * Consequently the caller must be prepared for @path.dentry to be
> + * dput(), an it must dput() whatever is in @path.dentry after the call.

"an it must dput()" -> "and it must dput()".

"if possible" leaves the reader guessing which paths update @path. As
above, it is updated on success and on -EFTYPE, and untouched on every
other error. Since the caller cannot tell the two cases apart from the
return value alone, is that worth stating here?


> @@ -4658,9 +4664,18 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	op.mode = mode;
>  	dentry = lookup_open(&nd, file, &op);
>
> -	if (IS_ERR(dentry))
> +	if (IS_ERR(dentry)) {
> +		if (dentry == -EFTYPE) {

dentry is a struct dentry * and -EFTYPE is an int. Both compilers warn:

warning: comparison between pointer and integer ('struct dentry *' and
'int') [-Wpointer-integer-compare]

and with CONFIG_WERROR (the default for COMPILE_TEST builds) fs/namei.c
no longer compiles. It evaluates as intended only because the int is
converted to a pointer with the same bits as ERR_PTR(-EFTYPE). Should
this be:

		if (PTR_ERR(dentry) == -EFTYPE) {


> +			/* Try to determine what was found */
> +			struct dentry *child = d_lookup(path->dentry, &nd.last);
> +			dput(path->dentry);
> +			path->dentry = child;
> +			WARN_ON_ONCE(child && d_is_reg(child));

lookup_open() drops the parent's inode lock before returning, so this
d_lookup() runs unlocked. Between ->atomic_open() rejecting a
non-regular object and this lookup, another task can unlink it and
create a regular file with the same name. d_lookup() can also return a
hashed negative dentry.

Either way @path.dentry is then neither "the object that is not a
regular file" nor NULL, and the WARN fires on a race that ordinary
concurrent activity (remote, over nfsd) can drive. Could this store
NULL when the child is negative or regular, and drop the WARN, so the
documented contract always holds?

Does this recovery find anything for most ->atomic_open()
implementations? lookup_open() only reaches ->atomic_open() with a
negative or in-lookup dentry, and atomic_open() dputs it on error, so
what d_lookup() sees is whatever the filesystem hashed before failing.

The NFS client d_drop()s the dentry before returning -EFTYPE:

fs/nfs/dir.c:nfs_atomic_open() {
	...
		d_drop(dentry);
		switch (err) {
		...
		case -EISDIR:
		case -ENOTDIR:
			if (open_flags & __O_REGULAR) {
				err = -EFTYPE;
				break;
			}

gfs2 and cifs return -EFTYPE before instantiating anything. Only ceph
checks d_is_reg() on a dentry it has already spliced. So on gfs2, cifs
and a re-exported NFS mount, path->dentry is always NULL here, and the
caller cannot distinguish a directory from a symlink. That might not
be acceptable for what nfsd needs. The found type needs to come
back from ->atomic_open() itself, probably.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)

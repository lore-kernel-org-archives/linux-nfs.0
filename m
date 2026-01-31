Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0382B3033CA;
	Sat, 31 Jan 2026 16:54:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769878448; cv=none; b=fgoYhH0uSsff/5ttIzLRdj1Vg3o9qw5NVeIlgfyG5x1RK6I1WZKgLkvpVyGF/sQmqmOnIcW3Pp6p7U239bF3bbsaYQlqCmRahyyZdadSmsLWhmBAwvAnIysDehkf3FEBI853X4Z/4YVl/zZ+5bfXMSDM3TAkYhAhxDvZYP5yemQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769878448; c=relaxed/simple;
	bh=L/h0dWQ/ETs9jph2UAJnePpqz8jLDJqILLP1qN4w2GA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=EKLKFKRR2ne5UioHP1M9z1ezMAU9NNYK8cSrsri80NRwiJTAesA6BdMoL2o90DbRBbDzjg4iivKmJvPGae1mDysJGi8q3XntV7eRKn/ckDyX5yoEtPcUAQJRUEms1wRBj7tiFlRXaZDQLRg1Y2lxlfUg4X/6TloYODgP/agyW5s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iHgKnw+U; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iHgKnw+U"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 37C61C16AAE;
	Sat, 31 Jan 2026 16:54:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769878447;
	bh=L/h0dWQ/ETs9jph2UAJnePpqz8jLDJqILLP1qN4w2GA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=iHgKnw+UsEdNPjxAWuF4PQhtqokFO8YsVxh6BsCJ/RmpFM16FGlkr1NfDZjyQF8rz
	 iUEnT9bjb+0E9YHmzYN8sfA+98XXdWqPSXj+tNnaPHL9X4l4Yn/cTQLIjZGlffMELS
	 /pYT0vQMm9w3M4VQ0CT02sIFflEKu5t0a/eLJj59zLxln4pNz/Y7HElR0M62QltR1w
	 SItqO77o9P9wljD8g7tgfQOqrnRdo1jOhXBofu4fm/yM42X9wGV680/in37I2uF7gv
	 7gYI0DEPSBSMBsIdxU+BP7R/ERykE0yAHZrjwBdfVH1et/vpcbZyYdoV1iPPn/Xdt5
	 QTBSlKGe5MT7w==
Message-ID: <6d56e691114294ed3187e7a6f281c98293393a1a.camel@kernel.org>
Subject: Re: [PATCH] nfs: fix memory leak in nfs_sysfs_init if kset_register
 fails
From: Trond Myklebust <trondmy@kernel.org>
To: Benjamin Coddington <bcodding@hammerspace.com>, Salah Triki
	 <salah.triki@gmail.com>
Cc: Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Sat, 31 Jan 2026 11:54:06 -0500
In-Reply-To: <9EF0F792-3B22-4A20-8A37-9C4B2236740C@hammerspace.com>
References: <20260131000937.229276-1-salah.triki@gmail.com>
	 <9EF0F792-3B22-4A20-8A37-9C4B2236740C@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.2 (3.58.2-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sat, 2026-01-31 at 07:21 -0500, Benjamin Coddington wrote:
> On 30 Jan 2026, at 19:09, Salah Triki wrote:
>=20
> > When `kset_register()` fails, it does not clean up the underlying
> > kobject. Calling `kfree()` directly is incorrect because the
> > kobject
> > within the kset has already been initialized, and its internal
> > resources or reference counting must be handled properly.
> >=20
> > As stated in the kobject documentation, once a kobject is
> > registered
> > (or even just initialized), you must use `kobject_put()` instead of
> > `kfree()` to let the reference counting mechanism perform the
> > cleanup
> > via the ktype's release callback.
>=20
> I don't think this patch is correct - the kobj is not initialized
> yet, and
> on error return from kset_register() you'll likely get the WARN from
> lib/kobject.c:734 kobject_put() when calling kset_put().
>=20
> That said it does look like that path might leak kobj->name, you
> might
> look at doing kfree_const() on it.
>=20
> Did you test this - how did you determine this was a problem?
>=20
> Ben

If you take a look at kset_register(), you'll see that it does free the
kobj.name pointer if there is an error when adding the kobject.

IOW: there is no bug in the current code.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com

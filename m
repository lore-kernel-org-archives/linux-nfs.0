Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D42A377EAF
	for <linux-nfs@vger.kernel.org>; Mon,  1 Jun 2026 12:29:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.184
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780316980; cv=none; b=DXtlGZDmHaumuqoHXAlZaCJxWzPYk2+zBmkUulOyjQwEih/sZ9MgyXMDpHDVx3EZADLP7pPN0VUvHdOfZ/XnFGI0sAJtwG0C4mdIyMT6OZg1sAFearUwnakeFQiXX0DXTTz3Ahq9gGCEsjwJ3GjzvMucNo4reFaWh1JJdfe2e0E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780316980; c=relaxed/simple;
	bh=TUvFeov/t657TNOQJvz/GBhBlySgEfEBZt4OqlT+uGo=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=fDqYdqzQeteRq3qlm7r8a2iUlV3iF0i+jeq5RgXeFnGeNhKlLtcXSwg4vitbntDMqLoJ3zua+BVyRGVYEANKQ565Zsp1uy5fSCa240ol1Chf73AfwdTeZ2xoczcuB26zTJkoirH7IQm84ifvh1wPSHZ0H7kP8WgceOnfiKRMwQY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=teIhe/1O; arc=none smtp.client-ip=195.121.94.184
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="teIhe/1O"
X-KPN-MessageId: 89c8e635-5db5-11f1-afe2-005056994fde
Received: from mta.kpnmail.nl (unknown [10.31.161.190])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id 89c8e635-5db5-11f1-afe2-005056994fde;
	Mon, 01 Jun 2026 14:29:30 +0200 (CEST)
Received: from mtaoutbound.kpnmail.nl (unknown [10.128.135.190])
	by mta.kpnmail.nl (Halon) with ESMTP
	id 89c79c72-5db5-11f1-99d0-0050569977a2;
	Mon, 01 Jun 2026 14:29:30 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:subject:message-id:to:from:date;
	bh=VDzHHkf8QOru1wxAKtK/INLroex+ZV6tTjFIyVYoD5c=;
	b=teIhe/1Ohwko4xlYGXQUqOz9rx0ozBNg99PtmO4CWFb9nIIHtIEnQS2tcNcREcQgl01Tt7RaPC8v0
	 58SY8MAFcbsTVFmlki+Fr42QbJ/aOWi07Sf80W1Dt5B3stEorz2pE4rEAlnUMCEAIZ5marew9XPzSZ
	 JnbmqkFgDGlMon8d7ulcBc+aZ90HXzUJUqCundODwUfaNPkHG8USNi03ShadVjXmHZGC/AKr7IklTg
	 SC1Wafgjf7bEM0xRfF5OEJoqwz6NXjYXsr3MrKD12VHl8Xz94RpfejeJPn7PdQa95qClVL9DbMluLl
	 73HvYy6+KZMWb0QtnHVba3ZFsyFQU0A==
X-KPN-MID: 33|vkR23cbhivSCatsOLkO6VwKjqrAxinbMvThVXzE11QR5MNzg1WaBsQ3TVR0NWpJ
 HsM4vCM6eTYkdn9pTFG7gVZ3dTYU1zDeWL9OBsh6nazY=
X-CMASSUN: 33|kkUOlpdkIuBacfWte+RLTkgt4U5UtYUMqkidsetI1V0KQ4Cq16NCUjoan8W6y0W
 djTyIe8YdI3TWWQnRmLc0Lg==
X-KPN-VerifiedSender: Yes
Received: from cpxoxapps-mh02 (cpxoxapps-mh02.personalcloud.so.kpn.org [10.128.135.208])
	by mtaoutbound.kpnmail.nl (Halon) with ESMTPSA
	id 89ba645a-5db5-11f1-b8d7-005056995d6c;
	Mon, 01 Jun 2026 14:29:30 +0200 (CEST)
Date: Mon, 1 Jun 2026 14:29:30 +0200 (CEST)
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>, NeilBrown <neilb@ownmail.net>,
	Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	Mateusz Guzik <mjguzik@gmail.com>
Message-ID: <207320656.62149.1780316970630@kpc.webmail.kpnmail.nl>
In-Reply-To: <20260601070042.249432-6-neilb@ownmail.net>
References: <20260601070042.249432-1-neilb@ownmail.net>
 <20260601070042.249432-6-neilb@ownmail.net>
Subject: Re: [PATCH 05/18] VFS: dentry_create: always set FMODE_CREATE when
 file is created.
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Priority: 3
Importance: Normal


> Op 01-06-2026 08:37 CEST schreef NeilBrown <neilb@ownmail.net>:
> 
>  
> From: NeilBrown <neil@brown.name>
> 
> atomic_open() may or may not need to create the file, and sets
> FMODE_CREATE to indicate that it has.  To allow the caller to know if
> the file was actually created, set FMODE_CREATE in the vfs_create()
> branch too.
> 
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index db3fddbccd21..e4f3c0d00c8c 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -5137,6 +5137,8 @@ struct file *dentry_create(struct path *path, int flags, umode_t mode,
>  		error = vfs_create(mnt_idmap(path->mnt), path->dentry, mode, NULL);
>  		if (!error)
>  			error = vfs_open(path, file);
> +		if (!error)
> +			file->f_mode |= FMODE_CREATED;

What if vfs_create() succeeded but vfs_open() failed? Then we don't set
FMODE_CREATED, why?

>  	}
>  	if (unlikely(error))
>  		return ERR_PTR(error);
> -- 
> 2.50.0.107.gf914562f5916.dirty

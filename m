Received: from mx1.manguebit.org (mx1.manguebit.org [143.255.12.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AA0459E35D;
	Fri, 11 Sep 2026 20:21:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=143.255.12.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789158113; cv=none; b=VtyMnC5xDEb39UrZawTfV5AO5HBQrfmeOULD5kEtQ9oLhceoHRwc6XRKbx7ZpgVyUatnGy3di9CF3clGcKcv9fNQP6vV/wLYjt1FqS5QC7tqoIU4B2KTa1FNo46QzMOs+CQ23WeGDPw1THmb/H4z8bidQ2jt/8c0wBF+dub5DR8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789158113; c=relaxed/simple;
	bh=Gda/p45mn0eDZ98/49FQRJN55Cd0HHPAXWHYrDruXPk=;
	h=Message-ID:From:To:Cc:Subject:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=eV+G2U8O9/uQXeKW8gVCKQlSXZCiC57rtpQ4zwwLy4Lnxpv1dtC8xnGa8Ecepy5rkLhXbGZXLsq7Y+R/w3LXP7qsVD6H3+udUsviAOYUY7M637wL1aWwWXxCmy+MdGqAcQ0/1SJPirdQi9ffUx7OGpARD13XrvVHX2lppZ0vfag=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org; spf=pass smtp.mailfrom=manguebit.org; dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b=Ul0TTLRS; arc=none smtp.client-ip=143.255.12.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=manguebit.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=manguebit.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=manguebit.org header.i=@manguebit.org header.b="Ul0TTLRS"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=manguebit.org; s=dkim; h=Content-Type:MIME-Version:Date:References:
	In-Reply-To:Subject:Cc:To:From:Message-ID:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=tdC+eeHQ2/y5B3/a3WDCCd1iGftUlGNNEOZKxfjw6Y8=; b=Ul0TTLRSppbnaeKmw4fCK2ft1x
	F34mxzOMJUI0cVF9k/fXLnBWQgRO3UeJzWuhRYtK1KaZ8BnrVVFf6IZ8pWFPGAfyyz3lKhFN1UBsv
	AhadtmlzpndrOPRm6lPyp0tyHYNEmMYUcq/tuyKNB5uS91toVwMIoiqZKtDHBnxt3vSHyfL0K+PCw
	+SjgtXfNotNqhkNOwgjOzxOPKMftYOcwjSPDk3IaYWoAKYXMQXM9OA8ZrYyfpk6n1C6EwR3TZ6QKM
	scYOL0wrM48BLSc4OLEb6vcHRx6dsk0wX5A40eNqhsDsU/oDu3KS8Ihsemii5xwg19/ZlnAwO9sdP
	xO+iBfJA==;
Received: from pc by mx1.manguebit.org with local (Exim 4.99.5)
	id 1x57kh-00000001Exp-194l;
	Fri, 11 Sep 2026 17:21:39 -0300
Message-ID: <920f0b50480231f1af8a9c8e7f118f5c@manguebit.org>
From: Paulo Alcantara <pc@manguebit.org>
To: David Howells <dhowells@redhat.com>, Christian Brauner
 <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>, Matthew Wilcox
 <willy@infradead.org>, Namjae Jeon <linkinjeon@kernel.org>, Marc Dionne
 <marc.dionne@auristor.com>, Stefan Metzmacher <metze@samba.org>, Eric Van
 Hensbergen <ericvh@kernel.org>, Dominique Martinet
 <asmadeus@codewreck.org>, Ilya Dryomov <idryomov@gmail.com>,
 netfs@lists.linux.dev, linux-afs@lists.infradead.org,
 linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
 ceph-devel@vger.kernel.org, v9fs@lists.linux.dev,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 5/5] cachefiles: Preset the state xattr when
 creating a new file
In-Reply-To: <20260910220242.2165023-6-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
 <20260910220242.2165023-6-dhowells@redhat.com>
Date: Fri, 11 Sep 2026 17:21:38 -0300
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

David Howells <dhowells@redhat.com> writes:

> With a really small cache, cachefiles is likely to see a lot of writes
> hitting ENOSPC - and this can include setxattr that sets the state xattr on
> a cachefile - but we don't really want to successfully fill a cache file
> only to have to scrap it because we can't set the xattr.
>
> Instead, preset the xattr when we create the tmpfile we're going to use,
> and scrap the file at that point if we get ENOSPC.  Only if setxattr
> succeeds do we allow data to be written to the file.
>
> Note that there is a potential performance loss in that writes to the cache
> have to be delayed until this is completed - but we do the tmpfile/setxattr
> in parallel, starting when the file is opened and only have to wait once
> writeback occurs.
>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Marc Dionne <marc.dionne@auristor.com>
> cc: Paulo Alcantara <pc@manguebit.org>
> cc: netfs@lists.linux.dev
> cc: linux-fsdevel@vger.kernel.org
> ---
>  fs/cachefiles/internal.h |  1 +
>  fs/cachefiles/namei.c    |  5 ++++
>  fs/cachefiles/xattr.c    | 59 +++++++++++++++++++++++++++++++++++++++-
>  3 files changed, 64 insertions(+), 1 deletion(-)
>
> diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
> index b2605111fd56..664be64ab538 100644
> --- a/fs/cachefiles/internal.h
> +++ b/fs/cachefiles/internal.h
> @@ -283,6 +283,7 @@ void cachefiles_withdraw_volume(struct cachefiles_volume *volume);
>  /*
>   * xattr.c
>   */
> +int cachefiles_preset_object_xattr(struct cachefiles_object *object, struct file *file);
>  extern int cachefiles_set_object_xattr(struct cachefiles_object *object);
>  extern int cachefiles_check_auxdata(struct cachefiles_object *object,
>  				    struct file *file);
> diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
> index ca093840e577..ef656a319ede 100644
> --- a/fs/cachefiles/namei.c
> +++ b/fs/cachefiles/namei.c
> @@ -450,6 +450,11 @@ struct file *cachefiles_create_tmpfile(struct cachefiles_object *object)
>  		pr_notice("Cache does not support read_iter and write_iter\n");
>  		goto err_unuse;
>  	}
> +
> +	/* Preallocate space for the xattr. */
> +	ret = cachefiles_preset_object_xattr(object, file);
> +	if (ret < 0)
> +		goto err_unuse;
>  out:
>  	cachefiles_end_secure(cache, saved_cred);
>  	object->content_info = CACHEFILES_CONTENT_ALL;
> diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
> index 551a3b0069c2..8ebb713482e3 100644
> --- a/fs/cachefiles/xattr.c
> +++ b/fs/cachefiles/xattr.c
> @@ -34,6 +34,57 @@ struct cachefiles_vol_xattr {
>  	__u8	data[];		/* netfs volume coherency data */
>  } __packed;
>  
> +/*
> + * Preset the state xattr on a cache file to allocate space for it.
> + */
> +int cachefiles_preset_object_xattr(struct cachefiles_object *object, struct file *file)
> +{
> +	struct cachefiles_xattr *buf;
> +	struct dentry *dentry = file->f_path.dentry;
> +	unsigned int len = object->cookie->aux_len;
> +	int ret;
> +
> +	buf = kzalloc(sizeof(struct cachefiles_xattr) + min(len, sizeof(__be64)), GFP_KERNEL);

You should use max() here.

Otherwise looks good,

Reviewed-by: Paulo Alcantara <pc@manguebit.org>

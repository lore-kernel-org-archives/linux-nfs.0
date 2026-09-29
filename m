Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.183])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16CCD55D896
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 15:19:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.183
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790695154; cv=none; b=fcB1ppVuiLR60fo3PrRNJpmcJ5qyb71I009G++eOHmHOPkVMjAwmawQNj1N9Bw8s+Tuph6KV3WTYCQqSi9cWAXJc4TX/wakEp8nHtR3I2bknRHWjDMYfOjc/l9JrTdSURE59h534Ka1j3gNguwDynj19jZ9O0RONTvCan1N2TvI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790695154; c=relaxed/simple;
	bh=POxNgs3Sk0smUjRTdny0WLN3IwiIFf9y/TxNt7OHXSQ=;
	h=Date:From:To:Cc:Message-ID:In-Reply-To:References:Subject:
	 MIME-Version:Content-Type; b=o7sY3LEP59Y9D8xzKrEfgJ1jcMFlnJSPs3Tuah4p11MzELUyrZTvYCtPT8+Al/SXxDQNY2D/dCPsH71TzJfh2jgKj1Z1ZISmomExSv52UogCY4OPkDIQ/WypOv9V0tICRS+GkrZDMvBjEEwP+h0NgWvV5CPaU8iwmAag/fygcoE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=kIgJPBzC; arc=none smtp.client-ip=195.121.94.183
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="kIgJPBzC"
X-KPN-MessageId: 1669baed-bc19-11f1-8f57-005056992ed3
Received: from mta.kpnmail.nl (unknown [10.31.161.188])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id 1669baed-bc19-11f1-8f57-005056992ed3;
	Tue, 29 Sep 2026 17:18:56 +0200 (CEST)
Received: from mtaoutbound.kpnmail.nl (unknown [10.128.135.190])
	by mta.kpnmail.nl (Halon) with ESMTP
	id 1668d7ff-bc19-11f1-ac16-00505699693e;
	Tue, 29 Sep 2026 17:18:56 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:subject:message-id:to:from:date;
	bh=ACDbdiVSBCu7/pMa28q8IG+OfHCoxEFwKjelrwVxaXo=;
	b=kIgJPBzCNop8a7wcoqU8geEt3KueLJC8HCERj/V78bn7eUXjRqmdA644bvSv7EdS0MWjmYrh/UFxd
	 tFiU2OLWUHxbpU2p6T83XLad/J99AS+469TyhklOophHku5FD15DOz7MP19VoAY/h3mbJduCxEgEwT
	 XNdAzWxj6EQmWGbL91fvAQsFz6A+NtygULAHRIt2VCNoncS+tNrRc4HXavKEbzk1AT0sHCq89x37dN
	 q2wbLjvoS0xq7JlftE/UgaOpfjS/3OUYYJCfhB0gg/gzF9ZVObwfnv1WM8+TwnNu4nMGX+1g0+VNw7
	 B3R218MQ1kyHNTAiGeKf8OUkvw11t1A==
X-KPN-MID: 33|VtfdXQ7XBA5Bw3zxqGdKWxVcQf+i4Kr3/piisen4KvftsHje7+hWv8iQzgUXMDK
 7JeBMbodJggf9I1eoncwpbKrrKhXu6MAJJbSoMVeWiZI=
X-CMASSUN: 33|YNUny+R1v2qHD+kD8+nSA3o19Hx1QizAlwfuOS/xy4BMUe316Enrqn20iIYD+MH
 qjZWeEaAK6ekHZ5+hj3Jgxw==
X-KPN-VerifiedSender: Yes
Received: from cpxoxapps-mh02 (cpxoxapps-mh02.personalcloud.so.kpn.org [10.128.135.208])
	by mtaoutbound.kpnmail.nl (Halon) with ESMTPSA
	id 165d89cd-bc19-11f1-916a-005056995d6c;
	Tue, 29 Sep 2026 17:18:56 +0200 (CEST)
Date: Tue, 29 Sep 2026 17:18:56 +0200 (CEST)
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>, NeilBrown <neilb@ownmail.net>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, Mateusz Guzik <mjguzik@gmail.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>, linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Message-ID: <113651329.602012.1790695136052@kpc.webmail.kpnmail.nl>
In-Reply-To: <20260919022441.3305170-7-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
 <20260919022441.3305170-7-neilb@ownmail.net>
Subject: Re: [PATCH v2 06/14] vfs: add some allowed open flags to
 vfs_lookup_open()
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


> Op 19-09-2026 04:06 CEST schreef NeilBrown <neilb@ownmail.net>:
> 
>  
> From: NeilBrown <neil@brown.name>
> 
> vfs_lookup_open() must allow:
>   O_LARGEFILE so that large files can be opened.
>   O_NONBLOCK so that break_lease() can be asked to return -EWOULDBLOCK.
> 
> Also O_NOFOLLOW as we don't/can't handle symlinks.  In fact we
> should enforce O_NOFOLLOW for the same reason we enforce __O_REGULAR.

I don't know all the NFS background, but: you can handle intermediate symlinks
but not trailing ones? Why is that?

> 
> Signed-off-by: NeilBrown <neil@brown.name>
> ---
>  fs/namei.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 0f69abb3743b..a08f37aca3e1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -4632,11 +4632,12 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
>  	int error = 0;
>  
>  	WARN_ONCE(mode & ~S_IALLUGO, "mode must only have permission bits");
> -	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR),
> +	WARN_ONCE(open_flag & ~(O_ACCMODE|O_CREAT|O_EXCL|O_TRUNC|__O_REGULAR|
> +				O_NONBLOCK|O_LARGEFILE|O_NOFOLLOW),
>  		  "open_flag has unsupported flags");
>  
>  	mode |= S_IFREG;
> -	open_flag |= __O_REGULAR;
> +	open_flag |= __O_REGULAR | O_NOFOLLOW;

What does __O_REGULAR | O_NOFOLLOW do? Does __O_REGULAR only block opening
if the final resolved thing is not a regular file, or does is also block
trailing symlinks? Afaict, the former.

>  
>  	error = lookup_noperm_common(last, parent->dentry);
>  	if (error)
> -- 
> 2.50.0.107.gf914562f5916.dirty

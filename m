Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F20454D5993;
	Fri, 25 Sep 2026 16:04:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790352259; cv=none; b=eF0RSI3VCoBhav8+7zRnFCPjgzIbmMiH3TD18dgpqVszeBGxzU8JPXsjvf9hJG9NPHVSjZVzIJPTYcIutahjQnQkA3LgI6Q8JWYUEw42/jid2D4k243GBKyVShCIP/w4TuYHvPgiSanpuX71HfPIkWaIV+MqQr4QSn53U2fCdxs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790352259; c=relaxed/simple;
	bh=IZ4F6iel9CQYqqk/dvStAas9CFSg4V10BDkGilw6Aw0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MmR/FaFVO5tNXbCjoHNej+oPJOvJnbEOpzor8FvqnZ+DA/v9Yh7jfLGTyrqTZadSyCGcZVNZvEEmaVKRf0rzjGqyXLaFRWAXXX4g4Pq4NvfyqneMXA6B6gXzeuZGTbAstH+dnl1vXlPM3KTNRuIQ1IISPbjPA+8eYPnThudZAP0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=StglrGOe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="StglrGOe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E862A1F00893;
	Fri, 25 Sep 2026 16:04:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790352255;
	bh=xxKiFFCryCgBG+J9gLCduvIgJfvaHBPdrbmundnTLmM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=StglrGOep6ggfNeYlGrPooEOQ3IynWTiiVN8I5HxyD/o7tfrYcBSYaPMR0PJY+SSW
	 gjH7cQkFI2CVkFLGDUyoY6qUnIHcDk8Da+xD0kjVmGAx8oWKaGtKMvaToawy1Y+lF9
	 khVhbzzv60Nnf9cp1eH5oVv470PZ8RQSegqGFyuOFyv6jZ3feeP9sFoUpPi1PPzZ+4
	 I7lJK/THcXYhhlr/Q/JEpUkrzr8RTp9e2GMzq6KkQneSTPgWkE60m48dzRUGpQufPR
	 G9ilaHZBSlHz3mqTUcMLhvdTUc60a302yoFW8uKC5MFydpGX7X2w++deM3hmzt5VPc
	 ZMTva6F1R9tEw==
Date: Fri, 25 Sep 2026 18:04:08 +0200
From: Christian Brauner <brauner@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, Jori Koolstra <jkoolstra@xs4all.nl>, 
	Mateusz Guzik <mjguzik@gmail.com>, Dorjoy Chowdhury <dorjoychy111@gmail.com>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Andreas Gruenbacher <agruenba@redhat.com>, gfs2@lists.linux.dev, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
	ceph-devel@vger.kernel.org, Paulo Alcantara <pc@manguebit.org>, 
	Namjae Jeon <linkinjeon@kernel.org>, linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 01/14] fixes for vfs_lookup_open, and integration with
 nfsd
Message-ID: <20260925-diavortrag-zueinander-komitee-6bb18933f480@brauner>
References: <20260919022441.3305170-1-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260919022441.3305170-1-neilb@ownmail.net>

On Sat, Sep 19, 2026 at 12:06:04PM +1000, NeilBrown wrote:
> Greetings.
> 
>  NFSv4 has an "OPEN" request which combines lookup and create and
>  truncate and permission checks etc much like the open() syscall.  When
>  nfsd implements this, I want it to share a much code as (reasonably)
>  possible with the open() paths - in particular I want it to use lookup_open() 
>  and so that it uses ->atomic_open() the same way that other code does.
>  (Longer term I want to make some locking changes and having all the code
>  central makes that easier.)
>  vfs_lookup_open() is a step towards that  but it isn't quite ready yet.
>  This series aims to make it ready, then use it.
> 
>  A particular issue is that using __O_REGULAR exactly meets the needs of
>  nfsd (it doesn't want to open anything else) but the errors returned by
>  __O_REGULAR aren't what nfsd needs.  nfsd needs to know if it was a
>  directory, or a symlink, or something else.
> 
>  I don't think __O_REGULAR should cause symlinks to result in -EFTYPE.
>  If a symlink is found, then it should be followed.  That is what
>  happens with filesystems that don't support ->atomic_open, but some
>  ->atomic_open handlers return -EFTYPE for symlinks when __O_REGULAR is
>  present.  I think that O_NOFOLLOW can affect how symlink are handled,
>  but where possible it is best to just return the symlink to the caller
>  and let it figure out what to do.
> 
>  For directories, nfsd wants EISDIR rather than EFTYPE.  It may be that
>  user-space could benefit from seeing EISDIR too, but that is a separate
>  issue.  So I want ->atomic_open to return EISDIR (if it returns an
>  error at all) rather than EFTYPE if a directory is found.  VFS code can
>  then map that to EFTYPE if needed.
> 
>  So the first few patches in this series improve the documentation for
>  atomic_open and then make changes to nfs, gfs2, ceph, cifs to better
>  match this documentation.  I would appreciate an Ack-by (or whatever
>  else might be appropriate) from fs maintainers for those.
> 
>  Subsequent patches make changes to vfs_lookup_open() and then to nfsd
>  to use it.
> 
>  A significant change here is that opening a file with
>  O_NONBLOCK|O_CREAT will result in -EWOULDBLOCK if a delegation
>  exists on the parent directory - currently it blocks.
>  Jeff - could you comment on that change (07/14)?
> 
>  There are quite a lot of changes here since my previous post,
>  particularly the changes to various filesystems.
>  I've stopped trying to return the dentry from vfs_lookup_open()
>  in the error case - no-one liked that.
> 
>  Thanks for your time,

Neil, I'll take the vfs specific fixes onto vfs-7.4.lookup and then nfs
can pull that all in?

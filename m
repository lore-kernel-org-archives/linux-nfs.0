Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E13A2BE644;
	Tue, 25 Aug 2026 06:20:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=198.137.202.133
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787638826; cv=none; b=fvEIY1IDE9iuwHH4U42bwXyBMf+GxCQ47frOnRqXI1rX88motyMfyLdGC8ND9f0frtwNocl/2l+an78oFHlkc9IcWcaydKPh1ldbLbzm3sfOaERaD/Xi7/ldgFSfho5Bcy3xKTBag+UMi2RyVvnRAyh/IEgFPl9Ir5oSqrkNOPE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787638826; c=relaxed/simple;
	bh=UwAVE8feyzEEVa7B3YVGRwg0taJTQAUkktooec9JQes=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=cxkW82iHLXaskLxyO6uG3WtZYSnIQsfL6XmcQmcBghhOqGX4sekkA5l0Em7ngxlybEYBw2RtSNg6tlei7KxCLUG2SPOLHT2gngKndlmeurjUymBjugP2xE00btwjE/IWeJIj78LgDQC1YjOi6jzafvS0fktmtUi/Pkh94URTHZY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org; dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b=b0B4lFod; arc=none smtp.client-ip=198.137.202.133
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=infradead.org
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=bombadil.srs.infradead.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="b0B4lFod"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20210309; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=ocLSwSEGwFnmhH+Iqzhe0daYm5t7ZVnHocyZcda2cao=; b=b0B4lFodYJY+K2zHiZL5uOLfuO
	fh0h3Mw4Gc1G8fNJpzblMX0AfnnfJwmXMNJO1cFoHrJ5pfKsz0kXrdoiCQuFD79QYpyXABYcYzKVK
	NpUr9Nf/4tBmamhCaS9EhjLtjjkomhwHw/9cWtlfcyxlyUcVs65bKcsVFvoeybbTETiBDBKDNkG1Z
	uqPE99JqqU2W9MajQGyX3ub2osOCJamEtj7LJ7S3pveUaFMgOAP+edmjUBTWQv7691Bd9kqIv2bMD
	I8bTsbTuWbMQXrxzyIv8aFna4pHy0vsWjbAlcoX00RWn5NiyALwCUqVnn0pfeUsKNRje+KBOINntj
	S6JWMUgw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wykWG-00000000Dlq-2s2p;
	Tue, 25 Aug 2026 06:20:24 +0000
Date: Mon, 24 Aug 2026 23:20:24 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <cel@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Ameer Hamza <ameer.hamza@truenas.com>,
	Amir Goldstein <amir73il@gmail.com>
Subject: Re: [PATCH v1] splice: emit a single fsnotify access event per NFSD
 READ
Message-ID: <ao00KJYNtQqHQGhl@infradead.org>
References: <20260824161021.245575-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260824161021.245575-1-cel@kernel.org>
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html

On Mon, Aug 24, 2026 at 12:10:21PM -0400, Chuck Lever wrote:
> nfsd_finish_read() calls fsnotify_access() on both NFSD read paths,
> because splice_direct_to_actor() does not emit the event itself. The
> iterator path reaches nfsd_finish_read() from vfs_iocb_iter_read(),
> which has already emitted one. A READ served without splice therefore
> emits two access events.
> 
> NFSD does not use splice for the GSS integrity and privacy services, so
> a READ on a sec=krb5i or sec=krb5p mount takes the iterator. An inotify
> watch on that file sees the READ twice.
> 
> Reported-by: Ameer Hamza <ameer.hamza@truenas.com>
> Closes: https://lore.kernel.org/linux-nfs/20260818225715.572140-1-ameer.hamza@truenas.com/
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> Link: https://lore.kernel.org/linux-nfs/CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCzN2Xz=xm1FyumewHZXg@mail.gmail.com/
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/vfs.c          |  7 ++----
>  fs/splice.c            | 56 +++++++++++++++++++++++++++++++-----------
>  include/linux/splice.h |  4 +--
>  3 files changed, 45 insertions(+), 22 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f9131827d391..c134064a1c79 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1046,7 +1046,6 @@ static __be32 nfsd_finish_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		nfsd_stats_io_read_add(nn, fhp->fh_export, host_err);
>  		*eof = nfsd_eof_on_read(file, offset, host_err, *count);
>  		*count = host_err;
> -		fsnotify_access(file);
>  		trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
>  		return 0;
>  	} else {
> @@ -1080,10 +1079,8 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	ssize_t host_err;
>  
>  	trace_nfsd_read_splice(rqstp, fhp, offset, *count);
> -	host_err = rw_verify_area(READ, file, &offset, *count);
> -	if (!host_err)
> -		host_err = splice_direct_to_actor(file, &sd,
> -						  nfsd_direct_splice_actor);
> +	host_err = vfs_splice_direct_to_actor(file, &sd,
> +					      nfsd_direct_splice_actor);
>  	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
>  }
>  
> diff --git a/fs/splice.c b/fs/splice.c
> index 9d8f63e2fd1a..42ad712a0f4d 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1009,21 +1009,14 @@ ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
>  }
>  EXPORT_SYMBOL_GPL(vfs_splice_read);
>  
> -/**
> - * splice_direct_to_actor - splices data directly between two non-pipes
> - * @in:		file to splice from
> - * @sd:		actor information on where to splice to
> - * @actor:	handles the data splicing
> - *
> - * Description:
> - *    This is a special case helper to splice directly between two
> - *    points, without requiring an explicit pipe. Internally an allocated
> - *    pipe is cached in the process, and reused during the lifetime of
> - *    that process.
> - *
> +/*
> + * This is a special case helper to splice directly between two
> + * points, without requiring an explicit pipe. Internally an allocated
> + * pipe is cached in the process, and reused during the lifetime of
> + * that process.
>   */
> -ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
> -			       splice_direct_actor *actor)
> +static ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
> +				      splice_direct_actor *actor)
>  {
>  	struct pipe_inode_info *pipe;
>  	ssize_t ret, bytes;
> @@ -1147,7 +1140,40 @@ ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
>  
>  	goto done;
>  }
> -EXPORT_SYMBOL(splice_direct_to_actor);
> +
> +/**
> + * vfs_splice_direct_to_actor - splice from a file through a caller's actor

Can we use this to start retiring the really weird direct terminology
here that is confusing?  I.e. name this vfs_splice_to_actor?
With that we'll only need to fix up do_splice_direct (which is an event
worse name) to fix the public API.

> + * @in:		file to splice from; must be seekable (FMODE_LSEEK)
> + * @sd:		splice parameters. The caller sets @sd->pos and
> + *		@sd->total_len. @sd->pos advances as data is consumed,
> + *		and @sd->total_len is overwritten with the length of
> + *		each read.
> + * @actor:	consumes each pipe-full and returns the number of
> + *		bytes taken

The @ line should just have a short description of the parameter and
not explain all the details.

> + *
> + * Description:

And this Description is accepted by te parset, but redundant.

I'd rework the kerneldoc as:

/**
 * vfs_splice_to_actor - call an actor on data read from a file
 * @in:		file to read from
 * @sd:		splice parameter descriptor
 * @actor:	callback to process a pipes worth of data
 *
 * Read up to @sd->total_len worth of data from @in, and call @actor when the
 * hidden pipe used to buffer the data is full. The caller must set @sd->pos and
 * @sd->total_len. @sd->pos advances as data is consumed, and @sd->total_len is
 * overwritten with the length of data read.
 *
 * Ensures the read is allowed using rw_verify_area() and emits fsnotify access
 * events. @in must be seekable (FMODE_LSEEK).
 *
 * Return: The number of bytes spliced, or a negative errno.
 */

And, looking at the weird semantics of the splice_desc, maybe an even
better idea is to build that inside of vfs_splice_direct_to_actor
and pass in pos, len, and private_data instead?

I.e.:

/**
 * vfs_splice_to_actor - call an actor on data read from a file
 * @in:		file to read from
 * @pos:	file offset
 * @count:	maximum number of bytes to read
 * @actor:	callback to process a pipes worth of data
 * @private:	private data passed to @actor
 *
 * Read up to @count worth of data from @in at @pos, and call @actor when the
 * hidden pipe used to buffer the data is full.
 *
 * Ensures the read is allowed using rw_verify_area() and emits fsnotify access
 * events. @in must be seekable (FMODE_LSEEK).
 *
 * Return: The number of bytes spliced, or a negative errno.
 */

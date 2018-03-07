Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42080 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754333AbeCGVFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 16:05:52 -0500
Date: Wed, 7 Mar 2018 16:05:51 -0500
To: Olga Kornievskaia <kolga@netapp.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v7 05/10] NFSD introduce asynch copy feature
Message-ID: <20180307210551.GC28844@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-6-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180220164229.65404-6-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It looks like "struct nfsd_copy" is being used in at least three
different ways: to hold the xdr arguments and reply, to hold the state
needed while doing a copy, and to hold the callback arguments.  I wonder
if the code would be clearer if those were three different data
structures.

> +static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
> +{
> +	memcpy(&dst->cp_src_stateid, &src->cp_src_stateid, sizeof(stateid_t));
> +	memcpy(&dst->cp_dst_stateid, &src->cp_dst_stateid, sizeof(stateid_t));
> +	dst->cp_src_pos = src->cp_src_pos;
> +	dst->cp_dst_pos = src->cp_dst_pos;
> +	dst->cp_count = src->cp_count;
> +	dst->cp_consecutive = src->cp_consecutive;
> +	dst->cp_synchronous = src->cp_synchronous;
> +	memcpy(&dst->cp_res, &src->cp_res, sizeof(src->cp_res));
> +	/* skipping nfsd4_callback */
> +	memcpy(&dst->fh, &src->fh, sizeof(src->fh));
> +	dst->net = src->net;
> +	dst->cp_clp = src->cp_clp;
> +	atomic_inc(&dst->cp_clp->cl_refcount);
> +	dst->fh_dst = get_file(src->fh_dst);
> +	dst->fh_src = get_file(src->fh_src);

Just another minor gripe, but: could we name those fd_* or file_* or
something instead of fh?  I tend to assume "fh" means "nfs filehandle".

> +}
> +
> +static void cleanup_async_copy(struct nfsd4_copy *copy, bool remove)
> +{
> +	fput(copy->fh_dst);
> +	fput(copy->fh_src);
> +	if (remove) {
> +		spin_lock(&copy->cp_clp->async_lock);
> +		list_del(&copy->copies);
> +		spin_unlock(&copy->cp_clp->async_lock);
> +	}

I don't understand yet why you need these two cases.  Anyway, I'd rather
you did this in the caller.  So the caller can do either:

	spin_lock()
	list_del()
	spin_unlock()
	cleanup_async_copy()

or just

	cleanup_async_copy()

Or define another helper for the first case if you're really doing it a
lot.  Just don't make me have to remember what that second argument
means each time I see it used.

> +	atomic_dec(&copy->cp_clp->cl_refcount);
> +	kfree(copy);
> +}
...
> +	copy->cp_clp = cstate->clp;
> +	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
> +		sizeof(struct knfsd_fh));
> +	copy->net = SVC_NET(rqstp);
> +	/* for now disable asynchronous copy feature */
> +	copy->cp_synchronous = 1;
> +	if (!copy->cp_synchronous) {
> +		status = nfsd4_init_copy_res(copy, 0);
> +		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> +		if (!async_copy) {
> +			status = nfserrno(-ENOMEM);
> +			goto out;
> +		}
> +		dup_copy_fields(copy, async_copy);
> +		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> +			sizeof(copy->cp_dst_stateid));
> +		async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
> +				async_copy, "%s", "copy thread");
> +		if (IS_ERR(async_copy->copy_task)) {
> +			status = PTR_ERR(async_copy->copy_task);

status should be an nfs error.

--b.

> +			goto out_err;
> +		}
> +		spin_lock(&async_copy->cp_clp->async_lock);
> +		list_add(&async_copy->copies,
> +				&async_copy->cp_clp->async_copies);
> +		spin_unlock(&async_copy->cp_clp->async_lock);
> +		wake_up_process(async_copy->copy_task);
> +	} else {
> +		status = nfsd4_do_copy(copy, 1);
>  	}
> -
> -	fput(src);
> -	fput(dst);
>  out:
>  	return status;
> +out_err:
> +	cleanup_async_copy(async_copy, false);
> +	goto out;
>  }
>  
>  static __be32

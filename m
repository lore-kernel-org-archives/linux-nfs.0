Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54416 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751268AbeAYW3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Jan 2018 17:29:03 -0500
Date: Thu, 25 Jan 2018 17:29:02 -0500
To: Olga Kornievskaia <kolga@netapp.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v6 05/10] NFSD first draft of async copy
Message-ID: <20180125222902.GC21492@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <20171024174752.74910-6-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171024174752.74910-6-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 24, 2017 at 01:47:47PM -0400, Olga Kornievskaia wrote:
> +	copy->cp_clp = cstate->clp;
> +	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
> +		sizeof(struct knfsd_fh));
> +	copy->net = SVC_NET(rqstp);
> +	if (!copy->cp_synchronous) {

I was thinking we might want to do a synchronous copy anyway in some
cases: e.g. if the copy is relatively small or if the filesystem
supports clone.

But I guess that's a premature optimization; better to keep this as you
have it for now.

--b.

> +		status = nfsd4_init_copy_res(copy, 0);
> +		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> +		if (!async_copy) {
> +			status = nfserrno(-ENOMEM);
> +			goto out;
> +		}
> +		dup_copy_fields(copy, async_copy);
> +		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> +			sizeof(copy->cp_dst_stateid));
> +		spin_lock(&async_copy->cp_clp->async_lock);
> +		list_add(&async_copy->copies,
> +				&async_copy->cp_clp->async_copies);
> +		spin_unlock(&async_copy->cp_clp->async_lock);
> +		async_copy->copy_task = kthread_create(nfsd4_do_async_copy,
> +				async_copy, "%s", "copy thread");
> +		if (IS_ERR(async_copy->copy_task)) {
> +			status = PTR_ERR(async_copy->copy_task);
> +			goto out_err_dec;
> +		}
> +		wake_up_process(async_copy->copy_task);
> +	} else {
> +		status = nfsd4_do_copy(copy, 1);

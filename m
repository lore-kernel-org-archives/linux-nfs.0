Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35983 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567AbbCXKoY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Mar 2015 06:44:24 -0400
Received: by qgez102 with SMTP id z102so99799660qge.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2015 03:44:23 -0700 (PDT)
Date: Tue, 24 Mar 2015 06:44:20 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Chengyu Song <csong84@gatech.edu>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, taesoo@gatech.edu, changwoo@gatech.edu,
        sanidhya@gatech.edu, blee@gatech.edu
Subject: Re: [PATCH 1/1] nfsd: incorrect check for debugfs returns
Message-ID: <20150324064420.515096c7@tlielax.poochiereds.net>
In-Reply-To: <1427165885-20823-1-git-send-email-csong84@gatech.edu>
References: <1427165885-20823-1-git-send-email-csong84@gatech.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Mar 2015 22:58:05 -0400
Chengyu Song <csong84@gatech.edu> wrote:

> debugfs_create_dir and debugfs_create_file may return -ENODEV when debugfs
> is not configured, so the return value should be checked against ERROR_VALUE
> as well, otherwise the later dereference of the dentry pointer would crash
> the kernel.
> 
> Signed-off-by: Chengyu Song <csong84@gatech.edu>
> ---
>  fs/nfsd/fault_inject.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> index c16bf5a..621d065 100644
> --- a/fs/nfsd/fault_inject.c
> +++ b/fs/nfsd/fault_inject.c
> @@ -132,19 +132,23 @@ int nfsd_fault_inject_init(void)
>  	unsigned int i;
>  	struct nfsd_fault_inject_op *op;
>  	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
> +	struct dentry *dent;
>  
> -	debug_dir = debugfs_create_dir("nfsd", NULL);
> -	if (!debug_dir)
> +	dent = debugfs_create_dir("nfsd", NULL);
> +	if (IS_ERR_OR_NULL(dent))
>  		goto fail;
> +	debug_dir = dent;
>  
>  	for (i = 0; i < NUM_INJECT_OPS; i++) {
>  		op = &inject_ops[i];
> -		if (!debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd))
> +		dent = debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);
> +		if (IS_ERR_OR_NULL(dent))
>  			goto fail;
> +
>  	}
>  	return 0;
>  
>  fail:
>  	nfsd_fault_inject_cleanup();
> -	return -ENOMEM;
> +	return dent ? PTR_ERR(dent) : -ENOMEM;
>  }

No objection to taking this patch in the near term if it helps, but we
had discussed over the summer just removing the NFS fault injection
framework.

Bruce, any objections to making that happen for v4.1?

-- 
Jeff Layton <jeff.layton@primarydata.com>

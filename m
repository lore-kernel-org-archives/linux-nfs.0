Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:39676 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733AbaGJIeJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 04:34:09 -0400
Date: Thu, 10 Jul 2014 01:34:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 014/100] nfsd: set stateid access and deny bits in
 nfs4_get_vfs_file
Message-ID: <20140710083406.GA1805@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-15-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-15-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> @@ -3343,20 +3347,15 @@ out:
>  static __be32
>  nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
>  {
> -	u32 op_share_access = open->op_share_access;
>  	__be32 status;
>  
> -	if (!test_access(op_share_access, stp))
> -		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, open);
> +	if (!test_access(open->op_share_access, stp))
> +		status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
>  	else
>  		status = nfsd4_truncate(rqstp, cur_fh, open);
>  
>  	if (status)
>  		return status;
> -
> -	/* remember the open */
> -	set_access(op_share_access, stp);
> -	set_deny(open->op_share_deny, stp);
>  	return nfs_ok;

This function is trivial enough now to be merged into the only caller,
especially as that open actually has another call to nfs4_get_vfs_file
right next to it in another branch.


>  	} else {
> -		status = nfs4_get_vfs_file(rqstp, fp, current_fh, open);
> -		if (status)
> -			goto out;
>  		stp = open->op_stp;
>  		open->op_stp = NULL;
>  		init_open_stateid(stp, fp, open);
> +		status = nfs4_get_vfs_file(rqstp, fp, current_fh, stp, open);
> +		if (status) {
> +			release_open_stateid(stp);
> +			goto out;
> +		}

I can't find a place where we set the access bits before here.


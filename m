Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53854 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbaKGVBR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 16:01:17 -0500
Date: Fri, 7 Nov 2014 16:01:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna.Schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 2/3] nfsd: Add ALLOCATE support
Message-ID: <20141107210115.GA5723@fieldses.org>
References: <1415389467-16547-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1415389467-16547-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1415389467-16547-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 07, 2014 at 02:44:26PM -0500, Anna.Schumaker@netapp.com wrote:
> @@ -533,6 +534,28 @@ __be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  }
>  #endif
>  
> +__be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			   struct file *file, loff_t offset, loff_t len,
> +			   int flags)
> +{
> +	__be32 err;
> +	int error;
> +
> +	if (!S_ISREG(file_inode(file)->i_mode))
> +		return nfserr_inval;
> +
> +	err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry, NFSD_MAY_WRITE);
> +	if (err)
> +		return err;
> +
> +	error = vfs_fallocate(file, flags, offset, len);
> +	if (!error)
> +		error = commit_metadata(fhp);
> +
> +	if (error == -ENODEV)
> +		return nfserr_inval;


I don't think we need this check any more.

I'll just remove it myself as I apply if there's no objection.

--b.

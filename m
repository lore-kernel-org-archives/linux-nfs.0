Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41366 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215Ab3C1QKK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 12:10:10 -0400
Date: Thu, 28 Mar 2013 12:10:07 -0400
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 13/14] NFSD: Server implementation of MAC Labeling
Message-ID: <20130328161006.GE7080@fieldses.org>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
 <1364478845-29796-14-git-send-email-SteveD@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1364478845-29796-14-git-send-email-SteveD@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 28, 2013 at 09:54:04AM -0400, Steve Dickson wrote:
> @@ -888,6 +924,11 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  					    setattr->sa_acl);
>  	if (status)
>  		goto out;
> +	if (setattr->sa_label != NULL)
> +		status = nfsd4_set_nfs4_label(rqstp, &cstate->current_fh,
> +				setattr->sa_label);

I'm getting an error from setattr over NFS4.0, even when I don't have
nfs4_label support compiled in, I'm not sure why....  Maybe sa_label
isn't being initialized to NULL in that case?

(Reproduceable with pynfs 4.0 SATT13.)

...
> index 2b2e239..b2b2e5a 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -28,6 +28,7 @@
>  #include <asm/uaccess.h>
>  #include <linux/exportfs.h>
>  #include <linux/writeback.h>
> +#include <linux/security.h>
>  
>  #ifdef CONFIG_NFSD_V3
>  #include "xdr3.h"
> @@ -621,6 +622,34 @@ int nfsd4_is_junction(struct dentry *dentry)
>  		return 0;
>  	return 1;
>  }
> +#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct nfs4_label *label)
> +{
> +	__be32 error;
> +	int host_error;
> +	struct dentry *dentry;
> +
> +	/* XXX: should we have a MAY_SSECCTX? */
> +	error = fh_verify(rqstp, fhp, 0 /* S_IFREG */, NFSD_MAY_SATTR);
> +	if (error)
> +		return error;
> +
> +	dentry = fhp->fh_dentry;
> +
> +	mutex_lock(&dentry->d_inode->i_mutex);
> +	host_error = security_inode_setsecctx(dentry, label->label, label->len);
> +	mutex_unlock(&dentry->d_inode->i_mutex);
> +	return nfserrno(host_error);
> +}
> +#else
> +__be32 nfsd4_set_nfs4_label(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +		struct nfs4_label *label)
> +{
> +	return -EOPNOTSUPP;

That's returning a kernel error number to an nfs client.  You want
something else, maybe nfserr_attrnotsupp?

But this actually should have been caught earlier by
check_attr_support().

--b.

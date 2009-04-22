From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/11] nfsd: CHANGE old function calls to new calls
Date: Wed, 22 Apr 2009 16:05:53 -0400
Message-ID: <20090422200553.GH9541@fieldses.org>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090325133707.16437.66360.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krishna Kumar <krkumar2@in.ibm.com>, jlayton@redhat.com,
	linux-nfs@vger.kernel.org
To: Krishna Kumar <krikku@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:59870 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbZDVUF4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 16:05:56 -0400
In-Reply-To: <20090325133707.16437.66360.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 25, 2009 at 07:07:07PM +0530, Krishna Kumar wrote:
> @@ -1337,12 +1321,30 @@ nfsd_read(struct svc_rqst *rqstp, struct
>  			goto out;
>  		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
>  	} else {
> -		err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
> -		if (err)
> -			goto out;
> -		err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen, count);
> -		nfsd_close(file);
> +		struct fhcache	*fh;
> +
> +		/* Check if this fh is cached */
> +		fh = nfsd_get_fhcache(fhp->fh_handle.fh_auth[3]);

How do you know fh_auth[3] is sufficient to identify the file reliably?
This looks very fragile to me.

If the goal is to bypass rqst_exp_find(), exportfs_decode_fh() and
friends--that makes me nervous.  We should figure out how to make those
lookups faster instead.  Or at the very least, make sure we're keying on
the entire filehandle instead of just part of it.

--b.

> +		if (fh && fh->p_filp) {
> +			/* Got cached values */
> +			file = fh->p_filp;
> +			fhp->fh_dentry = file->f_dentry;
> +			fhp->fh_export = fh->p_exp;
> +			err = fh_verify(rqstp, fhp, S_IFREG, NFSD_MAY_READ);
> +		} else {
> +			/* Nothing in cache */
> +			err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ,
> +					&file);
> +		}
> +
> +		if (!err)
> +			err = nfsd_vfs_read(rqstp, fhp, file, offset, vec, vlen,
> +					    count);
> +
> +		/* Update cached values if required, and clean up */
> +		fh_cache_upd(fh, file, fhp->fh_export);
>  	}
> +
>  out:
>  	return err;
>  }

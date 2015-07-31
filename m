Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33901 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946192AbbGaU24 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 16:28:56 -0400
Received: by ykax123 with SMTP id x123so68526603yka.1
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2015 13:28:55 -0700 (PDT)
Date: Fri, 31 Jul 2015 16:28:51 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do nfs4_check_fh in nfs4_check_file instead of
 nfs4_check_olstateid
Message-ID: <20150731162851.6b727863@tlielax.poochiereds.net>
In-Reply-To: <20150731200534.GA20543@fieldses.org>
References: <1438253866-7393-1-git-send-email-jeff.layton@primarydata.com>
	<20150730151641.GE9349@fieldses.org>
	<20150731200534.GA20543@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 31 Jul 2015 16:05:34 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jul 30, 2015 at 11:16:41AM -0400, J. Bruce Fields wrote:
> > On Thu, Jul 30, 2015 at 06:57:46AM -0400, Jeff Layton wrote:
> > > Currently, preprocess_stateid_op calls nfs4_check_olstateid which
> > > verifies that the open stateid corresponds to the current_fh in the
> > > call by calling nfs4_check_fh.
> > > 
> > > If the stateid is a NFS4_DELEG_STID however, then no such check is
> > > done. Move the call to nfs4_check_fh into nfs4_check_file instead
> > > so that it can be done for all stateid types.
> > 
> > Thanks, applying for 4.2 and -stable with a note that this can screw up
> > permissions checking later in nfs4_check_file.
> 
> By the way I also had to apply the following to avoid a NULL dereference
> in the special-stateid case (when we'll jump to the "done:" label with
> "s" still NULL).  Thanks to pynfs4.0 RD1 for catching that....
> 
> --b.
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5cee7f2c4802..95202719a1fd 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4615,10 +4615,6 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
>  	struct file *file;
>  	__be32 status;
>  
> -	status = nfs4_check_fh(fhp, s);
> -	if (status)
> -		return status;
> -
>  	file = nfs4_find_file(s, flags);
>  	if (file) {
>  		status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> @@ -4691,6 +4687,9 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>  		status = nfserr_bad_stateid;
>  		break;
>  	}
> +	if (status)
> +		goto out;
> +	status = nfs4_check_fh(fhp, s);
>  
>  done:
>  	if (!status && filpp)

Good catch. My bad for not running pynfs against it! If you're adding
this as a separate patch you can add my:

Reviewed-by: Jeff Layton <jlayton@poochiereds.net>

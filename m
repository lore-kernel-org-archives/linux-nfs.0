Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38187 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751641AbaHDVqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2014 17:46:51 -0400
Date: Mon, 4 Aug 2014 17:46:47 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Rishi Agrawal <Rishi_Agrawal@symantec.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Rajesh Ghanekar <Rajesh_Ghanekar@symantec.com>,
        Ram Pandiri <ram_pandiri@symantec.com>,
        Sreeharsha Sarabu <Sreeharsha_Sarabu@symantec.com>,
        Abhijit Dey <Abhijit_Dey@symantec.com>,
        Tushar Shinde <Tushar_Shinde@symantec.com>,
        "bfields@redhat.com" <bfields@redhat.com>
Subject: Re: [PATCH] nfsd: allow turning off nfsv3 readdir_plus
Message-ID: <20140804214646.GK23341@fieldses.org>
References: <20AEB6A025F81A4288597093171D1B5719CF5813D2@APJ1XCHEVSPIN35.SYMC.SYMANTEC.COM>
 <53DF992D.6090404@RedHat.com>
 <20140804152411.GB23341@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140804152411.GB23341@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 04, 2014 at 11:24:11AM -0400, bfields wrote:
> +static int
> +nfsd3_is_readdirplus_supported(struct svc_rqst *rqstp, struct svc_fh *fhp)
> +{
> +	struct svc_export *exp;
> +	int supported = 1; /* fall back to readdirplus supported in case of errors.*/
> +	int err;
> +
> +	err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_READ);
> +	if (err) {
> +		goto out;
> +	}

Actually, this isn't right: errors from fh_verify should be returned to
the client or weird things could happen (e.g. what should have been a
transient DELAY error could result in the client turning off
readdirplus).  And MAY_READ is more than nfsd_readdir actually asks for,
I think, probably should just be MAY_NOP here.

I'll fix that up.--b.

> +
> +	exp = fhp->fh_export;
> +	if (exp->ex_flags & NFSEXP_NOREADDIRPLUS) {
> +		supported = 0;
> +	}
> +out:
> +	return supported;
> +}
> +
>  /*
>   * Read a portion of a directory, including file handles and attrs.
>   * For now, we choose to ignore the dircount parameter.
> @@ -471,10 +491,16 @@ nfsd3_proc_readdirplus(struct svc_rqst *rqstp, struct nfsd3_readdirargs *argp,
>  	resp->buflen = resp->count;
>  	resp->rqstp = rqstp;
>  	offset = argp->cookie;
> -	nfserr = nfsd_readdir(rqstp, &resp->fh,
> -				     &offset,
> -				     &resp->common,
> -				     nfs3svc_encode_entry_plus);
> +
> +	if (nfsd3_is_readdirplus_supported(rqstp, &resp->fh)) {
> +		nfserr = nfsd_readdir(rqstp, &resp->fh,
> +				&offset,
> +				&resp->common,
> +				nfs3svc_encode_entry_plus);
> +	} else {
> +		nfserr = nfserrno(-EOPNOTSUPP);
> +	}
> +
>  	memcpy(resp->verf, argp->verf, 8);
>  	for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
>  		page_addr = page_address(*p);
> diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
> index cf47c313794e..584b6ef3a5e8 100644
> --- a/include/uapi/linux/nfsd/export.h
> +++ b/include/uapi/linux/nfsd/export.h
> @@ -28,7 +28,8 @@
>  #define NFSEXP_ALLSQUASH	0x0008
>  #define NFSEXP_ASYNC		0x0010
>  #define NFSEXP_GATHERED_WRITES	0x0020
> -/* 40 80 100 currently unused */
> +#define NFSEXP_NOREADDIRPLUS    0x0040
> +/* 80 100 currently unused */
>  #define NFSEXP_NOHIDE		0x0200
>  #define NFSEXP_NOSUBTREECHECK	0x0400
>  #define	NFSEXP_NOAUTHNLM	0x0800		/* Don't authenticate NLM requests - just trust */
> @@ -47,7 +48,7 @@
>   */
>  #define	NFSEXP_V4ROOT		0x10000
>  /* All flags that we claim to support.  (Note we don't support NOACL.) */
> -#define NFSEXP_ALLFLAGS		0x17E3F
> +#define NFSEXP_ALLFLAGS		0x1FE7F
>  
>  /* The flags that may vary depending on security flavor: */
>  #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
> -- 
> 1.9.3
> 

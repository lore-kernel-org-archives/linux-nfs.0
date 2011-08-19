Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34667 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab1HSVMw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 17:12:52 -0400
Subject: Re: [PATCH] nfsd4: fix seqid_mutating_error
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Fri, 19 Aug 2011 17:12:53 -0400
In-Reply-To: <20110819172416.GA1112@fieldses.org>
References: <20110819172416.GA1112@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1313788373.26701.1.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-08-19 at 13:24 -0400, J. Bruce Fields wrote: 
> Yipes--noticed while doing some unrelated v4 state work.  I'll probably
> send this along soonish.
> 
> --b.
> 
> commit 8eea0f78ed3f3238e238c8ca76e5c7a5c1e7b5f5
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Wed Aug 10 19:16:22 2011 -0400
> 
>     nfsd4: fix seqid_mutating_error
>     
>     The set of errors here does *not* agree with the set of errors specified
>     in the rfc!
>     
>     While we're there, turn this macros into a function, for the usual
>     reasons, and move it to the one place where it's actually used.
>     
>     Cc: stable@kernel.org
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index c8bf405..f810996 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1623,6 +1623,18 @@ static void write_cinfo(__be32 **p, struct nfsd4_change_info *c)
>  								\
>  	save = resp->p;
>  
> +static bool seqid_mutating_err(__be32 err)
> +{
> +	/* rfc 3530 section 8.1.5: */
> +	return	err != nfserr_stale_clientid &&
> +		err != nfserr_stale_stateid &&
> +		err != nfserr_bad_stateid &&
> +		err != nfserr_bad_seqid &&
> +		err != nfserr_bad_xdr &&
> +		err != nfserr_resource &&
> +		err != nfserr_nofilehandle;

Any reason not to convert the above into a switch() statement while you
are at it?

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com


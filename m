Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57305 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993Ab2JSMo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Oct 2012 08:44:26 -0400
Date: Fri, 19 Oct 2012 08:44:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Cc: yongjun_wei@trendmicro.com.cn, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: remove unused variable in nfsd4_delegreturn()
Message-ID: <20121019124421.GB20324@fieldses.org>
References: <CAPgLHd_u-xX9oHdst_nCf0h+HmSigU7euOy3UYbemc=Um7trSw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPgLHd_u-xX9oHdst_nCf0h+HmSigU7euOy3UYbemc=Um7trSw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 18, 2012 at 10:44:21PM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> The variable inode is initialized but never used
> otherwise, so remove the unused variable.
> 
> dpatch engine is used to auto generate this patch.
> (https://github.com/weiyj/dpatch)

Thanks, applying for 3.8.--b.

> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  fs/nfsd/nfs4state.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index d0237f8..620ff81 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3807,12 +3807,10 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	struct nfs4_delegation *dp;
>  	stateid_t *stateid = &dr->dr_stateid;
>  	struct nfs4_stid *s;
> -	struct inode *inode;
>  	__be32 status;
>  
>  	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
>  		return status;
> -	inode = cstate->current_fh.fh_dentry->d_inode;
>  
>  	nfs4_lock_state();
>  	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s, cstate->minorversion);
> 

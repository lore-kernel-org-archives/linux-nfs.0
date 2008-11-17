From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 19/51] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid
 bmap
Date: Mon, 17 Nov 2008 16:05:10 +0200
Message-ID: <49217A16.3090000@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350029-10810-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:13137 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752180AbYKQOFO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:05:14 -0500
In-Reply-To: <1226350029-10810-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:47 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> Separate the access bits from the want bits and enable __set_bit to
> work correctly with st_access_bmap.
> 
> Signed-off-by: Andy Adamson<andros@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index b772469..db79c0c 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1186,7 +1186,8 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
>  	stp->st_stateid.si_generation = 0;
>  	stp->st_access_bmap = 0;
>  	stp->st_deny_bmap = 0;
> -	__set_bit(open->op_share_access, &stp->st_access_bmap);
> +	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,

review 11-13: should be (open->op_share_access & NFS4_SHARE_DENY_MASK)
also, define NFS4_SHARE_ACCESS_MASK (== NFS4_SHARE_DENY_MASK)
and use it in access_valid() as well.

> +		  &stp->st_access_bmap);
>  	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
>  	stp->st_openstp = NULL;
>  }

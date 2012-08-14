Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37566 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755869Ab2HNT6p (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 15:58:45 -0400
Date: Tue, 14 Aug 2012 15:58:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Swap the struct nfs4_operation getter and setter
Message-ID: <20120814195843.GA16057@fieldses.org>
References: <1344974108-24531-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1344974108-24531-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 14, 2012 at 03:55:08PM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> stateid_setter should be matched to op_set_currentstateid, rather than
> op_get_currentstateid.

Why didn't we notice that?

Oh, the two prototypes are actually identical.  Eh.  OK, applying,
thanks.

--b.

> 
> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfsd/nfs4proc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index c9c1c0a..f2bb0ef 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1054,8 +1054,8 @@ struct nfsd4_operation {
>  	char *op_name;
>  	/* Try to get response size before operation */
>  	nfsd4op_rsize op_rsize_bop;
> -	stateid_setter op_get_currentstateid;
> -	stateid_getter op_set_currentstateid;
> +	stateid_getter op_get_currentstateid;
> +	stateid_setter op_set_currentstateid;
>  };
>  
>  static struct nfsd4_operation nfsd4_ops[];
> -- 
> 1.7.11.4
> 

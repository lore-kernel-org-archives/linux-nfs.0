Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47121 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753826AbaA0XBd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jan 2014 18:01:33 -0500
Date: Mon, 27 Jan 2014 18:01:31 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Ming Chen <mchen@cs.stonybrook.edu>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "trond.myklebust@primarydata.com" <trond.myklebust@primarydata.com>,
        Erez Zadok <ezk@fsl.cs.sunysb.edu>,
        "dhildeb@us.ibm.com" <dhildeb@us.ibm.com>,
        "geoff@cs.hmc.edu" <geoff@cs.hmc.edu>
Subject: Re: [PATCH] nfsd: consider CLAIM_FH when handing out delegation
Message-ID: <20140127230131.GB8534@fieldses.org>
References: <F2EEB2C045C93A4889A2C09F59EDB20858153672@mail2.cs.stonybrook.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F2EEB2C045C93A4889A2C09F59EDB20858153672@mail2.cs.stonybrook.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 09, 2014 at 09:26:10PM +0000, Ming Chen wrote:
> CLAIM_FH was added by NFSv4.1.  It is the same as CLAIM_NULL except that it
> uses only current FH to identify the file to be opened.
> 
> The NFS client is using CLAIM_FH if the FH is available when opening a file.
> Currently, we cannot get any delegation if we stat a file before open it
> because the server delegation code does not recognize CLAIM_FH.
> 
> We tested this patch and found delegation can be handed out now when claim is
> CLAIM_FH.

Looks reasonable, thanks; applying.--b.

> 
> See http://marc.info/?l=linux-nfs&m=136369847801388&w=2 and
> http://www.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#New_open_claim_types
> 
> Signed-off-by: Ming Chen <mchen@cs.stonybrook.edu>
> ---
>  fs/nfsd/nfs4state.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 105d6fa..514d9c2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -3125,6 +3125,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
>  				goto out_no_deleg;
>  			break;
>  		case NFS4_OPEN_CLAIM_NULL:
> +		case NFS4_OPEN_CLAIM_FH:
>  			/*
>  			 * Let's not give out any delegations till everyone's
>  			 * had the chance to reclaim theirs....
> -- 
> 1.7.1

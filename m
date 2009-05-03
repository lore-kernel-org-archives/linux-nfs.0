From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC 04/10] nfsd41: Remember the auth flavor to use for
	callbacks
Date: Sun, 3 May 2009 16:42:36 -0400
Message-ID: <20090503204236.GB22306@fieldses.org>
References: <49FA2D86.8060402@panasas.com> <1241132761-32494-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48970 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbZECUmh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 16:42:37 -0400
In-Reply-To: <1241132761-32494-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2009 at 02:06:01AM +0300, Benny Halevy wrote:
> From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> The callbacks will be sent using the same authentication flavor that
> was used during session creation.  We'll add code to remember the
> principal in the case RPCSEC_GSS in a separate patch.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index cc9705b..ad30039 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1284,6 +1284,7 @@ out_new:
>  	copy_verf(new, &verf);
>  	copy_cred(&new->cl_cred, &rqstp->rq_cred);
>  	new->cl_addr = ip_addr;
> +	new->cl_flavor = rqstp->rq_flavor;
>  	gen_clid(new);
>  	gen_confirm(new);
>  	add_to_unconfirmed(new, strhashval);

Most of the code here is duplicated between the 4.1 and 4.0 cases, and
this is just adding a line that was already there in the 4.0 case.  (The
same will be true for rembering the princpal in the RPCSEC_GSS case.)
Could we move the rest of this initialization into create_client (giving
it some more arguments if necessary), and eliminate some code
duplication?

--b.

> -- 
> 1.6.2.1
> 

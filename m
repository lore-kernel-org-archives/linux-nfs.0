From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs4: allow server to change forechannel max_ops
Date: Tue, 25 May 2010 12:57:04 -0400
Message-ID: <1274806624.11283.10.camel@heimdal.trondhjem.org>
References: <20100525164224.GC4235@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50865 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab0EYQ5V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 May 2010 12:57:21 -0400
In-Reply-To: <20100525164224.GC4235@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-05-25 at 12:42 -0400, J. Bruce Fields wrote: 
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> Section 18.36.3 of rfc 5661 says that "For the fore channel, the server
> MAY change the requested value."
> 
> Also, there's no reason why the client would have to care if the server
> is willing to accept *more* operations per compound than the client
> requested.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  fs/nfs/nfs4proc.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> On the other hand, if the server *decreases* max_ops on the forechannel,
> the client may need to do something.  (Probably just fail for now.)  Why
> aren't we checking for that case?
> 
> --b.
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 071fced..a5a3690 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4880,7 +4880,6 @@ static int nfs4_verify_channel_attrs(struct nfs41_create_session_args *args,
>  
>  	ret |= _verify_fore_channel_attr(headerpadsz);
>  	ret |= _verify_fore_channel_attr(max_resp_sz);
> -	ret |= _verify_fore_channel_attr(max_ops);
>  
>  	ret |= _verify_back_channel_attr(headerpadsz);
>  	ret |= _verify_back_channel_attr(max_rqst_sz);

Yes. That all looks wrong.

Can we please just get rid of that senseless macro, and open code those
checks instead of the above patch? The current code is just pure
obfuscation...

Trond

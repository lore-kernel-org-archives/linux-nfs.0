From: Alexandros Batsakis <batsakis@netapp.com>
Subject: Re: [pnfs] [PATCH 4/5] nfsd41: set the session maximum response sizecached
Date: Wed, 1 Jul 2009 16:09:55 -0700
Message-ID: <5BDF2F31-6F9B-4214-95F9-4EE9B40E5538@netapp.com>
References: <> <1245872278-18743-1-git-send-email-andros@netapp.com><1245872278-18743-2-git-send-email-andros@netapp.com><1245872278-18743-3-git-send-email-andros@netapp.com><1245872278-18743-4-git-send-email-andros@netapp.com> <1245872278-18743-5-git-send-email-andros@netapp.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: <bfields@citi.umich.edu>, "Adamson, Andy" <andros@netapp.com>,
	<linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4404 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbZGAXKk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jul 2009 19:10:40 -0400
In-Reply-To: <1245872278-18743-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 24, 2009, at 12:37 PM, Adamson, Andy wrote:

> From: Andy Adamson <andros@netapp.com>
>
> NFSD_SLOT_CACHE_SIZE holds the encoded operations past the SEQUENCE  
> operation.
> ca_maxresponsesize_cached (draft-ietf-nfsv4-minorversion1-29) is the  
> xdr
> encoded size of the request including the RPC header. Since the RPC  
> header
> size varies with security flavor credential and verifier. we cannot  
> set an
> accurate ca_maxresponsesize_cached. Use NFSD_SLOT_CACHE_SIZE as an
> approximate ca_maxresponsesize_cached - we will have at least that  
> much space.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 991c3cc..a0bd6da 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -464,9 +464,14 @@ static int init_forechannel_attrs(struct  
> svc_rqst *rqstp,
>                 fchan->maxresp_sz = maxcount;
>         session_fchan->maxresp_sz = fchan->maxresp_sz;
>
> -       /* Set the max response cached size our default which is
> -        * a multiple of PAGE_SIZE and small */
> -       session_fchan->maxresp_cached = NFSD_PAGES_PER_SLOT *  
> PAGE_SIZE;
> +       /*
> +        * The ca_maxresponssize_cached definition includes the xdr
> +        * encoded size of the rpc header with the variable length  
> security
> +        * flavor credential plus verifier as well as the encoded  
> SEQUENCE
> +        * operation response size which are not included in
> +        * NFSD_SLOT_CACHE_SIZE. We err on the side of being a bit  
> small.
> +        */
> +       session_fchan->maxresp_cached = NFSD_SLOT_CACHE_SIZE;
>         fchan->maxresp_cached = session_fchan->maxresp_cached;
>
>
Here we set the maxresp_cached equal to 512 which is normally much  
less than the maxresp_sz, and we return this value to client in  
CREATE_SESSION.
This leads to a bunch of NFSERR_TOO_BIG_TO_CACHE errors for OPENs,  
READs, etc.
In theory the client should be able to recover (or better prevent this  
by not setting cachethis=1).
Is there a reason that maxresp_cached is so small ?

-alexandros
>         /* Use the client's maxops if possible */
> --
> 1.5.4.3
>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>


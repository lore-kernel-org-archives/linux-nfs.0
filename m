Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570Ab3DVMSY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Apr 2013 08:18:24 -0400
Message-ID: <51752A88.4080301@RedHat.com>
Date: Mon, 22 Apr 2013 08:18:16 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Libtirpc-devel Mailing List
	<libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [Libtirpc-devel] [PATCH] svc_getargs(): Should not be freeing
 arg pointers on failures
References: <1366310898-9206-1-git-send-email-steved@redhat.com>
In-Reply-To: <1366310898-9206-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 18/04/13 14:48, Steve Dickson wrote:
> commit 82cc2e61 (SVCAUTH_WRAP/SVCAUTH_UNWRAP) introduce a regression
> that causes callers of svc_getargs() to crash when svc_freeargs() frees
> args points that are allocated on the stack.
> 
> svc_getargs() should let the callers do the freeing and not make any
> assumptions on the type of memory passed in.
> 
> Also see:
>     https://bugzilla.redhat.com/show_bug.cgi?id=948378
> and
>     CVE-2013-1950 EMBARGOED rpcbind: invalid pointer free leads to crash
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  src/svc_dg.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/src/svc_dg.c b/src/svc_dg.c
> index b1ac462..6e00191 100644
> --- a/src/svc_dg.c
> +++ b/src/svc_dg.c
> @@ -284,7 +284,6 @@ svc_dg_getargs(xprt, xdr_args, args_ptr)
>  {
>  	if (! SVCAUTH_UNWRAP(xprt->xp_auth, &(su_data(xprt)->su_xdrs),
>  			     xdr_args, args_ptr)) {
> -		(void)svc_freeargs(xprt, xdr_args, args_ptr);
>  		return FALSE;
>  	}
>  	return TRUE;
> 

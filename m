Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753894AbbHXRvc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Aug 2015 13:51:32 -0400
Subject: Re: [PATCH] rpc.gssd: Replace exit(0) by return in
 process_krb5_upcall
To: andros@netapp.com
References: <1440014300-1502-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55DB59A2.6060209@RedHat.com>
Date: Mon, 24 Aug 2015 13:51:30 -0400
MIME-Version: 1.0
In-Reply-To: <1440014300-1502-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/19/2015 03:58 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> exit(0) silenty reaps the gssd_k5_kt_princ struct, the in-memory
> rpc.gssd cache which means that rpc.gssd will get a new TGT and TGS for
> each upcall, ignoring a valid TGT in the kerberos credential cache.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd_proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 03afc8b..3fc7bba 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -684,7 +684,7 @@ out:
>  		AUTH_DESTROY(auth);
>  	if (rpc_clnt)
>  		clnt_destroy(rpc_clnt);
> -	exit(0);
> +	return;
>  
>  out_return_error:
>  	do_error_downcall(fd, uid, downcall_err);
> 

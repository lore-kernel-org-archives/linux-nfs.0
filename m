Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753842AbcENQgM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 May 2016 12:36:12 -0400
Subject: Re: [PATCH 1/2] gssd: no longer needed pid logic
To: Olga Kornievskaia <kolga@netapp.com>
References: <1462286792-8889-1-git-send-email-kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <adc79876-1a1a-0104-0230-ad51533bef3b@RedHat.com>
Date: Sat, 14 May 2016 12:36:10 -0400
MIME-Version: 1.0
In-Reply-To: <1462286792-8889-1-git-send-email-kolga@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/03/2016 10:46 AM, Olga Kornievskaia wrote:
> with threads, we don't need to distinguish zero uid.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Committed... 

steved.

> ---
>  utils/gssd/gssd_proc.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index b19c595..afaaf9e 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -604,7 +604,6 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
>  	gss_buffer_desc		token;
>  	int			err, downcall_err = -EACCES;
>  	OM_uint32		maj_stat, min_stat, lifetime_rec;
> -	pid_t			pid, childpid = -1;
>  	gss_name_t		gacceptor = GSS_C_NO_NAME;
>  	gss_OID			mech;
>  	gss_buffer_desc		acceptor  = {0};
> @@ -702,11 +701,7 @@ out:
>  	if (rpc_clnt)
>  		clnt_destroy(rpc_clnt);
>  
> -	pid = getpid();
> -	if (pid == childpid)
> -		exit(0);
> -	else
> -		return;
> +	return;
>  
>  out_return_error:
>  	do_error_downcall(fd, uid, downcall_err);
> 

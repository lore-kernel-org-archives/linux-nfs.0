Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27947 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905Ab1KRQei (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Nov 2011 11:34:38 -0500
Message-ID: <4EC6890C.3070803@netapp.com>
Date: Fri, 18 Nov 2011 11:34:20 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: peter.staubach@emc.com
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, john@calva.com,
        trond.myklebust@netapp.com
Subject: Re: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS errors
References: <4EC685D1.2000900@Calva.COM> <5E6794FC7B8FCA41A704019BE3C70E8B9422FC09@MX31A.corp.emc.com>
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B9422FC09@MX31A.corp.emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri 18 Nov 2011 11:27:37 AM EST, peter.staubach@emc.com wrote:
> Given that the poor user will be sitting, with almost nothing working because of the expired ticket, how does the user figure out what is going on or how does the admin help him?
>
> Some guidance seems like a good thing.  Is there really a problem with these messages being printed to the log?

I agree.  Rather than removing the messages, is there a way to slow 
them down even further so the logs don't fill up as quickly?

>
> 	Thanx...
>
> 		ps
>
>
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of John Hughes
> Sent: Friday, November 18, 2011 11:21 AM
> To: Trond Myklebust
> Cc: linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS errors
>
> Don't write anything to the log if a user Kerberos ticket expires or is missing,
> these are not kernel problems.
>
> Signed-off-by: John Hughes<john@calva.com>
>
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index 39914be..18897cb 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -1339,14 +1339,6 @@ static void nfs4_state_start_reclaim_nograce(struct nfs_client *clp)
>   	nfs4_state_mark_reclaim_helper(clp, nfs4_state_mark_reclaim_nograce);
>   }
>
> -static void nfs4_warn_keyexpired(const char *s)
> -{
> -	printk_ratelimited(KERN_WARNING "Error: state manager"
> -			" encountered RPCSEC_GSS session"
> -			" expired against NFSv4 server %s.\n",
> -			s);
> -}
> -
>   static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
>   {
>   	switch (error) {
> @@ -1378,7 +1370,6 @@ static int nfs4_recovery_handle_error(struct nfs_client *clp, int error)
>   			return 0;
>   		case -EKEYEXPIRED:
>   			/* Nothing we can do */
> -			nfs4_warn_keyexpired(clp->cl_hostname);
>   			return 0;
>   	}
>   	return error;
> @@ -1620,7 +1611,6 @@ static void nfs4_set_lease_expired(struct nfs_client *clp, int status)
>   		break;
>
>   	case -EKEYEXPIRED:
> -		nfs4_warn_keyexpired(clp->cl_hostname);
>   	case -NFS4ERR_NOT_SAME: /* FixMe: implement recovery
>   				 * in nfs4_exchange_id */
>   	default:
> @@ -1728,8 +1718,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
>   	} while (atomic_read(&clp->cl_count)>  1);
>   	return;
>   out_error:
> -	printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
> -			" with error %d\n", clp->cl_hostname, -status);
> +	if (status != -EACCESS)
> +		printk(KERN_WARNING "Error: state manager failed on NFSv4 server %s"
> +				" with error %d\n", clp->cl_hostname, -status);
>   	nfs4_end_drain_session(clp);
>   	nfs4_clear_state_manager_bit(clp);
>   }
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



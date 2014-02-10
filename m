Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8467 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752231AbaBJXBf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Feb 2014 18:01:35 -0500
Message-ID: <52F95A4C.7040408@RedHat.com>
Date: Mon, 10 Feb 2014 18:01:32 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Don't create a gss auth cache unless rpc.gssd
 is running
References: <D03884DC-C5D3-4496-8F5C-682C3E6372AD@primarydata.com> <1392068887-25091-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1392068887-25091-1-git-send-email-trond.myklebust@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/10/2014 04:48 PM, Trond Myklebust wrote:
> An infinite loop is caused when nfs4_establish_lease() fails
> with -EACCES. This causes nfs4_handle_reclaim_lease_error()
> to sleep a bit and resets the NFS4CLNT_LEASE_EXPIRED bit.
> This in turn causes nfs4_state_manager() to try and
> reestablished the lease, again, again, again...
> 
> The problem is a valid RPCSEC_GSS client is being created when
> rpc.gssd is not running.
> 
> Link: http://lkml.kernel.org/r/1392066375-16502-1-git-send-email-steved@redhat.com
> Fixes: 0ea9de0ea6a4 (sunrpc: turn warn_gssd() log message into a dprintk())
> Reported-by: Steve Dickson <steved@redhat.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>  net/sunrpc/auth_gss/auth_gss.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 6c0513a7f992..44a61e8fda6f 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -991,6 +991,8 @@ gss_create_new(struct rpc_auth_create_args *args, struct rpc_clnt *clnt)
>  	gss_auth->service = gss_pseudoflavor_to_service(gss_auth->mech, flavor);
>  	if (gss_auth->service == 0)
>  		goto err_put_mech;
> +	if (!gssd_running(gss_auth->net))
> +		goto err_put_mech;
>  	auth = &gss_auth->rpc_auth;
>  	auth->au_cslack = GSS_CRED_SLACK >> 2;
>  	auth->au_rslack = GSS_VERF_SLACK >> 2;
> 
Unfortunately I'm seeing the same loop but this time its with _nfs4_proc_exchange_id

Here is the trace point output:
  192.168.62.8-ma-20371 [000] .... 955443.604229: nfs4_exchange_id: error=-13 (EACCES) dstaddr=192.168.62.8

and here is the rpcdebug output:
[ 2782.341981] NFS call  exchange_id auth=RPCSEC_GSS, 'Linux NFSv4.1 <client>'
[ 2782.360540] NFS reply exchange_id: -13

All three mounts (v4.0, v4.1, v4.2) are hung...

Looking into it...

steved.



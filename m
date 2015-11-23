Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751416AbbKWPoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2015 10:44:03 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id BCB3AC0032ED
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2015 15:44:03 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] statd: Update existing record if we receive
 SM_MON with new cookie
To: Scott Mayhew <smayhew@redhat.com>
References: <1448054824-36153-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <56533442.4060907@RedHat.com>
Date: Mon, 23 Nov 2015 10:44:02 -0500
MIME-Version: 1.0
In-Reply-To: <1448054824-36153-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/20/2015 04:27 PM, Scott Mayhew wrote:
> This prevents rpc.statd's in-memory (and on-disk) monitor lists from
> winding up with  multiple records for the same peer with outdated
> cookie values.  This happens in some HA-NFS configurations where
> rpc.statd is always running.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  utils/statd/monitor.c | 40 +++++++++++++++++++++++++++-------------
>  1 file changed, 27 insertions(+), 13 deletions(-)
> 
> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
> index 286a5e2..368bd80 100644
> --- a/utils/statd/monitor.c
> +++ b/utils/statd/monitor.c
> @@ -72,6 +72,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
>  	};
>  	char *dnsname = NULL;
> +	int existing = 0;
>  
>  	xlog(D_CALL, "Received SM_MON for %s from %s", mon_name, my_name);
>  
> @@ -148,17 +149,26 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  		if (statd_matchhostname(NL_MY_NAME(clnt), my_name) &&
>  		    NL_MY_PROC(clnt) == id->my_proc &&
>  		    NL_MY_PROG(clnt) == id->my_prog &&
> -		    NL_MY_VERS(clnt) == id->my_vers &&
> -		    memcmp(NL_PRIV(clnt), argp->priv, SM_PRIV_SIZE) == 0) {
> -			/* Hey!  We already know you guys! */
> -			xlog(D_GENERAL,
> -				"Duplicate SM_MON request for %s "
> -				"from procedure on %s",
> -				mon_name, my_name);
> +		    NL_MY_VERS(clnt) == id->my_vers) {
> +			if (memcmp(NL_PRIV(clnt), argp->priv, SM_PRIV_SIZE)) {
> +				xlog(D_GENERAL,
> +					"Received SM_MON request with new "
> +					"cookie for %s from procedure on %s",
> +					mon_name, my_name);
> +
> +				existing = 1; 
> +				break;
> +			} else {
> +				/* Hey!  We already know you guys! */
> +				xlog(D_GENERAL,
> +					"Duplicate SM_MON request for %s "
> +					"from procedure on %s",
> +					mon_name, my_name);
>  
> -			/* But we'll let you pass anyway. */
> -			free(dnsname);
> -			goto success;
> +				/* But we'll let you pass anyway. */
> +				free(dnsname);
> +				goto success;
> +			}
>  		}
>  		clnt = NL_NEXT(clnt);
>  	}
> @@ -167,7 +177,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  	 * We're committed...ignoring errors.  Let's hope that a malloc()
>  	 * doesn't fail.  (I should probably fix this assumption.)
>  	 */
> -	if (!(clnt = nlist_new(my_name, mon_name, 0))) {
> +	if (!existing && !(clnt = nlist_new(my_name, mon_name, 0))) {
>  		free(dnsname);
>  		xlog_warn("out of memory");
>  		goto failure;
> @@ -180,8 +190,11 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  	clnt->dns_name = dnsname;
>  
>  	/*
> -	 * Now, Create file on stable storage for host.
> +	 * Now, Create file on stable storage for host, first deleting any
> +	 * existing records on file.
>  	 */
> +	nsm_delete_monitored_host(dnsname, mon_name, my_name);
> +
>  	if (!nsm_insert_monitored_host(dnsname,
>  				(struct sockaddr *)(char *)&my_addr, argp)) {
>  		nlist_free(NULL, clnt);
> @@ -190,7 +203,8 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  
>  	/* PRC: do the HA callout: */
>  	ha_callout("add-client", mon_name, my_name, -1);
> -	nlist_insert(&rtnl, clnt);
> +	if (!existing)
> +		nlist_insert(&rtnl, clnt);
>  	xlog(D_GENERAL, "MONITORING %s for %s", mon_name, my_name);
>   success:
>  	result.res_stat = STAT_SUCC;
> 

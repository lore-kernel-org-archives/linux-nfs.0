Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbaFARNk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Jun 2014 13:13:40 -0400
Message-ID: <538B5F40.5050709@RedHat.com>
Date: Sun, 01 Jun 2014 13:13:36 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: jvrao@linux.vnet.ibm.com, rongzeng@us.ibm.com,
        rong zeng <rongzeng@oc1547780626.ibm.com>
Subject: Re: [PATCH] Adding a callback for incoming sm_notify to better handle
 stale lock issue in client crash recovery in HA-NFS environment. The callout
 parameters are:
References: <537B445A.60707@RedHat.com>
In-Reply-To: <537B445A.60707@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/20/2014 08:02 AM, Steve Dickson wrote:
> [ Forwarding this on to the mailing list ] 
> 
> From: rong zeng <rongzeng@oc1547780626.ibm.com>
> 
> 1. "sm-notify" - callout name
> 2. monitored client name as in the SM_NOTIFY request
> 3. IP of the sender of the SM_NOITFY request.
> 4. state value in the SM_NOTIFY request
> 
> This new interface can be used by different HA-NFS product
> in its specific configuration and environment to
> recover from the client crash and stale lock scenarios.
> 
> Signed-off-by: Rong Zeng <rongzeng@us.ibm.com>
Committed... 

steved.

> ---
>  utils/statd/callback.c |   13 ++++++++-----
>  utils/statd/statd.man  |   20 ++++++++++++++++----
>  2 files changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/statd/callback.c b/utils/statd/callback.c
> index d1cc139..58ba70b 100644
> --- a/utils/statd/callback.c
> +++ b/utils/statd/callback.c
> @@ -15,6 +15,7 @@
>  #include "rpcmisc.h"
>  #include "statd.h"
>  #include "notlist.h"
> +#include "ha-callout.h"
> 
>  /* Callback notify list. */
>  /* notify_list *cbnl = NULL; ... never used */
> @@ -87,6 +88,13 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
>  	xlog(D_CALL, "Received SM_NOTIFY from %s, state: %d",
>  				argp->mon_name, argp->state);
> 
> +	if (!statd_present_address(sap, ip_addr, sizeof(ip_addr))) {
> +		xlog_warn("Unrecognized sender address");
> +		return ((void *) &result);
> +	}
> +
> +	ha_callout("sm-notify", argp->mon_name, ip_addr, argp->state);
> +
>  	/* quick check - don't bother if we're not monitoring anyone */
>  	if (rtnl == NULL) {
>  		xlog_warn("SM_NOTIFY from %s while not monitoring any hosts",
> @@ -94,11 +102,6 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
>  		return ((void *) &result);
>  	}
> 
> -	if (!statd_present_address(sap, ip_addr, sizeof(ip_addr))) {
> -		xlog_warn("Unrecognized sender address");
> -		return ((void *) &result);
> -	}
> -
>  	/* okir change: statd doesn't remove the remote host from its
>  	 * internal monitor list when receiving an SM_NOTIFY call from
>  	 * it. Lockd will want to continue monitoring the remote host
> diff --git a/utils/statd/statd.man b/utils/statd/statd.man
> index 896c2f8..1e5520c 100644
> --- a/utils/statd/statd.man
> +++ b/utils/statd/statd.man
> @@ -346,7 +346,8 @@ points due to inactivity.
>  .SS High-availability callouts
>  .B rpc.statd
>  can exec a special callout program during processing of
> -successful SM_MON, SM_UNMON, and SM_UNMON_ALL requests.
> +successful SM_MON, SM_UNMON, and SM_UNMON_ALL requests,
> +or when it receives SM_NOTIFY.
>  Such a program may be used in High Availability NFS (HA-NFS)
>  environments to track lock state that may need to be migrated after
>  a system reboot.
> @@ -357,15 +358,26 @@ option.
>  The program is run with 3 arguments:
>  The first is either
>  .B add-client
> -or
>  .B del-client
> +or
> +.B sm-notify
>  depending on the reason for the callout.
>  The second is the
>  .I mon_name
>  of the monitored peer.
>  The third is the
> -.I caller_name
> -of the requesting lock manager.
> +.I caller_name 
> +of the requesting lock manager for
> +.B add-client
> +or
> +.B del-client
> +, otherwise it is
> +.I IP_address 
> +of the caller sending SM_NOTIFY.
> +The forth is the
> +.I state_value
> +in the SM_NOTIFY request.
> +
>  .SS IPv6 and TI-RPC support
>  TI-RPC is a pre-requisite for supporting NFS on IPv6.
>  If TI-RPC support is built into
> 

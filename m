Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750731AbcFUQIz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2016 12:08:55 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 17DEB46211
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2016 16:08:55 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] statd: suppress a benign log message in
 nsm_delete_host()
To: Scott Mayhew <smayhew@redhat.com>
References: <1466020386-43034-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <b909e138-f48f-5aaf-9319-eeb50a6c0ee0@RedHat.com>
Date: Tue, 21 Jun 2016 12:08:54 -0400
MIME-Version: 1.0
In-Reply-To: <1466020386-43034-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/15/2016 03:53 PM, Scott Mayhew wrote:
> Commit 76f8ce8c (statd: Update existing record if we receive SM_MON with
> new cookie) added some logic to unconditionally delete some existing
> on-disk monitor records.  That works fine in an HA-NFS setup where
> there's a good chance of monitor files being left around after service
> failovers, but in the case where there isn't an existing monitor file
> statd emits a scary looking message like this:
> 
> Jun 15 14:14:59 hostname rpc.statd[1368]: Failed to delete: could not
> stat original file /var/lib/nfs/statd/sm/nfs.smayhew.test: No such file
> or directory
> 
> That message can be suppressed.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  support/include/nsm.h |  3 ++-
>  support/nsm/file.c    | 14 ++++++++------
>  utils/statd/monitor.c |  6 +++---
>  3 files changed, 13 insertions(+), 10 deletions(-)
> 
> diff --git a/support/include/nsm.h b/support/include/nsm.h
> index fb4d823..080d176 100644
> --- a/support/include/nsm.h
> +++ b/support/include/nsm.h
> @@ -59,7 +59,8 @@ extern unsigned int
>  extern _Bool	nsm_insert_monitored_host(const char *hostname,
>  			const struct sockaddr *sap, const struct mon *m);
>  extern void	nsm_delete_monitored_host(const char *hostname,
> -			const char *mon_name, const char *my_name);
> +			const char *mon_name, const char *my_name,
> +			const int chatty);
>  extern void	nsm_delete_notified_host(const char *hostname,
>  			const char *mon_name, const char *my_name);
>  extern size_t	nsm_priv_to_hex(const char *priv, char *buf,
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 7a8b504..aafa755 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -1013,7 +1013,7 @@ nsm_load_notify_list(nsm_populate_t func)
>  
>  static void
>  nsm_delete_host(const char *directory, const char *hostname,
> -		const char *mon_name, const char *my_name)
> +		const char *mon_name, const char *my_name, const int chatty)
>  {
>  	char line[LINELEN + 1 + SM_MAXSTRLEN + 2];
>  	char *outbuf = NULL;
> @@ -1029,8 +1029,9 @@ nsm_delete_host(const char *directory, const char *hostname,
>  	}
>  
>  	if (stat(path, &stb) == -1) {
> -		xlog(L_ERROR, "Failed to delete: "
> -			"could not stat original file %s: %m", path);
> +		if (chatty)
> +			xlog(L_ERROR, "Failed to delete: "
> +				"could not stat original file %s: %m", path);
>  		goto out;
>  	}
>  	remaining = (size_t)stb.st_size + 1;
> @@ -1109,13 +1110,14 @@ out:
>   * @hostname: '\0'-terminated C string containing hostname of record to delete
>   * @mon_name: '\0'-terminated C string containing monname of record to delete
>   * @my_name: '\0'-terminated C string containing myname of record to delete
> + * @chatty: should an error be logged if the monitor file doesn't exist?
>   *
>   */
>  void
>  nsm_delete_monitored_host(const char *hostname, const char *mon_name,
> -		const char *my_name)
> +		const char *my_name, const int chatty)
>  {
> -	nsm_delete_host(NSM_MONITOR_DIR, hostname, mon_name, my_name);
> +	nsm_delete_host(NSM_MONITOR_DIR, hostname, mon_name, my_name, chatty);
>  }
>  
>  /**
> @@ -1129,5 +1131,5 @@ void
>  nsm_delete_notified_host(const char *hostname, const char *mon_name,
>  		const char *my_name)
>  {
> -	nsm_delete_host(NSM_NOTIFY_DIR, hostname, mon_name, my_name);
> +	nsm_delete_host(NSM_NOTIFY_DIR, hostname, mon_name, my_name, 1);
>  }
> diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
> index 368bd80..45c4346 100644
> --- a/utils/statd/monitor.c
> +++ b/utils/statd/monitor.c
> @@ -193,7 +193,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
>  	 * Now, Create file on stable storage for host, first deleting any
>  	 * existing records on file.
>  	 */
> -	nsm_delete_monitored_host(dnsname, mon_name, my_name);
> +	nsm_delete_monitored_host(dnsname, mon_name, my_name, 0);
>  
>  	if (!nsm_insert_monitored_host(dnsname,
>  				(struct sockaddr *)(char *)&my_addr, argp)) {
> @@ -324,7 +324,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
>  			ha_callout("del-client", mon_name, my_name, -1);
>  
>  			nsm_delete_monitored_host(clnt->dns_name,
> -							mon_name, my_name);
> +							mon_name, my_name, 1);
>  			nlist_free(&rtnl, clnt);
>  
>  			return (&result);
> @@ -379,7 +379,7 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
>  			/* PRC: do the HA callout: */
>  			ha_callout("del-client", mon_name, my_name, -1);
>  			nsm_delete_monitored_host(clnt->dns_name,
> -							mon_name, my_name);
> +							mon_name, my_name, 1);
>  			nlist_free(&rtnl, clnt);
>  			++count;
>  			clnt = temp;
> 

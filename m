Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:61673 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab0IQS1t convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 14:27:49 -0400
Subject: Re: [PATCH] rpcbind: don't ignore bind and init_transport errors
Content-Type: text/plain; charset=utf-8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100917181251.GA21111@sith.mimuw.edu.pl>
Date: Fri, 17 Sep 2010 14:26:08 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>
Message-Id: <690CDF34-1D1E-44E2-B077-7EDD350701CB@oracle.com>
References: <20100917181251.GA21111@sith.mimuw.edu.pl>
To: =?utf-8?Q?Jan_R=C4=99korajski?= <baggins@sith.mimuw.edu.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 17, 2010, at 2:12 PM, Jan Rękorajski wrote:

> Hi,
> rpcbind currently silently ignores any errors that occur during
> init_transport, it also happily continues if bind(2) fails for
> UDP socket - it's enough if just one UDP socket is bound.
> 
> This patch makes rpcbind fail if there are problems with
> setting up any transport, so we don't end up with
> semi/non functional running daemon.

Can you give us some details about why transport initialization was failing?  There are probably some cases where we do want rpcbind to soldier on in spite of such troubles.

> Signed-off-by: Jan Rękorajski <baggins@sith.mimuw.edu.pl>
> 
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index 63023e1..06e5b08 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -179,11 +179,17 @@ main(int argc, char *argv[])
> 	
> 	rpc_control(RPC_SVC_CONNMAXREC_SET, &maxrec);
> 
> -	init_transport(nconf);
> +	if (init_transport(nconf)) {
> +		syslog(LOG_ERR, "%s: can't init local transport\n", argv[0]);
> +		exit(1);
> +	}
> 
> 	while ((nconf = getnetconfig(nc_handle))) {
> 		if (nconf->nc_flag & NC_VISIBLE)
> -			init_transport(nconf);
> +			if (init_transport(nconf)) {
> +				syslog(LOG_ERR, "%s: can't init %s transport\n", argv[0], nconf->nc_netid);
> +				exit(1);
> +			}
> 	}
> 	endnetconfig(nc_handle);
> 
> @@ -276,7 +282,6 @@ init_transport(struct netconfig *nconf)
> 	int aicode;
> 	int addrlen = 0;
> 	int nhostsbak;
> -	int checkbind;
> 	int on = 1;
> 	struct sockaddr *sa = NULL;
> 	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
> @@ -358,7 +363,6 @@ init_transport(struct netconfig *nconf)
> 	       /*
> 		* Bind to specific IPs if asked to
> 		*/
> -		checkbind = 0;
> 		while (nhostsbak > 0) {
> 			--nhostsbak;
> 			/*
> @@ -425,9 +429,8 @@ init_transport(struct netconfig *nconf)
> 					hosts[nhostsbak], nconf->nc_netid);
> 				if (res != NULL)
> 					freeaddrinfo(res);
> -				continue;
> -			} else
> -				checkbind++;
> +				return 1;
> +			}
> 			(void) umask(oldmask);
> 
> 			/* Copy the address */
> @@ -476,8 +479,6 @@ init_transport(struct netconfig *nconf)
> 				goto error;
> 			}
> 		}
> -		if (!checkbind)
> -			return 1;
> 	} else {	/* NC_TPI_COTS */
> 		if ((strcmp(nconf->nc_netid, "local") != 0) &&
> 		    (strcmp(nconf->nc_netid, "unix") != 0)) {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
chuck[dot]lever[at]oracle[dot]com





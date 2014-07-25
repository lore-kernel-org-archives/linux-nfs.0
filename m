Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1609 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760415AbaGYPAw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jul 2014 11:00:52 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s6PF0gRk009263
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 11:00:47 -0400
Message-ID: <53D27115.4030909@RedHat.com>
Date: Fri, 25 Jul 2014 11:00:37 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Rinku Kothiya <rkothiya@redhat.com>, linux-nfs@vger.kernel.org
CC: Christian Horn <chorn@redhat.com>
Subject: Re: [PATCH] gssd: configurable connection timeout for the rpcgssd
 service
References: <1405430799-22006-1-git-send-email-rkothiya@redhat.com>
In-Reply-To: <1405430799-22006-1-git-send-email-rkothiya@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 15/07/14 09:26, Rinku Kothiya wrote:
> When using rpc.gssd to secure NFSv3 FS using krb5,  the following errors
> can happen as a result of network congestion.
> 
> "rpc.gssd WARNING: can't create tcp rpc_clnt to server ... : RPC: Remote
> system error - Connection timed out"
> 
> we had a successful reproducer of the problem which we tested using this
> patch by starting rpc.gssd with "-T 60" as the option which solved the
> problem. reproducer steps were to throttle the network using tc command
> and then in a never ending loop mount the share, then write some data in
> the file on the share and unmount it. keep a delay of 5 sec between the
> iteration of each loop.
> 
> CC: Christian Horn <chorn@redhat.com>
> Signed-off-by:
Committed...

steved.
> ---
>  utils/gssd/gssd.c      | 6 +++++-
>  utils/gssd/gssd.h      | 1 +
>  utils/gssd/gssd.man    | 8 ++++++++
>  utils/gssd/gssd_proc.c | 6 +++++-
>  4 files changed, 19 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
> index 611ef1a..6b8b863 100644
> --- a/utils/gssd/gssd.c
> +++ b/utils/gssd/gssd.c
> @@ -64,6 +64,7 @@ char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
>  int  use_memcache = 0;
>  int  root_uses_machine_creds = 1;
>  unsigned int  context_timeout = 0;
> +unsigned int  rpc_timeout = 5;
>  char *preferred_realm = NULL;
>  int pipefds[2] = { -1, -1 };
>  
> @@ -105,7 +106,7 @@ main(int argc, char *argv[])
>  	char *progname;
>  
>  	memset(ccachesearch, 0, sizeof(ccachesearch));
> -	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:R:")) != -1) {
> +	while ((opt = getopt(argc, argv, "DfvrlmnMp:k:d:t:T:R:")) != -1) {
>  		switch (opt) {
>  			case 'f':
>  				fg = 1;
> @@ -143,6 +144,9 @@ main(int argc, char *argv[])
>  			case 't':
>  				context_timeout = atoi(optarg);
>  				break;
> +			case 'T':
> +				rpc_timeout = atoi(optarg);
> +				break;
>  			case 'R':
>  				preferred_realm = strdup(optarg);
>  				break;
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 56a18d6..48f4ad8 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -66,6 +66,7 @@ extern char			*ccachesearch[];
>  extern int			use_memcache;
>  extern int			root_uses_machine_creds;
>  extern unsigned int 		context_timeout;
> +extern unsigned int rpc_timeout;
>  extern char			*preferred_realm;
>  extern int			pipefds[2];
>  
> diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
> index ac13fd4..ea58fa0 100644
> --- a/utils/gssd/gssd.man
> +++ b/utils/gssd/gssd.man
> @@ -289,6 +289,14 @@ new kernel contexts to be negotiated after
>  seconds, which allows changing Kerberos tickets and identities frequently.
>  The default is no explicit timeout, which means the kernel context will live
>  the lifetime of the Kerberos service ticket used in its creation.
> +.TP
> +.B -T timeout
> +Timeout, in seconds, to create an RPC connection with a server while
> +establishing an authenticated gss context for a user.
> +The default timeout is set to 5 seconds.
> +If you get messages like "WARNING: can't create tcp rpc_clnt to server
> +%servername% for user with uid %uid%: RPC: Remote system error -
> +Connection timed out", you should consider an increase of this timeout.
>  .SH SEE ALSO
>  .BR rpc.svcgssd (8),
>  .BR kerberos (1),
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 40ff188..1398cd6 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -850,7 +850,7 @@ create_auth_rpc_client(struct clnt_info *clp,
>  	OM_uint32		min_stat;
>  	char			rpc_errmsg[1024];
>  	int			protocol;
> -	struct timeval		timeout = {5, 0};
> +	struct timeval	timeout;
>  	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
>  	socklen_t		salen;
>  
> @@ -918,6 +918,10 @@ create_auth_rpc_client(struct clnt_info *clp,
>  	if (!populate_port(addr, salen, clp->prog, clp->vers, protocol))
>  		goto out_fail;
>  
> +	/* set the timeout according to the requested valued */
> +	timeout.tv_sec = (long) rpc_timeout;
> +	timeout.tv_usec = (long) 0;
> +
>  	rpc_clnt = nfs_get_rpcclient(addr, salen, protocol, clp->prog,
>  				     clp->vers, &timeout);
>  	if (!rpc_clnt) {
> 

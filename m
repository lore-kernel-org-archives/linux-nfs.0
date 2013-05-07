Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752908Ab3EGQYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 May 2013 12:24:00 -0400
Message-ID: <5189250C.3010903@RedHat.com>
Date: Tue, 07 May 2013 12:00:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@netapp.com>
CC: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] statd: exit if a statd is already running
References: <1367017819-11006-1-git-send-email-dros@netapp.com>
In-Reply-To: <1367017819-11006-1-git-send-email-dros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 26/04/13 19:10, Weston Andros Adamson wrote:
> Moves nfs_probe_statd from mount to nfs support lib to share with statd.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> 
> This patch stops users from running multiple instances of statd, which can
> obviously cause a lot of problems.
> 
>  support/include/nfsrpc.h |  5 +++++
>  support/nfs/getport.c    | 22 ++++++++++++++++++++++
>  utils/mount/network.c    | 17 -----------------
>  utils/statd/statd.c      |  6 ++++++
>  4 files changed, 33 insertions(+), 17 deletions(-)
Committed... 

steved.
> 
> diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
> index a0b80e1..1bfae7a 100644
> --- a/support/include/nfsrpc.h
> +++ b/support/include/nfsrpc.h
> @@ -156,6 +156,11 @@ extern unsigned long	nfs_pmap_getport(const struct sockaddr_in *,
>  				const struct timeval *);
>  
>  /*
> + * Use nfs_pmap_getport to see if statd is running locally
> + */
> +extern int nfs_probe_statd(void);
> +
> +/*
>   * Contact a remote RPC service to discover whether it is responding
>   * to requests.
>   */
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 3331ad4..081594c 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -1102,3 +1102,25 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
>  
>  	return port;
>  }
> +
> +static const char *nfs_ns_pgmtbl[] = {
> +        "status",
> +        NULL,
> +};
> +
> +/*
> + * nfs_probe_statd - use nfs_pmap_getport to see if statd is running locally
> + *
> + * Returns non-zero if statd is running locally.
> + */
> +int nfs_probe_statd(void)
> +{
> +        struct sockaddr_in addr = {
> +                .sin_family             = AF_INET,
> +                .sin_addr.s_addr        = htonl(INADDR_LOOPBACK),
> +        };
> +        rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
> +
> +        return nfs_getport_ping((struct sockaddr *)(char *)&addr, sizeof(addr),
> +                                program, (rpcvers_t)1, IPPROTO_UDP);
> +}
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 4be48cd..e2cdcaf 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -65,11 +65,6 @@ extern int nfs_mount_data_version;
>  extern char *progname;
>  extern int verbose;
>  
> -static const char *nfs_ns_pgmtbl[] = {
> -	"status",
> -	NULL,
> -};
> -
>  static const char *nfs_mnt_pgmtbl[] = {
>  	"mount",
>  	"mountd",
> @@ -761,18 +756,6 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
>  					&nfs_server->pmap);
>  }
>  
> -static int nfs_probe_statd(void)
> -{
> -	struct sockaddr_in addr = {
> -		.sin_family		= AF_INET,
> -		.sin_addr.s_addr	= htonl(INADDR_LOOPBACK),
> -	};
> -	rpcprog_t program = nfs_getrpcbyname(NSMPROG, nfs_ns_pgmtbl);
> -
> -	return nfs_getport_ping(SAFE_SOCKADDR(&addr), sizeof(addr),
> -				program, (rpcvers_t)1, IPPROTO_UDP);
> -}
> -
>  /**
>   * start_statd - attempt to start rpc.statd
>   *
> diff --git a/utils/statd/statd.c b/utils/statd/statd.c
> index 652546c..ed9c1db 100644
> --- a/utils/statd/statd.c
> +++ b/utils/statd/statd.c
> @@ -237,6 +237,12 @@ int main (int argc, char **argv)
>  	/* Set hostname */
>  	MY_NAME = NULL;
>  
> +	/* Refuse to start if another statd is running */
> +	if (nfs_probe_statd()) {
> +		fprintf(stderr, "Statd service already running!\n");
> +		exit(1);
> +	}
> +
>  	/* Process command line switches */
>  	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:L", longopts, NULL)) != EOF) {
>  		switch (arg) {
> 

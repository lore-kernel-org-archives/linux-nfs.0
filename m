Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:46666 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753409Ab3D0AUb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Apr 2013 20:20:31 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] statd: exit if a statd is already running
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1367017819-11006-1-git-send-email-dros@netapp.com>
Date: Fri, 26 Apr 2013 20:20:16 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@netapp.com>
Message-Id: <ECB66D2E-4451-419F-8E67-F327AFA257C5@oracle.com>
References: <1367017819-11006-1-git-send-email-dros@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 26, 2013, at 7:10 PM, Weston Andros Adamson <dros@netapp.com> wrote:

> Moves nfs_probe_statd from mount to nfs support lib to share with statd.
> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>

Acked-by: Chuck Lever <chuck.lever@oracle.com>

> ---
> 
> This patch stops users from running multiple instances of statd, which can
> obviously cause a lot of problems.
> 
> support/include/nfsrpc.h |  5 +++++
> support/nfs/getport.c    | 22 ++++++++++++++++++++++
> utils/mount/network.c    | 17 -----------------
> utils/statd/statd.c      |  6 ++++++
> 4 files changed, 33 insertions(+), 17 deletions(-)
> 
> diff --git a/support/include/nfsrpc.h b/support/include/nfsrpc.h
> index a0b80e1..1bfae7a 100644
> --- a/support/include/nfsrpc.h
> +++ b/support/include/nfsrpc.h
> @@ -156,6 +156,11 @@ extern unsigned long	nfs_pmap_getport(const struct sockaddr_in *,
> 				const struct timeval *);
> 
> /*
> + * Use nfs_pmap_getport to see if statd is running locally
> + */
> +extern int nfs_probe_statd(void);
> +
> +/*
>  * Contact a remote RPC service to discover whether it is responding
>  * to requests.
>  */
> diff --git a/support/nfs/getport.c b/support/nfs/getport.c
> index 3331ad4..081594c 100644
> --- a/support/nfs/getport.c
> +++ b/support/nfs/getport.c
> @@ -1102,3 +1102,25 @@ unsigned long nfs_pmap_getport(const struct sockaddr_in *sin,
> 
> 	return port;
> }
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
> extern char *progname;
> extern int verbose;
> 
> -static const char *nfs_ns_pgmtbl[] = {
> -	"status",
> -	NULL,
> -};
> -
> static const char *nfs_mnt_pgmtbl[] = {
> 	"mount",
> 	"mountd",
> @@ -761,18 +756,6 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
> 					&nfs_server->pmap);
> }
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
> /**
>  * start_statd - attempt to start rpc.statd
>  *
> diff --git a/utils/statd/statd.c b/utils/statd/statd.c
> index 652546c..ed9c1db 100644
> --- a/utils/statd/statd.c
> +++ b/utils/statd/statd.c
> @@ -237,6 +237,12 @@ int main (int argc, char **argv)
> 	/* Set hostname */
> 	MY_NAME = NULL;
> 
> +	/* Refuse to start if another statd is running */
> +	if (nfs_probe_statd()) {
> +		fprintf(stderr, "Statd service already running!\n");
> +		exit(1);
> +	}
> +
> 	/* Process command line switches */
> 	while ((arg = getopt_long(argc, argv, "h?vVFNH:dn:p:o:P:L", longopts, NULL)) != EOF) {
> 		switch (arg) {
> -- 
> 1.7.12.4 (Apple Git-37)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





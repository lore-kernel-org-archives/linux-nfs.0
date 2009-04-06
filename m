From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 4/5] nfs-utils: switch gssd to use standard function for
	getting an RPC client
Date: Mon, 6 Apr 2009 11:35:35 -0400
Message-ID: <34D0EC93-420A-4CD7-B5BC-163F92E8EFE8@oracle.com>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
	<1238938983-7347-5-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1238938983-7347-5-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 5, 2009, at 9:43 AM, Jeff Layton wrote:
> We already have a common function for setting up an RPC client. Switch
> gssd to use it.

Maybe this is a nit, but I would like a stronger justification... like  
"switch to a function that can support IPv6".

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/gssd/gssd_proc.c |   53 ++++++++++++++++++++ 
> +--------------------------
> 1 files changed, 24 insertions(+), 29 deletions(-)
>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index bebefe7..1f7dadd 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -72,6 +72,7 @@
> #include "gss_util.h"
> #include "krb5_util.h"
> #include "context.h"
> +#include "nfsrpc.h"
>
> /*
>  * pollarray:
> @@ -624,10 +625,10 @@ int create_auth_rpc_client(struct clnt_info  
> *clp,
> 	int			retval = -1;
> 	OM_uint32		min_stat;
> 	char			rpc_errmsg[1024];
> -	int			sockp = RPC_ANYSOCK;
> -	int			sendsz = 32768, recvsz = 32768;
> 	int			protocol;
> +	struct timeval		timeout = {5, 0};
> 	struct sockaddr		*addr = (struct sockaddr *) &clp->addr;
> +	socklen_t		salen;
>
> 	/* Create the context as the user (not as root) */
> 	save_uid = geteuid();
> @@ -695,33 +696,27 @@ int create_auth_rpc_client(struct clnt_info  
> *clp,
> 	if (!populate_port(addr, clp->servicename, protocol))
> 		goto out_fail;
>
> -	if (protocol == IPPROTO_TCP) {
> -		if ((rpc_clnt = clnttcp_create(
> -					(struct sockaddr_in *) &clp->addr,
> -					clp->prog, clp->vers, &sockp,
> -					sendsz, recvsz)) == NULL) {
> -			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
> -				 "WARNING: can't create tcp rpc_clnt "
> -				 "for server %s for user with uid %d",
> -				 clp->servername, uid);
> -			printerr(0, "%s\n",
> -				 clnt_spcreateerror(rpc_errmsg));
> -			goto out_fail;
> -		}
> -	} else if (protocol == IPPROTO_UDP) {
> -		const struct timeval timeout = {5, 0};
> -		if ((rpc_clnt = clntudp_bufcreate(
> -					(struct sockaddr_in *) &clp->addr,
> -					clp->prog, clp->vers, timeout,
> -					&sockp, sendsz, recvsz)) == NULL) {
> -			snprintf(rpc_errmsg, sizeof(rpc_errmsg),
> -				 "WARNING: can't create udp rpc_clnt "
> -				 "for server %s for user with uid %d",
> -				 clp->servername, uid);
> -			printerr(0, "%s\n",
> -				 clnt_spcreateerror(rpc_errmsg));
> -			goto out_fail;
> -		}
> +	switch (addr->sa_family) {
> +	case AF_INET:
> +		salen = sizeof(struct sockaddr_in);
> +		break;
> +	default:
> +		printerr(1, "ERROR: Unknown address family %d\n",
> +			 addr->sa_family);
> +		goto out_fail;
> +	}
> +
> +	rpc_clnt = nfs_get_rpcclient(addr, salen, protocol, clp->prog,
> +				     clp->vers, &timeout);
> +	if (!rpc_clnt) {
> +		snprintf(rpc_errmsg, sizeof(rpc_errmsg),
> +			 "WARNING: can't create %s rpc_clnt to server %s for "
> +			 "user with uid %d",
> +			 protocol == IPPROTO_TCP ? "tcp" : "udp",
> +			 clp->servername, uid);
> +		printerr(0, "%s\n",
> +			 clnt_spcreateerror(rpc_errmsg));
> +		goto out_fail;
> 	}
>
> 	printerr(2, "creating context with server %s\n", clp->servicename);

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

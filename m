Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38371 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169Ab1HCRwt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 13:52:49 -0400
Message-ID: <4E398AEA.9080700@RedHat.com>
Date: Wed, 03 Aug 2011 13:52:42 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
CC: NFS <linux-nfs@vger.kernel.org>, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2] rpc.mountd: let mountd consult /etc/services for port
References: <4DAD48C7.9090808@cn.fujitsu.com> <4DE0C380.7040608@cn.fujitsu.com>
In-Reply-To: <4DE0C380.7040608@cn.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Mi, 

My apologizes for taking so long on this... It did fall off my radar...
but after some unit testing, it appears things 
work as expected.... 

Committed!

steved.

On 05/28/2011 05:42 AM, Mi Jinlong wrote:
> At RHEL, if user set port for mountd at /etc/services as 
> "mount   12345/tcp", mountd should be bind to 12345, but the 
> latest nfs-utils, mountd get a rand port, not 12345.
> 
> This patch make sure mountd be bind to the port which was set
> at /etc/service.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  support/include/rpcmisc.h |    1 +
>  support/nfs/svc_create.c  |    9 ++++-
>  support/nfs/svc_socket.c  |   80 +++++++++++++++++++++------------------------
>  utils/mountd/mountd.man   |    5 ++-
>  utils/statd/statd.man     |    5 ++-
>  5 files changed, 53 insertions(+), 47 deletions(-)
> 
> diff --git a/support/include/rpcmisc.h b/support/include/rpcmisc.h
> index 0b06457..b806227 100644
> --- a/support/include/rpcmisc.h
> +++ b/support/include/rpcmisc.h
> @@ -53,6 +53,7 @@ void		rpc_init(char *name, int prog, int vers,
>  void		rpc_dispatch(struct svc_req *rq, SVCXPRT *xprt,
>  				struct rpc_dtable *dtable, int nvers,
>  				void *argp, void *resp);
> +int		getservport(u_long number, const char *proto);
>  
>  extern int	_rpcpmstart;
>  extern int	_rpcfdtype;
> diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
> index b3f75ed..c159fc8 100644
> --- a/support/nfs/svc_create.c
> +++ b/support/nfs/svc_create.c
> @@ -393,7 +393,7 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
>  	const struct sigaction create_sigaction = {
>  		.sa_handler	= SIG_IGN,
>  	};
> -	unsigned int visible, up;
> +	unsigned int visible, up, servport;
>  	struct netconfig *nconf;
>  	void *handlep;
>  
> @@ -417,8 +417,13 @@ nfs_svc_create(char *name, const rpcprog_t program, const rpcvers_t version,
>  		if (!(nconf->nc_flag & NC_VISIBLE))
>  			continue;
>  		visible++;
> +		if (port == 0)
> +			servport = getservport(program, nconf->nc_proto);
> +		else
> +			servport = port;
> +
>  		up += svc_create_nconf(name, program, version, dispatch,
> -						port, nconf);
> +						servport, nconf);
>  	}
>  
>  	if (visible == 0)
> diff --git a/support/nfs/svc_socket.c b/support/nfs/svc_socket.c
> index 03a5325..c252f53 100644
> --- a/support/nfs/svc_socket.c
> +++ b/support/nfs/svc_socket.c
> @@ -35,14 +35,43 @@
>  # define __close(f)		close ((f))
>  #endif
>  
> +int getservport(u_long number, const char *proto)
> +{
> +	char rpcdata[1024], servdata[1024];
> +	struct rpcent rpcbuf, *rpcp;
> +	struct servent servbuf, *servp = NULL;
> +	int ret;
> +
> +	ret = getrpcbynumber_r(number, &rpcbuf, rpcdata, sizeof rpcdata,
> +				&rpcp);
> +	if (ret == 0 && rpcp != NULL) {
> +		/* First try name.  */
> +		ret = getservbyname_r(rpcp->r_name, proto, &servbuf, servdata,
> +					sizeof servdata, &servp);
> +		if ((ret != 0 || servp == NULL) && rpcp->r_aliases) {
> +			const char **a;
> +
> +			/* Then we try aliases.  */
> +			for (a = (const char **) rpcp->r_aliases; *a != NULL; a++) {
> +				ret = getservbyname_r(*a, proto, &servbuf, servdata,
> +							sizeof servdata, &servp);
> +				if (ret == 0 && servp != NULL)
> +					break;
> +			}
> +		}
> +	}
> +
> +	if (ret == 0 && servp != NULL)
> +		return ntohs(servp->s_port);
> +
> +	return 0;
> +}
> +
>  static int
>  svc_socket (u_long number, int type, int protocol, int reuse)
>  {
>    struct sockaddr_in addr;
>    socklen_t len = sizeof (struct sockaddr_in);
> -  char rpcdata [1024], servdata [1024];
> -  struct rpcent rpcbuf, *rpcp;
> -  struct servent servbuf, *servp = NULL;
>    int sock, ret;
>    const char *proto = protocol == IPPROTO_TCP ? "tcp" : "udp";
>  
> @@ -66,48 +95,13 @@ svc_socket (u_long number, int type, int protocol, int reuse)
>  
>    memset (&addr, 0, sizeof (addr));
>    addr.sin_family = AF_INET;
> +  addr.sin_port = htons(getservport(number, proto));
>  
> -  ret = getrpcbynumber_r (number, &rpcbuf, rpcdata, sizeof rpcdata,
> -			  &rpcp);
> -  if (ret == 0 && rpcp != NULL)
> -    {
> -      /* First try name.  */
> -      ret = getservbyname_r (rpcp->r_name, proto, &servbuf, servdata,
> -			     sizeof servdata, &servp);
> -      if ((ret != 0 || servp == NULL) && rpcp->r_aliases)
> -	{
> -	  const char **a;
> -
> -	  /* Then we try aliases.  */
> -	  for (a = (const char **) rpcp->r_aliases; *a != NULL; a++) 
> -	    {
> -	      ret = getservbyname_r (*a, proto, &servbuf, servdata,
> -				     sizeof servdata, &servp);
> -	      if (ret == 0 && servp != NULL)
> -		break;
> -	    }
> -	}
> -    }
> -
> -  if (ret == 0 && servp != NULL)
> +  if (bind(sock, (struct sockaddr *) &addr, len) < 0)
>      {
> -      addr.sin_port = servp->s_port;
> -      if (bind (sock, (struct sockaddr *) &addr, len) < 0)
> -	{
> -	  perror (_("svc_socket: bind problem"));
> -	  (void) __close (sock);
> -	  sock = -1;
> -	}
> -    }
> -  else
> -    {
> -	  addr.sin_port = 0;
> -	  if (bind (sock, (struct sockaddr *) &addr, len) < 0)
> -	    {
> -	      perror (_("svc_socket: bind problem"));
> -	      (void) __close (sock);
> -	      sock = -1;
> -	    }
> +      perror (_("svc_socket: bind problem"));
> +      (void) __close(sock);
> +      sock = -1;
>      }
>  
>    if (sock >= 0)
> diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
> index 016a357..b322437 100644
> --- a/utils/mountd/mountd.man
> +++ b/utils/mountd/mountd.man
> @@ -122,7 +122,10 @@ Ignored (compatibility with unfsd??).
>  Specifies the port number used for RPC listener sockets.
>  If this option is not specified,
>  .B rpc.mountd
> -chooses a random ephemeral port for each listener socket.
> +will try to consult
> +.IR /etc/services ,
> +if gets port succeed, set the same port for all listener socket,
> +otherwise chooses a random ephemeral port for each listener socket.
>  .IP
>  This option can be used to fix the port value of
>  .BR rpc.mountd 's
> diff --git a/utils/statd/statd.man b/utils/statd/statd.man
> index b72236c..203f8c9 100644
> --- a/utils/statd/statd.man
> +++ b/utils/statd/statd.man
> @@ -219,7 +219,10 @@ for details.
>  Specifies the port number used for RPC listener sockets.
>  If this option is not specified,
>  .B rpc.statd
> -chooses a random ephemeral port for each listener socket.
> +will try to consult
> +.IR /etc/services ,
> +if gets port succeed, set the same port for all listener socket,
> +otherwise chooses a random ephemeral port for each listener socket.
>  .IP
>  This option can be used to fix the port value of its listeners when
>  SM_NOTIFY requests must traverse a firewall between clients and servers.

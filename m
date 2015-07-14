Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811AbbGNSHN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 14:07:13 -0400
Message-ID: <55A54FD0.7020004@RedHat.com>
Date: Tue, 14 Jul 2015 14:07:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] rpc.nfsd: Squelch DNS errors when using the --host
 option
References: <20150610144349.19869.87412.stgit@manet.1015granger.net>
In-Reply-To: <20150610144349.19869.87412.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/10/2015 10:46 AM, Chuck Lever wrote:
> Sean Elble <elbles@sessys.com> says:
>> [rpc.nfsd --host] throws an error/warning (where nfs-server is
>> defined in /etc/hosts for the IPv4 address of the interface I wish
>> for TCP port 2049 to be opened on):
>>
>>  rpc.nfsd: unable to resolve nfs-server:nfs to inet6 address: Name
>>  or service not known
> 
> I think we can simplify the use of getaddrinfo(3) so that only one
> call is needed to gather both IPv4 and IPv6 addresses. The call
> should fail, and an error should be reported, only when there are
> _no_ addresses bound to a hostname.
> 
> Reported-by: Sean Elble <elbles@sessys.com>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
> 
> 
> Here is version 3. This version addresses both Jeff's and Kinglong's
> review comments. It has passed basic testing.
> 
> 
>  utils/nfsd/nfsd.c   |   70 ++-------------------------------------------------
>  utils/nfsd/nfssvc.c |   47 ++++++++++++++++++----------------
>  utils/nfsd/nfssvc.h |    2 +
>  3 files changed, 29 insertions(+), 90 deletions(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 201bb13..2165744 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -52,50 +52,6 @@ static struct option longopts[] =
>  	{ NULL, 0, 0, 0 }
>  };
>  
> -/* given a family and ctlbits, disable any that aren't listed in netconfig */
> -#ifdef HAVE_LIBTIRPC
> -static void
> -nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
> -{
> -	struct netconfig *nconf;
> -	unsigned int *famproto;
> -	void *handle;
> -
> -	xlog(D_GENERAL, "Checking netconfig for visible protocols.");
> -
> -	handle = setnetconfig();
> -	while((nconf = getnetconfig(handle))) {
> -		if (!(nconf->nc_flag & NC_VISIBLE))
> -			continue;
> -
> -		if (!strcmp(nconf->nc_protofmly, NC_INET))
> -			famproto = proto4;
> -		else if (!strcmp(nconf->nc_protofmly, NC_INET6))
> -			famproto = proto6;
> -		else
> -			continue;
> -
> -		if (!strcmp(nconf->nc_proto, NC_TCP))
> -			NFSCTL_TCPSET(*famproto);
> -		else if (!strcmp(nconf->nc_proto, NC_UDP))
> -			NFSCTL_UDPSET(*famproto);
> -
> -		xlog(D_GENERAL, "Enabling %s %s.", nconf->nc_protofmly,
> -			nconf->nc_proto);
> -	}
> -	endnetconfig(handle);
> -	return;
> -}
> -#else /* HAVE_LIBTIRPC */
> -static void
> -nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
> -{
> -	/* Enable all IPv4 protocols if no TIRPC support */
> -	*proto4 = NFSCTL_ALLBITS;
> -	*proto6 = 0;
> -}
> -#endif /* HAVE_LIBTIRPC */
> -
>  int
>  main(int argc, char **argv)
>  {
> @@ -108,8 +64,6 @@ main(int argc, char **argv)
>  	unsigned int minorversset = 0;
>  	unsigned int versbits = NFSCTL_VERDEFAULT;
>  	unsigned int protobits = NFSCTL_ALLBITS;
> -	unsigned int proto4 = 0;
> -	unsigned int proto6 = 0;
>  	int grace = -1;
>  	int lease = -1;
>  
> @@ -278,18 +232,6 @@ main(int argc, char **argv)
>  
>  	xlog_open(progname);
>  
> -	nfsd_enable_protos(&proto4, &proto6);
> -
> -	if (!NFSCTL_TCPISSET(protobits)) {
> -		NFSCTL_TCPUNSET(proto4);
> -		NFSCTL_TCPUNSET(proto6);
> -	}
> -
> -	if (!NFSCTL_UDPISSET(protobits)) {
> -		NFSCTL_UDPUNSET(proto4);
> -		NFSCTL_UDPUNSET(proto6);
> -	}
> -
>  	/* make sure that at least one version is enabled */
>  	found_one = 0;
>  	for (c = NFSD_MINVERS; c <= NFSD_MAXVERS; c++) {
> @@ -302,8 +244,7 @@ main(int argc, char **argv)
>  	}
>  
>  	if (NFSCTL_VERISSET(versbits, 4) &&
> -	    !NFSCTL_TCPISSET(proto4) &&
> -	    !NFSCTL_TCPISSET(proto6)) {
> +	    !NFSCTL_TCPISSET(protobits)) {
>  		xlog(L_ERROR, "version 4 requires the TCP protocol");
>  		exit(1);
>  	}
> @@ -337,15 +278,10 @@ main(int argc, char **argv)
>  
>  	i = 0;
>  	do {
> -		error = nfssvc_set_sockets(AF_INET, proto4, haddr[i], port);
> -		if (!error)
> -			socket_up = 1;
> -#ifdef IPV6_SUPPORTED
> -		error = nfssvc_set_sockets(AF_INET6, proto6, haddr[i], port);
> +		error = nfssvc_set_sockets(protobits, haddr[i], port);
>  		if (!error)
>  			socket_up = 1;
> -#endif /* IPV6_SUPPORTED */
> -	} while (++i < hcounter); 
> +	} while (++i < hcounter);
>  
>  	if (rdma_port) {
>  		error = nfssvc_set_rdmaport(rdma_port);
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 027e5ac..a2b11d8 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -24,6 +24,7 @@
>  
>  #include "nfslib.h"
>  #include "xlog.h"
> +#include "nfssvc.h"
>  
>  #ifndef NFSD_FS_DIR
>  #define NFSD_FS_DIR	  "/proc/fs/nfsd"
> @@ -124,22 +125,6 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  	if (fd < 0)
>  		return 0;
>  
> -	switch(hints->ai_family) {
> -	case AF_INET:
> -		family = "inet";
> -		break;
> -#ifdef IPV6_SUPPORTED
> -	case AF_INET6:
> -		family = "inet6";
> -		break;
> -#endif /* IPV6_SUPPORTED */
> -	default:
> -		xlog(L_ERROR, "Unknown address family specified: %d\n",
> -				hints->ai_family);
> -		rc = EAFNOSUPPORT;
> -		goto error;
> -	}
> -
>  	rc = getaddrinfo(node, port, hints, &addrhead);
>  	if (rc == EAI_NONAME && !strcmp(port, "nfs")) {
>  		snprintf(buf, sizeof(buf), "%d", NFS_PORT);
> @@ -147,10 +132,10 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  	}
>  
>  	if (rc != 0) {
> -		xlog(L_ERROR, "unable to resolve %s:%s to %s address: "
> -				"%s", node ? node : "ANYADDR", port, family,
> -				rc == EAI_SYSTEM ? strerror(errno) :
> -					gai_strerror(rc));
> +		xlog(L_ERROR, "unable to resolve %s:%s: %s",
> +			node ? node : "ANYADDR", port,
> +			rc == EAI_SYSTEM ? strerror(errno) :
> +				gai_strerror(rc));
>  		goto error;
>  	}
>  
> @@ -169,6 +154,20 @@ nfssvc_setfds(const struct addrinfo *hints, const char *node, const char *port)
>  			continue;
>  		}
>  
> +		switch(addr->ai_addr->sa_family) {
> +		case AF_INET:
> +			family = "AF_INET";
> +			break;
> +#ifdef IPV6_SUPPORTED
> +		case AF_INET6:
> +			family = "AF_INET6";
> +			break;
> +#endif /* IPV6_SUPPORTED */
> +		default:
> +			addr = addr->ai_next;
> +			continue;
> +		}
> +
>  		xlog(D_GENERAL, "Creating %s %s socket.", family, proto);
>  
>  		/* open socket and prepare to hand it off to kernel */
> @@ -252,12 +251,16 @@ error:
>  }
>  
>  int
> -nfssvc_set_sockets(const int family, const unsigned int protobits,
> +nfssvc_set_sockets(const unsigned int protobits,
>  		   const char *host, const char *port)
>  {
>  	struct addrinfo hints = { .ai_flags = AI_PASSIVE };
>  
> -	hints.ai_family = family;
> +#ifdef IPV6_SUPPORTED
> +	hints.ai_family = AF_UNSPEC;
> +#else  /* IPV6_SUPPORTED */
> +	hints.ai_family = AF_INET;
> +#endif /* IPV6_SUPPORTED */
>  
>  	if (!NFSCTL_ANYPROTO(protobits))
>  		return EPROTOTYPE;
> diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
> index fbb89b2..7d70f0d 100644
> --- a/utils/nfsd/nfssvc.h
> +++ b/utils/nfsd/nfssvc.h
> @@ -22,7 +22,7 @@
>  
>  void	nfssvc_mount_nfsdfs(char *progname);
>  int	nfssvc_inuse(void);
> -int	nfssvc_set_sockets(const int family, const unsigned int protobits,
> +int	nfssvc_set_sockets(const unsigned int protobits,
>  			   const char *host, const char *port);
>  void	nfssvc_set_time(const char *type, const int seconds);
>  int	nfssvc_set_rdmaport(const char *port);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

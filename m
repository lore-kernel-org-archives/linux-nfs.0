From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,PATCH] svc: Modify svc_xprt_create to take a sockaddr
Date: Mon, 21 Jan 2008 12:47:08 -0500
Message-ID: <9ECEB764-A93C-4DF2-BB6E-273C33C02B6E@oracle.com>
References: <20080121171105.29028.61809.stgit@dell3.ogc.int>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:16681 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbYAURtK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2008 12:49:10 -0500
In-Reply-To: <20080121171105.29028.61809.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Tom-

On Jan 21, 2008, at 12:11 PM, Tom Tucker wrote:
> Modify the svc_create_xprt function to take a sockaddr instead of just
> a port. This approach allows a single transport class,
> "tcp" for example, to support both IPv4 and IPv6 connections since
> this information is now provided in the sockaddr when the endpoint
> is created.  This also allows RPC servers to create listening  
> endpoints
> on a specific interface.

I assume this goes along with the server-side rpcb_register_v3  
patches I proposed last week?

> Also modify the svc_xprt_find function to search based on sockaddr so
> interface specific endpoints can be searched for.
>
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
>
>  fs/lockd/svc.c                  |   16 +++--
>  fs/nfs/callback.c               |    8 ++
>  fs/nfsd/nfsctl.c                |  135 ++++++++++++++++++++++++++++ 
> +----------
>  fs/nfsd/nfssvc.c                |   11 +++
>  include/linux/sunrpc/svc_xprt.h |    4 +
>  net/sunrpc/svc_xprt.c           |   96 ++++++++++++++++++++++------
>  6 files changed, 206 insertions(+), 64 deletions(-)
>
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 0822646..89e40fb 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -229,19 +229,27 @@ static int make_socks(struct svc_serv *serv,  
> int proto)
>  	static int warned;
>  	struct svc_xprt *xprt;
>  	int err = 0;
> +	struct sockaddr_in sin = {
> +		.sin_family = AF_INET,
> +		.sin_addr = { INADDR_ANY }
> +	};
>
>  	if (proto == IPPROTO_UDP || nlm_udpport) {
> -		xprt = svc_find_xprt(serv, "udp", 0, 0);
> +		sin.sin_port = htons(nlm_udpport);
> +		xprt = svc_find_xprt(serv, "udp", NULL);
>  		if (!xprt)
> -			err = svc_create_xprt(serv, "udp", nlm_udpport,
> +			err = svc_create_xprt(serv, "udp",
> +					      (struct sockaddr *)&sin,
>  					      SVC_SOCK_DEFAULTS);
>  		else
>  			svc_xprt_put(xprt);
>  	}
>  	if (err >= 0 && (proto == IPPROTO_TCP || nlm_tcpport)) {
> -		xprt = svc_find_xprt(serv, "tcp", 0, 0);
> +		sin.sin_port = htons(nlm_tcpport);
> +		xprt = svc_find_xprt(serv, "tcp", NULL);
>  		if (!xprt)
> -			err = svc_create_xprt(serv, "tcp", nlm_tcpport,
> +			err = svc_create_xprt(serv, "tcp",
> +					      (struct sockaddr *)&sin,
>  					      SVC_SOCK_DEFAULTS);
>  		else
>  			svc_xprt_put(xprt);

This is sort of a generic question.

The server-side interface appears to be using strings to identify  
transports ("tcp"), but the client-side is still using numbers  
(XPRT_TRANSPORT_TCP).  There are one or two sticky issues to fix  
before the client-side can use strings, but...

Should the server-side use netids instead of arbitrary strings?  I  
guess that would be a little awkward because you'd need to use "udp6"  
for UDP on IPv6, and so on.

In any event, should we use macros for these instead of open-coded  
strings?

> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
> index e27ca14..4517e31 100644
> --- a/fs/nfs/callback.c
> +++ b/fs/nfs/callback.c
> @@ -111,7 +111,11 @@ int nfs_callback_up(void)
>  {
>  	struct svc_serv *serv;
>  	int ret = 0;
> -
> +	struct sockaddr_in sin = {
> +		.sin_family = AF_INET,
> +		.sin_addr = { INADDR_ANY },
> +		.sin_port = htons(nfs_callback_set_tcpport)
> +	};
>  	lock_kernel();
>  	mutex_lock(&nfs_callback_mutex);
>  	if (nfs_callback_info.users++ || nfs_callback_info.pid != 0)
> @@ -123,7 +127,7 @@ int nfs_callback_up(void)
>  	if (!serv)
>  		goto out_err;
>
> -	ret = svc_create_xprt(serv, "tcp", nfs_callback_set_tcpport,
> +	ret = svc_create_xprt(serv, "tcp", (struct sockaddr *)&sin,
>  			      SVC_SOCK_ANONYMOUS);
>  	if (ret <= 0)
>  		goto out_destroy;
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index d22bc45..a02d96f 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -497,6 +497,74 @@ static ssize_t write_versions(struct file  
> *file, char *buf, size_t size)
>  	return len;
>  }
>
> +/*
> + * This function parses the string in buf to produce a transport
> + * string and a sockaddr. It supports NIPQUAD formatted IPv4 and IPv6
> + * addresses. The address string is qualified by an address family
> + * specified as an integer. Pseudo BNF for the syntax is as follows:
> + *
> + * <valid_cmd>	: <xprt_name> <addr> <port>
> + * <xprt_name>	: STRING;
> + * <addr>	: '2' <ip4_addr> | '10' <ip6_addr>
> + * <ip4_addr>	: "%u.%u.%u.%u"
> + * <ip6_addr>	: "%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x"

Seems like the parser should be able to distinguish an IPv4 address  
from an IPv6 address without the need for <addr>.  The NFS client  
checks if the address string contains a colon -- if yes, it's an IPv6  
address.  See fs/nfs/super.c:nfs_parse_server_address() .

> + * <port>	: INTEGER;
> + */
> +static int parse_xprt_sockaddr(char *buf, char *transport, struct  
> sockaddr *sa)
> +{
> +	unsigned int addr[8];
> +	unsigned short port;
> +	int af, rc, count, i;
> +	struct sockaddr_in *sin;
> +	struct sockaddr_in6 *sin6;
> +
> +	rc = sscanf(buf, "%15s %4d%n", transport, &af, &count);
> +	if (rc != 2)
> +		goto bad_fmt;
> +
> +	switch (af) {
> +	case AF_INET:
> +		rc = sscanf(&buf[count], NIPQUAD_FMT " %6hu",
> +			    &addr[0], &addr[1], &addr[2], &addr[3], &port);
> +		if (rc != 5)
> +			goto bad_fmt;
> +
> +		sin = (struct sockaddr_in *)sa;
> +		memset(sin, 0, sizeof(struct sockaddr_in));
> +		sin->sin_family = af;
> +		sin->sin_addr.s_addr = htonl(((unsigned char)addr[0] << 24) |
> +					     ((unsigned char)addr[1] << 16) |
> +					     ((unsigned char)addr[2] << 8) |
> +					     ((unsigned char)addr[3]));
> +		sin->sin_port = htons(port);
> +		break;
> +
> +	case AF_INET6:
> +		rc = sscanf(&buf[count], NIP6_FMT " %6hu",
> +			    &addr[0], &addr[1], &addr[2], &addr[3],
> +			    &addr[4], &addr[5], &addr[6], &addr[7],
> +			    &port);
> +		if (rc != 9)
> +			goto bad_fmt;
> +
> +		sin6 = (struct sockaddr_in6 *)sa;
> +		memset(sin6, 0, sizeof(struct sockaddr_in6));
> +		sin6->sin6_family = af;
> +		for (i = 0; i < 8; i++)
> +			sin6->sin6_addr.s6_addr16[i] =
> +				htons((unsigned short)addr[i]);
> +		sin6->sin6_port = htons(port);
> +		break;

You could replace those sscanf() calls with functions that convert  
strings to addresses in the kernel already: in4_pton() and in6_pton() .

At some point it might even make sense to create a helper that is  
shared being client and server.

> +
> +	default:
> +		goto bad_fmt;
> +	}
> +	return 0;
> +
> + bad_fmt:
> +	return -1;
> +}
> +
>  static ssize_t write_ports(struct file *file, char *buf, size_t size)
>  {
>  	if (size == 0) {
> @@ -555,52 +623,53 @@ static ssize_t write_ports(struct file *file,  
> char *buf, size_t size)
>  		return len;
>  	}
>  	/*
> -	 * Add a transport listener by writing it's transport name
> +	 * Add a transport listener by writing it's transport name and  
> address
>  	 */
>  	if (isalpha(buf[0])) {
>  		int err;
>  		char transport[16];
> -		int port;
> -		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
> -			err = nfsd_create_serv();
> -			if (!err) {
> -				err = svc_create_xprt(nfsd_serv,
> -						      transport, port,
> -						      SVC_SOCK_ANONYMOUS);
> -				if (err == -ENOENT)
> -					/* Give a reasonable perror msg for
> -					 * bad transport string */
> -					err = -EPROTONOSUPPORT;
> -			}
> -			return err < 0 ? err : 0;
> +		struct sockaddr_storage ss;
> +		if (parse_xprt_sockaddr(buf, transport, (struct sockaddr *)&ss))
> +			goto bad_fmt;
> +		err = nfsd_create_serv();
> +		if (!err) {
> +			err = svc_create_xprt(nfsd_serv,
> +					      transport,
> +					      (struct sockaddr *)&ss,
> +					      SVC_SOCK_ANONYMOUS);
> +			if (err == -ENOENT)
> +				/* Give a reasonable perror msg for
> +				 * bad transport string */
> +				err = -EPROTONOSUPPORT;
>  		}
> +		return err < 0 ? err : 0;
>  	}
>  	/*
> -	 * Remove a transport by writing it's transport name and port number
> +	 * Remove a transport by writing it's transport name and address
>  	 */
>  	if (buf[0] == '-' && isalpha(buf[1])) {
>  		struct svc_xprt *xprt;
> -		int err = -EINVAL;
>  		char transport[16];
> -		int port;
> -		if (sscanf(&buf[1], "%15s %4d", transport, &port) == 2) {
> -			if (port == 0)
> -				return -EINVAL;
> -			lock_kernel();
> -			if (nfsd_serv) {
> -				xprt = svc_find_xprt(nfsd_serv, transport,
> -						     AF_UNSPEC, port);
> -				if (xprt) {
> -					svc_close_xprt(xprt);
> -					svc_xprt_put(xprt);
> -					err = 0;
> -				} else
> -					err = -ENOTCONN;
> -			}
> -			unlock_kernel();
> -			return err < 0 ? err : 0;
> +		struct sockaddr_storage ss;
> +		int err = -EINVAL;
> +		if (parse_xprt_sockaddr(&buf[1], transport,
> +					(struct sockaddr *)&ss))
> +			goto bad_fmt;
> +		lock_kernel();
> +		if (nfsd_serv) {
> +			xprt = svc_find_xprt(nfsd_serv, transport,
> +					     (struct sockaddr *)&ss);
> +			if (xprt) {
> +				svc_close_xprt(xprt);
> +				svc_xprt_put(xprt);
> +				err = 0;
> +			} else
> +				err = -ENOTCONN;
>  		}
> +		unlock_kernel();
> +		return err < 0 ? err : 0;
>  	}
> + bad_fmt:
>  	return -EINVAL;
>  }
>
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 9647b0f..5b95f1b 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -231,12 +231,18 @@ int nfsd_create_serv(void)
>  static int nfsd_init_socks(int port)
>  {
>  	int error;
> +	struct sockaddr_in sin = {
> +		.sin_family = AF_INET,
> +		.sin_addr = { INADDR_ANY },
> +		.sin_port = htons(port)
> +	};
>  	if (!list_empty(&nfsd_serv->sv_permsocks))
>  		return 0;
>
>  	error = lockd_up(IPPROTO_UDP);
>  	if (error >= 0) {
> -		error = svc_create_xprt(nfsd_serv, "udp", port,
> +		error = svc_create_xprt(nfsd_serv, "udp",
> +					(struct sockaddr *)&sin,
>  					SVC_SOCK_DEFAULTS);
>  		if (error < 0)
>  			lockd_down();
> @@ -247,7 +253,8 @@ static int nfsd_init_socks(int port)
>  #ifdef CONFIG_NFSD_TCP
>  	error = lockd_up(IPPROTO_TCP);
>  	if (error >= 0) {
> -		error = svc_create_xprt(nfsd_serv, "tcp", port,
> +		error = svc_create_xprt(nfsd_serv, "tcp",
> +					(struct sockaddr *)&sin,
>  					SVC_SOCK_DEFAULTS);
>  		if (error < 0)
>  			lockd_down();
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/ 
> svc_xprt.h
> index 6fd7b01..36aaf8f 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -71,7 +71,7 @@ int	svc_reg_xprt_class(struct svc_xprt_class *);
>  void	svc_unreg_xprt_class(struct svc_xprt_class *);
>  void	svc_xprt_init(struct svc_xprt_class *, struct svc_xprt *,
>  		      struct svc_serv *);
> -int	svc_create_xprt(struct svc_serv *, char *, unsigned short, int);
> +int	svc_create_xprt(struct svc_serv *, char *, struct sockaddr *,  
> int);
>  void	svc_xprt_enqueue(struct svc_xprt *xprt);
>  void	svc_xprt_received(struct svc_xprt *);
>  void	svc_xprt_put(struct svc_xprt *xprt);
> @@ -80,7 +80,7 @@ void	svc_close_xprt(struct svc_xprt *xprt);
>  void	svc_delete_xprt(struct svc_xprt *xprt);
>  int	svc_port_is_privileged(struct sockaddr *sin);
>  int	svc_print_xprts(char *buf, int maxlen);
> -struct	svc_xprt *svc_find_xprt(struct svc_serv *, char *, int, int);
> +struct	svc_xprt *svc_find_xprt(struct svc_serv *, char *, struct  
> sockaddr *);
>  int	svc_xprt_names(struct svc_serv *serv, char *buf, int buflen);
>
>  static inline void svc_xprt_get(struct svc_xprt *xprt)
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index c3fb367..6258cbe 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -9,6 +9,7 @@
>  #include <linux/fcntl.h>
>  #include <linux/net.h>
>  #include <linux/in.h>
> +#include <linux/in6.h>
>  #include <linux/inet.h>
>  #include <linux/udp.h>
>  #include <linux/tcp.h>
> @@ -128,8 +129,8 @@ int svc_print_xprts(char *buf, int maxlen)
>  		struct svc_xprt_class *xcl =
>  			list_entry(le, struct svc_xprt_class, xcl_list);
>
> -		sprintf(tmpstr, "%s %d\n", xcl->xcl_name, xcl->xcl_max_payload);
> -		slen = strlen(tmpstr);
> +		slen = sprintf(tmpstr, "%s %d\n",
> +			       xcl->xcl_name, xcl->xcl_max_payload);
>  		if (len + slen > maxlen)
>  			break;
>  		len += slen;
> @@ -179,16 +180,11 @@ void svc_xprt_init(struct svc_xprt_class  
> *xcl, struct svc_xprt *xprt,
>  }
>  EXPORT_SYMBOL_GPL(svc_xprt_init);
>
> -int svc_create_xprt(struct svc_serv *serv, char *xprt_name,  
> unsigned short port,
> +int svc_create_xprt(struct svc_serv *serv, char *xprt_name, struct  
> sockaddr *sa,
>  		    int flags)
>  {
>  	struct svc_xprt_class *xcl;
> -	struct sockaddr_in sin = {
> -		.sin_family		= AF_INET,
> -		.sin_addr.s_addr	= INADDR_ANY,
> -		.sin_port		= htons(port),
> -	};
> -	dprintk("svc: creating transport %s[%d]\n", xprt_name, port);
> +	dprintk("svc: creating %s transport\n", xprt_name);
>  	spin_lock(&svc_xprt_class_lock);
>  	list_for_each_entry(xcl, &svc_xprt_class_list, xcl_list) {
>  		struct svc_xprt *newxprt;
> @@ -201,7 +197,8 @@ int svc_create_xprt(struct svc_serv *serv, char  
> *xprt_name, unsigned short port,
>
>  		spin_unlock(&svc_xprt_class_lock);
>  		newxprt = xcl->xcl_ops->
> -			xpo_create(serv, (struct sockaddr *)&sin, sizeof(sin),
> +			xpo_create(serv, (struct sockaddr *)sa,
> +				   svc_addr_len(sa),
>  				   flags);
>  		if (IS_ERR(newxprt)) {
>  			module_put(xcl->xcl_owner);
> @@ -979,17 +976,67 @@ static struct svc_deferred_req  
> *svc_deferred_dequeue(struct svc_xprt *xprt)
>  	return dr;
>  }
>
> +static int compare_sin(struct sockaddr_in *a, struct sockaddr_in *b)
> +{
> +	if (a->sin_addr.s_addr && (a->sin_addr.s_addr != b- 
> >sin_addr.s_addr))
> +		return -1;

More explicit:

   if (a->sin_addr.s_addr != INADDR_ANY && ...

Documents the intent, and the generated object code should be identical.

> +	if (a->sin_port && (a->sin_port != b->sin_port))
> +		return -1;
> +	return 0;
> +}
> +
> +static int compare_in6_addr(const struct in6_addr *a, const struct  
> in6_addr *b)
> +{
> +	int i;
> +	for (i = 0; i < 8; i++)
> +		if (a->s6_addr16[i] != b->s6_addr16[i])
> +			return -1;
> +	return 0;
> +}
> +

Yeah, we already have one of these in the kernel: ipv6_addr_equal()

> +static int compare_sin6(struct sockaddr_in6 *a, struct  
> sockaddr_in6 *b)
> +{
> +	static struct in6_addr _in6addr_any = IN6ADDR_ANY_INIT;
> +	if (compare_in6_addr(&a->sin6_addr, &_in6addr_any) &&
> +	    compare_in6_addr(&a->sin6_addr, &b->sin6_addr))
> +		return -1;

And we have ipv6_addr_any() as well.

> +	if (a->sin6_port && (a->sin6_port != b->sin6_port))
> +		return -1;
> +	return 0;
> +}
> +
> +static int compare_sa(struct sockaddr *a, struct sockaddr *b)
> +{
> +	if (a->sa_family != b->sa_family)
> +		return -1;
> +	switch (a->sa_family) {
> +	case AF_INET:
> +		return compare_sin((struct sockaddr_in *)a,
> +				   (struct sockaddr_in *)b);
> +	case AF_INET6:
> +		return compare_sin6((struct sockaddr_in6 *)a,
> +				    (struct sockaddr_in6 *)b);
> +	default:
> +		return -1;
> +	}
> +}
> +
>  /*
>   * Return the transport instance pointer for the endpoint accepting
>   * connections/peer traffic from the specified transport class,
>   * address family and port.
>   *
> - * Specifying 0 for the address family or port is effectively a
> + * Both serv and xcl_name must be specified.
> + *
> + * If the specified 'sa' is NULL, then the first transport matching
> + * the xcl_name is returned.
> + *
> + * Specifying AF_UNSPEC for the address family or port is  
> effectively a
>   * wild-card, and will result in matching the first transport in the
>   * service's list that has a matching class name.
>   */
>  struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
> -			       int af, int port)
> +			       struct sockaddr *sa)
>  {
>  	struct svc_xprt *xprt;
>  	struct svc_xprt *found = NULL;
> @@ -1002,10 +1049,13 @@ struct svc_xprt *svc_find_xprt(struct  
> svc_serv *serv, char *xcl_name,
>  	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
>  		if (strcmp(xprt->xpt_class->xcl_name, xcl_name))
>  			continue;
> -		if (af != AF_UNSPEC && af != xprt->xpt_local.ss_family)
> -			continue;
> -		if (port && port != svc_xprt_local_port(xprt))
> -			continue;
> +		if (sa) {
> +			if (sa->sa_family != AF_UNSPEC &&
> +			    sa->sa_family != xprt->xpt_local.ss_family)
> +				continue;
> +			if (compare_sa(sa, (struct sockaddr *)&xprt->xpt_local))
> +				continue;
> +		}
>  		found = xprt;
>  		svc_xprt_get(xprt);
>  		break;
> @@ -1022,7 +1072,7 @@ EXPORT_SYMBOL_GPL(svc_find_xprt);
>  int svc_xprt_names(struct svc_serv *serv, char *buf, int buflen)
>  {
>  	struct svc_xprt *xprt;
> -	char xprt_str[64];
> +	char xprt_str[128];
>  	int totlen = 0;
>  	int len;
>
> @@ -1033,12 +1083,16 @@ int svc_xprt_names(struct svc_serv *serv,  
> char *buf, int buflen)
>  	spin_lock_bh(&serv->sv_lock);
>  	list_for_each_entry(xprt, &serv->sv_permsocks, xpt_list) {
>  		len = snprintf(xprt_str, sizeof(xprt_str),
> -			       "%s %d\n", xprt->xpt_class->xcl_name,
> -			       svc_xprt_local_port(xprt));
> +			       "%s ", xprt->xpt_class->xcl_name);
>  		/* If the string was truncated, replace with error string */
> -		if (len >= sizeof(xprt_str))
> +		if (len >= sizeof(xprt_str)) {
>  			strcpy(xprt_str, "name-too-long\n");
> -		/* Don't overflow buffer */
> +			continue;
> +		}
> +		__svc_print_addr((struct sockaddr *)&xprt->xpt_local,
> +				 &xprt_str[len],
> +				 sizeof(xprt_str) - len - 1);
> +		strcat(xprt_str, "\n");
>  		len = strlen(xprt_str);
>  		if (buflen && (len + totlen >= buflen))
>  			break;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




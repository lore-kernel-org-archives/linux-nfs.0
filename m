From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 03/10] SUNRPC: Provide functions for managing universal
 addresses
Date: Thu, 16 Jul 2009 15:54:16 -0400
Message-ID: <1247774056.12292.131.camel@heimdal.trondhjem.org>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
	 <20090715213709.7582.56522.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:51152 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932765AbZGPTyY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 15:54:24 -0400
In-Reply-To: <20090715213709.7582.56522.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-07-15 at 17:37 -0400, Chuck Lever wrote:
> Introduce a set of functions in the kernel's RPC implementation for
> converting between a socket address and either a standard
> presentation address string or an RPC universal address.
> 
> The universal address functions will be used to encode and decode
> RPCB_FOO and NFSv4 SETCLIENTID arguments.  The other functions are
> part of a previous promise to deliver shared functions that can be
> used by upper-layer protocols to display and manipulate IP
> addresses.
> 
> The kernel's current address printf formatters were designed
> specifically for kernel to user-space APIs that require a particular
> string format for socket addresses, thus are somewhat limited for the
> purposes of sunrpc.ko.  The formatter for IPv6 addresses, %pI6, does
> not support short-handing or scope IDs.  Also, these printf formatters
> are unique per address family, so a separate formatter string is
> required for printing AF_INET and AF_INET6 addresses.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfs/internal.h           |    2 
>  include/linux/sunrpc/clnt.h |   12 +
>  net/sunrpc/Makefile         |    2 
>  net/sunrpc/addr.c           |  524 +++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 537 insertions(+), 3 deletions(-)
>  create mode 100644 net/sunrpc/addr.c
> 
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index d3823d7..a19b7b9 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -370,8 +370,6 @@ unsigned int nfs_page_array_len(unsigned int base, size_t len)
>  		PAGE_SIZE - 1) >> PAGE_SHIFT;
>  }
>  
> -#define IPV6_SCOPE_DELIMITER	'%'
> -
>  /*
>   * Set the port number in an address.  Be agnostic about the address
>   * family.
> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
> index 37881f1..bf38c4a 100644
> --- a/include/linux/sunrpc/clnt.h
> +++ b/include/linux/sunrpc/clnt.h
> @@ -151,5 +151,17 @@ void		rpc_force_rebind(struct rpc_clnt *);
>  size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
>  const char	*rpc_peeraddr2str(struct rpc_clnt *, enum rpc_display_format_t);
>  
> +unsigned short	rpc_get_port(const struct sockaddr *sap);
> +void		rpc_set_port(struct sockaddr *sap, const unsigned short port);
> +size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
> +size_t		rpc_pton(const char *, const size_t,
> +			 struct sockaddr *, const size_t);
> +char *		rpc_sockaddr2uaddr(const struct sockaddr *);
> +size_t		rpc_uaddr2sockaddr(const char *, const size_t,
> +				   struct sockaddr *, const size_t);
> +
> +#define IPV6_SCOPE_DELIMITER		'%'
> +#define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_SUNRPC_CLNT_H */
> diff --git a/net/sunrpc/Makefile b/net/sunrpc/Makefile
> index 7a594cc..6020f5b 100644
> --- a/net/sunrpc/Makefile
> +++ b/net/sunrpc/Makefile
> @@ -12,7 +12,7 @@ obj-$(CONFIG_SUNRPC_XPRT_RDMA) += xprtrdma/
>  sunrpc-y := clnt.o xprt.o socklib.o xprtsock.o sched.o \
>  	    auth.o auth_null.o auth_unix.o auth_generic.o \
>  	    svc.o svcsock.o svcauth.o svcauth_unix.o \
> -	    rpcb_clnt.o timer.o xdr.o \
> +	    addr.o rpcb_clnt.o timer.o xdr.o \
>  	    sunrpc_syms.o cache.o rpc_pipe.o \
>  	    svc_xprt.o
>  sunrpc-$(CONFIG_NFS_V4_1) += backchannel_rqst.o bc_svc.o
> diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
> new file mode 100644
> index 0000000..9ddcffd
> --- /dev/null
> +++ b/net/sunrpc/addr.c
> @@ -0,0 +1,524 @@
> +/*
> + * Copyright 2009, Oracle.  All rights reserved.
> + *
> + * Convert socket addresses to presentation addresses and universal
> + * addresses, and vice versa.
> + *
> + * Universal addresses are introduced by RFC 1833 and further refined by
> + * recent RFCs describing NFSv4.  The universal address format is part
> + * of the external (network) interface provided by rpcbind version 3
> + * and 4, and by NFSv4.  Such an address is a string containing a
> + * presentation format IP address followed by a port number in
> + * "hibyte.lobyte" format.
> + *
> + * There are some challenges to constructing universal addresses.
> + * In particular, constructing a presentation address string for IPv4
> + * is straightforward, but it's not so easy for IPv6 addresses.  Such
> + * addresses can be "short-handed" to remove the longest string of
> + * zeros, and mapped v4 presentation addresses can appear in a special
> + * dotted-quad form.  Refer to RFC 4291, Section 2.2 for details on
> + * IPv6 presentation formats.
> + *
> + * IPv6 addresses can also include a scope ID, typically denoted by
> + * a '%' followed by a device name or a non-negative integer.
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/socket.h>
> +#include <linux/in.h>
> +#include <linux/in6.h>
> +#include <linux/inet.h>
> +
> +#include <net/ipv6.h>
> +
> +#include <linux/sunrpc/clnt.h>
> +
> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> +
> +struct rpc_zeros {
> +	unsigned int	count;
> +	int		index;
> +};
> +
> +static const struct rpc_zeros zeros_init = {
> +	.count		= 0,
> +	.index		= -1,
> +};
> +
> +static void rpc_find_longest_zero_run(const struct in6_addr *addr,
> +				      struct rpc_zeros *longest)
> +{
> +	struct rpc_zeros zeros;
> +	unsigned int i;
> +
> +	zeros = zeros_init;
> +	*longest = zeros_init;
                     ^^^^^^^^^^ Why do this when you could just set
longest->index to -1?

> +
> +	for (i = 0; i < ARRAY_SIZE(addr->s6_addr16); i++) {
> +		if (addr->s6_addr16[i] == 0) {
> +			if (zeros.index == -1)
> +				zeros.index = i;
> +			zeros.count++;
> +		} else {
> +			if (zeros.count > longest->count ||
> +			    longest->index == -1)
> +				*longest = zeros;
> +			zeros = zeros_init;
> +		}
> +	}
> +
> +	/*
> +	 * Maybe the last run of zeros didn't terminate.
> +	 * Not likely for a host address.
> +	 */
> +	if (zeros.index != -1) {
> +		if (zeros.count > longest->count ||
> +		    longest->index == -1)
> +			*longest = zeros;
> +	}
> +}
> +
> +/*
> + * Append a set of halfwords from @addr onto the string in @buf.
> + *
> + * Returns the new length of the string in @buf, or zero if
> + * some error occurs.
> + */
> +static size_t rpc_append_halfword6(const struct in6_addr *addr,
> +				   const char *fmt,
> +				   const unsigned int start,
> +				   const unsigned int end,
> +				   char *buf, const size_t buflen)
> +{
> +	char tmp[sizeof("ffff:") + 1];

You are passing 'fmt' as an argument, yet you assume it will have a
format that makes sense of the above 'sizeof' calculation? Why not just
drop the ':', and always use fmt=="%x"?

As far as I can see, that would simplify rpc_ntop6_shorthand too...

> +	unsigned int i;
> +	size_t len = 0;
> +
> +	for (i = start; i < end; i++) {
> +		len = snprintf(tmp, sizeof(tmp), fmt,
> +					ntohs(addr->s6_addr16[i]));
> +		if (unlikely(len > sizeof(tmp)))
> +			return 0;
> +
> +		len = strlcat(buf, tmp, buflen);
> +		if (unlikely(len > buflen))
> +			return 0;
> +	}
> +
> +	return len;
> +}
> +
> +/*
> + * This implementation depends on the Linux kernel's definition of
> + * in6_addr, which is a union of arrays that facilities dissecting
> + * the address into 16-bit chunks.
> + */
> +static size_t rpc_ntop6_shorthand(const struct in6_addr *addr,
> +				  struct rpc_zeros *longest,
> +				  char *buf, const size_t buflen)
> +{
> +	size_t len;
> +
> +	/*
> +	 * Left half, before the longest string of zeros
> +	 */
> +	buf[0] = '\0';
> +	if (longest->index == 0) {
> +		len = strlcat(buf, ":", buflen);
> +		if (unlikely(len > buflen))
> +			return 0;
> +	} else {
> +		len = rpc_append_halfword6(addr, "%x:",
> +					0, longest->index, buf, buflen);
> +		if (unlikely(len == 0))
> +			return 0;
> +	}
> +
> +	/*
> +	 * Right half, after the longest string of zeros
> +	 */
> +	if (longest->index + longest->count >= ARRAY_SIZE(addr->s6_addr16)) {
> +		len = strlcat(buf, ":", buflen);
> +		if (unlikely(len > buflen))
> +			return 0;
> +	} else {
> +		len = rpc_append_halfword6(addr, ":%x",
> +			longest->index + longest->count,
> +			ARRAY_SIZE(addr->s6_addr16), buf, buflen);
> +		if (unlikely(len == 0))
> +			return 0;
> +	}
> +
> +	return len;
> +}

The shorthand format is, AFAICS, not an obligatory notation. Why should
we implement it, if it involves all this complication?

> +
> +static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
> +				  char *buf, const int buflen)
> +{
> +	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
> +	const struct in6_addr *addr = &sin6->sin6_addr;
> +	struct rpc_zeros longest;
> +
> +	/*
> +	 * RFC 4291, Section 2.2.3
> +	 *
> +	 * Special presentation address format for mapped v4
> +	 * addresses.
> +	 */
> +	if (ipv6_addr_v4mapped(addr))
> +		return snprintf(buf, buflen, "::ffff:%pI4",
> +					&addr->s6_addr32[3]);

Err... Won't that give you ::ffff:x.x.x.x ?

> +	/*
> +	 * RFC 4291, Section 2.2.2
> +	 *
> +	 * See if address can be short-handed.
> +	 */
> +	rpc_find_longest_zero_run(addr, &longest);
> +	if (longest.index != -1 && longest.count > 1)
> +		return rpc_ntop6_shorthand(addr, &longest, buf, buflen);
> +
> +	/*
> +	 * RFC 4291, Section 2.2.1
> +	 *
> +	 * Short-handing not possible, so spell out full
> +	 * address.  We don't want leading zeros in each
> +	 * halfword, so avoid %pI6.
> +	 */
> +	return snprintf(buf, buflen, "%x:%x:%x:%x:%x:%x:%x:%x",
> +		ntohs(addr->s6_addr16[0]), ntohs(addr->s6_addr16[1]),
> +		ntohs(addr->s6_addr16[2]), ntohs(addr->s6_addr16[3]),
> +		ntohs(addr->s6_addr16[4]), ntohs(addr->s6_addr16[5]),
> +		ntohs(addr->s6_addr16[6]), ntohs(addr->s6_addr16[7]));

Why not use %pI6 ?

> +}
> +
> +static size_t rpc_ntop6(const struct sockaddr *sap,
> +			char *buf, const size_t buflen)
> +{
> +	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
> +	char scopebuf[IPV6_SCOPE_ID_LEN];
> +	size_t len;
> +	int rc;
> +
> +	len = rpc_ntop6_noscopeid(sap, buf, buflen);
> +	if (unlikely(len == 0))
> +		return len;
> +
> +	if (!(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL) &&
> +	    !(ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_SITELOCAL))
> +		return len;
> +
> +	rc = snprintf(scopebuf, sizeof(scopebuf), "%c%u",
> +			IPV6_SCOPE_DELIMITER, sin6->sin6_scope_id);
> +	if (unlikely((size_t)rc > sizeof(scopebuf)))
> +		return 0;
> +
> +	len += rc;
> +	if (unlikely(len > buflen))
> +		return 0;
> +
> +	strcat(buf, scopebuf);
> +	return len;
> +}
> +
> +#else	/* !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) */
> +
> +static size_t rpc_ntop6_noscopeid(const struct sockaddr *sap,
> +				  char *buf, const int buflen)
> +{
> +	return 0;
> +}
> +
> +static size_t rpc_ntop6(const struct sockaddr *sap,
> +			char *buf, const size_t buflen)
> +{
> +	return 0;
> +}
> +
> +#endif	/* !(defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) */
> +
> +static int rpc_ntop4(const struct sockaddr *sap,
> +		     char *buf, const size_t buflen)
> +{
> +	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
> +
> +	return snprintf(buf, buflen, "%pI4", &sin->sin_addr);
> +}
> +
> +/**
> + * rpc_ntop - construct a presentation address in @buf
> + * @sap: socket address
> + * @buf: construction area
> + * @buflen: size of @buf, in bytes
> + *
> + * Plants a %NUL-terminated string in @buf and returns the length
> + * of the string, excluding the %NUL.  Otherwise zero is returned.
> + */
> +size_t rpc_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
> +{
> +	char tmp[INET6_ADDRSTRLEN + IPV6_SCOPE_ID_LEN + 1];
> +	size_t len;
> +
> +	switch (sap->sa_family) {
> +	case AF_INET:
> +		len = rpc_ntop4(sap, tmp, sizeof(tmp));
> +		break;
> +	case AF_INET6:
> +		len = rpc_ntop6(sap, tmp, sizeof(tmp));
> +		break;
> +	default:
> +		return 0;
> +	}
> +
> +	if (unlikely(len == 0 || len > sizeof(tmp) || len > buflen))
> +		return 0;
> +	return strlcpy(buf, tmp, buflen);

Why two copies?


> +/**
> + * rpc_sockaddr2uaddr - Construct a universal address string from
> @sap.
> + * @sap: socket address
> + *
> + * Returns a %NUL-terminated string in dynamically allocated memory;
> + * otherwise NULL is returned if an error occurred.  Caller must
> + * free the returned string.
> + */
> +char *rpc_sockaddr2uaddr(const struct sockaddr *sap)
> +{
> +       char portbuf[RPCBIND_MAXUADDRPLEN + 1];
> +       char addrbuf[RPCBIND_MAXUADDRLEN + 1];
> +       unsigned short port;
> +
> +       switch (sap->sa_family) {
> +       case AF_INET:
> +               if (rpc_ntop4(sap, addrbuf, sizeof(addrbuf)) == 0)
> +                       return NULL;
> +               port = ntohs(((struct sockaddr_in *)sap)->sin_port);
> +               break;
> +       case AF_INET6:
> +               if (rpc_ntop6_noscopeid(sap, addrbuf, sizeof(addrbuf))
> == 0)
> +                       return NULL;
> +               port = ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
> +               break;
> +       default:
> +               return NULL;
> +       }
> +
> +       if (snprintf(portbuf, sizeof(portbuf),
> +                    ".%u.%u", port >> 8, port & 0xff) >
> (int)sizeof(portbuf))
> +               return NULL;
> +
> +       if (strlcat(addrbuf, portbuf, sizeof(addrbuf)) >
> sizeof(addrbuf))
> +               return NULL;
> +
> +       return kstrdup(addrbuf, GFP_ATOMIC);

GFP_ATOMIC? Why?

> +}
> +EXPORT_SYMBOL_GPL(rpc_sockaddr2uaddr);

> +unsigned short rpc_get_port(const struct sockaddr *sap)
> +{
> +	switch (sap->sa_family) {
> +	case AF_INET:
> +		return ntohs(((struct sockaddr_in *)sap)->sin_port);
> +	case AF_INET6:
> +		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
> +	}
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(rpc_get_port);

inline helper?

> +
> +void rpc_set_port(struct sockaddr *sap, const unsigned short port)
> +{
> +	switch (sap->sa_family) {
> +	case AF_INET:
> +		((struct sockaddr_in *)sap)->sin_port = htons(port);
> +		break;
> +	case AF_INET6:
> +		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
> +		break;
> +	}
> +}
> +EXPORT_SYMBOL_GPL(rpc_set_port);

ditto


Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:34301 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751222AbcJGPP2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Oct 2016 11:15:28 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 01/10] SUNRPC: add AF_VSOCK support to addr.[ch]
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1475834514-4058-2-git-send-email-stefanha@redhat.com>
Date: Fri, 7 Oct 2016 11:15:20 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <E1AFFD7C-D0D3-495E-BB11-94358FF31DBA@oracle.com>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com> <1475834514-4058-2-git-send-email-stefanha@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Stefan-

> On Oct 7, 2016, at 6:01 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> AF_VSOCK addresses are a Context ID (CID) and port number tuple.  The
> CID is a unique address, similar to a IP address on a local subnet.
> 
> Extend the addr.h functions to handle AF_VSOCK addresses.

I'm wondering if there's a specification for how to construct
the universal address form of an AF_VSOCK address. This would
be needed for populating an fs_locations response, or for
updating the NFS server's local rpcbind service.

A traditional NFS server employs IP-address based access
control. How does that work with the new address family? Do
you expect changes to mountd or exportfs?

Is there a standard that defines the "vsock" netid? A new
netid requires at least an IANA action. Is there a document
that describes how RPC works with a VSOCK transport?

This work appears to define two separate things: a new address
family, and a new transport type. Wouldn't it be cleaner to
dispense with the "proto=vsock" piece, and just support TCP
over AF_VSOCK (just as it works for AF_INET and AF_INET6) ?

At Connectathon, we discussed what happens when a guest is
live-migrated to another host with a vsock-enabled NFSD.
Essentially, the server at the known-local address would
change identities and its content could be completely
different. For instance, the file handles would all change,
including the file handle of the export's root directory.
Clients don't tolerate that especially well.

Can't a Docker-based or kvm-based guest simply mount one of
the host's local file systems directly? What would be the
value of inserting NFS into that picture?


> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> v2:
> * Replace CONFIG_VSOCKETS with CONFIG_SUNRPC_XPRT_VSOCK to prevent
>   build failures when SUNRPC=y and VSOCKETS=m.  Built-in code cannot
>   link against code in a module.

> ---
> include/linux/sunrpc/addr.h | 44 ++++++++++++++++++++++++++++++++++
> net/sunrpc/Kconfig          | 10 ++++++++
> net/sunrpc/addr.c           | 57 +++++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 111 insertions(+)
> 
> diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
> index 5c9c6cd..c4169bc 100644
> --- a/include/linux/sunrpc/addr.h
> +++ b/include/linux/sunrpc/addr.h
> @@ -10,6 +10,7 @@
> #include <linux/socket.h>
> #include <linux/in.h>
> #include <linux/in6.h>
> +#include <linux/vm_sockets.h>
> #include <net/ipv6.h>
> 
> size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
> @@ -26,6 +27,8 @@ static inline unsigned short rpc_get_port(const struct sockaddr *sap)
> 		return ntohs(((struct sockaddr_in *)sap)->sin_port);
> 	case AF_INET6:
> 		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
> +	case AF_VSOCK:
> +		return ((struct sockaddr_vm *)sap)->svm_port;
> 	}
> 	return 0;
> }
> @@ -40,6 +43,9 @@ static inline void rpc_set_port(struct sockaddr *sap,
> 	case AF_INET6:
> 		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
> 		break;
> +	case AF_VSOCK:
> +		((struct sockaddr_vm *)sap)->svm_port = port;
> +		break;
> 	}
> }
> 
> @@ -106,6 +112,40 @@ static inline bool __rpc_copy_addr6(struct sockaddr *dst,
> }
> #endif	/* !(IS_ENABLED(CONFIG_IPV6) */
> 
> +#if IS_ENABLED(CONFIG_VSOCKETS)
> +static inline bool rpc_cmp_vsock_addr(const struct sockaddr *sap1,
> +				      const struct sockaddr *sap2)
> +{
> +	const struct sockaddr_vm *svm1 = (const struct sockaddr_vm *)sap1;
> +	const struct sockaddr_vm *svm2 = (const struct sockaddr_vm *)sap2;
> +
> +	return svm1->svm_cid == svm2->svm_cid;
> +}
> +
> +static inline bool __rpc_copy_vsock_addr(struct sockaddr *dst,
> +					 const struct sockaddr *src)
> +{
> +	const struct sockaddr_vm *ssvm = (const struct sockaddr_vm *)src;
> +	struct sockaddr_vm *dsvm = (struct sockaddr_vm *)dst;
> +
> +	dsvm->svm_family = ssvm->svm_family;
> +	dsvm->svm_cid = ssvm->svm_cid;
> +	return true;
> +}
> +#else	/* !(IS_ENABLED(CONFIG_VSOCKETS) */
> +static inline bool rpc_cmp_vsock_addr(const struct sockaddr *sap1,
> +				      const struct sockaddr *sap2)
> +{
> +	return false;
> +}
> +
> +static inline bool __rpc_copy_vsock_addr(struct sockaddr *dst,
> +					 const struct sockaddr *src)
> +{
> +	return false;
> +}
> +#endif	/* !(IS_ENABLED(CONFIG_VSOCKETS) */
> +
> /**
>  * rpc_cmp_addr - compare the address portion of two sockaddrs.
>  * @sap1: first sockaddr
> @@ -125,6 +165,8 @@ static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
> 			return rpc_cmp_addr4(sap1, sap2);
> 		case AF_INET6:
> 			return rpc_cmp_addr6(sap1, sap2);
> +		case AF_VSOCK:
> +			return rpc_cmp_vsock_addr(sap1, sap2);
> 		}
> 	}
> 	return false;
> @@ -161,6 +203,8 @@ static inline bool rpc_copy_addr(struct sockaddr *dst,
> 		return __rpc_copy_addr4(dst, src);
> 	case AF_INET6:
> 		return __rpc_copy_addr6(dst, src);
> +	case AF_VSOCK:
> +		return __rpc_copy_vsock_addr(dst, src);
> 	}
> 	return false;
> }
> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
> index 04ce2c0..d18fc1a 100644
> --- a/net/sunrpc/Kconfig
> +++ b/net/sunrpc/Kconfig
> @@ -61,3 +61,13 @@ config SUNRPC_XPRT_RDMA
> 
> 	  If unsure, or you know there is no RDMA capability on your
> 	  hardware platform, say N.
> +
> +config SUNRPC_XPRT_VSOCK
> +	bool "RPC-over-AF_VSOCK transport"
> +	depends on SUNRPC && VSOCKETS && !(SUNRPC=y && VSOCKETS=m)
> +	default SUNRPC && VSOCKETS
> +	help
> +	  This option allows the NFS client and server to use the AF_VSOCK
> +	  transport to communicate between virtual machines and the host.
> +
> +	  If unsure, say Y.
> diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
> index 2e0a6f9..f4dd962 100644
> --- a/net/sunrpc/addr.c
> +++ b/net/sunrpc/addr.c
> @@ -16,11 +16,14 @@
>  * RFC 4291, Section 2.2 for details on IPv6 presentation formats.
>  */
> 
> + /* TODO register netid and uaddr with IANA? (See RFC 5665 5.1/5.2) */
> +
> #include <net/ipv6.h>
> #include <linux/sunrpc/addr.h>
> #include <linux/sunrpc/msg_prot.h>
> #include <linux/slab.h>
> #include <linux/export.h>
> +#include <linux/vm_sockets.h>
> 
> #if IS_ENABLED(CONFIG_IPV6)
> 
> @@ -108,6 +111,26 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
> 
> #endif	/* !IS_ENABLED(CONFIG_IPV6) */
> 
> +#ifdef CONFIG_SUNRPC_XPRT_VSOCK
> +
> +static size_t rpc_ntop_vsock(const struct sockaddr *sap,
> +			     char *buf, const size_t buflen)
> +{
> +	const struct sockaddr_vm *svm = (struct sockaddr_vm *)sap;
> +
> +	return snprintf(buf, buflen, "%u", svm->svm_cid);
> +}
> +
> +#else	/* !CONFIG_SUNRPC_XPRT_VSOCK */
> +
> +static size_t rpc_ntop_vsock(const struct sockaddr *sap,
> +			     char *buf, const size_t buflen)
> +{
> +	return 0;
> +}
> +
> +#endif	/* !CONFIG_SUNRPC_XPRT_VSOCK */
> +
> static int rpc_ntop4(const struct sockaddr *sap,
> 		     char *buf, const size_t buflen)
> {
> @@ -132,6 +155,8 @@ size_t rpc_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
> 		return rpc_ntop4(sap, buf, buflen);
> 	case AF_INET6:
> 		return rpc_ntop6(sap, buf, buflen);
> +	case AF_VSOCK:
> +		return rpc_ntop_vsock(sap, buf, buflen);
> 	}
> 
> 	return 0;
> @@ -229,6 +254,34 @@ static size_t rpc_pton6(struct net *net, const char *buf, const size_t buflen,
> }
> #endif
> 
> +#ifdef CONFIG_SUNRPC_XPRT_VSOCK
> +static size_t rpc_pton_vsock(const char *buf, const size_t buflen,
> +			     struct sockaddr *sap, const size_t salen)
> +{
> +	const size_t prefix_len = strlen("vsock:");
> +	struct sockaddr_vm *svm = (struct sockaddr_vm *)sap;
> +	unsigned int cid;
> +
> +	if (strncmp(buf, "vsock:", prefix_len) != 0 ||
> +	    salen < sizeof(struct sockaddr_vm))
> +		return 0;
> +
> +	if (kstrtouint(buf + prefix_len, 10, &cid) != 0)
> +		return 0;
> +
> +	memset(svm, 0, sizeof(struct sockaddr_vm));
> +	svm->svm_family = AF_VSOCK;
> +	svm->svm_cid = cid;
> +	return sizeof(struct sockaddr_vm);
> +}
> +#else
> +static size_t rpc_pton_vsock(const char *buf, const size_t buflen,
> +			     struct sockaddr *sap, const size_t salen)
> +{
> +	return 0;
> +}
> +#endif
> +
> /**
>  * rpc_pton - Construct a sockaddr in @sap
>  * @net: applicable network namespace
> @@ -249,6 +302,10 @@ size_t rpc_pton(struct net *net, const char *buf, const size_t buflen,
> {
> 	unsigned int i;
> 
> +	/* TODO is there a nicer way to distinguish vsock addresses? */
> +	if (strncmp(buf, "vsock:", 6) == 0)
> +		return rpc_pton_vsock(buf, buflen, sap, salen);
> +
> 	for (i = 0; i < buflen; i++)
> 		if (buf[i] == ':')
> 			return rpc_pton6(net, buf, buflen, sap, salen);
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever




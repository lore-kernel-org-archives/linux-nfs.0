Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:56590 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932230AbdJaOKl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 10:10:41 -0400
Received: by mail-qt0-f195.google.com with SMTP id z28so20812078qtz.13
        for <linux-nfs@vger.kernel.org>; Tue, 31 Oct 2017 07:10:41 -0700 (PDT)
Message-ID: <1509459038.4553.26.camel@redhat.com>
Subject: Re: [PATCH v3 08/14] SUNRPC: add AF_VSOCK support to svc_xprt.c
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>, linux-nfs@vger.kernel.org
Cc: Abbas Naderi <abiusx@google.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Date: Tue, 31 Oct 2017 10:10:38 -0400
In-Reply-To: <20170630132352.32133-9-stefanha@redhat.com>
References: <20170630132352.32133-1-stefanha@redhat.com>
         <20170630132352.32133-9-stefanha@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-06-30 at 14:23 +0100, Stefan Hajnoczi wrote:
> Allow creation of AF_VSOCK service xprts.  This is needed for the
> "vsock-bc" backchannel.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
>  include/linux/sunrpc/svc_xprt.h | 12 ++++++++++++
>  net/sunrpc/svc_xprt.c           | 18 ++++++++++++++++++
>  2 files changed, 30 insertions(+)
> 
> diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
> index ddb7f94..938f9ee 100644
> --- a/include/linux/sunrpc/svc_xprt.h
> +++ b/include/linux/sunrpc/svc_xprt.h
> @@ -8,6 +8,7 @@
>  #define SUNRPC_SVC_XPRT_H
>  
>  #include <linux/sunrpc/svc.h>
> +#include <linux/vm_sockets.h>
>  
>  struct module;
>  
> @@ -156,12 +157,15 @@ static inline unsigned short svc_addr_port(const struct sockaddr *sa)
>  {
>  	const struct sockaddr_in *sin = (const struct sockaddr_in *)sa;
>  	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sa;
> +	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)sa;
>  
>  	switch (sa->sa_family) {
>  	case AF_INET:
>  		return ntohs(sin->sin_port);
>  	case AF_INET6:
>  		return ntohs(sin6->sin6_port);
> +	case AF_VSOCK:
> +		return svm->svm_port;
>  	}
>  
>  	return 0;
> @@ -174,6 +178,8 @@ static inline size_t svc_addr_len(const struct sockaddr *sa)
>  		return sizeof(struct sockaddr_in);
>  	case AF_INET6:
>  		return sizeof(struct sockaddr_in6);
> +	case AF_VSOCK:
> +		return sizeof(struct sockaddr_vm);
>  	}
>  	BUG();
>  }
> @@ -193,6 +199,7 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
>  {
>  	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
>  	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
> +	const struct sockaddr_vm *svm = (const struct sockaddr_vm *)addr;
>  
>  	switch (addr->sa_family) {
>  	case AF_INET:
> @@ -206,6 +213,11 @@ static inline char *__svc_print_addr(const struct sockaddr *addr,
>  			ntohs(sin6->sin6_port));
>  		break;
>  
> +	case AF_VSOCK:
> +		snprintf(buf, len, "%u, port=%u",
> +			 svm->svm_cid, svm->svm_port);
> +		break;
> +
>  	default:
>  		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
>  		break;
> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> index 7bfe1fb..2a8ccc1 100644
> --- a/net/sunrpc/svc_xprt.c
> +++ b/net/sunrpc/svc_xprt.c
> @@ -10,6 +10,7 @@
>  #include <linux/kthread.h>
>  #include <linux/slab.h>
>  #include <net/sock.h>
> +#include <net/af_vsock.h>
>  #include <linux/sunrpc/addr.h>
>  #include <linux/sunrpc/stats.h>
>  #include <linux/sunrpc/svc_xprt.h>
> @@ -195,6 +196,13 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
>  		.sin6_port		= htons(port),
>  	};
>  #endif
> +#ifdef CONFIG_SUNRPC_XPRT_VSOCK
> +	struct sockaddr_vm svm = {
> +		.svm_family		= AF_VSOCK,
> +		.svm_cid		= VMADDR_CID_ANY,
> +		.svm_port		= port,
> +	};
> +#endif
>  	struct sockaddr *sap;
>  	size_t len;
>  
> @@ -209,6 +217,12 @@ static struct svc_xprt *__svc_xpo_create(struct svc_xprt_class *xcl,
>  		len = sizeof(sin6);
>  		break;
>  #endif
> +#ifdef CONFIG_SUNRPC_XPRT_VSOCK
> +	case AF_VSOCK:
> +		sap = (struct sockaddr *)&svm;
> +		len = sizeof(svm);
> +		break;
> +#endif
>  	default:
>  		return ERR_PTR(-EAFNOSUPPORT);
>  	}
> @@ -595,6 +609,10 @@ int svc_port_is_privileged(struct sockaddr *sin)
>  	case AF_INET6:
>  		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
>  			< PROT_SOCK;
> +	case AF_VSOCK:
> +		return ((struct sockaddr_vm *)sin)->svm_port <=
> +			LAST_RESERVED_PORT;
> +
>  	default:
>  		return 0;
>  	}

Does vsock even have the concept of a privileged port? I would imagine
that root in a guest VM would carry no particular significance from an
export security standpoint

Since you're defining a new transport here, it might be nice write the
RFCs to avoid that distinction, if possible.

Note that RDMA just has svc_port_is_privileged always return 1.

-- 
Jeff Layton <jlayton@redhat.com>

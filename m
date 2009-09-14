From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH v3 03/12] nfsd41: sunrpc: add new xprt class for
 nfsv4.1 backchannel
Date: Mon, 14 Sep 2009 11:17:38 +0300
Message-ID: <4AADFC22.7050104@panasas.com>
References: <4AA8C597.8080809@panasas.com> <1252574732-30108-1-git-send-email-bhalevy@panasas.com> <4AA90E3A.80400@panasas.com> <20090911205821.GE5701@fieldses.org> <5e24e8930909111412r2c7bdc58u119767517154d6@mail.gmail.com> <20090913202821.GD13109@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:30123 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755182AbZINIQd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2009 04:16:33 -0400
In-Reply-To: <20090913202821.GD13109@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 13, 2009, 23:28 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Fri, Sep 11, 2009 at 02:12:35PM -0700, Alexandros Batsakis wrote:
>> On Fri, Sep 11, 2009 at 1:58 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> On Thu, Sep 10, 2009 at 05:33:30PM +0300, Benny Halevy wrote:
>>>> diff --git a/include/linux/sunrpc/xprtrdma.h b/include/linux/sunrpc/xprtrdma.h
>>>> index 54a379c..c2f04e1 100644
>>>> --- a/include/linux/sunrpc/xprtrdma.h
>>>> +++ b/include/linux/sunrpc/xprtrdma.h
>>>> @@ -41,11 +41,6 @@
>>>>  #define _LINUX_SUNRPC_XPRTRDMA_H
>>>>
>>>>  /*
>>>> - * RPC transport identifier for RDMA
>>>> - */
>>>> -#define XPRT_TRANSPORT_RDMA  256
>>>> -
>>>> -/*
>>>>   * rpcbind (v3+) RDMA netid.
>>>>   */
>>>>  #define RPCBIND_NETID_RDMA   "rdma"
>>>> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
>>>> index c2a46c4..d7c98d1 100644
>>>> --- a/include/linux/sunrpc/xprtsock.h
>>>> +++ b/include/linux/sunrpc/xprtsock.h
>>>> @@ -20,8 +20,13 @@ void               cleanup_socket_xprt(void);
>>>>   * values. No such restriction exists for new transports, except that
>>>>   * they may not collide with these values (17 and 6, respectively).
>>>>   */
>>>> -#define XPRT_TRANSPORT_UDP   IPPROTO_UDP
>>>> -#define XPRT_TRANSPORT_TCP   IPPROTO_TCP
>>>> +#define XPRT_TRANSPORT_BC    (1 << 31)
>>>> +enum xprt_transports {
>>>> +     XPRT_TRANSPORT_UDP      = IPPROTO_UDP,
>>>> +     XPRT_TRANSPORT_TCP      = IPPROTO_TCP,
>>>> +     XPRT_TRANSPORT_BC_TCP   = IPPROTO_TCP | XPRT_TRANSPORT_BC,
>>>> +     XPRT_TRANSPORT_RDMA     = 256
>>>> +};
>>> This fails to compile when CONFIG_SUNRPC_XPRT_RDMA is set.
>>>
>>> A minimal fix might be:
>>>
>>>        --- a/net/sunrpc/xprtrdma/transport.c
>>>        +++ b/net/sunrpc/xprtrdma/transport.c
>>>        @@ -50,6 +50,8 @@
>>>         #include <linux/module.h>
>>>         #include <linux/init.h>
>>>         #include <linux/seq_file.h>
>>>        +#include <linux/in.h>
>>>        +#include <linux/sunrpc/xprtsock.h>
>>>
>>>         #include "xprt_rdma.h"
>>>
>>> Or maybe just ditch the enum and leave these as they were before.
>>>
>> The incentive here was to have all the transports definitions together
>> so that nobody re-uses a number by mistake (not very likely of
>> course), so I think the fix you suggested is appropriate.
> 
> OK.  Actually, rather than adding a socket-specific include to an
> rdma-specific file, how about the below?  Applying with the following
> change assuming no objections.

Ack

Benny

> 
> --b.
> 
> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
> index 7cc42af..6f9457a 100644
> --- a/include/linux/sunrpc/xprt.h
> +++ b/include/linux/sunrpc/xprt.h
> @@ -124,6 +124,23 @@ struct rpc_xprt_ops {
>  	void		(*print_stats)(struct rpc_xprt *xprt, struct seq_file *seq);
>  };
>  
> +/*
> + * RPC transport identifiers
> + *
> + * To preserve compatibility with the historical use of raw IP protocol
> + * id's for transport selection, UDP and TCP identifiers are specified
> + * with the previous values. No such restriction exists for new transports,
> + * except that they may not collide with these values (17 and 6,
> + * respectively).
> + */
> +#define XPRT_TRANSPORT_BC       (1 << 31)
> +enum xprt_transports {
> +	XPRT_TRANSPORT_UDP	= IPPROTO_UDP,
> +	XPRT_TRANSPORT_TCP	= IPPROTO_TCP,
> +	XPRT_TRANSPORT_BC_TCP	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
> +	XPRT_TRANSPORT_RDMA	= 256
> +};
> +
>  struct rpc_xprt {
>  	struct kref		kref;		/* Reference count */
>  	struct rpc_xprt_ops *	ops;		/* transport methods */
> diff --git a/include/linux/sunrpc/xprtsock.h b/include/linux/sunrpc/xprtsock.h
> index d7c98d1..3f14a02 100644
> --- a/include/linux/sunrpc/xprtsock.h
> +++ b/include/linux/sunrpc/xprtsock.h
> @@ -13,22 +13,6 @@ int		init_socket_xprt(void);
>  void		cleanup_socket_xprt(void);
>  
>  /*
> - * RPC transport identifiers for UDP, TCP
> - *
> - * To preserve compatibility with the historical use of raw IP protocol
> - * id's for transport selection, these are specified with the previous
> - * values. No such restriction exists for new transports, except that
> - * they may not collide with these values (17 and 6, respectively).
> - */
> -#define XPRT_TRANSPORT_BC	(1 << 31)
> -enum xprt_transports {
> -	XPRT_TRANSPORT_UDP 	= IPPROTO_UDP,
> -	XPRT_TRANSPORT_TCP 	= IPPROTO_TCP,
> -	XPRT_TRANSPORT_BC_TCP 	= IPPROTO_TCP | XPRT_TRANSPORT_BC,
> -	XPRT_TRANSPORT_RDMA	= 256
> -};
> -
> -/*
>   * RPC slot table sizes for UDP, TCP transports
>   */
>  extern unsigned int xprt_udp_slot_table_entries;

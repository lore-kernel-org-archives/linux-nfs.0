Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:42634 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752722AbbKBV3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Nov 2015 16:29:07 -0500
Subject: Re: [PATCH v4 16/16] NFS: Enable client side NFSv4.1 backchannel to
 use other transports
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151024211707.4715.61650.stgit@manet.1015granger.net>
 <20151024212832.4715.39528.stgit@manet.1015granger.net>
 <5637CAFC.7070805@Netapp.com>
 <920F59C9-B37D-47AA-ADE8-F72B1958FE68@oracle.com>
CC: <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <5637D59F.2000309@Netapp.com>
Date: Mon, 2 Nov 2015 16:29:03 -0500
MIME-Version: 1.0
In-Reply-To: <920F59C9-B37D-47AA-ADE8-F72B1958FE68@oracle.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/02/2015 04:16 PM, Chuck Lever wrote:
> 
>> On Nov 2, 2015, at 3:43 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>
>> Hi Chuck,
>>
>> Sorry for the delay in reviewing.
>>
>> On 10/24/2015 05:28 PM, Chuck Lever wrote:
>>> Forechannel transports get their own "bc_up" method to create an
>>> endpoint for the backchannel service.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> fs/nfs/callback.c                 |   40 +++++++------------------------------
>>> include/linux/sunrpc/xprt.h       |    2 ++
>>> net/sunrpc/xprtrdma/backchannel.c |   21 +++++++++++++++++++
>>> net/sunrpc/xprtrdma/transport.c   |    1 +
>>> net/sunrpc/xprtrdma/xprt_rdma.h   |    1 +
>>> net/sunrpc/xprtsock.c             |   12 +++++++++++
>>> 6 files changed, 45 insertions(+), 32 deletions(-)
>>>
>>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>>> index 75f7c0a..a7f2e6e 100644
>>> --- a/fs/nfs/callback.c
>>> +++ b/fs/nfs/callback.c
>>> @@ -99,17 +99,6 @@ nfs4_callback_up(struct svc_serv *serv)
>>> }
>>>
>>> #if defined(CONFIG_NFS_V4_1)
>>> -static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net)
>>> -{
>>> -	/*
>>> -	 * Create an svc_sock for the back channel service that shares the
>>> -	 * fore channel connection.
>>> -	 * Returns the input port (0) and sets the svc_serv bc_xprt on success
>>> -	 */
>>> -	return svc_create_xprt(serv, "tcp-bc", net, PF_INET, 0,
>>> -			      SVC_SOCK_ANONYMOUS);
>>> -}
>>> -
>>> /*
>>>  * The callback service for NFSv4.1 callbacks
>>>  */
>>> @@ -184,11 +173,6 @@ static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
>>> 		xprt->bc_serv = serv;
>>> }
>>> #else
>>> -static int nfs41_callback_up_net(struct svc_serv *serv, struct net *net)
>>> -{
>>> -	return 0;
>>> -}
>>> -
>>> static void nfs_minorversion_callback_svc_setup(struct svc_serv *serv,
>>> 		struct svc_rqst **rqstpp, int (**callback_svc)(void *vrqstp))
>>> {
>>> @@ -259,7 +243,8 @@ static void nfs_callback_down_net(u32 minorversion, struct svc_serv *serv, struc
>>> 	svc_shutdown_net(serv, net);
>>> }
>>>
>>> -static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct net *net)
>>> +static int nfs_callback_up_net(int minorversion, struct svc_serv *serv,
>>> +			       struct net *net, struct rpc_xprt *xprt)
>>> {
>>> 	struct nfs_net *nn = net_generic(net, nfs_net_id);
>>> 	int ret;
>>> @@ -275,20 +260,11 @@ static int nfs_callback_up_net(int minorversion, struct svc_serv *serv, struct n
>>> 		goto err_bind;
>>> 	}
>>>
>>> -	switch (minorversion) {
>>> -		case 0:
>>> -			ret = nfs4_callback_up_net(serv, net);
>>> -			break;
>>> -		case 1:
>>> -		case 2:
>>> -			ret = nfs41_callback_up_net(serv, net);
>>> -			break;
>>> -		default:
>>> -			printk(KERN_ERR "NFS: unknown callback version: %d\n",
>>> -					minorversion);
>>> -			ret = -EINVAL;
>>> -			break;
>>> -	}
>>> +	ret = -EPROTONOSUPPORT;
>>> +	if (minorversion == 0)
>>> +		ret = nfs4_callback_up_net(serv, net);
>>> +	else if (xprt->ops->bc_up)
>>> +		ret = xprt->ops->bc_up(serv, net);
>>>
>>> 	if (ret < 0) {
>>> 		printk(KERN_ERR "NFS: callback service start failed\n");
>>> @@ -364,7 +340,7 @@ int nfs_callback_up(u32 minorversion, struct rpc_xprt *xprt)
>>> 		goto err_create;
>>> 	}
>>>
>>> -	ret = nfs_callback_up_net(minorversion, serv, net);
>>> +	ret = nfs_callback_up_net(minorversion, serv, net, xprt);
>>> 	if (ret < 0)
>>> 		goto err_net;
>>>
>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>> index 82c0839..9d22f43 100644
>>> --- a/include/linux/sunrpc/xprt.h
>>> +++ b/include/linux/sunrpc/xprt.h
>>> @@ -54,6 +54,7 @@ enum rpc_display_format_t {
>>> struct rpc_task;
>>> struct rpc_xprt;
>>> struct seq_file;
>>> +struct svc_serv;
> 
> Adding
> 
>   struct net;
> 
> here seems to help.

Yep.  I'll fix up the patch and send to Trond in a few minutes!

Anna
> 
> 
>>> /*
>>>  * This describes a complete RPC request
>>> @@ -138,6 +139,7 @@ struct rpc_xprt_ops {
>>> 	void		(*inject_disconnect)(struct rpc_xprt *xprt);
>>> 	int		(*bc_setup)(struct rpc_xprt *xprt,
>>> 				    unsigned int min_reqs);
>>> +	int		(*bc_up)(struct svc_serv *serv, struct net *net);
>>
>> Disabling CONFIG_SUNRPC_DEBUG gives me several:
>>
>>  CC [M]  fs/nfsd/nfs4acl.o
>>  CC [M]  fs/nfsd/nfs4callback.o
>> In file included from include/linux/sunrpc/clnt.h:19:0,
>>                 from fs/nfsd/nfs4callback.c:34:
>> include/linux/sunrpc/xprt.h:142:46: error: 'struct net' declared inside parameter list [-Werror]
>>  int  (*bc_up)(struct svc_serv *serv, struct net *net);
>>                                              ^
>> include/linux/sunrpc/xprt.h:142:46: error: its scope is only this definition or declaration, which is probably not what you want [-Werror]
>>
>> I'm guessing an include file is missing somewhere?
>>
>> Anna
>>
>>
>>> 	void		(*bc_free_rqst)(struct rpc_rqst *rqst);
>>> 	void		(*bc_destroy)(struct rpc_xprt *xprt,
>>> 				      unsigned int max_reqs);
>>> diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
>>> index 0b3387f..2dcb44f 100644
>>> --- a/net/sunrpc/xprtrdma/backchannel.c
>>> +++ b/net/sunrpc/xprtrdma/backchannel.c
>>> @@ -7,6 +7,7 @@
>>> #include <linux/module.h>
>>> #include <linux/sunrpc/xprt.h>
>>> #include <linux/sunrpc/svc.h>
>>> +#include <linux/sunrpc/svc_xprt.h>
>>>
>>> #include "xprt_rdma.h"
>>>
>>> @@ -174,6 +175,26 @@ out_err:
>>> }
>>>
>>> /**
>>> + * xprt_rdma_bc_up - Create transport endpoint for backchannel service
>>> + * @serv: server endpoint
>>> + * @net: network namespace
>>> + *
>>> + * The "xprt" is an implied argument: it supplies the name of the
>>> + * backchannel transport class.
>>> + *
>>> + * Returns zero on success, negative errno on failure
>>> + */
>>> +int xprt_rdma_bc_up(struct svc_serv *serv, struct net *net)
>>> +{
>>> +	int ret;
>>> +
>>> +	ret = svc_create_xprt(serv, "rdma-bc", net, PF_INET, 0, 0);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +	return 0;
>>> +}
>>> +
>>> +/**
>>>  * rpcrdma_bc_marshal_reply - Send backwards direction reply
>>>  * @rqst: buffer containing RPC reply data
>>>  *
>>> diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
>>> index 845278e..8c545f7 100644
>>> --- a/net/sunrpc/xprtrdma/transport.c
>>> +++ b/net/sunrpc/xprtrdma/transport.c
>>> @@ -708,6 +708,7 @@ static struct rpc_xprt_ops xprt_rdma_procs = {
>>> 	.inject_disconnect	= xprt_rdma_inject_disconnect,
>>> #if defined(CONFIG_SUNRPC_BACKCHANNEL)
>>> 	.bc_setup		= xprt_rdma_bc_setup,
>>> +	.bc_up			= xprt_rdma_bc_up,
>>> 	.bc_free_rqst		= xprt_rdma_bc_free_rqst,
>>> 	.bc_destroy		= xprt_rdma_bc_destroy,
>>> #endif
>>> diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> index eb87d96e8..f8dd17b 100644
>>> --- a/net/sunrpc/xprtrdma/xprt_rdma.h
>>> +++ b/net/sunrpc/xprtrdma/xprt_rdma.h
>>> @@ -520,6 +520,7 @@ void xprt_rdma_cleanup(void);
>>>  */
>>> #if defined(CONFIG_SUNRPC_BACKCHANNEL)
>>> int xprt_rdma_bc_setup(struct rpc_xprt *, unsigned int);
>>> +int xprt_rdma_bc_up(struct svc_serv *, struct net *);
>>> int rpcrdma_bc_post_recv(struct rpcrdma_xprt *, unsigned int);
>>> void rpcrdma_bc_receive_call(struct rpcrdma_xprt *, struct rpcrdma_rep *);
>>> int rpcrdma_bc_marshal_reply(struct rpc_rqst *);
>>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>>> index 44a81e4..dc47067 100644
>>> --- a/net/sunrpc/xprtsock.c
>>> +++ b/net/sunrpc/xprtsock.c
>>> @@ -1306,6 +1306,17 @@ static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
>>> 		xs_tcp_read_reply(xprt, desc) :
>>> 		xs_tcp_read_callback(xprt, desc);
>>> }
>>> +
>>> +static int xs_tcp_bc_up(struct svc_serv *serv, struct net *net)
>>> +{
>>> +	int ret;
>>> +
>>> +	ret = svc_create_xprt(serv, "tcp-bc", net, PF_INET, 0,
>>> +			      SVC_SOCK_ANONYMOUS);
>>> +	if (ret < 0)
>>> +		return ret;
>>> +	return 0;
>>> +}
>>> #else
>>> static inline int _xs_tcp_read_data(struct rpc_xprt *xprt,
>>> 					struct xdr_skb_reader *desc)
>>> @@ -2582,6 +2593,7 @@ static struct rpc_xprt_ops xs_tcp_ops = {
>>> 	.inject_disconnect	= xs_inject_disconnect,
>>> #ifdef CONFIG_SUNRPC_BACKCHANNEL
>>> 	.bc_setup		= xprt_setup_bc,
>>> +	.bc_up			= xs_tcp_bc_up,
>>> 	.bc_free_rqst		= xprt_free_bc_rqst,
>>> 	.bc_destroy		= xprt_destroy_bc,
>>> #endif
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> —
> Chuck Lever
> 
> 
> 


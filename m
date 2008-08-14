From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/8] SUNRPC: Refactor svc_register()
Date: Thu, 14 Aug 2008 17:11:25 -0400
Message-ID: <30F27AE9-3D40-4B3D-9496-4C57493BD6BC@oracle.com>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net> <20080813224016.13068.29786.stgit@manray.1015granger.net> <20080814203640.GJ23859@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@netapp.com, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:38992 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbYHNVLt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2008 17:11:49 -0400
In-Reply-To: <20080814203640.GJ23859@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 14, 2008, at 4:36 PM, J. Bruce Fields wrote:
> On Wed, Aug 13, 2008 at 06:40:17PM -0400, Chuck Lever wrote:
>> Clean up: refactor the rpcb_register() call out of svc_register().
>>
>> The next patch will choose the correct registration subroutine to use
>> based on whether IPv6 support is desired for RPC services.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> include/linux/sunrpc/svc.h |    4 +++-
>> net/sunrpc/svc.c           |   40 ++++++++++++++++++++++++++ 
>> +-------------
>> 2 files changed, 30 insertions(+), 14 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index a794d4a..2a41d29 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -395,7 +395,9 @@ struct svc_serv *  svc_create_pooled(struct  
>> svc_program *, unsigned int,
>> int		   svc_set_num_threads(struct svc_serv *, struct svc_pool *,  
>> int);
>> void		   svc_destroy(struct svc_serv *);
>> int		   svc_process(struct svc_rqst *);
>> -int		   svc_register(struct svc_serv *, int, unsigned short);
>> +int		   svc_register(const struct svc_serv *, const unsigned short,
>> +				const unsigned short);
>> +
>> void		   svc_wake_up(struct svc_serv *);
>> void		   svc_reserve(struct svc_rqst *rqstp, int space);
>> struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 58a8012..aa334c2 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -720,17 +720,32 @@ svc_exit_thread(struct svc_rqst *rqstp)
>> }
>> EXPORT_SYMBOL(svc_exit_thread);
>>
>> -/*
>> - * Register an RPC service with the local portmapper.
>> - * To unregister a service, call this routine with
>> - * proto and port == 0.
>> +static int __svc_register(const u32 program, const u32 version,
>> +			  sa_family_t family,
>> +			  const unsigned short protocol,
>> +			  const unsigned short port)
>> +{
>> +	int error, result;
>> +
>> +	error = rpcb_register(program, version, protocol, port, &result);
>> +	if (!result)
>> +		error = -EACCES;
>> +	return error;
>
> Isn't "result" 0 whenever error is nonzero?  In that case the above  
> is really equivalent to
>
> 	rpcb_register(program, version, protocol, port, &result);
> 	return result ? 0 : -EACCES;
>
> Is that what's intended?  I don't believe it's the behavior of the
> original code.

I'll fix it.  It's a vestige of a previous implementation of  
rpcb_v4_register.

> I understand why they're there, but the separate "result" and "error"
> returns are kinda confusing.  If the distinction's not needed then I
> wonder whether it should just be buried as deep in rpcb_register() as
> possible so we don't have to think about it.

pmap_set() is the user space API for this function, and it returns a  
bool_t -- TRUE if the service was registered, FALSE if it failed in  
any way.  It is probably unnecessary to expose the RPC call and RPC  
reply status codes separately.

To fix this, I will rework the rpcb_register() and rpcb_v4_register()  
APIs, and the patches in this series that depend on them.

>> +}
>> +
>> +/**
>> + * svc_register - register an RPC service with the local portmapper
>> + * @serv: svc_serv struct for the service to register
>> + * @proto: transport protocol number to advertise
>> + * @port: port to advertise
>> + *
>>  */
>> -int
>> -svc_register(struct svc_serv *serv, int proto, unsigned short port)
>> +int svc_register(const struct svc_serv *serv, const unsigned short  
>> proto,
>> +		 const unsigned short port)
>> {
>> 	struct svc_program	*progp;
>> 	unsigned int		i;
>> -	int			error = 0, dummy;
>> +	int			error = 0;
>>
>> 	BUG_ON(proto == 0 && port == 0);
>>
>> @@ -739,8 +754,9 @@ svc_register(struct svc_serv *serv, int proto,  
>> unsigned short port)
>> 			if (progp->pg_vers[i] == NULL)
>> 				continue;
>>
>> -			dprintk("svc: svc_register(%s, %s, %d, %d)%s\n",
>> +			dprintk("svc: svc_register(%s, %u, %s, %u, %d)%s\n",
>> 					progp->pg_name,
>> +					serv->sv_family,
>> 					proto == IPPROTO_UDP?  "udp" : "tcp",
>> 					port,
>> 					i,
>> @@ -750,13 +766,11 @@ svc_register(struct svc_serv *serv, int  
>> proto, unsigned short port)
>> 			if (progp->pg_vers[i]->vs_hidden)
>> 				continue;
>>
>> -			error = rpcb_register(progp->pg_prog, i, proto, port, &dummy);
>> +			error = __svc_register(progp->pg_prog, i,
>> +						serv->sv_family, proto,
>> +						port);
>> 			if (error < 0)
>> 				break;
>> -			if (!dummy) {
>> -				error = -EACCES;
>> -				break;
>> -			}
>> 		}
>> 	}
>>
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




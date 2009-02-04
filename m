From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Use AF_INET6 NFSv4 callback listener only if IPv6 is built in
Date: Wed, 4 Feb 2009 14:04:01 -0500
Message-ID: <8D75C60F-AA91-46B6-B9AA-C679417C4948@oracle.com>
References: <20090204164857.26771.31809.stgit@ingres.1015granger.net> <96EEB7FB-3E36-4F1C-8570-D2A6BB758A79@oracle.com> <1233772405.7161.45.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:59368 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763696AbZBDTER (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2009 14:04:17 -0500
In-Reply-To: <1233772405.7161.45.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Feb 4, 2009, at Feb 4, 2009, 1:33 PM, Trond Myklebust wrote:
> On Wed, 2009-02-04 at 11:56 -0500, Chuck Lever wrote:
>> Sorry, "fixing" is a bit too strong.  I mean working around the issue
>> until we have a long-term solution.
>
> This isn't an acceptable workaround, since it causes a regression for
> those people who do have IPv6 enabled as a module. i.e. me...

Don't you just get normal AF_INET callbacks in that case?

Is the problem that you are using an IPv6 mount address, and want to  
ensure your callback service and lockd are listening on AF_INET6?   
That dependency web is a problem, and for a workaround we can also  
disable IPv6 mounts if IPv6 support is built as a module.

> The real problem here is the existence of serv->sv_family, which
> basically means that we need to decide whether or not we want IPv6
> functionality when we set up the server, instead of when we set up the
> transport. Why do we need this in the first place?

1.  we don't want to create an AF_INET6 listener for kernel RPC  
services that can't yet support it (ie just NFSD at this point).

2.  svc_create() handles rpcbind registration, so it needs to know  
whether to register both inet and inet6 netids or just inet.  Maybe we  
should move the svc_register call to svc_create_xprt() ?

3.  sock_create(AF_INET6) would pin ipv6.ko, but NFSD allows listener  
sockets to come and go.  I would rather just pin ipv6.ko for the  
duration, and unpin it in svc_destroy.  Again, svc_create_xprt might  
be a place to do that.

> Trond
>
>> On Feb 4, 2009, at Feb 4, 2009, 11:51 AM, Chuck Lever wrote:
>>
>>> Apparently a lot of people need to disable IPv6 completely on their
>>> distributor-built systems, and they do this by blacklisting the
>>> ipv6.ko
>>> module.  If CONFIG_IPV6_MODULE is set but the module can't be  
>>> loaded,
>>> this causes the creation of the NFSv4 callback listener to fail.
>>>
>>> As a workaround, change the callback service to use an AF_INET6
>>> listener
>>> only if IPv6 is built into the kernel.
>>>
>>> This allows IPv6 NFS testing to continue, while supporting legacy  
>>> IPv4
>>> NFS as before.  In the meantime, we will pursue a long-term fix so
>>> that
>>> the callback server will be able to handle this case correctly.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> Trond, here's what I'm thinking about for fixing the callback server
>>> piece of the "unloadable ipv6.ko" problem.  Comments?
>>>
>>> fs/nfs/callback.c |   10 ++++++----
>>> fs/nfs/client.c   |    6 +++---
>>> 2 files changed, 9 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
>>> index 3e634f2..5d99335 100644
>>> --- a/fs/nfs/callback.c
>>> +++ b/fs/nfs/callback.c
>>> @@ -43,13 +43,15 @@ static const int nfs_set_port_max = 65535;
>>>
>>> /*
>>> * If the kernel has IPv6 support available, always listen for
>>> - * both AF_INET and AF_INET6 requests.
>>> + * both AF_INET and AF_INET6 requests.  To avoid breaking lockd
>>> + * if the ipv6 module was built but has been blacklisted, enable
>>> + * this only if IPv6 support is built into the kernel.
>>> */
>>> -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>> +#if defined(CONFIG_IPV6)
>>> static const sa_family_t	nfs_callback_family = AF_INET6;
>>> -#else
>>> +#else	/* CONFIG_IPV6 */
>>> static const sa_family_t	nfs_callback_family = AF_INET;
>>> -#endif
>>> +#endif	/* CONFIG_IPV6 */
>>>
>>> static int param_set_port(const char *val, struct kernel_param *kp)
>>> {
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index 9b728f3..a230c35 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -223,7 +223,7 @@ void nfs_put_client(struct nfs_client *clp)
>>> 	}
>>> }
>>>
>>> -#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>>> +#ifdef CONFIG_IPV6
>>> static const struct in6_addr *nfs_map_ipv4_addr(const struct
>>> sockaddr *sa, struct in6_addr *addr_mapped)
>>> {
>>> 	switch (sa->sa_family) {
>>> @@ -255,7 +255,7 @@ static int nfs_sockaddr_match_ipaddr(const
>>> struct sockaddr *sa1,
>>> 	}
>>> 	return 0;
>>> }
>>> -#else
>>> +#else	/* CONFIG_IPV6 */
>>> static int nfs_sockaddr_match_ipaddr4(const struct sockaddr_in *sa1,
>>> 				 const struct sockaddr_in *sa2)
>>> {
>>> @@ -270,7 +270,7 @@ static int nfs_sockaddr_match_ipaddr(const
>>> struct sockaddr *sa1,
>>> 	return nfs_sockaddr_match_ipaddr4((const struct sockaddr_in *)sa1,
>>> 			(const struct sockaddr_in *)sa2);
>>> }
>>> -#endif
>>> +#endif	/* CONFIG_IPV6 */
>>>
>>> /*
>>> * Find a client by IP address and protocol version
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>>> in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





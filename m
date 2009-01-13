From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] SUNRPC: Clearer error message when user space is running portmap
Date: Tue, 13 Jan 2009 18:13:03 -0500
Message-ID: <6D6D6836-6B2A-4FB3-B7B1-2B54663E64D5@oracle.com>
References: <20090113172538.6755.83766.stgit@ingres.1015granger.net> <20090113173156.6755.86231.stgit@ingres.1015granger.net> <1231868640.7036.11.camel@heimdal.trondhjem.org> <FEC54836-11C4-46C6-9F89-CE3A6825E38C@oracle.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:49706 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758603AbZAMXNV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2009 18:13:21 -0500
In-Reply-To: <FEC54836-11C4-46C6-9F89-CE3A6825E38C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 13, 2009, at Jan 13, 2009, 1:26 PM, Chuck Lever wrote:
> On Jan 13, 2009, at Jan 13, 2009, 12:44 PM, Trond Myklebust wrote:
>> On Tue, 2009-01-13 at 12:31 -0500, Chuck Lever wrote:
>>> Detect the case where we sent an rpcbind v4 SET but user space  
>>> doesn't
>>> support rpcbind protocol version 4.
>>>
>>> When registering an AF_INET service, a warning is sent to the log  
>>> once,
>>> and we down-shift to version 2.  With AF_INET6, an error is always  
>>> sent
>>> to the log, and the registration fails.
>>>
>>> This should help distributors and testers determine why their NFSD
>>> service won't start, but normal users/admins should really never see
>>> this message unless something very strange has happened.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> net/sunrpc/svc.c |   44 ++++++++++++++++++++++++++++++++++++++------
>>> 1 files changed, 38 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>>> index e93bc55..daed77f 100644
>>> --- a/net/sunrpc/svc.c
>>> +++ b/net/sunrpc/svc.c
>>> @@ -736,6 +736,18 @@ static void  
>>> __svc_rpcb_prog_mismatch_error(void)
>>> 	}
>>> }
>>>
>>> +static int __svc_rpcb_cant_register(const char *progname, const  
>>> u32 version)
>>> +{
>>> +	printk(KERN_ERR
>>> +		"svc: Could not register an IPv6 listener for %s v%u "
>>> +		"with the local portmapper.\n"
>>> +		"svc: The kernel tried an rpcbind version 4 request, "
>>> +		"but your portmapper\n"
>>> +		"svc: does not support rpcbind version 4.",
>>> +		progname, version);
>>> +	return -EAFNOSUPPORT;
>>> +}
>>
>> This is ___way___ too intrusive...
>
>> We already have stuff like the NFSv4 callback channel that  
>> automatically
>> assumes that it should use an IPv6 registration as long as  
>> CONFIG_IPV6
>> or CONFIG_IPV6_MODULE are defined.
>
> I believe the callback channel service does not register itself with  
> the local portmapper.  This function wouldn't be invoked in that case.
>
>> Compiling in IPv6 without having an IPv6-capable portmapper should
>> certainly not be flagged as a kernel error.
>
> It's an error if the kernel can't register an RPC service that asked  
> to be registered, isn't it?
>
> But the point I _think_ you're making is that enabling kernel IPv6  
> support (outside of RPC) shouldn't cause problems like this.  If  
> CONFIG_SUNRPC_REGISTER_V4 is not set, then IPv6 RPC listeners for  
> lockd and NFSD aren't created at all, even if CONFIG_IPV6 is  
> enabled, and this problem is avoided.
>
> (I think proper dependencies exist to make this work right today,  
> but it's pretty confusing.  An additional CONFIG entry for  
> explicitly enabling lockd and NFSD via IPv6 would make this better  
> understood).

The problem now becomes "what to do if user space doesn't support  
registering an IPv6 kernel RPC service?"

The kernel uses a single listener for each RPC service; either IPv6 or  
IPv4.  Since the svc_serv is created first, then after that the  
transport is created and registered, we would have to tear down the  
transport and svc_serv and then try to create these again with only  
AF_INET listeners.

Alternately, we could just have svc_register() fall back and register  
just IPv4, even though it's an AF_INET6 listener.  The code is  
designed so that AF_INET6 listeners handle all the IPv4 traffic too.

One benefit is that with this mechanism, replacing portmapper with  
rpcbind suddenly allows the kernel's RPC services to handle AF_INET6  
traffic (if they support it already).

Does this sound OK?

> The other problem here is that when registering an IPv6 RPC service,  
> the kernel uses an IPv6 loopback address to test whether the user  
> space portmapper is actually IPv6 enabled.  I expect this is why the  
> new kernel running with the old user space never got "program  
> version mismatch" -- the portmapper wasn't listening on IPv6 to  
> reply to the request.

Yes, now tested; this is indeed the case.  Switching to IPv4 loopback  
fixed the hang-and-timeout, and registering an AF_INET6 service fails  
immediately now on my Fedora Core 6 system.

> This was the reason I wanted to use a connected transport for  
> registration upcalls -- then rpcb_v4_register could tell immediately  
> that user space wasn't prepared for kernel IPv6 RPC services,  
> instead of timing out after many seconds.
>
> We can switch to always use IPv4 for the registration upcall to  
> avoid this problem and retain backwards compatibility.  However,  
> this means that the kernel can't detect whether user space is really  
> IPv6 enabled.  It can only tell whether rpcbindv4 is supported.  Do  
> we think that is sufficient?  (I'll hazard a guess that the answer  
> is "yes").
>
>>> /*
>>> * Register an "inet" protocol family netid with the local
>>> * rpcbind daemon via an rpcbind v4 SET request.
>>> @@ -811,10 +823,14 @@ static int __svc_rpcb_register6(const u32  
>>> program, const u32 version,
>>> /*
>>> * Register a kernel RPC service via rpcbind version 4.
>>> *
>>> + * This logic is complicated by the case where user space is not
>>> + * running a portmapper that can handle a verison 4 request.
>>> + *
>>> * Returns zero on success; a negative errno value is returned
>>> * if any error occurs.
>>> */
>>> -static int __svc_register(const u32 program, const u32 version,
>>> +static int __svc_register(const char *progname,
>>> +			  const u32 program, const u32 version,
>>> 			  const sa_family_t family,
>>> 			  const unsigned short protocol,
>>> 			  const unsigned short port)
>>> @@ -823,11 +839,25 @@ static int __svc_register(const u32 program,  
>>> const u32 version,
>>>
>>> 	switch (family) {
>>> 	case AF_INET:
>>> -		return __svc_rpcb_register4(program, version,
>>> -						protocol, port);
>>> +		if (__svc_register_version == 4) {
>>> +			error = __svc_rpcb_register4(program, version,
>>> +							protocol, port);
>>> +			if (error != -EPROTONOSUPPORT)
>>> +				return error;
>>> +		}
>>> +
>>> +		/* Down-shift. */
>>> +		__svc_rpcb_prog_mismatch_error();
>>> +		return rpcb_register(program, version, protocol, port);
>>> 	case AF_INET6:
>>> +		/* This won't work if we don't have version 4. */
>>> +		if (__svc_register_version != 4)
>>> +			return __svc_rpcb_cant_register(progname, version);
>>> +
>>> 		error = __svc_rpcb_register6(program, version,
>>> 						protocol, port);
>>> +		if (error == -EPROTONOSUPPORT)
>>> +			return __svc_rpcb_cant_register(progname, version);
>>> 		if (error < 0)
>>> 			return error;
>>>
>>> @@ -854,7 +884,8 @@ static int __svc_register(const u32 program,  
>>> const u32 version,
>>> * Returns zero on success; a negative errno value is returned
>>> * if any error occurs.
>>> */
>>> -static int __svc_register(const u32 program, const u32 version,
>>> +static int __svc_register(const char *progname,
>>> +			  const u32 program, const u32 version,
>>> 			  sa_family_t family,
>>> 			  const unsigned short protocol,
>>> 			  const unsigned short port)
>>> @@ -901,8 +932,9 @@ int svc_register(const struct svc_serv *serv,  
>>> const unsigned short proto,
>>> 			if (progp->pg_vers[i]->vs_hidden)
>>> 				continue;
>>>
>>> -			error = __svc_register(progp->pg_prog, i,
>>> -						serv->sv_family, proto, port);
>>> +			error = __svc_register(progp->pg_name, progp->pg_prog,
>>> +						i, serv->sv_family,
>>> +						proto, port);
>>> 			if (error < 0)
>>> 				break;
>>> 		}
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com





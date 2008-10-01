From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/10] lockd: struct nlm_reboot should contain a full
	socket address
Date: Wed, 1 Oct 2008 14:18:01 -0400
Message-ID: <20081001181801.GF6001@fieldses.org>
References: <20080917161337.4963.74674.stgit@ellison.1015granger.net> <20080917161811.4963.60224.stgit@ellison.1015granger.net> <20080926230938.GK7138@fieldses.org> <E908BC09-5443-440E-9402-E2E319A3BD8E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57549 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753408AbYJASSC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Oct 2008 14:18:02 -0400
In-Reply-To: <E908BC09-5443-440E-9402-E2E319A3BD8E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 01, 2008 at 12:17:02PM -0400, Chuck Lever wrote:
> On Sep 26, 2008, at Sep 26, 2008, 7:09 PM, J. Bruce Fields wrote:
>> On Wed, Sep 17, 2008 at 11:18:11AM -0500, Chuck Lever wrote:
>>> The XDR decoders for the NSM NOTIFY procedure should construct a full
>>> socket address and store it in the nlm_reboot structure.  In addition
>>> to being able to store larger addresses, this means upper layer
>>> routines get an address family tag so they can distinguish between
>>> AF_INET and AF_INET6 addresses.
>>>
>>> This also keeps potentially large socket addresses off the stack and
>>> instead in dynamically allocated storage.
>>
>> So one way to think of this would be that you're extending the
>> kernel<->statd interface by using the address family of statd's notify
>> call to communicate the address family of the host that rebooted.
>>
>> Do I have that right?
>
> For statd, we're using the same technique that we used when constructing 
> the source address in nlmsvc_lookup_host().  There's no family tag 
> associated with the address because the 16-byte opaque in the on-the-wire 
> format has room only for the sin6_addr part of the address.

OK.  It seems a bit tricky, but I can't see why it doesn't work.

--b.

> The notification downcall for IPv6 peers has to come via IPv6 loopback
> for this to work.
>
>>
>>
>> --b.
>>
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/lockd/svc4proc.c       |   10 +---------
>>> fs/lockd/svcproc.c        |   10 +---------
>>> fs/lockd/xdr.c            |   28 ++++++++++++++++++++++++++--
>>> fs/lockd/xdr4.c           |   27 +++++++++++++++++++++++++--
>>> include/linux/lockd/xdr.h |    3 ++-
>>> 5 files changed, 55 insertions(+), 23 deletions(-)
>>>
>>> diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
>>> index 6a5ef9f..e61c05f 100644
>>> --- a/fs/lockd/svc4proc.c
>>> +++ b/fs/lockd/svc4proc.c
>>> @@ -430,8 +430,6 @@ static __be32
>>> nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot  
>>> *argp,
>>> 					      void	        *resp)
>>> {
>>> -	struct sockaddr_in	saddr;
>>> -
>>> 	dprintk("lockd: SM_NOTIFY     called\n");
>>>
>>> 	if (!nlm_privileged_requester(rqstp)) {
>>> @@ -441,13 +439,7 @@ nlm4svc_proc_sm_notify(struct svc_rqst *rqstp,  
>>> struct nlm_reboot *argp,
>>> 		return rpc_system_err;
>>> 	}
>>>
>>> -	/* Obtain the host pointer for this NFS server and try to
>>> -	 * reclaim all locks we hold on this server.
>>> -	 */
>>> -	memset(&saddr, 0, sizeof(saddr));
>>> -	saddr.sin_family = AF_INET;
>>> -	saddr.sin_addr.s_addr = argp->addr;
>>> -	nlm_host_rebooted((struct sockaddr *)&saddr, sizeof(saddr),
>>> +	nlm_host_rebooted((struct sockaddr *)&argp->addr, argp->addrlen,
>>> 			  argp->mon, argp->len, argp->state);
>>>
>>> 	return rpc_success;
>>> diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
>>> index 62fcfdb..86a487a 100644
>>> --- a/fs/lockd/svcproc.c
>>> +++ b/fs/lockd/svcproc.c
>>> @@ -462,8 +462,6 @@ static __be32
>>> nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot  
>>> *argp,
>>> 					      void	        *resp)
>>> {
>>> -	struct sockaddr_in	saddr;
>>> -
>>> 	dprintk("lockd: SM_NOTIFY     called\n");
>>>
>>> 	if (!nlm_privileged_requester(rqstp)) {
>>> @@ -473,13 +471,7 @@ nlmsvc_proc_sm_notify(struct svc_rqst *rqstp,  
>>> struct nlm_reboot *argp,
>>> 		return rpc_system_err;
>>> 	}
>>>
>>> -	/* Obtain the host pointer for this NFS server and try to
>>> -	 * reclaim all locks we hold on this server.
>>> -	 */
>>> -	memset(&saddr, 0, sizeof(saddr));
>>> -	saddr.sin_family = AF_INET;
>>> -	saddr.sin_addr.s_addr = argp->addr;
>>> -	nlm_host_rebooted((struct sockaddr *)&saddr, sizeof(saddr),
>>> +	nlm_host_rebooted((struct sockaddr *)&argp->addr, argp->addrlen,
>>> 			  argp->mon, argp->len, argp->state);
>>>
>>> 	return rpc_success;
>>> diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
>>> index 1f22629..92c5695 100644
>>> --- a/fs/lockd/xdr.c
>>> +++ b/fs/lockd/xdr.c
>>> @@ -9,6 +9,7 @@
>>> #include <linux/types.h>
>>> #include <linux/sched.h>
>>> #include <linux/utsname.h>
>>> +#include <linux/in.h>
>>> #include <linux/nfs.h>
>>>
>>> #include <linux/sunrpc/xdr.h>
>>> @@ -346,11 +347,34 @@ nlmsvc_decode_notify(struct svc_rqst *rqstp,  
>>> __be32 *p, struct nlm_args *argp)
>>> int
>>> nlmsvc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct  
>>> nlm_reboot *argp)
>>> {
>>> +	struct sockaddr_in *sin = (struct sockaddr_in *)&argp->addr;
>>> +	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&argp->addr;
>>> +
>>> 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len,  
>>> SM_MAXSTRLEN)))
>>> 		return 0;
>>> 	argp->state = ntohl(*p++);
>>> -	/* Preserve the address in network byte order */
>>> -	argp->addr = *p++;
>>> +
>>> +	/* Decode the 16-byte private field */
>>> +	memset(&argp->addr, 0, sizeof(argp->addr));
>>> +	switch (svc_addr(rqstp)->sa_family) {
>>> +	case AF_INET:
>>> +		/* data in recv buffer is already in network byte order */
>>> +		sin->sin_family = AF_INET;
>>> +		sin->sin_addr.s_addr = *p++;
>>> +		argp->addrlen = sizeof(*sin);
>>> +		break;
>>> +	case AF_INET6:
>>> +		sin6->sin6_family = AF_INET6;
>>> +		sin6->sin6_addr.s6_addr32[0] = *p++;
>>> +		sin6->sin6_addr.s6_addr32[1] = *p++;
>>> +		sin6->sin6_addr.s6_addr32[2] = *p++;
>>> +		sin6->sin6_addr.s6_addr32[3] = *p++;
>>> +		argp->addrlen = sizeof(*sin6);
>>> +		break;
>>> +	default:
>>> +		return -EIO;
>>> +	}
>>> +
>>> 	return xdr_argsize_check(rqstp, p);
>>> }
>>>
>>> diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
>>> index 50c493a..2009020 100644
>>> --- a/fs/lockd/xdr4.c
>>> +++ b/fs/lockd/xdr4.c
>>> @@ -353,11 +353,34 @@ nlm4svc_decode_notify(struct svc_rqst *rqstp,  
>>> __be32 *p, struct nlm_args *argp)
>>> int
>>> nlm4svc_decode_reboot(struct svc_rqst *rqstp, __be32 *p, struct  
>>> nlm_reboot *argp)
>>> {
>>> +	struct sockaddr_in *sin = (struct sockaddr_in *)&argp->addr;
>>> +	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&argp->addr;
>>> +
>>> 	if (!(p = xdr_decode_string_inplace(p, &argp->mon, &argp->len,  
>>> SM_MAXSTRLEN)))
>>> 		return 0;
>>> 	argp->state = ntohl(*p++);
>>> -	/* Preserve the address in network byte order */
>>> -	argp->addr  = *p++;
>>> +
>>> +	/* Decode the 16-byte private field */
>>> +	memset(&argp->addr, 0, sizeof(argp->addr));
>>> +	switch (svc_addr(rqstp)->sa_family) {
>>> +	case AF_INET:
>>> +		/* address in recv buffer is already in network byte order */
>>> +		sin->sin_family = AF_INET;
>>> +		sin->sin_addr.s_addr = *p++;
>>> +		argp->addrlen = sizeof(*sin);
>>> +		break;
>>> +	case AF_INET6:
>>> +		sin6->sin6_family = AF_INET6;
>>> +		sin6->sin6_addr.s6_addr32[0] = *p++;
>>> +		sin6->sin6_addr.s6_addr32[1] = *p++;
>>> +		sin6->sin6_addr.s6_addr32[2] = *p++;
>>> +		sin6->sin6_addr.s6_addr32[3] = *p++;
>>> +		argp->addrlen = sizeof(*sin6);
>>> +		break;
>>> +	default:
>>> +		return -EIO;
>>> +	}
>>> +
>>> 	return xdr_argsize_check(rqstp, p);
>>> }
>>>
>>> diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
>>> index d6b3a80..6057b7e 100644
>>> --- a/include/linux/lockd/xdr.h
>>> +++ b/include/linux/lockd/xdr.h
>>> @@ -80,7 +80,8 @@ struct nlm_reboot {
>>> 	char *		mon;
>>> 	unsigned int	len;
>>> 	u32		state;
>>> -	__be32		addr;
>>> +	struct sockaddr_storage	addr;
>>> +	size_t		addrlen;
>>> };
>>>
>>> /*
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
>

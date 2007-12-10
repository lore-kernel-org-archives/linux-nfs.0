From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 01/27] SUNRPC: rpc_create() default hostname should support
 AF_INET6 addresses
Date: Mon, 10 Dec 2007 15:55:31 -0500
Message-ID: <475DA7C3.1050703@redhat.com>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net> <20071210195623.2823.13011.stgit@manray.1015granger.net> <475DA054.7010002@redhat.com> <E7A6950F-9651-42A0-A89D-F561C434CD42@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: trond.myklebust@fys.uio.no, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753548AbXLJU5P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 15:57:15 -0500
In-Reply-To: <E7A6950F-9651-42A0-A89D-F561C434CD42@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Dec 10, 2007, at 3:23 PM, Peter Staubach wrote:
>> Chuck Lever wrote:
>>> If the ULP doesn't pass a hostname string to rpc_create(), it 
>>> manufactures
>>> one based on the passed-in address.  Be smart enough to handle an 
>>> AF_INET6
>>> address properly in this case.
>>>
>>> Move the default servername logic before the xprt_create_transport() 
>>> call
>>> to simplify error handling in rpc_create().
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>>  net/sunrpc/clnt.c |   32 +++++++++++++++++++++++++++-----
>>>  1 files changed, 27 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>> index 76be83e..c297161 100644
>>> --- a/net/sunrpc/clnt.c
>>> +++ b/net/sunrpc/clnt.c
>>> @@ -30,6 +30,7 @@
>>>  #include <linux/smp_lock.h>
>>>  #include <linux/utsname.h>
>>>  #include <linux/workqueue.h>
>>> +#include <linux/in6.h>
>>>   #include <linux/sunrpc/clnt.h>
>>>  #include <linux/sunrpc/rpc_pipe_fs.h>
>>> @@ -247,7 +248,7 @@ struct rpc_clnt *rpc_create(struct 
>>> rpc_create_args *args)
>>>          .addrlen = args->addrsize,
>>>          .timeout = args->timeout
>>>      };
>>> -    char servername[20];
>>> +    char servername[48];
>>>
>>>
>>
>> Just out of curiosity, how or why was 48 chosen?
>
> It's a multiple of 16 bytes for cache alignment, and it is just a bit 
> larger than the largest size of a meaningful IPv6 address string 
> (which is 46 bytes, I believe).
>
> If there's an appropriate pre-defined buffer size, I would gladly 
> replace the naked integer with that.  It would be nice if there was 
> one defined along with the NIPQUAD/NIP6 macros.
>

Yes, it would be nice if there was a symbolic constant which would
make this a little more understandable.

It appears to me, from the definitions of NIP6 and NIP6_FMT,
that the maximum that the string will ever hold will be 40 bytes,
8 shorts printed as 4 byte hex values plus 7 intermediate ':'
characters plus the '\0' string terminator, so 48 should be
enough, currently.  I think that we might run into a problem
if NIP6 or NIP6_FMT were ever changed to allow more bytes.

Having the symbolic constant defined near to NIP6 and NIP6_FMT
would eliminate this invisible dependency.

    Thanx...

       ps

>>>      xprt = xprt_create_transport(&xprtargs);
>>>      if (IS_ERR(xprt))
>>> @@ -258,13 +259,34 @@ struct rpc_clnt *rpc_create(struct 
>>> rpc_create_args *args)
>>>       * up a string representation of the passed-in address.
>>>       */
>>>      if (args->servername == NULL) {
>>> -        struct sockaddr_in *addr =
>>> -                    (struct sockaddr_in *) args->address;
>>> -        snprintf(servername, sizeof(servername), NIPQUAD_FMT,
>>> -            NIPQUAD(addr->sin_addr.s_addr));
>>> +        servername[0] = '\0';
>>> +        switch (args->address->sa_family) {
>>> +        case AF_INET: {
>>> +            struct sockaddr_in *sin =
>>> +                    (struct sockaddr_in *)args->address;
>>> +            snprintf(servername, sizeof(servername), NIPQUAD_FMT,
>>> +                 NIPQUAD(sin->sin_addr.s_addr));
>>> +            break;
>>> +        }
>>> +        case AF_INET6: {
>>> +            struct sockaddr_in6 *sin =
>>> +                    (struct sockaddr_in6 *)args->address;
>>> +            snprintf(servername, sizeof(servername), NIP6_FMT,
>>> +                 NIP6(sin->sin6_addr));
>>> +            break;
>>> +        }
>>> +        default:
>>> +            /* caller wants default server name, but
>>> +             * address family isn't recognized. */
>>> +            return ERR_PTR(-EINVAL);
>>> +        }
>>>          args->servername = servername;
>>>      }
>>>  +    xprt = xprt_create_transport(&xprtargs);
>>> +    if (IS_ERR(xprt))
>>> +        return (struct rpc_clnt *)xprt;
>>> +
>>>      /*
>>>       * By default, kernel RPC client connects from a reserved port.
>>>       * CAP_NET_BIND_SERVICE will not be set for unprivileged 
>>> requesters,
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>


From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/7] lockd: Use AF_INET6 listener only when IPv6 support is built in
Date: Fri, 30 Jan 2009 15:46:51 -0500
Message-ID: <130964B3-CDE1-440F-B0E0-33620036E239@oracle.com>
References: <20090130200021.22301.22618.stgit@ingres.1015granger.net> <20090130201041.22301.60941.stgit@ingres.1015granger.net> <1233347546.9741.31.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51590 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754651AbZA3UrJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Jan 2009 15:47:09 -0500
In-Reply-To: <1233347546.9741.31.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 30, 2009, at Jan 30, 2009, 3:32 PM, Trond Myklebust wrote:
> On Fri, 2009-01-30 at 15:10 -0500, Chuck Lever wrote:
>> Apparently a lot of people need to completely disable IPv6 on their
>> distribution-built systems, and they do this by blacklisting the
>> ipv6 module.  This causes lockd_up(), and thus NFS mounts, to fail
>> in all cases (even for IPv4 mounts) if CONFIG_IPV6_MODULE and
>> CONFIG_SUNRPC_REGISTER_V4 is set.
>>
>> As a workaround, change lockd to use an AF_INET6 listener only if  
>> IPv6
>> is built into the kernel.
>>
>> This allows IPv6 NFS testing to continue, while supporting legacy  
>> IPv4
>> NFS as before.  In the meantime, we will pursue a long-term fix so  
>> that
>> lockd (and eventually NFSD) will be able to handle this case  
>> correctly.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Tested-by: Steve Dickson <steved@redhat.com>
>> ---
>>
>> fs/lockd/svc.c |   11 ++++++-----
>> 1 files changed, 6 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>> index 64f1c31..39ec7f2 100644
>> --- a/fs/lockd/svc.c
>> +++ b/fs/lockd/svc.c
>> @@ -54,14 +54,15 @@ unsigned long			nlmsvc_timeout;
>>
>> /*
>>  * If the kernel has IPv6 support available, always listen for
>> - * both AF_INET and AF_INET6 requests.
>> + * both AF_INET and AF_INET6 requests.  To avoid breaking lockd
>> + * if the ipv6 module was built but has been blacklisted, enable
>> + * this only if IPv6 support is built into the kernel.
>>  */
>> -#if (defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)) && \
>> -	defined(CONFIG_SUNRPC_REGISTER_V4)
>> +#if defined(CONFIG_IPV6) && defined(CONFIG_SUNRPC_REGISTER_V4)
>> static const sa_family_t	nlmsvc_family = AF_INET6;
>> -#else	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) &&  
>> CONFIG_SUNRPC_REGISTER_V4 */
>> +#else	/* CONFIG_IPV6 && CONFIG_SUNRPC_REGISTER_V4 */
>> static const sa_family_t	nlmsvc_family = AF_INET;
>> -#endif	/* (CONFIG_IPV6 || CONFIG_IPV6_MODULE) &&  
>> CONFIG_SUNRPC_REGISTER_V4 */
>> +#endif	/* CONFIG_IPV6 && CONFIG_SUNRPC_REGISTER_V4 */
>>
>> /*
>>  * These can be set at insmod time (useful for NFS as root  
>> filesystem),
>
> That issue will affect the NFSv4 callback server too.

I'll submit a separate patch for that.

> How about using something like a 'symbol_request(ipv6_getsockopt)' to
> probe whether or not IPv6 is available.

That's a good idea.  I was about to go looking for the right way to  
check if the module is available.

I've been discussing this with Steve.  He'd like some way for lockd to  
recover if only an IPv4 mount is requested, but the logic to do this  
(and to report real errors on IPv6 mounts, and to handle the NFSD  
cases) might get complicated.  Plus, once we start lockd with an  
AF_INET listener, we are stuck with IPv4-only until lockd is restarted  
from scratch.

I think we want any issues in this area to be handled at mount/export  
time, and not specifically by lockd or the callback server.  What do  
you think?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com

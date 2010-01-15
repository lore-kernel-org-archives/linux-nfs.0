From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/3] SUNRPC: Use rpc_pton() in ip_map_parse()
Date: Fri, 15 Jan 2010 17:55:09 -0500
Message-ID: <5578B738-CE6E-4800-B636-2AC27D6BAAE5@oracle.com>
References: <20100113210650.19409.38009.stgit@localhost.localdomain> <20100113211031.19409.92550.stgit@localhost.localdomain> <20100115222508.GE30624@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:25173 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758552Ab0AOWzw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jan 2010 17:55:52 -0500
In-Reply-To: <20100115222508.GE30624@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 15, 2010, at 5:25 PM, J. Bruce Fields wrote:
> On Wed, Jan 13, 2010 at 04:10:31PM -0500, Chuck Lever wrote:
>> The existing logic in ip_map_parse() can not currently parse
>> shorthanded IPv6 addresses (anything with a double colon), nor can
>> it parse an IPv6 presentation address with a scope ID.  An
>> IPv6-enabled mountd can pass down both.
>
> Why does mountd need to be able to do that?

AFAICT, the glibc APIs (like inet_ntop(3) and getnameinfo(3)) provide  
no way to disable shorthanding.

Since we have kernel support for it now, it makes sense to me to allow  
the kernel to accept a broader range of valid presentation address  
formats.

>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> net/sunrpc/svcauth_unix.c |   47 ++++++++++++++++++++++++ 
>> +--------------------
>> 1 files changed, 26 insertions(+), 21 deletions(-)
>>
>> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
>> index d8c0411..97f0e9e 100644
>> --- a/net/sunrpc/svcauth_unix.c
>> +++ b/net/sunrpc/svcauth_unix.c
>> @@ -15,6 +15,7 @@
>> #include <linux/kernel.h>
>> #define RPCDBG_FACILITY	RPCDBG_AUTH
>>
>> +#include <linux/sunrpc/clnt.h>
>>
>> /*
>>  * AUTHUNIX and AUTHNULL credentials are both handled here.
>> @@ -187,10 +188,13 @@ static int ip_map_parse(struct cache_detail  
>> *cd,
>> 	 * for scratch: */
>> 	char *buf = mesg;
>> 	int len;
>> -	int b1, b2, b3, b4, b5, b6, b7, b8;
>> -	char c;
>> 	char class[8];
>> -	struct in6_addr addr;
>> +	union {
>> +		struct sockaddr		sa;
>> +		struct sockaddr_in	s4;
>> +		struct sockaddr_in6	s6;
>> +	} address;
>> +	struct sockaddr_in6 sin6;
>> 	int err;
>>
>> 	struct ip_map *ipmp;
>> @@ -209,24 +213,24 @@ static int ip_map_parse(struct cache_detail  
>> *cd,
>> 	len = qword_get(&mesg, buf, mlen);
>> 	if (len <= 0) return -EINVAL;
>>
>> -	if (sscanf(buf, "%u.%u.%u.%u%c", &b1, &b2, &b3, &b4, &c) == 4) {
>> -		addr.s6_addr32[0] = 0;
>> -		addr.s6_addr32[1] = 0;
>> -		addr.s6_addr32[2] = htonl(0xffff);
>> -		addr.s6_addr32[3] =
>> -			htonl((((((b1<<8)|b2)<<8)|b3)<<8)|b4);
>> -       } else if (sscanf(buf, "%04x:%04x:%04x:%04x:%04x:%04x:%04x: 
>> %04x%c",
>> -			&b1, &b2, &b3, &b4, &b5, &b6, &b7, &b8, &c) == 8) {
>> -		addr.s6_addr16[0] = htons(b1);
>> -		addr.s6_addr16[1] = htons(b2);
>> -		addr.s6_addr16[2] = htons(b3);
>> -		addr.s6_addr16[3] = htons(b4);
>> -		addr.s6_addr16[4] = htons(b5);
>> -		addr.s6_addr16[5] = htons(b6);
>> -		addr.s6_addr16[6] = htons(b7);
>> -		addr.s6_addr16[7] = htons(b8);
>> -       } else
>> +	if (rpc_pton(buf, len, &address.sa, sizeof(address)) == 0)
>> 		return -EINVAL;
>> +	switch (address.sa.sa_family) {
>> +	case AF_INET:
>> +		/* Form a mapped IPv4 address in sin6 */
>> +		memset(&sin6, 0, sizeof(sin6));
>> +		sin6.sin6_family = AF_INET6;
>> +		sin6.sin6_addr.s6_addr32[2] = htonl(0xffff);
>> +		sin6.sin6_addr.s6_addr32[3] = address.s4.sin_addr.s_addr;
>> +		break;
>> +#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
>> +	case AF_INET6:
>> +		memcpy(&sin6, &address.s6, sizeof(sin6));
>> +		break;
>> +#endif
>> +	default:
>> +		return -EINVAL;
>> +	}
>>
>> 	expiry = get_expiry(&mesg);
>> 	if (expiry ==0)
>> @@ -243,7 +247,8 @@ static int ip_map_parse(struct cache_detail *cd,
>> 	} else
>> 		dom = NULL;
>>
>> -	ipmp = ip_map_lookup(class, &addr);
>> +	/* IPv6 scope IDs are ignored for now */
>> +	ipmp = ip_map_lookup(class, &sin6.sin6_addr);
>> 	if (ipmp) {
>> 		err = ip_map_update(ipmp,
>> 			     container_of(dom, struct unix_domain, h),
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



